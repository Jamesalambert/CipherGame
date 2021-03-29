//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle : ObservableObject {
        
    @Published
    private
    var model : Game = Game()
    
    @Published
    var currentPuzzleHash : Int?
    
    @Published
    var currentCiphertextCharacter : Character? = nil {
        didSet {
            if let current = currentCiphertextCharacter, current.isUppercase {
                currentCiphertextCharacter = Character(String(current).lowercased())
            }
        }
    }
    
    @Published
    var currentUserSelectionIndex : Int? = nil
    
    @Published
    var difficultyLevel : UInt = 0 {
        didSet{
            if difficultyLevel > (gameRules.count - 1) {
                difficultyLevel = UInt(gameRules.count - 1)
            }
        }
    }
    
    @Published
    var capType : Int = 3
    
    @Published
    var fontDesign : Font.Design = .monospaced
    
    //MARK: - public API
    
    var currentPuzzle : Puzzle? {
        guard let currentPuzzleHash = self.currentPuzzleHash else {return nil}
        
        let puzzles = model.books.map{book in book.puzzles}.joined()
        
        guard let currentPuzzle = puzzles.first(where: {$0.hashValue == currentPuzzleHash}) else {return nil}
        
        return currentPuzzle
    }
    
    var availableBooks : [PuzzleTitle]{
        var out : [PuzzleTitle] = []
        
        for book in model.books {
            out.append(PuzzleTitle(id: book.hashValue,
                                   title: book.title))
        }
        return out
    }

    
    func puzzleTitles(for bookHash : Int) -> [PuzzleTitle] {
        guard let book = model.books.first(where: {book in book.hashValue == bookHash}) else {return []}
        return book.puzzles.map{puzzle in PuzzleTitle(id: puzzle.hashValue, title: puzzle.title)}
    }
    
    func puzzleIsCompleted(hash : Int) -> Bool{
         guard let puzzle = model.books.map{book in book.puzzles}.joined()
                .first(where: {puzzle in puzzle.hashValue == hash}) else {return false}
        
        return puzzle.isSolved
    }
    
    var userGuess : Character? {
        
        get {
            guard let current = currentCiphertextCharacter else {return nil}
            return self.plaintext(for: current)
        }
        
        set {
            guard let currentPuzzle = currentPuzzle else {return}
            
            model.updateUsersGuesses(cipherCharacter: currentCiphertextCharacter!,
                                     plaintextCharacter: newValue,
                                     in: currentPuzzle,
                                     at: currentUserSelectionIndex!)
        }
    }
    
    var data : [GameInfo] {
     
        guard self.currentPuzzle != nil else {
            
            return []
            
        }
        
        var puzzleData = Array<GameInfo>()
        
        for (index, char) in self.currentPuzzle!.ciphertext.enumerated() {
            
            if let newGameTriad = gameRules[Int(difficultyLevel)]?(char, index) {
                
                let output = GameInfo(id: newGameTriad.id,
                                      cipherLetter: newGameTriad.cipherLetter,
                                      userGuessLetter: newGameTriad.userGuessLetter)
                
                puzzleData.append(output)
            }
        }
        
        return puzzleData
    }
    
    var letterCount : [(Character, Int)] {return currentPuzzle?.letterCount() ?? []}
    
    func plaintext(for ciphertext : Character) -> Character?{
        return currentPuzzle!.usersGuesses[ciphertext]?.0
    }
    
    
}

struct PuzzleTitle : Identifiable, Hashable {
    var id : Int
    var title : String
}

struct GameInfo : Identifiable {
    
    var id: Int
    var cipherLetter : Character
    var userGuessLetter : Character?
}
