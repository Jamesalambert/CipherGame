//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle : ObservableObject {
    
    
    @Published
    var theme : ThemeDelegateProtocol = ThemeManager()
    
    @Published
    var model : Game
    
    @Published
    var currentPuzzleHash : UUID?{
        didSet{
            if let currentPuzzleHash = currentPuzzleHash {
                model.lastOpenPuzzleHash = currentPuzzleHash
                characterCount = letterCount.map{pair in
                    CharacterCount(character: pair.character, count: pair.count)}
            }
        }
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
    var difficultyLevel : UInt = 0 {
        didSet{
            if difficultyLevel > (gameRules.count - 1) {
                difficultyLevel = UInt(gameRules.count - 1)
            }
            characterCount = letterCount.map{pair in
                CharacterCount(character: pair.character, count: pair.count)}
        }
    }
    
    
    @Published
    var capType : Int = 3
    
    @Published
    var fontDesign : Font.Design = .monospaced
        
    @Published
    var showLessons : Bool = true
    
    @Published
    var characterCount : [CharacterCount] = []
    
    //MARK: - public API
    
    var currentPuzzle : Puzzle {
        guard let currentPuzzleHash = self.currentPuzzleHash else {
            return Puzzle(title: "A", plaintext: "A",header: "A", footer: "A", keyAlphabet: "a", id: UUID())}
        
        let puzzles = model.books.map{book in book.puzzles}.joined()
        
        guard let currentPuzzle = puzzles.first(where: {$0.id == currentPuzzleHash}) else {
            return Puzzle(title: "!", plaintext: "!",header: "!", footer: "!", keyAlphabet: "a", id: UUID())}
        
        return currentPuzzle
    }
    
    var availableBooks : [PuzzleTitle]{
        var out : [PuzzleTitle] = []
        
        var books = model.books
        if !showLessons {
            books.removeAll(where: {$0.title == Game.firstPuzzle.book})
        }
        
        for (index, book) in books.enumerated() {
            out.append(PuzzleTitle(index: index,
                                   id: book.id,
                                   title: book.title,
                                   isSolved: book.isSolved))
        }
        return out
    }
    
    var headerText : String {
        return currentPuzzle.header
    }
    
    var footerText : String {
        return currentPuzzle.footer
    }
    
    func puzzleTitles(for bookHash : UUID) -> [PuzzleTitle] {
        guard let book = model.books.first(where: {book in book.id == bookHash}) else {return []}
        return book.puzzles.enumerated().map{(index, puzzle) in PuzzleTitle(index: index,
                                                    theme: book.theme?.rawValue,
                                                      id: puzzle.id,
                                                      title: puzzle.title,
                                                      isSolved: puzzle.isSolved)}
    }
    
    func puzzleIsCompleted(hash : UUID) -> Bool{
         guard let puzzle = model.books.map{book in book.puzzles}.joined()
                .first(where: {puzzle in puzzle.id == hash}) else {return false}
        
        return puzzle.isSolved
    }
    
    var userGuess : Character? {
        get {
            guard let current = currentCiphertextCharacter else {return nil}
            return self.plaintext(for: current)
        }
        
        set {
            model.updateUsersGuesses(cipherCharacter: currentCiphertextCharacter!,
                                     plaintextCharacter: newValue,
                                     in: currentPuzzle,
                                     at: currentUserSelectionIndex!)
        }
    }
    
    var data : [GameInfo] {

        //guard let currentPuzzle = self.currentPuzzle else {return []}

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
    
//var charsPerLine : Int = 30

    
//    func puzzlines(for width : CGFloat) -> [PuzzleLine] {
//        charsPerLine = Int(width / 30)
//        return puzzleLines
//    }
//
//    var puzzleLines : [PuzzleLine]{
//        guard let currentPuzzle = self.currentPuzzle else {return []}
//
//        let gameLines = currentPuzzle.ciphertext.asLines(of: charsPerLine).enumerated().map { (ciphertextLineNumber, ciphertextLine) -> PuzzleLine in
//
//            let puzzleLine = ciphertextLine.enumerated().compactMap{ (index, char) -> GameInfo? in
//
//                let ciphertextIndex = ciphertextLineNumber * charsPerLine + index
//
//                if let newGameTriad = gameRules[Int(difficultyLevel)]?(char, ciphertextIndex) {
//
//                    let characterPair = GameInfo(id: newGameTriad.id,
//                                          cipherLetter: newGameTriad.cipherLetter,
//                                          userGuessLetter: newGameTriad.userGuessLetter)
//                    return characterPair
//                }
//                return nil
//            }
//            return PuzzleLine(id: ciphertextLineNumber, characters: puzzleLine)
//        }
//        return gameLines
//    }

    
    var letterCount : [(character: Character, count: Int)] {
        
        var output : [(character:Character, count:Int)] = []
        
        for keyChar in currentPuzzle.letterCount.keys {
            output.append((Character(keyChar), currentPuzzle.letterCount[keyChar] ?? 0))
        }
        
        return output.sorted {
            if self.difficultyLevel == 0 {
                return ($0.count > $1.count) || (($0.count == $1.count) && ($0.character < $1.character))
            } else {
                return $0.character < $1.character
            }
        }
    }
    
    func plaintext(for ciphertext : Character) -> Character?{
        if let plaintextCharacter = currentPuzzle.usersGuesses[String(ciphertext)] {
            return Character(plaintextCharacter)
        }
        return nil
    }
    
    init() {
        self.model = Game()
        self.currentPuzzleHash = self.model.lastOpenPuzzleHash
    }
    
    
    
}

struct PuzzleTitle : Identifiable, Hashable {
    var index : Int
    var theme : Int?
    var id : UUID
    var title : String
    var isSolved : Bool
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

struct CharacterCount : Identifiable {
    var id : Character {
        return character
    }
    var character : Character
    var count : Int
}
