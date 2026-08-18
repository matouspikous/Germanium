//
//  ListeningPracticeViewController.swift
//  Germanium
//
//  Features 4 & 5: Audio pronunciation and Listening comprehension (Dictation)
//

import UIKit

class ListeningPracticeViewController: UIViewController {
    
    private var sentences: [Sentence] = []
    private var currentIndex = 0
    
    private let instructionLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private let playSlowButton = UIButton(type: .system)
    private let textView = UITextView()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let showAnswerButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let hintLabel = UILabel()
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Listening Practice"
        
        // Load sentences from various sources
        sentences = DataProvider.loadSentences(from: "sentences")
        if sentences.isEmpty {
            sentences = DataProvider.loadSentences(from: "a1_sentences")
        }
        
        setupUI()
        loadNextSentence()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        audioManager.stop()
    }
    
    private func setupUI() {
        instructionLabel.text = "Listen to the German sentence and type what you hear:"
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        hintLabel.text = ""
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.font = UIFont.italicSystemFont(ofSize: 14)
        
        playButton.setTitle("▶️ Play Normal", for: .normal)
        playButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        playButton.addTarget(self, action: #selector(playNormal), for: .touchUpInside)
        
        playSlowButton.setTitle("🐢 Play Slow", for: .normal)
        playSlowButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        playSlowButton.addTarget(self, action: #selector(playSlow), for: .touchUpInside)
        
        let playStack = UIStackView(arrangedSubviews: [playButton, playSlowButton])
        playStack.axis = .horizontal
        playStack.spacing = 20
        playStack.distribution = .fillEqually
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 8
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        checkButton.setTitle("Check Answer", for: .normal)
        checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        showAnswerButton.setTitle("Show Answer", for: .normal)
        showAnswerButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        showAnswerButton.addTarget(self, action: #selector(showAnswer), for: .touchUpInside)
        
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        
        nextButton.setTitle("Next ➡️", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nextButton.addTarget(self, action: #selector(nextSentence), for: .touchUpInside)
        nextButton.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [
            instructionLabel,
            hintLabel,
            playStack,
            textView,
            checkButton,
            showAnswerButton,
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
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        instructionLabel.textColor = ThemeManager.shared.textColor
        hintLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        textView.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        textView.textColor = ThemeManager.shared.textColor
        textView.layer.borderColor = ThemeManager.shared.borderColor.cgColor
    }
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    private func loadNextSentence() {
        guard !sentences.isEmpty else {
            instructionLabel.text = "No sentences available. Please add sentence files."
            return
        }
        
        currentIndex = Int.random(in: 0..<sentences.count)
        let sentence = sentences[currentIndex]
        
        // Show English as hint
        hintLabel.text = "Hint: \(sentence.english)"
        
        textView.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
        showAnswerButton.isHidden = false
    }
    
    @objc private func playNormal() {
        guard !sentences.isEmpty else { return }
        let sentence = sentences[currentIndex]
        audioManager.speakNormal(sentence.german)
    }
    
    @objc private func playSlow() {
        guard !sentences.isEmpty else { return }
        let sentence = sentences[currentIndex]
        audioManager.speakSlowly(sentence.german)
    }
    
    @objc private func checkAnswer() {
        guard !sentences.isEmpty else { return }
        
        let userAnswer = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let correctAnswer = sentences[currentIndex].german
        
        if userAnswer.lowercased() == correctAnswer.lowercased() {
            feedbackLabel.text = "✅ Correct!\n\(correctAnswer)"
            feedbackLabel.textColor = systemGreen
            nextButton.isHidden = false
            showAnswerButton.isHidden = true
        } else {
            // Show what was wrong
            feedbackLabel.text = "❌ Not quite right.\nYour answer: \(userAnswer)"
            feedbackLabel.textColor = systemRed
        }
    }
    
    @objc private func showAnswer() {
        guard !sentences.isEmpty else { return }
        let sentence = sentences[currentIndex]
        feedbackLabel.text = "Answer: \(sentence.german)"
        feedbackLabel.textColor = ThemeManager.shared.textColor
        nextButton.isHidden = false
        showAnswerButton.isHidden = true
    }
    
    @objc private func nextSentence() {
        loadNextSentence()
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
