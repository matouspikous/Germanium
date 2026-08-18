//
//  MistakeTracker.swift
//  Germanium
//

import Foundation

class MistakeTracker {
    static let shared = MistakeTracker()
    private let defaults = UserDefaults.standard
    private let mistakeKey = "mistakeTracking"
    
    private var mistakes: [String: Int] {
        get { return defaults.dictionary(forKey: mistakeKey) as? [String: Int] ?? [:] }
        set { defaults.set(newValue, forKey: mistakeKey) }
    }
    
    func recordMistake(for identifier: String) {
        var current = mistakes
        current[identifier] = (current[identifier] ?? 0) + 1
        mistakes = current
    }
    
    func getMistakeCount(for identifier: String) -> Int {
        return mistakes[identifier] ?? 0
    }
    
    func shouldRepeat(for identifier: String) -> Bool {
        let count = getMistakeCount(for: identifier)
        if count > 0 {
            return Int.random(in: 1...100) <= 30 // 30% chance
        }
        return false
    }
    
    func decrementMistake(for identifier: String) {
        var current = mistakes
        if let count = current[identifier], count > 0 {
            current[identifier] = count - 1
        }
        mistakes = current
    }
}
