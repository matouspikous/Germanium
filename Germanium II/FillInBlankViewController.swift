//
//  FillInBlankViewController.swift
//  Germanium
//
//  Feature 8: Fill-in-the-Blank exercises
//

import UIKit

class FillInBlankViewController: UIViewController {
    
    private var items: [FillInBlankItem] = []
    private var currentIndex = 0
    
    private let instructionLabel = UILabel()
    private let sentenceLabel = UILabel()
    private let hintLabel = UILabel()
    private let answerField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fill in the Blank"
        
        items = DataProvider.loadFillInBlank()
        
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
        instructionLabel.text = "Fill in the blank with the correct word:"
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        sentenceLabel.numberOfLines = 0
        sentenceLabel.textAlignment = .center
        sentenceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.font = UIFont.italicSystemFont(ofSize: 14)
        
        answerField.borderStyle = .roundedRect
        answerField.font = UIFont.systemFont(ofSize: 18)
        answerField.textAlignment = .center
        answerField.autocapitalizationType = .none
        answerField.autocorrectionType = .no
        answerField.placeholder = "Type your answer"
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        speakButton.setTitle("🔊 Listen", for: .normal)
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        speakButton.addTarget(self, action: #selector(speakSentence), for: .touchUpInside)
        
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        
        nextButton.setTitle("Next ➡️", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nextButton.addTarget(self, action: #selector(nextItem), for: .touchUpInside)
        nextButton.isHidden = true
        
        let buttonStack = UIStackView(arrangedSubviews: [checkButton, speakButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        
        let stack = UIStackView(arrangedSubviews: [
            instructionLabel,
            sentenceLabel,
            hintLabel,
            answerField,
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
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        instructionLabel.textColor = ThemeManager.shared.textColor
        sentenceLabel.textColor = ThemeManager.shared.textColor
        hintLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        answerField.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        answerField.textColor = ThemeManager.shared.textColor
    }
    
    @objc private func dismissKeyboard() {
        answerField.resignFirstResponder()
    }
    
    private func loadNextItem() {
        guard !items.isEmpty else {
            sentenceLabel.text = "No fill-in-the-blank items available.\nPlease add fill_blank.txt file."
            return
        }
        
        currentIndex = Int.random(in: 0..<items.count)
        let item = items[currentIndex]
        
        sentenceLabel.text = item.sentenceWithBlank
        hintLabel.text = item.hint.isEmpty ? "" : "Hint: \(item.hint)"
        
        answerField.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
    }
    
    @objc private func checkAnswer() {
        guard !items.isEmpty else { return }
        
        let userAnswer = answerField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let item = items[currentIndex]
        
        // Support multiple correct answers separated by /
        let correctAnswers = item.answer.components(separatedBy: "/").map {
            $0.trimmingCharacters(in: .whitespaces).lowercased()
        }
        
        if correctAnswers.contains(userAnswer.lowercased()) {
            let completeSentence = item.sentenceWithBlank.replacingOccurrences(of: "___", with: item.answer)
            feedbackLabel.text = "✅ Correct!\n\(completeSentence)"
            feedbackLabel.textColor = systemGreen
            nextButton.isHidden = false
        } else {
            feedbackLabel.text = "❌ Incorrect.\nCorrect answer: \(item.answer)"
            feedbackLabel.textColor = systemRed
            nextButton.isHidden = false
        }
    }
    
    @objc private func speakSentence() {
        guard !items.isEmpty else { return }
        let item = items[currentIndex]
        let completeSentence = item.sentenceWithBlank.replacingOccurrences(of: "___", with: item.answer)
        audioManager.speakNormal(completeSentence)
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
