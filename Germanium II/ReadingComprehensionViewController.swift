//
//  ReadingComprehensionViewController.swift
//  Germanium
//
//  Feature 18: Reading Comprehension with passages and questions
//

import UIKit

class ReadingComprehensionViewController: UIViewController {
    
    private var passages: [ReadingPassage] = []
    private var currentPassageIndex = 0
    private var currentQuestionIndex = 0
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let passageTextView = UITextView()
    private let questionLabel = UILabel()
    private let answerField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let nextQuestionButton = UIButton(type: .system)
    private let nextPassageButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    private let progressLabel = UILabel()
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reading Comprehension"
        
        passages = DataProvider.loadReadingPassages()
        
        setupUI()
        loadPassage()
        
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        passageTextView.isEditable = false
        passageTextView.isScrollEnabled = false
        passageTextView.font = UIFont.systemFont(ofSize: 16)
        passageTextView.layer.borderWidth = 1.0
        passageTextView.layer.cornerRadius = 8
        
        speakButton.setTitle("🔊 Read Aloud", for: .normal)
        speakButton.addTarget(self, action: #selector(speakPassage), for: .touchUpInside)
        
        progressLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.textAlignment = .center
        
        questionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        
        answerField.borderStyle = .roundedRect
        answerField.font = UIFont.systemFont(ofSize: 16)
        answerField.placeholder = "Type your answer"
        answerField.autocapitalizationType = .none
        answerField.autocorrectionType = .no
        
        checkButton.setTitle("Check Answer", for: .normal)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        
        nextQuestionButton.setTitle("Next Question ➡️", for: .normal)
        nextQuestionButton.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
        nextQuestionButton.isHidden = true
        
        nextPassageButton.setTitle("Next Passage 📖", for: .normal)
        nextPassageButton.addTarget(self, action: #selector(nextPassage), for: .touchUpInside)
        nextPassageButton.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            passageTextView,
            speakButton,
            progressLabel,
            questionLabel,
            answerField,
            checkButton,
            feedbackLabel,
            nextQuestionButton,
            nextPassageButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        contentView.backgroundColor = ThemeManager.shared.backgroundColor
        scrollView.backgroundColor = ThemeManager.shared.backgroundColor
        titleLabel.textColor = ThemeManager.shared.textColor
        questionLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        progressLabel.textColor = ThemeManager.shared.textColor
        passageTextView.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        passageTextView.textColor = ThemeManager.shared.textColor
        passageTextView.layer.borderColor = ThemeManager.shared.borderColor.cgColor
        answerField.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        answerField.textColor = ThemeManager.shared.textColor
    }
    
    @objc private func dismissKeyboard() {
        answerField.resignFirstResponder()
    }
    
    private func loadPassage() {
        guard !passages.isEmpty else {
            titleLabel.text = "No reading passages available"
            passageTextView.text = "Please add reading_passages.txt file."
            return
        }
        
        currentPassageIndex = Int.random(in: 0..<passages.count)
        currentQuestionIndex = 0
        
        let passage = passages[currentPassageIndex]
        
        titleLabel.text = passage.title
        passageTextView.text = passage.passage
        
        loadQuestion()
    }
    
    private func loadQuestion() {
        guard !passages.isEmpty else { return }
        
        let passage = passages[currentPassageIndex]
        
        if currentQuestionIndex < passage.questions.count {
            let question = passage.questions[currentQuestionIndex]
            questionLabel.text = "Question \(currentQuestionIndex + 1)/\(passage.questions.count):\n\(question.question)"
            progressLabel.text = "Question \(currentQuestionIndex + 1) of \(passage.questions.count)"
            
            answerField.text = ""
            feedbackLabel.text = ""
            nextQuestionButton.isHidden = true
            nextPassageButton.isHidden = true
            checkButton.isHidden = false
            answerField.isHidden = false
        } else {
            // All questions answered
            questionLabel.text = "✅ All questions completed!"
            progressLabel.text = ""
            answerField.isHidden = true
            checkButton.isHidden = true
            nextQuestionButton.isHidden = true
            nextPassageButton.isHidden = false
        }
    }
    
    @objc private func checkAnswer() {
        guard !passages.isEmpty else { return }
        
        let passage = passages[currentPassageIndex]
        guard currentQuestionIndex < passage.questions.count else { return }
        
        let userAnswer = answerField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let correctAnswer = passage.questions[currentQuestionIndex].answer
        
        // Support multiple correct answers separated by /
        let correctAnswers = correctAnswer.components(separatedBy: "/").map {
            $0.trimmingCharacters(in: .whitespaces).lowercased()
        }
        
        if correctAnswers.contains(userAnswer.lowercased()) {
            feedbackLabel.text = "✅ Correct!"
            feedbackLabel.textColor = systemGreen
        } else {
            feedbackLabel.text = "❌ Incorrect.\nCorrect answer: \(correctAnswer)"
            feedbackLabel.textColor = systemRed
        }
        
        nextQuestionButton.isHidden = false
    }
    
    @objc private func nextQuestion() {
        currentQuestionIndex += 1
        loadQuestion()
    }
    
    @objc private func nextPassage() {
        loadPassage()
    }
    
    @objc private func speakPassage() {
        guard !passages.isEmpty else { return }
        let passage = passages[currentPassageIndex]
        audioManager.speakSlowly(passage.passage)
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
