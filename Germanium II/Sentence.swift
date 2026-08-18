//
//  Sentence.swift
//  Germanium
//

import Foundation

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
