//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle : ObservableObject {
    
    //static let blank : Character = " "
    
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
    
    @Published
    var currentUserSelectionIndex : Int? = nil
    
    @Published
    var gameLevel : Int = 0 {
        didSet{
            if gameLevel > gameRules.count {
                gameLevel = gameRules.count - 1
            } else if gameLevel < 0 {
                gameLevel = 0
            }
        }
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
    
    
    var userGuess : Character? {
        
        get {
            guard let current = currentCiphertextCharacter else {return nil}
            return self.plaintext(for: current)
        }
        
        set {
            guard let newValue = newValue else {return}
            
            model.updateUsersGuesses(cipherCharacter: currentCiphertextCharacter!,
                                     plaintextCharacter: newValue,
                                     in: currentPuzzleTitle!,
                                     at: currentUserSelectionIndex!)
        }
    }
    
    var data : [GameInfo] {
     
        guard self.currentPuzzle != nil else {return []}
        
        var puzzleData = Array<GameInfo>()
        
        for (index, char) in self.currentPuzzle!.ciphertext.enumerated() {
            
            if let newPair = gameRules[gameLevel]?(char, index) {
                puzzleData.append(newPair)
            }
        }
        
        return puzzleData
    }
    
    var letterCount : [(Character, Int)] {return currentPuzzle?.letterCount() ?? []}
    
    func plaintext(for ciphertext : Character) -> Character?{
                
        return currentPuzzle!.usersGuesses[ciphertext]?.0
    }
    
   
    
    
    
    
    //MARK:- structs
    
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
