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

        guard let currentPuzzle = self.currentPuzzle else {return []}

        var puzzleData = Array<GameInfo>()

        for (index, char) in currentPuzzle.ciphertext.enumerated() {

            if let newGameTriad = gameRules[Int(difficultyLevel)]?(char, index) {

                let output = GameInfo(id: newGameTriad.id,
                                      cipherLetter: newGameTriad.cipherLetter,
                                      userGuessLetter: newGameTriad.userGuessLetter)

                puzzleData.append(output)
            }
        }

        return puzzleData
    }
    
//Experimental!
//    var puzzleLines : [ PuzzleLine ]{
//        guard let currentPuzzle = self.currentPuzzle else {return []}
//
//        let charsPerLine = 20
//        let numberOfLines = Int(ceil(Double(currentPuzzle.ciphertext.count) / Double(charsPerLine))) - 1
//
//        var output : [ PuzzleLine ] = []
//
//        var startIdx = currentPuzzle.ciphertext.startIndex
//        var endIdx = currentPuzzle.ciphertext.count < charsPerLine ? currentPuzzle.ciphertext.endIndex : currentPuzzle.ciphertext.index(startIdx, offsetBy: charsPerLine - 1)
//
//        for line in 0..<numberOfLines {
//
//            let lineCipherChars = currentPuzzle.ciphertext[startIdx...endIdx]
//
//            var lineChars : [GameInfo] = []
//
//            for (index, char) in lineCipherChars.enumerated() {
//                if let newGameTriad = gameRules[Int(difficultyLevel)]?(char, index) {
//
//                    let output = GameInfo(id: newGameTriad.id,
//                                          cipherLetter: newGameTriad.cipherLetter,
//                                          userGuessLetter: newGameTriad.userGuessLetter)
//
//                    lineChars.append(output)
//                }
//            }
//            output.append(PuzzleLine(id: line, characters: lineChars))
//
//            //update indices
//            startIdx = currentPuzzle.ciphertext.index(startIdx, offsetBy: charsPerLine)
//
//            if line == numberOfLines - 1{
//                endIdx = currentPuzzle.ciphertext.endIndex
//            } else {
//                endIdx = currentPuzzle.ciphertext.index(endIdx, offsetBy: charsPerLine)
//            }
//
//        }
//        return output
//    }

    
    var letterCount : [(Character, Int)] {return currentPuzzle?.letterCount() ?? []}
    
    func plaintext(for ciphertext : Character) -> Character?{
        return currentPuzzle!.usersGuesses[ciphertext]?.0
    }
    
    
}

struct PuzzleTitle : Identifiable, Hashable {
    var id : Int
    var title : String
}

struct GameInfo : Hashable, Identifiable {
    var id: Int
    var cipherLetter : Character
    var userGuessLetter : Character?
}

struct PuzzleLine : Identifiable, Hashable{
    var id: Int
    var characters : [GameInfo]
}
