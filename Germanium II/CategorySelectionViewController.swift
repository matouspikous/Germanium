//
//  CategorySelectionViewController.swift
//  Germanium
//

import UIKit

enum PracticeMode {
    case writing
    case ordering
}

class CategorySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private let mode: PracticeMode
    
    private let categories: [(title: String, filename: String)] = [
        ("All Sentences", "sentences"),
        ("A1 Level", "a1_sentences"),
        ("A2 Level", "a2_sentences"),
        ("B1 Level", "b1_sentences"),
        ("B2 Level", "b2_sentences"),
        ("C1 Level", "c1_sentences"),
        ("C2 Level", "c2_sentences"),
        //("Food & Dining", "food"),
        ("Restaurant", "restaurant"),
        //("School", "school"),
        ("Conversation", "conversation")
    ]
    
    init(mode: PracticeMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = mode == .writing ? "Writing Categories" : "Ordering Categories"
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
        tableView.reloadData()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = ThemeManager.shared.backgroundColor
        cell.textLabel?.textColor = ThemeManager.shared.textColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = categories[indexPath.row]
        
        if mode == .writing {
            let vc = WritingViewController(filename: category.filename)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = OrderingViewController(filename: category.filename)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
