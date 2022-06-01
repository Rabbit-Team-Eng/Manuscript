//
//  RandomWordGenerator.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/30/22.
//

import Foundation

public struct Word {
    public let word: String
    public let definition: String
}

class RandomWordGenerator {

    private var words: [Word] = []
    
    public static let shared: RandomWordGenerator = RandomWordGenerator()
    
    private init() {
        fillInTheLocalMemoryWithWords()
    }
    
    func getWord() -> Word {
        let index = Int.random(in: 1..<words.count - 1)
        return words[index]
    }
    
    
    private func fillInTheLocalMemoryWithWords() {
        if let jsonData = readFile(forName: "words") {
            
            do {
                let decodedData = try JSONDecoder().decode(Dictionary<String, String>.self, from: jsonData)
                
                decodedData.forEach { it in
                    words.append(Word(word: it.key, definition: it.value))
                }
                return
            
            } catch { }
        }
    }
    
    private func readFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"), let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }
}
