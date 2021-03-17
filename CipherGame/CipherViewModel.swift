//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle {
    
    //@Published
    private
    var model : Game = Game()
    
    private
    func plaintext(for ciphertext : Character) -> Character?{
        return model.usersGuesses[ciphertext]
    }
    
    //MARK: - public API
    
    
    var availablePuzzles : [String] {
        var out : [String] = []
        
        for key in model.puzzles.keys {
            out.append(String(key))
        }
        
        return out
    }
    
    var currentPuzzleTitle : String = "space"
    
    var currentPuzzle : [CipherPair] {
        
        guard let currentPuzzle = model.puzzles[currentPuzzleTitle] else {return []}
        
        
        var puzzleData = Array<CipherPair>()
        
        for (index, char) in currentPuzzle.enumerated() {
            let newPair = CipherPair(id: index,
                                     cipherLetter: char,
                                     userGuessLetter: plaintext(for: char))
            puzzleData.append(newPair)
        }
        
        return puzzleData
    }
    
    
    func updateUsersGuesses(cipherCharacter : Character, plaintextCharacter : Character){
        model.usersGuesses[cipherCharacter] = plaintextCharacter
    }
    
    
    
    //MARK:-
    
    struct CipherPair : Identifiable {
        
        var id: Int
        
        var cipherLetter : Character
        var userGuessLetter : Character?
    }
    
    
    
}
