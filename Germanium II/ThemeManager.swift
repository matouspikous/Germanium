//
//  ThemeManager.swift
//  Germanium
//

import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    var isDarkMode: Bool {
        get { return UserDefaults.standard.bool(forKey: "darkMode") }
        set {
            UserDefaults.standard.set(newValue, forKey: "darkMode")
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
    
    var backgroundColor: UIColor {
        return isDarkMode ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) : .white
    }
    
    var textColor: UIColor {
        return isDarkMode ? .white : .black
    }
    
    var secondaryBackgroundColor: UIColor {
        return isDarkMode ? UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    }
    
    var borderColor: UIColor {
        return isDarkMode ? UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) : .lightGray
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}
