//
//  SettingsViewController.swift
//  Germanium
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let darkModeSwitch = UISwitch()
    private let resetStatsButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        darkModeSwitch.isOn = ThemeManager.shared.isDarkMode
        darkModeSwitch.addTarget(self, action: #selector(darkModeToggled), for: .valueChanged)
        
        let darkModeLabel = UILabel()
        darkModeLabel.text = "Dark Mode"
        darkModeLabel.font = UIFont.systemFont(ofSize: 16)
        
        let darkModeStack = UIStackView(arrangedSubviews: [darkModeLabel, darkModeSwitch])
        darkModeStack.axis = .horizontal
        darkModeStack.spacing = 16
        
        resetStatsButton.setTitle("Reset Mistake Tracking", for: .normal)
        resetStatsButton.addTarget(self, action: #selector(resetStats), for: .touchUpInside)
        
        let infoLabel = UILabel()
        infoLabel.text = "Germanium is a privacy-focused German learning app. No data is collected or sent to the internet."
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [darkModeStack, resetStatsButton, infoLabel])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
            ])
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        
        for view in view.subviews {
            if let stackView = view as? UIStackView {
                applyThemeToStackView(stackView)
            }
        }
    }
    
    private func applyThemeToStackView(_ stackView: UIStackView) {
        for view in stackView.arrangedSubviews {
            if let label = view as? UILabel {
                label.textColor = ThemeManager.shared.textColor
            } else if let nestedStack = view as? UIStackView {
                applyThemeToStackView(nestedStack)
            }
        }
    }
    
    @objc private func darkModeToggled() {
        ThemeManager.shared.isDarkMode = darkModeSwitch.isOn
    }
    
    @objc private func resetStats() {
        let alert = UIAlertController(
            title: "Reset Statistics",
            message: "This will clear all mistake tracking. Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            UserDefaults.standard.removeObject(forKey: "mistakeTracking")
            let confirmAlert = UIAlertController(
                title: "Reset Complete",
                message: "All mistake tracking has been cleared.",
                preferredStyle: .alert
            )
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(confirmAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}
