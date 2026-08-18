//
//  TensePracticeViewController.swift
//  Germanium
//

import UIKit

enum TenseType: String, CaseIterable {
    case present = "Present"
    case pastPerfect = "Past Perfect"
    case future = "Future"
    case pastSimple = "Past Simple"
}

class TensePracticeViewController: UIViewController {
    private var sentences: [TenseSentence] = []
    private var currentIndex = 0
    private var fromTense: TenseType = .present
    private var toTense: TenseType = .pastSimple
    
    private let instructionLabel = UILabel()
    private let questionLabel = UILabel()
    private let textView = UITextView()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let fromTenseButton = UIButton(type: .system)
    private let toTenseButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tense Practice"
        sentences = DataProvider.loadTenseSentences()
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
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    private func setupUI() {
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 14)
        
        let fromStack = UIStackView()
        fromStack.axis = .horizontal
        fromStack.spacing = 8
        fromStack.alignment = .center
        let fromLabel = UILabel()
        fromLabel.text = "From:"
        fromLabel.font = UIFont.systemFont(ofSize: 14)
        fromTenseButton.setTitle(fromTense.rawValue, for: .normal)
        fromTenseButton.addTarget(self, action: #selector(selectFromTense), for: .touchUpInside)
        fromStack.addArrangedSubview(fromLabel)
        fromStack.addArrangedSubview(fromTenseButton)
        
        let toStack = UIStackView()
        toStack.axis = .horizontal
        toStack.spacing = 8
        toStack.alignment = .center
        let toLabel = UILabel()
        toLabel.text = "To:"
        toLabel.font = UIFont.systemFont(ofSize: 14)
        toTenseButton.setTitle(toTense.rawValue, for: .normal)
        toTenseButton.addTarget(self, action: #selector(selectToTense), for: .touchUpInside)
        toStack.addArrangedSubview(toLabel)
        toStack.addArrangedSubview(toTenseButton)
        
        let tenseControlStack = UIStackView(arrangedSubviews: [fromStack, toStack])
        tenseControlStack.axis = .horizontal
        tenseControlStack.distribution = .fillEqually
        tenseControlStack.spacing = 20
        
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 6
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
        
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        
        let buttonStack = UIStackView(arrangedSubviews: [checkButton, speakButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        
        let stack = UIStackView(arrangedSubviews: [instructionLabel, tenseControlStack, questionLabel, textView, buttonStack, feedbackLabel, nextButton])
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
        questionLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        textView.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        textView.textColor = ThemeManager.shared.textColor
        textView.layer.borderColor = ThemeManager.shared.borderColor.cgColor
    }
    
    @objc private func selectFromTense() {
        showTenseSelector(current: fromTense, title: "Select From Tense") { [weak self] selected in
            self?.fromTense = selected
            self?.fromTenseButton.setTitle(selected.rawValue, for: .normal)
            self?.showSentence()
        }
    }
    
    @objc private func selectToTense() {
        showTenseSelector(current: toTense, title: "Select To Tense") { [weak self] selected in
            self?.toTense = selected
            self?.toTenseButton.setTitle(selected.rawValue, for: .normal)
            self?.showSentence()
        }
    }
    
    private func showTenseSelector(current: TenseType, title: String, completion: @escaping (TenseType) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for tense in TenseType.allCases {
            let action = UIAlertAction(title: tense.rawValue, style: .default) { _ in
                completion(tense)
            }
            if tense == current {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showSentence() {
        guard sentences.count > 0 else { return }
        let sentence = sentences[currentIndex]
        
        instructionLabel.text = "Convert from \(fromTense.rawValue) to \(toTense.rawValue)"
        
        let sourceText: String
        switch fromTense {
        case .present: sourceText = sentence.present
        case .pastPerfect: sourceText = sentence.pastPerfect
        case .future: sourceText = sentence.future
        case .pastSimple: sourceText = sentence.pastSimple
        }
        
        questionLabel.text = sourceText
        textView.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
    }
    
    @objc private func checkAnswer() {
        let userAnswer = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sentence = sentences[currentIndex]
        
        let correctText: String
        switch toTense {
        case .present: correctText = sentence.present
        case .pastPerfect: correctText = sentence.pastPerfect
        case .future: correctText = sentence.future
        case .pastSimple: correctText = sentence.pastSimple
        }
        
        if userAnswer.lowercased() == correctText.lowercased() {
            feedbackLabel.text = "✅ Correct!\nEnglish: \(sentence.english)"
            feedbackLabel.textColor = systemGreen
            nextButton.isHidden = false
        } else {
            feedbackLabel.text = "❌ Correct: \(correctText)\nEnglish: \(sentence.english)"
            feedbackLabel.textColor = systemRed
            nextButton.isHidden = false
        }
    }
    
    @objc private func speakAnswer() {
        guard sentences.count > 0 else { return }
        let sentence = sentences[currentIndex]
        
        let correctText: String
        switch toTense {
        case .present: correctText = sentence.present
        case .pastPerfect: correctText = sentence.pastPerfect
        case .future: correctText = sentence.future
        case .pastSimple: correctText = sentence.pastSimple
        }
        
        audioManager.speakNormal(correctText)
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
