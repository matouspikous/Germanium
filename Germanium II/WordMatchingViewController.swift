//
//  WordMatchingViewController.swift
//  Germanium
//

import UIKit

class WordMatchingViewController: UIViewController {
    private var allPairs: [WordPair] = []
    private var currentBatch: [WordPair] = []
    private var shuffledGerman: [String] = []
    private var shuffledEnglish: [String] = []
    private var matches: [String: String] = [:]
    private var selectedGerman: String?
    private let filename: String
    
    private let germanStackView = UIStackView()
    private let englishStackView = UIStackView()
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let scoreLabel = UILabel()
    private var correctCount = 0
    
    // iOS 12 compatible colors
    private var systemGreen: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGreen
        } else {
            return UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
        }
    }
    
    private var systemBlue: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBlue
        } else {
            return UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        }
    }
    
    init(filename: String) {
        self.filename = filename
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Match Words"
        allPairs = DataProvider.loadWordPairs(from: filename)
        setupUI()
        loadNextBatch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 16)
        
        germanStackView.axis = .vertical
        germanStackView.spacing = 8
        germanStackView.distribution = .fillEqually
        
        englishStackView.axis = .vertical
        englishStackView.spacing = 8
        englishStackView.distribution = .fillEqually
        
        let columnsStack = UIStackView(arrangedSubviews: [germanStackView, englishStackView])
        columnsStack.axis = .horizontal
        columnsStack.spacing = 20
        columnsStack.distribution = .fillEqually
        
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        feedbackLabel.numberOfLines = 0
        
        nextButton.setTitle("Next Set", for: .normal)
        nextButton.addTarget(self, action: #selector(nextSet), for: .touchUpInside)
        nextButton.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [scoreLabel, columnsStack, feedbackLabel, nextButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            columnsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        scoreLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
    }
    
    private func loadNextBatch() {
        guard allPairs.count > 0 else { return }
        
        let batchSize = min(10, allPairs.count)
        currentBatch = Array(allPairs.shuffled().prefix(batchSize))
        shuffledGerman = currentBatch.map { $0.german }.shuffled()
        shuffledEnglish = currentBatch.map { $0.english }.shuffled()
        matches.removeAll()
        selectedGerman = nil
        feedbackLabel.text = ""
        nextButton.isHidden = true
        
        scoreLabel.text = "Score: \(correctCount)"
        populateButtons()
    }
    
    private func populateButtons() {
        germanStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        englishStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for german in shuffledGerman {
            let button = UIButton(type: .system)
            button.setTitle(german, for: .normal)
            button.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            button.setTitleColor(ThemeManager.shared.textColor, for: .normal)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(germanTapped(_:)), for: .touchUpInside)
            germanStackView.addArrangedSubview(button)
        }
        
        for english in shuffledEnglish {
            let button = UIButton(type: .system)
            button.setTitle(english, for: .normal)
            button.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            button.setTitleColor(ThemeManager.shared.textColor, for: .normal)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(englishTapped(_:)), for: .touchUpInside)
            englishStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func germanTapped(_ sender: UIButton) {
        guard let german = sender.titleLabel?.text else { return }
        
        // Don't allow selecting already matched items
        if matches.keys.contains(german) { return }
        
        selectedGerman = german
        
        for view in germanStackView.arrangedSubviews {
            if let btn = view as? UIButton {
                // Keep matched items green, highlight selected item blue, rest secondary
                if matches.keys.contains(btn.titleLabel?.text ?? "") {
                    btn.backgroundColor = systemGreen
                } else if btn == sender {
                    btn.backgroundColor = systemBlue
                } else {
                    btn.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
                }
            }
        }
    }
    
    @objc private func englishTapped(_ sender: UIButton) {
        guard let german = selectedGerman, let english = sender.titleLabel?.text else { return }
        
        let correctPair = currentBatch.first { $0.german == german && $0.english == english }
        
        if correctPair != nil {
            matches[german] = english
            correctCount += 1
            scoreLabel.text = "Score: \(correctCount)"
            
            sender.isEnabled = false
            sender.backgroundColor = systemGreen
            
            for view in germanStackView.arrangedSubviews {
                if let btn = view as? UIButton, btn.titleLabel?.text == german {
                    btn.isEnabled = false
                    btn.backgroundColor = systemGreen
                }
            }
            
            selectedGerman = nil
            
            // Reset all non-matched buttons to secondary color
            for view in germanStackView.arrangedSubviews {
                if let btn = view as? UIButton, !matches.keys.contains(btn.titleLabel?.text ?? "") {
                    btn.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
                }
            }
            
            if matches.count == currentBatch.count {
                feedbackLabel.text = "✅ All matched! Great job!"
                nextButton.isHidden = false
            }
        } else {
            feedbackLabel.text = "❌ Wrong match, try again"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.feedbackLabel.text = ""
            }
        }
    }
    
    @objc private func nextSet() {
        loadNextBatch()
    }
}
