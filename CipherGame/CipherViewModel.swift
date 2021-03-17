//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle {
    
    //@Published
    private var model : Game = Game()
    
    var currentPuzzle : [CipherPair] {
        
        var puzzle = Array<CipherPair>()
        
        for (index, char) in model.puzzle.enumerated() {
            let newPair = CipherPair(id: index,
                                     cipherLetter: char,
                                     userGuessLetter: plaintext(for: char))
            puzzle.append(newPair)
        }
        
        return puzzle
    }
    
    
    func updateUsersGuesses(cipherCharacter : Character, plaintextCharacter : Character){
        model.usersGuesses[cipherCharacter] = plaintextCharacter
    }
    
    private
    func plaintext(for ciphertext : Character) -> Character?{
        return model.usersGuesses[ciphertext]
    }
    
    
    struct CipherPair : Identifiable {
        
        var id: Int
        
        var cipherLetter : Character
        var userGuessLetter : Character?
    }
    
    
    
}
