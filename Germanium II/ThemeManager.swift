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
        return isDarkMode
            ? UIColor(red: 0.00, green: 0.00, blue: 0.05, alpha: 1.0)   // was 0.15 — noticeably darker
            : UIColor(red: 0.95, green: 0.90, blue: 0.90, alpha: 1.0)   // was .white — warm off-white
    }
    
    var textColor: UIColor {
        return isDarkMode ? .white : .black
    }
    
    var secondaryBackgroundColor: UIColor {
        return isDarkMode
            ? UIColor(red: 0.17, green: 0.17, blue: 0.19, alpha: 1.0)   // was 0.25
            : .white                                                     // was 0.95 gray
    }
    
    var borderColor: UIColor {
        return isDarkMode ? UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) : .lightGray
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}
