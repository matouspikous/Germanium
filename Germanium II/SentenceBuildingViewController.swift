//
//  SentenceBuildingViewController.swift
//  Germanium
//
//  Feature 16: Sentence Building from components
//

import UIKit

class SentenceBuildingViewController: UIViewController {
    
    private var items: [SentenceComponent] = []
    private var currentIndex = 0
    
    private let instructionLabel = UILabel()
    private let componentsLabel = UILabel()
    private let englishLabel = UILabel()
    private let textView = UITextView()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    private let hintButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sentence Building"
        
        items = DataProvider.loadSentenceComponents()
        
        setupUI()
        loadNextItem()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        instructionLabel.text = "Build a grammatically correct German sentence from these components:"
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        componentsLabel.numberOfLines = 0
        componentsLabel.textAlignment = .center
        componentsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        englishLabel.numberOfLines = 0
        englishLabel.textAlignment = .center
        englishLabel.font = UIFont.italicSystemFont(ofSize: 14)
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 8
        textView.autocapitalizationType = .sentences
        textView.autocorrectionType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        speakButton.setTitle("🔊 Listen", for: .normal)
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        speakButton.addTarget(self, action: #selector(speakSentence), for: .touchUpInside)
        
        hintButton.setTitle("💡 Hint", for: .normal)
        hintButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        hintButton.addTarget(self, action: #selector(showHint), for: .touchUpInside)
        
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        
        nextButton.setTitle("Next ➡️", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nextButton.addTarget(self, action: #selector(nextItem), for: .touchUpInside)
        nextButton.isHidden = true
        
        let buttonStack = UIStackView(arrangedSubviews: [checkButton, speakButton, hintButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        let stack = UIStackView(arrangedSubviews: [
            instructionLabel,
            componentsLabel,
            englishLabel,
            textView,
            buttonStack,
            feedbackLabel,
            nextButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        instructionLabel.textColor = ThemeManager.shared.textColor
        componentsLabel.textColor = ThemeManager.shared.textColor
        englishLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        textView.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        textView.textColor = ThemeManager.shared.textColor
        textView.layer.borderColor = ThemeManager.shared.borderColor.cgColor
    }
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    private func loadNextItem() {
        guard !items.isEmpty else {
            componentsLabel.text = "No sentence components available.\nPlease add sentence_building.txt file."
            return
        }
        
        currentIndex = Int.random(in: 0..<items.count)
        let item = items[currentIndex]
        
        // Show components in a structured way
        componentsLabel.text = "Subject: \(item.subject)\nVerb: \(item.verb)\nObject: \(item.object)"
        englishLabel.text = "English: \(item.english)"
        
        textView.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
    }
    
    @objc private func checkAnswer() {
        guard !items.isEmpty else { return }
        
        let userAnswer = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let item = items[currentIndex]
        
        // Normalize both answers for comparison
        let normalizedUser = normalizeAnswer(userAnswer)
        let normalizedCorrect = normalizeAnswer(item.correctSentence)
        
        if normalizedUser == normalizedCorrect {
            feedbackLabel.text = "✅ Correct!\n\(item.correctSentence)"
            feedbackLabel.textColor = systemGreen
            nextButton.isHidden = false
        } else {
            feedbackLabel.text = "❌ Not quite right.\nCorrect: \(item.correctSentence)"
            feedbackLabel.textColor = systemRed
            nextButton.isHidden = false
        }
    }
    
    private func normalizeAnswer(_ answer: String) -> String {
        // Remove extra spaces, normalize punctuation
        var normalized = answer.lowercased()
        normalized = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove trailing punctuation for comparison
        while normalized.hasSuffix(".") || normalized.hasSuffix("!") || normalized.hasSuffix("?") {
            normalized = String(normalized.dropLast())
        }
        return normalized
    }
    
    @objc private func speakSentence() {
        guard !items.isEmpty else { return }
        let item = items[currentIndex]
        audioManager.speakNormal(item.correctSentence)
    }
    
    @objc private func showHint() {
        guard !items.isEmpty else { return }
        let item = items[currentIndex]
        
        // Show first few characters of the correct sentence
        let hintLength = min(item.correctSentence.count / 2, 15)
        let hint = String(item.correctSentence.prefix(hintLength)) + "..."
        
        let alert = UIAlertController(title: "Hint", message: "The sentence starts with:\n\"\(hint)\"", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func nextItem() {
        loadNextItem()
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
