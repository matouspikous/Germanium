//
//  ArticlePracticeViewController.swift
//  Germanium
//
//  Feature 6: Gender/Article Practice (der/die/das)
//

import UIKit

class ArticlePracticeViewController: UIViewController {
    
    private var nouns: [GenderedNoun] = []
    private var currentIndex = 0
    private var correctCount = 0
    private var totalCount = 0
    
    private let instructionLabel = UILabel()
    private let nounLabel = UILabel()
    private let englishLabel = UILabel()
    private let buttonStack = UIStackView()
    private let derButton = UIButton(type: .system)
    private let dieButton = UIButton(type: .system)
    private let dasButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let scoreLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Article Practice"
        
        nouns = DataProvider.loadNounsWithGender()
        
        setupUI()
        loadNextNoun()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        instructionLabel.text = "Select the correct article for the noun:"
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        nounLabel.font = UIFont.boldSystemFont(ofSize: 28)
        nounLabel.textAlignment = .center
        
        englishLabel.font = UIFont.italicSystemFont(ofSize: 16)
        englishLabel.textAlignment = .center
        
        // Setup article buttons
        for (button, title) in [(derButton, "der"), (dieButton, "die"), (dasButton, "das")] {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 2
            button.addTarget(self, action: #selector(articleSelected(_:)), for: .touchUpInside)
        }
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(derButton)
        buttonStack.addArrangedSubview(dieButton)
        buttonStack.addArrangedSubview(dasButton)
        
        speakButton.setTitle("🔊 Listen", for: .normal)
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        speakButton.addTarget(self, action: #selector(speakNoun), for: .touchUpInside)
        
        feedbackLabel.font = UIFont.systemFont(ofSize: 18)
        feedbackLabel.textAlignment = .center
        feedbackLabel.numberOfLines = 0
        
        nextButton.setTitle("Next ➡️", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nextButton.addTarget(self, action: #selector(nextNoun), for: .touchUpInside)
        nextButton.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [
            instructionLabel,
            scoreLabel,
            nounLabel,
            englishLabel,
            buttonStack,
            speakButton,
            feedbackLabel,
            nextButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        instructionLabel.textColor = ThemeManager.shared.textColor
        scoreLabel.textColor = ThemeManager.shared.textColor
        nounLabel.textColor = ThemeManager.shared.textColor
        englishLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        
        for button in [derButton, dieButton, dasButton] {
            button.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            button.setTitleColor(ThemeManager.shared.textColor, for: .normal)
            button.layer.borderColor = ThemeManager.shared.borderColor.cgColor
        }
    }
    
    private func loadNextNoun() {
        guard !nouns.isEmpty else {
            nounLabel.text = "No nouns available"
            englishLabel.text = "Please add nouns_gender.txt file."
            return
        }
        
        currentIndex = Int.random(in: 0..<nouns.count)
        let noun = nouns[currentIndex]
        
        nounLabel.text = noun.noun
        englishLabel.text = "(\(noun.english))"
        
        feedbackLabel.text = ""
        nextButton.isHidden = true
        scoreLabel.text = "Score: \(correctCount)/\(totalCount)"
        
        // Reset button colors
        resetButtonColors()
        enableButtons(true)
    }
    
    private func resetButtonColors() {
        for button in [derButton, dieButton, dasButton] {
            button.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            button.layer.borderColor = ThemeManager.shared.borderColor.cgColor
        }
    }
    
    private func enableButtons(_ enabled: Bool) {
        derButton.isEnabled = enabled
        dieButton.isEnabled = enabled
        dasButton.isEnabled = enabled
    }
    
    @objc private func articleSelected(_ sender: UIButton) {
        guard !nouns.isEmpty else { return }
        
        let selectedArticle = sender.titleLabel?.text ?? ""
        let noun = nouns[currentIndex]
        let correctArticle = noun.gender.lowercased()
        
        totalCount += 1
        enableButtons(false)
        
        // Highlight correct answer
        let correctButton: UIButton
        switch correctArticle {
        case "der": correctButton = derButton
        case "die": correctButton = dieButton
        case "das": correctButton = dasButton
        default: correctButton = derButton
        }
        
        if selectedArticle.lowercased() == correctArticle {
            correctCount += 1
            sender.backgroundColor = systemGreen
            feedbackLabel.text = "✅ Correct! \(noun.gender) \(noun.noun)"
            feedbackLabel.textColor = systemGreen
        } else {
            sender.backgroundColor = systemRed
            correctButton.backgroundColor = systemGreen
            feedbackLabel.text = "❌ Incorrect.\nCorrect: \(noun.gender) \(noun.noun)"
            feedbackLabel.textColor = systemRed
        }
        
        scoreLabel.text = "Score: \(correctCount)/\(totalCount)"
        nextButton.isHidden = false
    }
    
    @objc private func speakNoun() {
        guard !nouns.isEmpty else { return }
        let noun = nouns[currentIndex]
        audioManager.speakNormal("\(noun.gender) \(noun.noun)")
    }
    
    @objc private func nextNoun() {
        loadNextNoun()
    }
    
    // iOS 12 compatible colors
    private var systemGreen: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGreen
        } else {
            return UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
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
