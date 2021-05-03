//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

class CipherPuzzle : ObservableObject {
    //MARK: - public API
    @Published
    var theme : ThemeDelegateProtocol = ThemeManager()
    
    @Published
    var model : Game
    
    @Published
    var visiblePuzzles : [Puzzle] = []
    
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
    var currentChapterHash : UUID? {
        didSet{
            if currentChapterHash != nil {
                currentPuzzleHash = currentChapter.puzzles.first?.id
                updateVisiblePuzzles()
            }
        }
    }
    
    @Published
    var currentCiphertextCharacter : Character?
    
    @Published
    var selectedIndex : Int?
    
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
    //MARK:- public computed properties
    
    var puzzleTitle : String {
        return currentPuzzle.title
    }
    
    var header : String {
        return currentPuzzle.header
    }
    
    var ciphertext : String {
        return currentPuzzle.ciphertext
    }
    
    var footer : String {
        return currentPuzzle.footer
    }
    
    var keyAlphabet : String {
        return currentPuzzle.keyAlphabet
    }
    
    var userGuesses : [String : String] {
        return currentPuzzle.usersGuesses
    }
    
    var guessIndices : [String: Set<Int>] {
        return currentPuzzle.guessIndices
    }
    
    var isSolved : Bool {
        return currentPuzzle.isSolved
    }
    
    var riddleAnswers : [String] {
        return currentPuzzle.riddleAnswers
    }
    
    var riddle : String {
        return currentPuzzle.riddle
    }
    
    var riddleKey : String {
        return currentPuzzle.riddleKey
    }
    
    var userRiddleAnswers : [String] {
        return currentPuzzle.userRiddleAnswers
    }
    
    var data : [GameInfo] {
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
    
    var installedBooks : [Book] {
        let books = model.books
        if showLessons {
            return books
        } else {
            let booksWithoutLessons = books.drop(while: {$0.title == "Lessons"})
            return Array(booksWithoutLessons)
        }
    }

    var installedBookIDs : [String] {
        return model.activeBookIds
    }
    
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
    
    //MARK:- private
    private
    var currentPuzzle : Puzzle {
        guard let currentPuzzleHash = self.currentPuzzleHash else {
            return Puzzle(title: "A", plaintext: "A",header: "A", footer: "A", keyAlphabet: "a", riddle: "", riddleAnswers: [], riddleKey: "", id: UUID())}
        
        let chapters : [Chapter] = model.books.flatMap{book in book.chapters}
        let puzzles : [Puzzle] = chapters.flatMap{$0.puzzles}
        
        guard let currentPuzzle = puzzles.first(where: {$0.id == currentPuzzleHash}) else {
            return Puzzle(title: "B", plaintext: "B",header: "B", footer: "B", keyAlphabet: "b", riddle: "?", riddleAnswers: [], riddleKey: "", id: UUID())}
        return currentPuzzle
    }
    
    private
    var currentChapter : Chapter {
        let chapters : [Chapter] = model.books.flatMap{$0.chapters}
        return chapters.first(where: {$0.id == currentChapterHash})!
    }
 
    //MARK:- Intent
    
    func add(answer : String){
        model.add(answer: answer, for: currentPuzzleHash!)
        updateVisiblePuzzles()
    }
    
    func guess(_ cipherCharacter : Character, is plainCharacter : Character?,
               at index : Int) {
        
        model.updateUsersGuesses(cipherCharacter: cipherCharacter,
                                 plaintextCharacter: plainCharacter,
                                 for: currentPuzzleHash!,
                                 at: index)
    }
    //MARK:-
    func updateVisiblePuzzles() {
        let defaultPuzzles = currentChapter.puzzles.filter{puzzle in puzzle.riddleKey.isEmpty}
        //get unlocked puzzles from model.
        let userAnswers = model.userAnswers(for: currentChapterHash!)
        let unlockedPuzzles = userAnswers.compactMap{guessedKey in
            currentChapter.puzzles.first(where: {$0.riddleKey == guessedKey})
        }
        visiblePuzzles = defaultPuzzles + unlockedPuzzles
    }
    
    func firstChapterHash(for bookID : String) -> UUID?{
        let book = model.books.first{$0.productID == bookID}
        return book?.chapters.first?.id
    }
    
//Experimental!
//    var charsPerLine : Int = 30
//    func puzzlines(for width : CGFloat) -> [PuzzleLine] {
//        charsPerLine = Int(width / 30)
//        return puzzleLines
//    }
//
//    var puzzleLines : [PuzzleLine]{
////        guard let currentPuzzle = self.currentPuzzle else {return []}
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
    
    func plaintext(for ciphertext : Character) -> Character?{
        if let plaintextCharacter = currentPuzzle.usersGuesses[String(ciphertext)] {
            return Character(plaintextCharacter)
        }
        return nil
    }
    
    init() {
        self.model = Game()
        self.currentPuzzleHash = self.model.lastOpenPuzzleHash
        self.currentChapterHash = self.model.lastOpenChapterHash
        self.loadPurchasedBooksFromKeychain()
    }
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
