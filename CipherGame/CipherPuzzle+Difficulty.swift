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
    
    var hintFunction : [Int : () -> Character?]{
        return [0 : easyHintChar,
                1 : hardHintChar,
                2 : hardHintChar]
    }
    
    func quickHint() -> Void {
        
        let alphabet = String.alphabet.map{Character(extendedGraphemeClusterLiteral: $0)}
        
        //dict that maps ciphertext to plaintext
        let plaintextFor = Dictionary(uniqueKeysWithValues: zip(currentPuzzle.keyAlphabet.map{Character(extendedGraphemeClusterLiteral: $0)}, alphabet))

        //get alphabetically first unguessed cipher char
        guard let firstUnguessedCipherChar = hintFunction[Int(difficultyLevel)]?() else {return}
        
        //get location of first occurance of the ciphertext char
        guard let indexInCiphertext = currentPuzzle.ciphertext.firstIndex(of: firstUnguessedCipherChar) else {return}
        
        //the answer we'll give to the user
        let hintSolution = plaintextFor[firstUnguessedCipherChar]
        
        //where it will be substituted into the puzzle
        let hintIndex = currentPuzzle.ciphertext.distance(from: currentPuzzle.ciphertext.startIndex,
                                                                to: indexInCiphertext)
        
        //update model.
        model.updateUsersGuesses(cipherCharacter: firstUnguessedCipherChar,
                                 plaintextCharacter: hintSolution,
                                 in: currentPuzzle,
                                 at: hintIndex)
    }
    
    
    private
    func easyHintChar() -> Character? {
        //chars that occur in the cipher arranged alphabetically
        let cipherLetters = self.letterCount.filter{$0.count != 0}.sorted(by: {$0.count > $1.count}).map{$0.character}
    
        //get numerically first unguessed cipher char
        guard let firstUnguessedCipherChar = cipherLetters.first(where: {!currentPuzzle.usersGuesses.keys.contains(String($0))}) else {return nil}
        
        return firstUnguessedCipherChar
    }
    
    private
    func hardHintChar() -> Character? {
        //chars that occur in the cipher arranged alphabetically
        let cipherLetters = self.letterCount.filter{$0.count != 0}.map{$0.character}.sorted(by: {$0 < $1})
    
        //get alphabetically first unguessed cipher char
        guard let firstUnguessedCipherChar = cipherLetters.first(where: {!currentPuzzle.usersGuesses.keys.contains(String($0))}) else {return nil}
        
        return firstUnguessedCipherChar
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

