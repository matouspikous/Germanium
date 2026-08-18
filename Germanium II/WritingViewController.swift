//
//  WritingViewController.swift
//  Germanium
//

import UIKit

class WritingViewController: UIViewController {
    private var sentences: [Sentence] = []
    private var currentIndex = 0
    private let filename: String
    
    private let questionLabel = UILabel()
    private let textView = UITextView()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    init(filename: String) {
        self.filename = filename
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Writing Task"
        sentences = DataProvider.loadSentences(from: filename)
        setupUI()
        showSentence()
        
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
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 18)
        
        feedbackLabel.numberOfLines = 0
        feedbackLabel.lineBreakMode = .byWordWrapping
        feedbackLabel.textAlignment = .center
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 6
        textView.isScrollEnabled = true
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        speakButton.setTitle("🔊 Listen", for: .normal)
        speakButton.addTarget(self, action: #selector(speakAnswer), for: .touchUpInside)
        
        nextButton.setTitle("Next ➡️", for: .normal)
        nextButton.addTarget(self, action: #selector(nextSentence), for: .touchUpInside)
        nextButton.isHidden = true
        
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        
        let buttonStack = UIStackView(arrangedSubviews: [checkButton, speakButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        
        let stack = UIStackView(arrangedSubviews: [questionLabel, feedbackLabel, textView, buttonStack, nextButton])
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
        questionLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        textView.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        textView.textColor = ThemeManager.shared.textColor
        textView.layer.borderColor = ThemeManager.shared.borderColor.cgColor
    }
    
    private func showSentence() {
        guard sentences.count > 0 else { return }
        let sentence = sentences[currentIndex]
        questionLabel.text = sentence.english
        textView.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
    }
    
    @objc private func checkAnswer() {
        let userAnswer = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let correct = sentences[currentIndex].german
        let identifier = "\(filename)_\(currentIndex)"
        
        if userAnswer.lowercased() == correct.lowercased() {
            feedbackLabel.text = "✅ Correct!"
            feedbackLabel.textColor = systemGreen
            nextButton.isHidden = false
            MistakeTracker.shared.decrementMistake(for: identifier)
        } else {
            feedbackLabel.text = "❌ Correct: \(correct)"
            feedbackLabel.textColor = systemRed
            nextButton.isHidden = false
            MistakeTracker.shared.recordMistake(for: identifier)
        }
    }
    
    @objc private func speakAnswer() {
        guard sentences.count > 0 else { return }
        let sentence = sentences[currentIndex]
        audioManager.speakNormal(sentence.german)
    }
    
    @objc private func nextSentence() {
        currentIndex = Int.random(in: 0..<sentences.count)
        showSentence()
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
