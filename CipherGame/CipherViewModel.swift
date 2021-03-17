//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle : ObservableObject {
    
    @Published
    private var model : Game = Game()
    
    var usersGuess : Dictionary<Character, Character> = {
        
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        var output = Dictionary<Character, Character>()
        
        for char in alphabet {
            output[char] = nil
        }
        
        return output
    }()
    
    
    var currentPuzzle : [CipherPair] {
        
        var puzzle = Array<CipherPair>()
        
        for (index, char) in model.puzzle.enumerated() {
            let newPair = CipherPair(id: index, cipherLetter: char, userGuessLetter: nil)
            puzzle.append(newPair)
        }
        
        return puzzle
        
    }
    
    
    struct CipherPair : Identifiable {
        
        var id: Int
        
        var cipherLetter : Character
        var userGuessLetter : Character?
    }
    
    
    
}
