//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle : ObservableObject {
    
    static let blank : Character = "_"
    
    @Published
    private
    var model : Game = Game()
    
    private
    func plaintext(for ciphertext : Character, in puzzle : String) -> Character?{
        
        guard let currentPuzzle = model.puzzles.first(where: {$0.title == puzzle}) else {return nil}
        
        return currentPuzzle.usersGuesses[ciphertext]
    }
    
    
    
    //MARK: - public API
    var availablePuzzles : [PuzzleTitle] {
        
        var out : [PuzzleTitle] = []
        for (index, puzzle) in model.puzzles.enumerated() {
            out.append(PuzzleTitle(id: index,
                                   title: puzzle.title))
        }
        return out
    }
    
    @Published
    var currentPuzzle : String? = "space"
    var currentCiphertextCharacter : Character? = nil
    var userGuess : Character? {
        
        get {
            return CipherPuzzle.blank
        }
        
        set {
            model.updateUsersGuesses(cipherCharacter: currentCiphertextCharacter!,
                                     plaintextCharacter: newValue ?? CipherPuzzle.blank,
                                     in: currentPuzzle!)
        }
    }
    
    var data : [GameInfo] {
        
        guard let currentPuzzleTitle = self.currentPuzzle else {return []}
        guard let currentPuzzle = model.puzzles.first(where: {$0.title == currentPuzzleTitle}) else {return []}
        
        
        var puzzleData = Array<GameInfo>()
        
        for (index, char) in currentPuzzle.ciphertext.enumerated() {
            let newPair = GameInfo(id: index,
                                     cipherLetter: char,
                                     userGuessLetter: plaintext(for: char, in: currentPuzzleTitle))
            puzzleData.append(newPair)
        }
        
        return puzzleData
    }
    
    func updateUsersGuesses(cipherCharacter : Character, plaintextCharacter : Character, in puzzle : String){
        model.updateUsersGuesses(cipherCharacter: cipherCharacter, plaintextCharacter: plaintextCharacter, in: puzzle)
    }
    
    
    
    //MARK:-
    
    
    
    struct PuzzleTitle : Identifiable, Hashable {
        var id : Int
        var title : String
    }
    
}

struct GameInfo : Identifiable {
    
    var id: Int
    
    var cipherLetter : Character
    var userGuessLetter : Character?
}
