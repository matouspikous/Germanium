//
//  CategorySelectionViewController.swift
//  Germanium
//

import UIKit

enum PracticeMode {
    case writing
    case ordering
}

/// A row is either a sentence file (opens Writing/Ordering) or a sub-list of rows.
enum CategoryEntry {
    case file(title: String, filename: String)
    case group(title: String, entries: [CategoryEntry])

    var title: String {
        switch self {
        case .file(let title, _): return title
        case .group(let title, _): return title
        }
    }
}

class CategorySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private let mode: PracticeMode
    private let entries: [CategoryEntry]
    private let customTitle: String?

    // MARK: - Content

    static let rootEntries: [CategoryEntry] = [
        .file(title: "All Sentences", filename: "sentences"),
        .file(title: "A1 Level", filename: "a1_sentences"),
        .file(title: "A2 Level", filename: "a2_sentences"),
        .file(title: "B1 Level", filename: "b1_sentences"),
        .file(title: "B2 Level", filename: "b2_sentences"),
        .file(title: "C1 Level", filename: "c1_sentences"),
        .file(title: "C2 Level", filename: "c2_sentences"),
        //.file(title: "Food & Dining", filename: "food"),
        .file(title: "Restaurant", filename: "restaurant"),
        //.file(title: "School", filename: "school"),
        .file(title: "Conversation", filename: "conversation"),
        .group(title: "Grammar", entries: CategorySelectionViewController.grammarEntries)
    ]

    static let grammarEntries: [CategoryEntry] = [
        .file(title: "Genitive", filename: "genitive"),
        .file(title: "Passiv", filename: "passiv"),
        .file(title: "Präteritum", filename: "praeteritum"),
        .file(title: "Konjunktiv II", filename: "konjunktivII"),
        .file(title: "Futur II", filename: "futurII"),
        .file(title: "Indirect speech", filename: "indirectSpeech"),
        .file(title: "Subjunctions and connectors", filename: "subjunctionsAndConnectors"),
        .file(title: "Participial attribute", filename: "participialAttribute"),
        .file(title: "Falsch machen", filename: "falschMachen")
    ]
    
    // MARK: - Init

    init(mode: PracticeMode,
         entries: [CategoryEntry] = CategorySelectionViewController.rootEntries,
         title: String? = nil) {
        self.mode = mode
        self.entries = entries
        self.customTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = customTitle ?? (mode == .writing ? "Writing Categories" : "Ordering Categories")
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
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = entries[indexPath.row].title
        cell.accessoryType = .disclosureIndicator

        cell.backgroundColor = ThemeManager.shared.backgroundColor
        cell.textLabel?.textColor = ThemeManager.shared.textColor

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch entries[indexPath.row] {
        case .group(let title, let subEntries):
            let vc = CategorySelectionViewController(mode: mode, entries: subEntries, title: title)
            navigationController?.pushViewController(vc, animated: true)

        case .file(_, let filename):
            if mode == .writing {
                let vc = WritingViewController(filename: filename)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = OrderingViewController(filename: filename)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
