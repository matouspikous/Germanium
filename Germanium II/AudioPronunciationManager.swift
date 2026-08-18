//
//  AudioPronunciationManager.swift
//  Germanium
//
//  Handles text-to-speech for German pronunciation (Features 4 & 5)
//  Uses AVSpeechSynthesizer which works offline on iOS 12+
//

import AVFoundation

class AudioPronunciationManager {
    static let shared = AudioPronunciationManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var germanVoice: AVSpeechSynthesisVoice?
    
    private init() {
        // Try to find a German voice
        let voices = AVSpeechSynthesisVoice.speechVoices()
        germanVoice = voices.first { $0.language.hasPrefix("de") }
        
        // Fallback to any German voice identifier
        if germanVoice == nil {
            germanVoice = AVSpeechSynthesisVoice(language: "de-DE")
        }
    }
    
    /// Speaks the given German text
    func speak(_ text: String, rate: Float = 0.45) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = germanVoice
        utterance.rate = rate  // Slower for learning (0.0 to 1.0, default ~0.5)
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    /// Speaks text slowly for dictation practice
    func speakSlowly(_ text: String) {
        speak(text, rate: 0.35)
    }
    
    /// Speaks text at normal speed
    func speakNormal(_ text: String) {
        speak(text, rate: 0.5)
    }
    
    /// Stop speaking
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    /// Check if currently speaking
    var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }
    
    /// Check if German voice is available
    var hasGermanVoice: Bool {
        return germanVoice != nil
    }
}
