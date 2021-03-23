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
    
    //MARK:- private
    
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
        
        if let guessIndices = currentPuzzle?.usersGuesses[ciphertext]?.1 {
            if guessIndices.containsItem(within: 20, of: index){
                return mediumLevel
            }
        }
        
        mediumLevel?.userGuessLetter = nil
        return mediumLevel
    }
    
    
    
    
    
    private
    var gameRules : [ Int : (Character, Int) -> GameInfo? ]{
        return [0 : easyGameInfo,
                1 : mediumGameInfo,
                2 : hardGameInfo]
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

extension Color {
    static let blue = Color.blue
    static let orange = Color.orange
    
    static func highlightColor(for colorScheme : ColorScheme) -> Color{
        if colorScheme == .light {
            return orange
        } else {
            return blue
        }
    }
}

extension Array where Element == Int {
    
    func containsItem(within distance : Int, of index : Int)-> Bool {
        if self.first(where: { item in abs(item - index) <= distance}) != nil {
            return true
        }
        return false
    }
    
    
}
