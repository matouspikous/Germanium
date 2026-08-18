//
//  Models.swift
//  Germanium
//

import Foundation

// MARK: - Existing Models

struct Sentence {
    let english: String
    let german: String
}

struct TenseSentence {
    let present: String
    let pastPerfect: String
    let future: String
    let pastSimple: String
    let english: String
}

struct VerbPractice {
    let infinitive: String
    let past: String
    let perfect: String
    let preposition: String
    let english: String
}

struct WordFamily {
    let stem: String
    let pairs: [(german: String, english: String)]
}

struct WordPair {
    let german: String
    let english: String
}

// MARK: - New Models for Added Features

// Feature 6: Gender/Article Practice
struct GenderedNoun {
    let noun: String      // e.g., "Haus"
    let gender: String    // "der", "die", or "das"
    let english: String   // e.g., "house"
}

// Feature 7: Case Practice
struct CasePracticeItem {
    let sentenceWithBlank: String   // e.g., "Ich gehe zu ___ Arzt."
    let correctArticle: String      // e.g., "dem"
    let grammaticalCase: String     // "Nominativ", "Akkusativ", "Dativ", "Genitiv"
    let preposition: String         // e.g., "zu"
    let english: String             // e.g., "I go to the doctor."
}

// Feature 8: Fill-in-the-Blank
struct FillInBlankItem {
    let sentenceWithBlank: String   // e.g., "Ich ___ nach Hause."
    let answer: String              // e.g., "gehe"
    let hint: String                // e.g., "verb for 'go'"
}

// Feature 16: Sentence Building
struct SentenceComponent {
    let subject: String             // e.g., "Ich"
    let verb: String                // e.g., "kaufen" (infinitive)
    let object: String              // e.g., "ein Buch"
    let correctSentence: String     // e.g., "Ich kaufe ein Buch."
    let english: String             // e.g., "I buy a book."
}

// Feature 17: Synonyms/Antonyms
struct SynonymAntonymPair {
    let word: String                // e.g., "groß"
    let relatedWord: String         // e.g., "klein"
    let type: String                // "synonym" or "antonym"
    let englishWord: String         // e.g., "big"
    let englishRelated: String      // e.g., "small"
}

// Feature 18: Reading Comprehension
struct ReadingPassage {
    let title: String
    let passage: String
    let questions: [(question: String, answer: String)]
}

// Feature 20: Adjective Declension
struct AdjectiveDeclensionItem {
    let adjective: String           // base form, e.g., "groß"
    let gender: String              // "m", "f", "n", "pl"
    let grammaticalCase: String     // "nom", "akk", "dat", "gen"
    let articleType: String         // "def" (definite), "indef" (indefinite), "none"
    let correctForm: String         // e.g., "große"
    let noun: String                // e.g., "Mann"
    let english: String             // e.g., "the tall man"
}
