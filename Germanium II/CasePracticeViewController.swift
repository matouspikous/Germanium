//
//  CasePracticeViewController.swift
//  Germanium
//
//  Feature 7: Case Practice (Akkusativ/Dativ/Genitiv)
//

import UIKit

class CasePracticeViewController: UIViewController {
    
    private var items: [CasePracticeItem] = []
    private var currentIndex = 0
    
    private let instructionLabel = UILabel()
    private let caseInfoLabel = UILabel()
    private let sentenceLabel = UILabel()
    private let prepositionLabel = UILabel()
    private let answerField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let englishLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    private let caseHelpButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Case Practice"
        
        items = DataProvider.loadCasePractice()
        
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
        instructionLabel.text = "Fill in the correct article for the case:"
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        caseInfoLabel.font = UIFont.boldSystemFont(ofSize: 18)
        caseInfoLabel.textAlignment = .center
        caseInfoLabel.numberOfLines = 0
        
        prepositionLabel.font = UIFont.systemFont(ofSize: 14)
        prepositionLabel.textAlignment = .center
        prepositionLabel.numberOfLines = 0
        
        sentenceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        sentenceLabel.textAlignment = .center
        sentenceLabel.numberOfLines = 0
        
        answerField.borderStyle = .roundedRect
        answerField.font = UIFont.systemFont(ofSize: 18)
        answerField.textAlignment = .center
        answerField.placeholder = "der/die/das/dem/den/des..."
        answerField.autocapitalizationType = .none
        answerField.autocorrectionType = .no
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        speakButton.setTitle("🔊 Listen", for: .normal)
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        speakButton.addTarget(self, action: #selector(speakSentence), for: .touchUpInside)
        
        caseHelpButton.setTitle("📚 Case Help", for: .normal)
        caseHelpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        caseHelpButton.addTarget(self, action: #selector(showCaseHelp), for: .touchUpInside)
        
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        
        englishLabel.font = UIFont.italicSystemFont(ofSize: 14)
        englishLabel.textAlignment = .center
        englishLabel.numberOfLines = 0
        
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
            caseInfoLabel,
            prepositionLabel,
            sentenceLabel,
            answerField,
            buttonStack,
            caseHelpButton,
            feedbackLabel,
            englishLabel,
            nextButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
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
        caseInfoLabel.textColor = ThemeManager.shared.textColor
        prepositionLabel.textColor = ThemeManager.shared.textColor
        sentenceLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        englishLabel.textColor = ThemeManager.shared.textColor
        answerField.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        answerField.textColor = ThemeManager.shared.textColor
    }
    
    @objc private func dismissKeyboard() {
        answerField.resignFirstResponder()
    }
    
    private func loadNextItem() {
        guard !items.isEmpty else {
            sentenceLabel.text = "No case practice items available.\nPlease add case_practice.txt file."
            return
        }
        
        currentIndex = Int.random(in: 0..<items.count)
        let item = items[currentIndex]
        
        caseInfoLabel.text = "Case: \(item.grammaticalCase)"
        prepositionLabel.text = item.preposition.isEmpty ? "" : "Preposition: \(item.preposition)"
        sentenceLabel.text = item.sentenceWithBlank
        englishLabel.text = item.english
        
        answerField.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
    }
    
    @objc private func checkAnswer() {
        guard !items.isEmpty else { return }
        
        let userAnswer = answerField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let item = items[currentIndex]
        
        // Support multiple correct answers separated by /
        let correctAnswers = item.correctArticle.components(separatedBy: "/").map {
            $0.trimmingCharacters(in: .whitespaces).lowercased()
        }
        
        if correctAnswers.contains(userAnswer.lowercased()) {
            let completeSentence = item.sentenceWithBlank.replacingOccurrences(of: "___", with: item.correctArticle)
            feedbackLabel.text = "✅ Correct!\n\(completeSentence)"
            feedbackLabel.textColor = systemGreen
            nextButton.isHidden = false
        } else {
            feedbackLabel.text = "❌ Incorrect.\nCorrect: \(item.correctArticle)"
            feedbackLabel.textColor = systemRed
            nextButton.isHidden = false
        }
    }
    
    @objc private func speakSentence() {
        guard !items.isEmpty else { return }
        let item = items[currentIndex]
        let completeSentence = item.sentenceWithBlank.replacingOccurrences(of: "___", with: item.correctArticle)
        audioManager.speakNormal(completeSentence)
    }
    
    @objc private func showCaseHelp() {
        let helpText = """
        German Cases Quick Reference:
        
        NOMINATIV (Subject):
        der/die/das/die (pl)
        ein/eine/ein
        
        AKKUSATIV (Direct Object):
        den/die/das/die (pl)
        einen/eine/ein
        
        DATIV (Indirect Object):
        dem/der/dem/den (pl)
        einem/einer/einem
        
        GENITIV (Possession):
        des/der/des/der (pl)
        eines/einer/eines
        
        Common Prepositions:
        + Akkusativ: durch, für, gegen, ohne, um
        + Dativ: aus, bei, mit, nach, seit, von, zu
        + Genitiv: während, wegen, trotz, statt
        + Wechselpräpositionen (Akk for motion, Dat for location):
          an, auf, hinter, in, neben, über, unter, vor, zwischen
        """
        
        let alert = UIAlertController(title: "Case Help", message: helpText, preferredStyle: .alert)
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
