//
//  HomeViewController.swift
//  Germanium
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    
    private let categories: [(title: String, subtitle: String, action: Selector)] = [
        //("Writing Practice", "Translate sentences", #selector(openWriting)),
        ("🧩 Word Ordering", "Arrange words correctly", #selector(openOrdering)),
        //("Tense Practice", "Convert between tenses", #selector(openTenses)),
        //("Verb Practice", "Master verb conjugations", #selector(openVerbs)),
        ("🧠 Word Families", "Learn morphological relations", #selector(openWordFamilies)),
        ("🔁 Word Matching", "Match German-English pairs", #selector(openWordMatching)),
        //("🔊 Audio Practice", "Listen and type (Dictation)", #selector(openListening)),
        //("📝 Fill in the Blank", "Complete sentences", #selector(openFillInBlank)),
        //("📖 Reading Comprehension", "Read passages & answer", #selector(openReading)),
        //("🎯 Case Practice", "Akkusativ/Dativ/Genitiv", #selector(openCasePractice)),
        ("📚 Synonyms & Antonyms", "Expand vocabulary", #selector(openSynonymsAntonyms)),
        //("🏗️ Sentence Building", "Construct sentences", #selector(openSentenceBuilding)),
        //("📐 Adjective Declension", "Practice endings", #selector(openAdjectiveDeclension)),
        ("🔤 Article Practice", "Der/Die/Das", #selector(openArticlePractice)),
        //("📋 Custom Word Lists", "Your own vocabulary", #selector(openCustomLists)),
        ("⚙️ Settings", "Dark mode & preferences", #selector(openSettings))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Germanium"
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
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
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ThemeManager.shared.textColor]
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.barStyle = ThemeManager.shared.isDarkMode ? .black : .default
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        cell.detailTextLabel?.text = category.subtitle
        cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = ThemeManager.shared.backgroundColor
        cell.textLabel?.textColor = ThemeManager.shared.textColor
        cell.detailTextLabel?.textColor = ThemeManager.shared.textColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = categories[indexPath.row]
        perform(category.action)
    }
    
    // MARK: - Navigation (Existing)
    
    @objc private func openWriting() {
        let vc = CategorySelectionViewController(mode: .writing)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openOrdering() {
        let vc = CategorySelectionViewController(mode: .ordering)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openTenses() {
        let vc = TensePracticeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openVerbs() {
        let vc = VerbPracticeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openWordFamilies() {
        let vc = WordFamilyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openWordMatching() {
        let vc = WordMatchingCategoryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Navigation (New Features)
    
    @objc private func openListening() {
        let vc = ListeningPracticeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openFillInBlank() {
        let vc = FillInBlankViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openReading() {
        let vc = ReadingComprehensionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openCasePractice() {
        let vc = CasePracticeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openSynonymsAntonyms() {
        let vc = SynonymAntonymViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openSentenceBuilding() {
        let vc = SentenceBuildingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openAdjectiveDeclension() {
        let vc = AdjectiveDeclensionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openArticlePractice() {
        let vc = ArticlePracticeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openCustomLists() {
        let vc = CustomWordListsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
