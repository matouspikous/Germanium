//
//  SynonymAntonymViewController.swift
//  Germanium
//
//  Feature 17: Synonym/Antonym matching to expand vocabulary
//

import UIKit

class SynonymAntonymViewController: UIViewController {
    
    private var allPairs: [SynonymAntonymPair] = []
    private var currentBatch: [SynonymAntonymPair] = []
    private var shuffledWords: [String] = []
    private var shuffledRelated: [String] = []
    private var matches: [String: String] = [:]
    private var selectedWord: String?
    private var currentMode: String = "both" // "synonym", "antonym", or "both"
    
    private let modeSegment = UISegmentedControl(items: ["Synonyms", "Antonyms", "Both"])
    private let instructionLabel = UILabel()
    private let wordsStackView = UIStackView()
    private let relatedStackView = UIStackView()
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let scoreLabel = UILabel()
    private var correctCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Synonyms & Antonyms"
        
        allPairs = DataProvider.loadSynonymsAntonyms()
        
        setupUI()
        loadNextBatch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        modeSegment.selectedSegmentIndex = 2 // "Both" by default
        modeSegment.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        
        instructionLabel.text = "Match words with their synonyms/antonyms:"
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        wordsStackView.axis = .vertical
        wordsStackView.spacing = 8
        wordsStackView.distribution = .fillEqually
        
        relatedStackView.axis = .vertical
        relatedStackView.spacing = 8
        relatedStackView.distribution = .fillEqually
        
        let columnsStack = UIStackView(arrangedSubviews: [wordsStackView, relatedStackView])
        columnsStack.axis = .horizontal
        columnsStack.spacing = 20
        columnsStack.distribution = .fillEqually
        
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        feedbackLabel.numberOfLines = 0
        
        nextButton.setTitle("Next Set", for: .normal)
        nextButton.addTarget(self, action: #selector(nextSet), for: .touchUpInside)
        nextButton.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [
            modeSegment,
            instructionLabel,
            scoreLabel,
            columnsStack,
            feedbackLabel,
            nextButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            columnsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        instructionLabel.textColor = ThemeManager.shared.textColor
        scoreLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
    }
    
    @objc private func modeChanged() {
        switch modeSegment.selectedSegmentIndex {
        case 0: currentMode = "synonym"
        case 1: currentMode = "antonym"
        default: currentMode = "both"
        }
        correctCount = 0
        loadNextBatch()
    }
    
    private func loadNextBatch() {
        guard !allPairs.isEmpty else {
            instructionLabel.text = "No synonym/antonym pairs available.\nPlease add synonyms_antonyms.txt file."
            return
        }
        
        // Filter by mode
        var filteredPairs = allPairs
        if currentMode == "synonym" {
            filteredPairs = allPairs.filter { $0.type.lowercased() == "synonym" }
        } else if currentMode == "antonym" {
            filteredPairs = allPairs.filter { $0.type.lowercased() == "antonym" }
        }
        
        guard !filteredPairs.isEmpty else {
            instructionLabel.text = "No pairs available for this mode."
            return
        }
        
        let batchSize = min(8, filteredPairs.count)
        currentBatch = Array(filteredPairs.shuffled().prefix(batchSize))
        
        shuffledWords = currentBatch.map { $0.word }.shuffled()
        shuffledRelated = currentBatch.map { $0.relatedWord }.shuffled()
        matches.removeAll()
        selectedWord = nil
        feedbackLabel.text = ""
        nextButton.isHidden = true
        
        scoreLabel.text = "Score: \(correctCount)"
        populateButtons()
    }
    
    private func populateButtons() {
        wordsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        relatedStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for word in shuffledWords {
            let pair = currentBatch.first { $0.word == word }
            let typeIndicator = pair?.type.lowercased() == "synonym" ? "≈" : "≠"
            
            let button = UIButton(type: .system)
            button.setTitle("\(word) \(typeIndicator)", for: .normal)
            button.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            button.setTitleColor(ThemeManager.shared.textColor, for: .normal)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(wordTapped(_:)), for: .touchUpInside)
            button.accessibilityHint = word // Store actual word
            wordsStackView.addArrangedSubview(button)
        }
        
        for related in shuffledRelated {
            let button = UIButton(type: .system)
            button.setTitle(related, for: .normal)
            button.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            button.setTitleColor(ThemeManager.shared.textColor, for: .normal)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(relatedTapped(_:)), for: .touchUpInside)
            relatedStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func wordTapped(_ sender: UIButton) {
        // Extract actual word from accessibility hint (without the ≈/≠ indicator)
        guard let word = sender.accessibilityHint else { return }
        
        // Don't allow selecting already matched items
        if matches.keys.contains(word) { return }
        
        selectedWord = word
        
        for view in wordsStackView.arrangedSubviews {
            if let btn = view as? UIButton {
                let btnWord = btn.accessibilityHint ?? ""
                if matches.keys.contains(btnWord) {
                    btn.backgroundColor = systemGreen
                } else if btnWord == word {
                    btn.backgroundColor = systemBlue
                } else {
                    btn.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
                }
            }
        }
    }
    
    @objc private func relatedTapped(_ sender: UIButton) {
        guard let word = selectedWord, let related = sender.titleLabel?.text else { return }
        
        // Check if already matched
        if matches.values.contains(related) { return }
        
        let correctPair = currentBatch.first { $0.word == word && $0.relatedWord == related }
        
        if correctPair != nil {
            matches[word] = related
            correctCount += 1
            scoreLabel.text = "Score: \(correctCount)"
            
            sender.isEnabled = false
            sender.backgroundColor = systemGreen
            
            for view in wordsStackView.arrangedSubviews {
                if let btn = view as? UIButton, btn.accessibilityHint == word {
                    btn.isEnabled = false
                    btn.backgroundColor = systemGreen
                }
            }
            
            selectedWord = nil
            
            // Reset non-matched buttons
            for view in wordsStackView.arrangedSubviews {
                if let btn = view as? UIButton {
                    let btnWord = btn.accessibilityHint ?? ""
                    if !matches.keys.contains(btnWord) {
                        btn.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
                    }
                }
            }
            
            // Show English translations in feedback
            feedbackLabel.text = "✅ \(correctPair!.englishWord) \(correctPair!.type == "synonym" ? "≈" : "≠") \(correctPair!.englishRelated)"
            feedbackLabel.textColor = systemGreen
            
            if matches.count == currentBatch.count {
                feedbackLabel.text = "✅ All matched! Great job!"
                nextButton.isHidden = false
            }
        } else {
            feedbackLabel.text = "❌ Try again"
            feedbackLabel.textColor = systemRed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.feedbackLabel.text = ""
            }
        }
    }
    
    @objc private func nextSet() {
        loadNextBatch()
    }
    
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
    
    private var systemRed: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemRed
        } else {
            return UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        }
    }
}
