//
//  CustomWordListsViewController.swift
//  Germanium
//
//  Feature 14: Custom Word Lists - manage user's own vocabulary
//

import UIKit

class CustomWordListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var listNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Word Lists"
        
        setupUI()
        loadLists()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLists()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewList))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        tableView.backgroundColor = ThemeManager.shared.backgroundColor
        tableView.separatorColor = ThemeManager.shared.borderColor
        tableView.reloadData()
    }
    
    private func loadLists() {
        listNames = DataProvider.getCustomWordListNames()
        tableView.reloadData()
    }
    
    @objc private func createNewList() {
        let alert = UIAlertController(title: "New Word List", message: "Enter a name for your new list:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "List name"
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else { return }
            
            // Create empty list
            if DataProvider.saveCustomWordList(named: name, pairs: []) {
                self?.loadLists()
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listNames.isEmpty {
            return 1 // Show "No lists" message
        }
        return listNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if listNames.isEmpty {
            cell.textLabel?.text = "No custom lists yet. Tap + to create one."
            cell.textLabel?.textColor = ThemeManager.shared.textColor
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            let name = listNames[indexPath.row]
            let wordCount = DataProvider.loadCustomWordList(named: name).count
            cell.textLabel?.text = "\(name) (\(wordCount) words)"
            cell.textLabel?.textColor = ThemeManager.shared.textColor
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }
        
        cell.backgroundColor = ThemeManager.shared.backgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !listNames.isEmpty else { return }
        
        let name = listNames[indexPath.row]
        let vc = CustomWordListDetailViewController(listName: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !listNames.isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let name = listNames[indexPath.row]
            
            let alert = UIAlertController(title: "Delete List", message: "Are you sure you want to delete '\(name)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                if DataProvider.deleteCustomWordList(named: name) {
                    self?.loadLists()
                }
            })
            present(alert, animated: true)
        }
    }
}

// MARK: - Detail View Controller

class CustomWordListDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let listName: String
    private var pairs: [WordPair] = []
    private let tableView = UITableView()
    
    init(listName: String) {
        self.listName = listName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = listName
        
        setupUI()
        loadWords()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWord))
        let practiceButton = UIBarButtonItem(title: "Practice", style: .plain, target: self, action: #selector(startPractice))
        navigationItem.rightBarButtonItems = [addButton, practiceButton]
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        tableView.backgroundColor = ThemeManager.shared.backgroundColor
        tableView.separatorColor = ThemeManager.shared.borderColor
        tableView.reloadData()
    }
    
    private func loadWords() {
        pairs = DataProvider.loadCustomWordList(named: listName)
        tableView.reloadData()
    }
    
    @objc private func addWord() {
        let alert = UIAlertController(title: "Add Word", message: "Enter German word and English translation:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "German"
            textField.autocapitalizationType = .none
        }
        
        alert.addTextField { textField in
            textField.placeholder = "English"
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let german = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let english = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !german.isEmpty, !english.isEmpty,
                  let listName = self?.listName else { return }
            
            if DataProvider.addWordToCustomList(named: listName, german: german, english: english) {
                self?.loadWords()
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func startPractice() {
        guard !pairs.isEmpty else {
            let alert = UIAlertController(title: "No Words", message: "Add some words to practice first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let vc = CustomWordListPracticeViewController(listName: listName, pairs: pairs)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pairs.isEmpty {
            return 1
        }
        return pairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if pairs.isEmpty {
            cell.textLabel?.text = "No words yet. Tap + to add words."
            cell.selectionStyle = .none
        } else {
            let pair = pairs[indexPath.row]
            cell.textLabel?.text = "\(pair.german) — \(pair.english)"
            cell.selectionStyle = .default
        }
        
        cell.backgroundColor = ThemeManager.shared.backgroundColor
        cell.textLabel?.textColor = ThemeManager.shared.textColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !pairs.isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            pairs.remove(at: indexPath.row)
            _ = DataProvider.saveCustomWordList(named: listName, pairs: pairs)
            loadWords()
        }
    }
}

// MARK: - Practice View Controller

class CustomWordListPracticeViewController: UIViewController {
    
    private let listName: String
    private var pairs: [WordPair]
    private var currentIndex = 0
    private var isShowingGerman = true
    
    private let instructionLabel = UILabel()
    private let wordLabel = UILabel()
    private let answerField = UITextField()
    private let checkButton = UIButton(type: .system)
    private let feedbackLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let toggleDirectionButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    
    private let audioManager = AudioPronunciationManager.shared
    
    init(listName: String, pairs: [WordPair]) {
        self.listName = listName
        self.pairs = pairs.shuffled()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Practice: \(listName)"
        
        setupUI()
        loadNextWord()
        
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
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        
        wordLabel.font = UIFont.boldSystemFont(ofSize: 24)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
        
        toggleDirectionButton.setTitle("🔄 Switch Direction", for: .normal)
        toggleDirectionButton.addTarget(self, action: #selector(toggleDirection), for: .touchUpInside)
        
        answerField.borderStyle = .roundedRect
        answerField.font = UIFont.systemFont(ofSize: 18)
        answerField.textAlignment = .center
        answerField.placeholder = "Type translation"
        answerField.autocapitalizationType = .none
        answerField.autocorrectionType = .no
        
        checkButton.setTitle("Check", for: .normal)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        
        speakButton.setTitle("🔊 Listen", for: .normal)
        speakButton.addTarget(self, action: #selector(speakWord), for: .touchUpInside)
        
        feedbackLabel.font = UIFont.systemFont(ofSize: 16)
        feedbackLabel.numberOfLines = 0
        feedbackLabel.textAlignment = .center
        
        nextButton.setTitle("Next ➡️", for: .normal)
        nextButton.addTarget(self, action: #selector(nextWord), for: .touchUpInside)
        nextButton.isHidden = true
        
        let buttonStack = UIStackView(arrangedSubviews: [checkButton, speakButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        
        let stack = UIStackView(arrangedSubviews: [
            instructionLabel,
            toggleDirectionButton,
            wordLabel,
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
        wordLabel.textColor = ThemeManager.shared.textColor
        feedbackLabel.textColor = ThemeManager.shared.textColor
        answerField.backgroundColor = ThemeManager.shared.secondaryBackgroundColor
        answerField.textColor = ThemeManager.shared.textColor
    }
    
    @objc private func dismissKeyboard() {
        answerField.resignFirstResponder()
    }
    
    private func loadNextWord() {
        guard !pairs.isEmpty else { return }
        
        currentIndex = Int.random(in: 0..<pairs.count)
        let pair = pairs[currentIndex]
        
        if isShowingGerman {
            instructionLabel.text = "Translate from German to English:"
            wordLabel.text = pair.german
        } else {
            instructionLabel.text = "Translate from English to German:"
            wordLabel.text = pair.english
        }
        
        answerField.text = ""
        feedbackLabel.text = ""
        nextButton.isHidden = true
    }
    
    @objc private func toggleDirection() {
        isShowingGerman = !isShowingGerman
        loadNextWord()
    }
    
    @objc private func checkAnswer() {
        guard !pairs.isEmpty else { return }
        
        let userAnswer = answerField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pair = pairs[currentIndex]
        
        let correctAnswer = isShowingGerman ? pair.english : pair.german
        
        if userAnswer.lowercased() == correctAnswer.lowercased() {
            feedbackLabel.text = "✅ Correct!"
            feedbackLabel.textColor = systemGreen
        } else {
            feedbackLabel.text = "❌ Incorrect.\nCorrect: \(correctAnswer)"
            feedbackLabel.textColor = systemRed
        }
        
        nextButton.isHidden = false
    }
    
    @objc private func speakWord() {
        guard !pairs.isEmpty else { return }
        let pair = pairs[currentIndex]
        audioManager.speakNormal(pair.german)
    }
    
    @objc private func nextWord() {
        loadNextWord()
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
