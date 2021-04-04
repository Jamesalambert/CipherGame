//
//  CipherPuzzle+Difficulty.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import Foundation

extension CipherPuzzle {
    
    //MARK:- difficulty
    
    var gameRules : [ Int : (Character, Int) -> GameInfo?]{
        return [0 : easyGameInfo,
                1 : mediumGameInfo,
                2 : hardGameInfo]
    }
    
    
    
    
    private
    func easyGameInfo(for ciphertext : Character, at index : Int) -> GameInfo? {
        
        let newPair = GameInfo(id: index,
                               cipherLetter: ciphertext,
                               userGuessLetter: plaintext(for: ciphertext))
        return newPair
    }
    
    
    
    
    
    private
    func mediumGameInfo(for ciphertext : Character, at index: Int) -> GameInfo? {
                
        if String.alphabet.contains(ciphertext) {
            return easyGameInfo(for: ciphertext, at: index)
        }
        
        return nil
    }
    
    
    
    
    
    
    private
    func hardGameInfo(for ciphertext : Character, at index: Int) -> GameInfo? {
        
        var mediumLevel = mediumGameInfo(for: ciphertext, at: index)
        
        if let guessIndices = currentPuzzle.guessIndices[String(ciphertext)] {
            if guessIndices.containsItem(within: 20, of: index){
                return mediumLevel
            }
        }
        
        //not close to the user's guess index
        mediumLevel?.userGuessLetter = nil
        return mediumLevel
    }
    

}

