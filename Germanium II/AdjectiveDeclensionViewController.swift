//
//  AdjectiveDeclensionViewController.swift
//  Germanium
//
//  Feature 20: Adjective Declension Practice
//

import UIKit

class AdjectiveDeclensionViewController: UIViewController {
    
    private var items: [AdjectiveDeclensionItem] = []
    private var currentIndex = 0
    
    private let instructionLabel = UILabel()
    private let contextLabel = UILabel()
    private let promptLabel = UILabel()
    private let englishLabel = UILabel()
    private let answerField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    private let helpButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Adjective Declension"
        
        items = DataProvider.loadAdjectiveDeclension()
        
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
        instructionLabel.text = "Type the correct adjective ending:"
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        contextLabel.numberOfLines = 0
        contextLabel.textAlignment = .center
        contextLabel.font = UIFont.systemFont(ofSize: 14)
        
        promptLabel.numberOfLines = 0
        promptLabel.textAlignment = .center
        promptLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        englishLabel.numberOfLines = 0
        englishLabel.textAlignment = .center
        englishLabel.font = UIFont.italicSystemFont(ofSize: 14)
        
        answerField.borderStyle = .roundedRect
        answerField.font = UIFont.systemFont(ofSize: 18)
        answerField.textAlignment = .center
        answerField.placeholder = "Type adjective form"
        answerField.autocapitalizationType = .none
        answerField.autocorrectionType = .no
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        speakButton.setTitle("🔊 Listen", for: .normal)
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        speakButton.addTarget(self, action: #selector(speakPhrase), for: .touchUpInside)
        
        helpButton.setTitle("📚 Declension Table", for: .normal)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        helpButton.addTarget(self, action: #selector(showHelp), for: .touchUpInside)
        
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
            contextLabel,
            promptLabel,
            englishLabel,
            answerField,
            buttonStack,
            helpButton,
            feedbackLabel,
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
        contextLabel.textColor = ThemeManager.shared.textColor
        promptLabel.textColor = ThemeManager.shared.textColor
        englishLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        answerField.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        answerField.textColor = ThemeManager.shared.textColor
    }
    
    @objc private func dismissKeyboard() {
        answerField.resignFirstResponder()
    }
    
    private func loadNextItem() {
        guard !items.isEmpty else {
            promptLabel.text = "No adjective declension items available.\nPlease add adjective_declension.txt file."
            return
        }
        
        currentIndex = Int.random(in: 0..<items.count)
        let item = items[currentIndex]
        
        // Build context info
        let genderName = genderFullName(item.gender)
        let caseName = caseFullName(item.grammaticalCase)
        let articleTypeName = articleTypeFullName(item.articleType)
        
        contextLabel.text = "Gender: \(genderName) | Case: \(caseName) | Article: \(articleTypeName)"
        
        // Build the prompt with blank
        let article = getArticle(gender: item.gender, case: item.grammaticalCase, articleType: item.articleType)
        promptLabel.text = "\(article) _____ \(item.noun)"
        
        englishLabel.text = "(\(item.adjective)) → \(item.english)"
        
        answerField.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
    }
    
    private func genderFullName(_ g: String) -> String {
        switch g.lowercased() {
        case "m": return "Masculine"
        case "f": return "Feminine"
        case "n": return "Neuter"
        case "pl": return "Plural"
        default: return g
        }
    }
    
    private func caseFullName(_ c: String) -> String {
        switch c.lowercased() {
        case "nom": return "Nominativ"
        case "akk": return "Akkusativ"
        case "dat": return "Dativ"
        case "gen": return "Genitiv"
        default: return c
        }
    }
    
    private func articleTypeFullName(_ a: String) -> String {
        switch a.lowercased() {
        case "def": return "Definite (der/die/das)"
        case "indef": return "Indefinite (ein/eine)"
        case "none": return "No article"
        default: return a
        }
    }
    
    private func getArticle(gender: String, case grammaticalCase: String, articleType: String) -> String {
        // Return the appropriate article based on gender, case, and type
        if articleType.lowercased() == "none" {
            return ""
        }
        
        let g = gender.lowercased()
        let c = grammaticalCase.lowercased()
        let t = articleType.lowercased()
        
        if t == "def" {
            // Definite articles
            switch (g, c) {
            case ("m", "nom"): return "der"
            case ("m", "akk"): return "den"
            case ("m", "dat"): return "dem"
            case ("m", "gen"): return "des"
            case ("f", "nom"), ("f", "akk"): return "die"
            case ("f", "dat"): return "der"
            case ("f", "gen"): return "der"
            case ("n", "nom"), ("n", "akk"): return "das"
            case ("n", "dat"): return "dem"
            case ("n", "gen"): return "des"
            case ("pl", "nom"), ("pl", "akk"): return "die"
            case ("pl", "dat"): return "den"
            case ("pl", "gen"): return "der"
            default: return "der"
            }
        } else {
            // Indefinite articles
            switch (g, c) {
            case ("m", "nom"): return "ein"
            case ("m", "akk"): return "einen"
            case ("m", "dat"): return "einem"
            case ("m", "gen"): return "eines"
            case ("f", "nom"), ("f", "akk"): return "eine"
            case ("f", "dat"): return "einer"
            case ("f", "gen"): return "einer"
            case ("n", "nom"), ("n", "akk"): return "ein"
            case ("n", "dat"): return "einem"
            case ("n", "gen"): return "eines"
            case ("pl", _): return "" // No indefinite plural
            default: return "ein"
            }
        }
    }
    
    @objc private func checkAnswer() {
        guard !items.isEmpty else { return }
        
        let userAnswer = answerField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let item = items[currentIndex]
        
        if userAnswer.lowercased() == item.correctForm.lowercased() {
            let article = getArticle(gender: item.gender, case: item.grammaticalCase, articleType: item.articleType)
            let fullPhrase = "\(article) \(item.correctForm) \(item.noun)".trimmingCharacters(in: .whitespaces)
            feedbackLabel.text = "✅ Correct!\n\(fullPhrase)"
            feedbackLabel.textColor = systemGreen
            nextButton.isHidden = false
        } else {
            feedbackLabel.text = "❌ Incorrect.\nCorrect form: \(item.correctForm)"
            feedbackLabel.textColor = systemRed
            nextButton.isHidden = false
        }
    }
    
    @objc private func speakPhrase() {
        guard !items.isEmpty else { return }
        let item = items[currentIndex]
        let article = getArticle(gender: item.gender, case: item.grammaticalCase, articleType: item.articleType)
        let fullPhrase = "\(article) \(item.correctForm) \(item.noun)".trimmingCharacters(in: .whitespaces)
        audioManager.speakNormal(fullPhrase)
    }
    
    @objc private func showHelp() {
        let helpText = """
        Adjective Endings Quick Reference:
        
        AFTER DEFINITE ARTICLE (der/die/das):
        Nom: -e (all genders), -en (plural)
        Akk: -e (f/n), -en (m), -en (plural)
        Dat: -en (all)
        Gen: -en (all)
        
        AFTER INDEFINITE ARTICLE (ein/eine):
        Nom: -er (m), -e (f), -es (n)
        Akk: -en (m), -e (f), -es (n)
        Dat: -en (all)
        Gen: -en (all)
        
        NO ARTICLE (strong endings):
        Nom: -er (m), -e (f), -es (n), -e (pl)
        Akk: -en (m), -e (f), -es (n), -e (pl)
        Dat: -em (m/n), -er (f), -en (pl)
        Gen: -en (m/n), -er (f), -er (pl)
        """
        
        let alert = UIAlertController(title: "Adjective Declension", message: helpText, preferredStyle: .alert)
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
