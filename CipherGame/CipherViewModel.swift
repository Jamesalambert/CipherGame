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
    
    @Published
    var currentPuzzleTitle : String? = "space"
    
    var currentPuzzle : Puzzle? {
        guard let currentPuzzleTitle = self.currentPuzzleTitle else {return nil}
        guard let currentPuzzle = model.puzzles.first(where: {$0.title == currentPuzzleTitle}) else {return nil}
        return currentPuzzle
    }
    
    @Published
    var currentCiphertextCharacter : Character? = nil
    
    
    //MARK: - public API
    var availablePuzzles : [PuzzleTitle] {
        
        var out : [PuzzleTitle] = []
        for (index, puzzle) in model.puzzles.enumerated() {
            out.append(PuzzleTitle(id: index,
                                   title: puzzle.title))
        }
        return out
    }
    
    
    var userGuess : Character? {
        
        get {
            guard let current = currentCiphertextCharacter else {return nil}
            return self.plaintext(for: current)
        }
        
        set {
            model.updateUsersGuesses(cipherCharacter: currentCiphertextCharacter!,
                                     plaintextCharacter: newValue ?? CipherPuzzle.blank,
                                     in: currentPuzzleTitle!)
        }
    }
    
    var data : [GameInfo] {
     
        guard self.currentPuzzle != nil else {return []}
        
        var puzzleData = Array<GameInfo>()
        
        for (index, char) in self.currentPuzzle!.ciphertext.enumerated() {
            let newPair = GameInfo(id: index,
                                   cipherLetter: char,
                                   userGuessLetter: plaintext(for: char))
            puzzleData.append(newPair)
        }
        
        return puzzleData
    }
    
    var letterCount : [(Character, Int)] {return currentPuzzle?.letterCount() ?? []}
    
    
    //MARK:-
    
    private
    func updateUsersGuesses(cipherCharacter : Character, plaintextCharacter : Character, in puzzle : String){
        model.updateUsersGuesses(cipherCharacter: cipherCharacter, plaintextCharacter: plaintextCharacter, in: puzzle)
    }
    
    private
    func plaintext(for ciphertext : Character) -> Character?{
                
        return currentPuzzle!.usersGuesses[ciphertext]
    }
    
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
