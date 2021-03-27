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
    var currentPuzzleHash : Int? {
        didSet{
            print("Set Puzzle title\npuzzle: \(currentPuzzleHash ?? 0)")
        }
    }

    
    var currentPuzzle : Puzzle? {
        guard let currentPuzzleHash = self.currentPuzzleHash else {return nil}
        
        let puzzles = model.books.map{book in book.puzzles}.joined()
        
        guard let currentPuzzle = puzzles.first(where: {$0.hashValue == currentPuzzleHash}) else {return nil}
        
        return currentPuzzle
    }
    
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
    var difficultyLevel : Int = 0 {
        didSet{
            if difficultyLevel > gameRules.count {
                difficultyLevel = gameRules.count - 1
            } else if difficultyLevel < 0 {
                difficultyLevel = 0
            }
        }
    }
    
    @Published
    var capType : UITextAutocapitalizationType =  UITextAutocapitalizationType.allCharacters
    
    @Published
    var fontDesign : Font.Design = .monospaced
    
    //MARK: - public API
    
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
     
        guard self.currentPuzzle != nil else {return []}
        
        var puzzleData = Array<GameInfo>()
        
        for (index, char) in self.currentPuzzle!.ciphertext.enumerated() {
            
            if let newGameTriad = gameRules[difficultyLevel]?(char, index) {
                
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
