//
//  WritingViewController.swift
//  Germanium
//
//  Created by Matouš Pikous on 25/09/2025.
//  Copyright © 2025 Matouš Pikous. All rights reserved.
//

import Foundation


import UIKit

class WritingViewController: UIViewController {
    private var sentences = SentenceProvider.loadSentences()
    private var currentIndex = 0

    private let questionLabel = UILabel()
    private let textView = UITextView()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Writing Task"

        setupUI()
        showSentence()
    }

    private func setupUI() {
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 18)
        
        feedbackLabel.numberOfLines = 0              // allow multiple lines
        feedbackLabel.lineBreakMode = .byWordWrapping
        feedbackLabel.textAlignment = .center

        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 6
        textView.isScrollEnabled = true  // allow scrolling if text is long
        textView.translatesAutoresizingMaskIntoConstraints = false

        checkButton.setTitle("Check", for: .normal)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)

        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)

        let stack = UIStackView(arrangedSubviews: [questionLabel, feedbackLabel, textView, checkButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.heightAnchor.constraint(equalToConstant: 80) // adjust height as needed
        ])
    }

    private func showSentence() {
        guard sentences.count > 0 else { return }
        let sentence = sentences[currentIndex]
        questionLabel.text = sentence.english
        textView.text = ""
        feedbackLabel.text = ""
    }


    
    @objc private func checkAnswer() {
        let userAnswer = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let correct = sentences[currentIndex].german

        if userAnswer.lowercased() == correct.lowercased() {
            feedbackLabel.text = "✅ Correct!"

            // Pick a new random sentence
            currentIndex = Int.random(in: 0..<sentences.count)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showSentence()
            }
        } else {
            feedbackLabel.text = "❌ Correct: \(correct)"
        }
        
    }

}
