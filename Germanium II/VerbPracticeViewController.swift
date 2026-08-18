//
//  VerbPracticeViewController.swift
//  Germanium
//

import UIKit

class VerbPracticeViewController: UIViewController {
    private var verbs: [VerbPractice] = []
    private var currentIndex = 0
    
    private let questionLabel = UILabel()
    private let infinitiveField = UITextField()
    private let pastField = UITextField()
    private let perfectField = UITextField()
    //private let prepositionField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let screenshotButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verb Practice"
        verbs = DataProvider.loadVerbs()
        setupUI()
        showVerb()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 18)
        
        let fields = [
            ("Infinitive:", infinitiveField),
            ("Past:", pastField),
            ("Perfect:", perfectField)//,
            //("Preposition:", prepositionField)
        ]
        
        var fieldStacks: [UIStackView] = []
        for (label, field) in fields {
            let lbl = UILabel()
            lbl.text = label
            lbl.font = UIFont.systemFont(ofSize: 14)
            lbl.widthAnchor.constraint(equalToConstant: 100).isActive = true
            
            field.borderStyle = .roundedRect
            field.font = UIFont.systemFont(ofSize: 16)
            
            let stack = UIStackView(arrangedSubviews: [lbl, field])
            stack.axis = .horizontal
            stack.spacing = 8
            fieldStacks.append(stack)
        }
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        screenshotButton.setTitle("Next ➡️", for: .normal)
        screenshotButton.addTarget(self, action: #selector(nextVerb), for: .touchUpInside)
        screenshotButton.isHidden = true
        
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        
        var allViews: [UIView] = [questionLabel]
        allViews.append(contentsOf: fieldStacks)
        allViews.append(contentsOf: [checkButton, feedbackLabel, screenshotButton])
        
        let stack = UIStackView(arrangedSubviews: allViews)
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
        questionLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        
        //for field in [infinitiveField, pastField, perfectField, prepositionField] {
        //    field.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        //    field.textColor = ThemeManager.shared.textColor
        //}
        
        for field in [infinitiveField, pastField, perfectField] {
            field.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
            field.textColor = ThemeManager.shared.textColor
        }
    }
    
    private func showVerb() {
        guard verbs.count > 0 else { return }
        let verb = verbs[currentIndex]
        questionLabel.text = "English: \(verb.english)"
        
        infinitiveField.text = ""
        pastField.text = ""
        perfectField.text = ""
        //prepositionField.text = ""
        feedbackLabel.text = ""
        screenshotButton.isHidden = true
    }
    
    @objc private func checkAnswer() {
        let verb = verbs[currentIndex]
        
        let infinitiveCorrect = infinitiveField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == verb.infinitive.lowercased()
        let pastCorrect = pastField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == verb.past.lowercased()
        let perfectCorrect = perfectField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == verb.perfect.lowercased()
        //let prepositionCorrect = prepositionField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == verb.preposition.lowercased()
        
        
        if infinitiveCorrect && pastCorrect && perfectCorrect { //&& prepositionCorrect {
            feedbackLabel.text = "✅ All correct!"
            screenshotButton.isHidden = false
        } else {
            var feedback = "❌ Errors:\n"
            if !infinitiveCorrect { feedback += "Infinitive: \(verb.infinitive)\n" }
            if !pastCorrect { feedback += "Past: \(verb.past)\n" }
            if !perfectCorrect { feedback += "Perfect: \(verb.perfect)\n" }
            //if !prepositionCorrect { feedback += "Preposition: \(verb.preposition)\n" }
            feedbackLabel.text = feedback
            screenshotButton.isHidden = false
        }
    }
    
    @objc private func nextVerb() {
        currentIndex = Int.random(in: 0..<verbs.count)
        showVerb()
    }
}
