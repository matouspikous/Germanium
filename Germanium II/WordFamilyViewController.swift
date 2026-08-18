//
//  WordFamilyViewController.swift
//  Germanium
//

import UIKit

class WordFamilyViewController: UIViewController {
    private var families: [WordFamily] = []
    private var currentFamilyIndex = 0
    private var currentPairs: [(german: String, english: String)] = []
    private var shuffledGerman: [String] = []
    private var shuffledEnglish: [String] = []
    private var matches: [String: String] = [:]
    private var selectedGerman: String?
    
    private let stemLabel = UILabel()
    private let germanStackView = UIStackView()
    private let englishStackView = UIStackView()
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Word Families"
        families = DataProvider.loadWordFamilies()
        setupUI()
        showFamily()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        stemLabel.font = UIFont.boldSystemFont(ofSize: 24)
        stemLabel.textAlignment = .center
        stemLabel.numberOfLines = 0
        
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
        
        nextButton.setTitle("Next Family", for: .normal)
        nextButton.addTarget(self, action: #selector(nextFamily), for: .touchUpInside)
        nextButton.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [stemLabel, columnsStack, feedbackLabel, nextButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            columnsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        stemLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
    }
    
    private func showFamily() {
        guard families.count > 0 else { return }
        let family = families[currentFamilyIndex]
        
        stemLabel.text = "Stem: \(family.stem)"
        
        // Select maximum 10 pairs randomly
        let maxPairs = min(10, family.pairs.count)
        currentPairs = Array(family.pairs.shuffled().prefix(maxPairs))
        
        shuffledGerman = currentPairs.map { $0.german }.shuffled()
        shuffledEnglish = currentPairs.map { $0.english }.shuffled()
        matches.removeAll()
        selectedGerman = nil
        feedbackLabel.text = ""
        nextButton.isHidden = true
        
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
            button.addTarget(self, action: #selector(germanTapped(_:)), for: .touchUpInside)
            germanStackView.addArrangedSubview(button)
        }
        
        for english in shuffledEnglish {
            let button = UIButton(type: .system)
            button.setTitle(english, for: .normal)
            button.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            button.setTitleColor(ThemeManager.shared.textColor, for: .normal)
            button.layer.cornerRadius = 8
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
        
        let correctPair = currentPairs.first { $0.german == german && $0.english == english }
        
        if correctPair != nil {
            matches[german] = english
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
            
            if matches.count == currentPairs.count {
                feedbackLabel.text = "✅ All matched correctly!"
                nextButton.isHidden = false
            }
        } else {
            feedbackLabel.text = "❌ Try again"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.feedbackLabel.text = ""
            }
        }
    }
    
    @objc private func nextFamily() {
        // Select random family instead of going in order
        currentFamilyIndex = Int.random(in: 0..<families.count)
        showFamily()
    }
}
