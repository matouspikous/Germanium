//
//  Sentence.swift
//  Germanium
//
//  Created by Matouš Pikous on 25/09/2025.
//  Copyright © 2025 Matouš Pikous. All rights reserved.
//

import Foundation

struct Sentence {
    let english: String
    let german: String
}

class SentenceProvider {
    static func loadSentences() -> [Sentence] {
        guard let url = Bundle.main.url(forResource: "sentences", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return [
                Sentence(english: "How are you?", german: "Wie geht es dir?"),
                Sentence(english: "I like apples.", german: "Ich mag Äpfel."),
                Sentence(english: "She is reading a book.", german: "Sie liest ein Buch.")
            ]
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let parts = line.components(separatedBy: ";")
            if parts.count == 2 {
                return Sentence(english: parts[1].trimmingCharacters(in: .whitespaces),
                                german: parts[0].trimmingCharacters(in: .whitespaces))
            }
            return nil
        }
    }
}
