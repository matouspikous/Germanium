//
//  DataProvider.swift
//  Germanium
//

import Foundation

class DataProvider {
    
    static func loadSentences(from filename: String) -> [Sentence] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 2 {
                return Sentence(english: parts[1].trimmingCharacters(in: .whitespaces),
                                german: parts[0].trimmingCharacters(in: .whitespaces))
            }
            return nil
        }
    }
    
    static func loadTenseSentences() -> [TenseSentence] {
        guard let url = Bundle.main.url(forResource: "tense_sentences", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 5 {
                return TenseSentence(
                    present: parts[0].trimmingCharacters(in: .whitespaces),
                    pastPerfect: parts[1].trimmingCharacters(in: .whitespaces),
                    future: parts[2].trimmingCharacters(in: .whitespaces),
                    pastSimple: parts[3].trimmingCharacters(in: .whitespaces),
                    english: parts[4].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    static func loadVerbs() -> [VerbPractice] {
        guard let url = Bundle.main.url(forResource: "verb_practice", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 5 {
                return VerbPractice(
                    infinitive: parts[0].trimmingCharacters(in: .whitespaces),
                    past: parts[1].trimmingCharacters(in: .whitespaces),
                    perfect: parts[2].trimmingCharacters(in: .whitespaces),
                    preposition: parts[3].trimmingCharacters(in: .whitespaces),
                    english: parts[4].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    static func loadWordFamilies() -> [WordFamily] {
        guard let url = Bundle.main.url(forResource: "morphology", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            guard parts.count >= 3, parts.count % 2 == 1 else { return nil }
            
            let stem = parts[0].trimmingCharacters(in: .whitespaces)
            var pairs: [(german: String, english: String)] = []
            
            for i in stride(from: 1, to: parts.count, by: 2) {
                let german = parts[i].trimmingCharacters(in: .whitespaces)
                let english = parts[i+1].trimmingCharacters(in: .whitespaces)
                pairs.append((german: german, english: english))
            }
            
            return WordFamily(stem: stem, pairs: pairs)
        }
    }
    
    static func loadWordPairs(from filename: String) -> [WordPair] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 2 {
                return WordPair(
                    german: parts[0].trimmingCharacters(in: .whitespaces),
                    english: parts[1].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    // MARK: - New Data Loaders
    
    // Load nouns with gender for Article Practice (Feature 6)
    // Format: noun;gender;english
    // Example: Haus;das;house
    static func loadNounsWithGender() -> [GenderedNoun] {
        guard let url = Bundle.main.url(forResource: "nouns_gender", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 3 {
                return GenderedNoun(
                    noun: parts[0].trimmingCharacters(in: .whitespaces),
                    gender: parts[1].trimmingCharacters(in: .whitespaces),
                    english: parts[2].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    // Load fill-in-the-blank sentences (Feature 8)
    // Format: sentence_with_blank;answer;hint
    // Example: Ich ___ nach Hause.;gehe;verb for "go"
    static func loadFillInBlank() -> [FillInBlankItem] {
        guard let url = Bundle.main.url(forResource: "fill_blank", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count >= 2 {
                let hint = parts.count >= 3 ? parts[2].trimmingCharacters(in: .whitespaces) : ""
                return FillInBlankItem(
                    sentenceWithBlank: parts[0].trimmingCharacters(in: .whitespaces),
                    answer: parts[1].trimmingCharacters(in: .whitespaces),
                    hint: hint
                )
            }
            return nil
        }
    }
    
    // Load sentence building components (Feature 16)
    // Format: subject;verb;object;correct_sentence;english
    // Example: Ich;kaufen;ein Buch;Ich kaufe ein Buch.;I buy a book.
    static func loadSentenceComponents() -> [SentenceComponent] {
        guard let url = Bundle.main.url(forResource: "sentence_building", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 5 {
                return SentenceComponent(
                    subject: parts[0].trimmingCharacters(in: .whitespaces),
                    verb: parts[1].trimmingCharacters(in: .whitespaces),
                    object: parts[2].trimmingCharacters(in: .whitespaces),
                    correctSentence: parts[3].trimmingCharacters(in: .whitespaces),
                    english: parts[4].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    // Load synonyms/antonyms (Feature 17)
    // Format: word;synonym_or_antonym;type;english_word;english_related
    // Example: groß;klein;antonym;big;small
    static func loadSynonymsAntonyms() -> [SynonymAntonymPair] {
        guard let url = Bundle.main.url(forResource: "synonyms_antonyms", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 5 {
                return SynonymAntonymPair(
                    word: parts[0].trimmingCharacters(in: .whitespaces),
                    relatedWord: parts[1].trimmingCharacters(in: .whitespaces),
                    type: parts[2].trimmingCharacters(in: .whitespaces),
                    englishWord: parts[3].trimmingCharacters(in: .whitespaces),
                    englishRelated: parts[4].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    // Load reading passages (Feature 18)
    // Format in file: Each passage separated by "---"
    // First line: title
    // Following lines until questions marker "??": passage text
    // After "??": question;answer pairs
    static func loadReadingPassages() -> [ReadingPassage] {
        guard let url = Bundle.main.url(forResource: "reading_passages", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        
        let passages = content.components(separatedBy: "---")
        return passages.compactMap { passageText in
            let trimmed = passageText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            
            let questionSplit = trimmed.components(separatedBy: "??")
            guard questionSplit.count == 2 else { return nil }
            
            let textPart = questionSplit[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let questionsPart = questionSplit[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            let textLines = textPart.components(separatedBy: "\n")
            guard textLines.count >= 2 else { return nil }
            
            let title = textLines[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let passage = textLines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            
            let questionLines = questionsPart.components(separatedBy: "\n")
            var questions: [(question: String, answer: String)] = []
            
            for qLine in questionLines {
                let qTrimmed = qLine.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !qTrimmed.isEmpty else { continue }
                let qParts = qTrimmed.components(separatedBy: ";")
                if qParts.count == 2 {
                    questions.append((
                        question: qParts[0].trimmingCharacters(in: .whitespaces),
                        answer: qParts[1].trimmingCharacters(in: .whitespaces)
                    ))
                }
            }
            
            guard !questions.isEmpty else { return nil }
            
            return ReadingPassage(title: title, passage: passage, questions: questions)
        }
    }
    
    // Load adjective declension exercises (Feature 20)
    // Format: adjective;gender;case;article_type;correct_form;noun;english
    // Example: groß;m;nom;def;große;Mann;the tall man
    static func loadAdjectiveDeclension() -> [AdjectiveDeclensionItem] {
        guard let url = Bundle.main.url(forResource: "adjective_declension", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 7 {
                return AdjectiveDeclensionItem(
                    adjective: parts[0].trimmingCharacters(in: .whitespaces),
                    gender: parts[1].trimmingCharacters(in: .whitespaces),
                    grammaticalCase: parts[2].trimmingCharacters(in: .whitespaces),
                    articleType: parts[3].trimmingCharacters(in: .whitespaces),
                    correctForm: parts[4].trimmingCharacters(in: .whitespaces),
                    noun: parts[5].trimmingCharacters(in: .whitespaces),
                    english: parts[6].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    // Load case practice sentences (Feature 7)
    // Format: sentence_with_blank;correct_article;case;preposition;english
    // Example: Ich gehe zu ___ Arzt.;dem;Dativ;zu;I go to the doctor.
    static func loadCasePractice() -> [CasePracticeItem] {
        guard let url = Bundle.main.url(forResource: "case_practice", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 5 {
                return CasePracticeItem(
                    sentenceWithBlank: parts[0].trimmingCharacters(in: .whitespaces),
                    correctArticle: parts[1].trimmingCharacters(in: .whitespaces),
                    grammaticalCase: parts[2].trimmingCharacters(in: .whitespaces),
                    preposition: parts[3].trimmingCharacters(in: .whitespaces),
                    english: parts[4].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    // MARK: - Custom Word List Management (Feature 14)
    
    static func getCustomWordListsDirectory() -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let customListsDir = documentsURL.appendingPathComponent("CustomWordLists")
        
        if !fileManager.fileExists(atPath: customListsDir.path) {
            try? fileManager.createDirectory(at: customListsDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return customListsDir
    }
    
    static func getCustomWordListNames() -> [String] {
        guard let dir = getCustomWordListsDirectory() else { return [] }
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: dir.path)
            return files.filter { $0.hasSuffix(".txt") }.map { String($0.dropLast(4)) }
        } catch {
            return []
        }
    }
    
    static func loadCustomWordList(named name: String) -> [WordPair] {
        guard let dir = getCustomWordListsDirectory() else { return [] }
        let fileURL = dir.appendingPathComponent("\(name).txt")
        
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }
        
        return content.components(separatedBy: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let parts = trimmed.components(separatedBy: ";")
            if parts.count == 2 {
                return WordPair(
                    german: parts[0].trimmingCharacters(in: .whitespaces),
                    english: parts[1].trimmingCharacters(in: .whitespaces)
                )
            }
            return nil
        }
    }
    
    static func saveCustomWordList(named name: String, pairs: [WordPair]) -> Bool {
        guard let dir = getCustomWordListsDirectory() else { return false }
        let fileURL = dir.appendingPathComponent("\(name).txt")
        
        let content = pairs.map { "\($0.german);\($0.english)" }.joined(separator: "\n")
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    static func deleteCustomWordList(named name: String) -> Bool {
        guard let dir = getCustomWordListsDirectory() else { return false }
        let fileURL = dir.appendingPathComponent("\(name).txt")
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    static func addWordToCustomList(named name: String, german: String, english: String) -> Bool {
        var pairs = loadCustomWordList(named: name)
        pairs.append(WordPair(german: german, english: english))
        return saveCustomWordList(named: name, pairs: pairs)
    }
}
