//
//  OrderingViewController.swift
//  Germanium
//

import UIKit

class OrderingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var sentences: [Sentence] = []
    private var currentIndex = 0
    private var words: [String] = []
    private let filename: String
    
    private let questionLabel = UILabel()
    private let tableView = UITableView()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let screenshotButton = UIButton(type: .system)
    
    init(filename: String) {
        self.filename = filename
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ordering Task"
        sentences = DataProvider.loadSentences(from: filename)
        setupUI()
        showSentence()
        
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
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove delete icons
        tableView.allowsSelectionDuringEditing = false
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.addTarget(self, action: #selector(checkOrder), for: .touchUpInside)
        
        screenshotButton.setTitle("Next ➡️", for: .normal)
        screenshotButton.addTarget(self, action: #selector(nextSentence), for: .touchUpInside)
        screenshotButton.isHidden = true
        
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        
        let stack = UIStackView(arrangedSubviews: [questionLabel, tableView, checkButton, feedbackLabel, screenshotButton])
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
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        questionLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        tableView.backgroundColor = ThemeManager.shared.backgroundColor
        tableView.separatorColor = ThemeManager.shared.borderColor
        tableView.reloadData()
    }
    
    private func showSentence() {
        guard sentences.count > 0 else { return }
        let sentence = sentences[currentIndex]
        questionLabel.text = sentence.english
        words = sentence.german.components(separatedBy: " ").shuffled()
        tableView.reloadData()
        feedbackLabel.text = ""
        screenshotButton.isHidden = true
    }
    
    @objc private func checkOrder() {
        let userSentence = words.joined(separator: " ")
        let correct = sentences[currentIndex].german
        let identifier = "\(filename)_\(currentIndex)"
        
        if userSentence == correct {
            feedbackLabel.text = "✅ Correct!"
            screenshotButton.isHidden = false
            MistakeTracker.shared.decrementMistake(for: identifier)
        } else {
            feedbackLabel.text = "❌ Try again"
            MistakeTracker.shared.recordMistake(for: identifier)
            
            // Vibrate on iOS 10+
            if #available(iOS 10.0, *) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
    
    @objc private func nextSentence() {
        currentIndex = Int.random(in: 0..<sentences.count)
        showSentence()
    }
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = words[indexPath.row]
        cell.backgroundColor = ThemeManager.shared.backgroundColor
        cell.textLabel?.textColor = ThemeManager.shared.textColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let word = words.remove(at: sourceIndexPath.row)
        words.insert(word, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
