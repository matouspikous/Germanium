//
//  OrderingViewController.swift
//  Germanium
//
//  Created by Matouš Pikous on 25/09/2025.
//  Copyright © 2025 Matouš Pikous. All rights reserved.
//

import Foundation
import UIKit

class OrderingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var sentences = SentenceProvider.loadSentences()
    private var currentIndex = 0
    private var words: [String] = []

    private let questionLabel = UILabel()
    private let tableView = UITableView()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Ordering Task"

        setupUI()
        showSentence()
    }

    private func setupUI() {
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 18)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        checkButton.setTitle("Check", for: .normal)
        checkButton.addTarget(self, action: #selector(checkOrder), for: .touchUpInside)

        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)

        let stack = UIStackView(arrangedSubviews: [questionLabel, tableView, checkButton, feedbackLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func showSentence() {
        guard sentences.count > 0 else { return }
        let sentence = sentences[currentIndex]
        questionLabel.text = sentence.english
        words = sentence.german.components(separatedBy: " ").shuffled()
        tableView.reloadData()
        feedbackLabel.text = ""
    }

    @objc private func checkOrder() {
        let userSentence = words.joined(separator: " ")
        let correct = sentences[currentIndex].german

        if userSentence == correct {
            feedbackLabel.text = "✅ Correct!"

            // Pick a new random sentence
            currentIndex = Int.random(in: 0..<sentences.count)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showSentence()
            }
        } else {
            feedbackLabel.text = "❌ Try again"
        }
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{ return words.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = words[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let word = words.remove(at: sourceIndexPath.row)
        words.insert(word, at: destinationIndexPath.row)
    }
}
