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
                                     in: currentPuzzleTitle!)
        }
    }
    
    var data : [GameInfo] {
     
        guard self.currentPuzzle != nil else {return []}
        
        var puzzleData = Array<GameInfo>()
        
        for (index, char) in self.currentPuzzle!.ciphertext.enumerated() {
            
            if let newPair = gameRules[gameLevel]?(char,index) {
                puzzleData.append(newPair)
            }
        }
        
        return puzzleData
    }
    
    var letterCount : [(Character, Int)] {return currentPuzzle?.letterCount() ?? []}
    
    func plaintext(for ciphertext : Character) -> Character?{
                
        return currentPuzzle!.usersGuesses[ciphertext]
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
        
        if Puzzle.alphabet.contains(ciphertext) {
            let newPair = GameInfo(id: index,
                                   cipherLetter: ciphertext,
                                   userGuessLetter: plaintext(for: ciphertext))
            
            return newPair
        }
        
        return nil
    }
    
    
    private
    var gameRules : [ Int : (Character, Int) -> GameInfo? ]{
        return [0 : easyGameInfo,
                1 : mediumGameInfo]
    }
    
    
    
    private
    func updateUsersGuesses(cipherCharacter : Character, plaintextCharacter : Character, in puzzle : String){
        model.updateUsersGuesses(cipherCharacter: cipherCharacter, plaintextCharacter: plaintextCharacter, in: puzzle)
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
