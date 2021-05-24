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
    var theme : ThemeManager = ThemeManager()
    
    @Published
    var model : Game
    
    var visiblePuzzles : [Puzzle] {
        guard let currentChapter = currentChapter else {return []}
        let defaultPuzzles = currentChapter.puzzles.filter{puzzle in puzzle.riddleKey.isEmpty}
        //get unlocked puzzles from model.
        let userAnswers = model.userAnswers(for: currentChapterHash!)
        let unlockedPuzzles = userAnswers.compactMap{guessedKey in
            currentChapter.puzzles.first(where: {$0.riddleKey == guessedKey})
        }
        return defaultPuzzles + unlockedPuzzles
    }
    
    @Published
    var currentPuzzleHash : UUID?{
        didSet{
            if let currentPuzzleHash = currentPuzzleHash {
                model.lastOpenPuzzleHash = currentPuzzleHash
                characterCount = letterCount.map{pair in
                    CharacterCount(character: pair.character, count: pair.count)}
                currentGridPuzzleHash = nil
            }
            currentCiphertextCharacter = nil
        }
    }
    
    @Published
    var currentChapterHash : UUID? {
        didSet{
            guard let currentChapter = currentChapter else {return}
            self.currentPuzzleHash = currentChapter.puzzles.first?.id
            self.currentGridPuzzleHash = nil
        }
    }
    
    var currentChapterGridPuzzle : GridPuzzle?{
        return currentChapter?.gridPuzzle
    }
    
    var displayedCipherPuzzle : DisplayedCipherPuzzle? {
        return DisplayedCipherPuzzle(currentCipherPuzzle,
                                     puzzleCharacters: gameInfo(from: currentCipherPuzzle))
    }
    
    @Published
    var currentGridPuzzleHash : UUID?{
        didSet{
            if currentGridPuzzleHash != nil{
                currentPuzzleHash = nil
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
    
    //MARK:-
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
    
    
    var currentCipherPuzzle : Puzzle? {
        return currentChapter?.puzzles.first(where: {$0.id == currentPuzzleHash})
    }
    
    private
    var currentChapter : Chapter? {
        let chapters : [Chapter] = model.books.flatMap{$0.chapters}
        return chapters.first(where: {$0.id == currentChapterHash})
    }
 
    //MARK:- Intent
    
    func add(answer : String){
        model.add(answer: answer, for: currentPuzzleHash!)
    }
    
    func guess(_ cipherCharacter : Character, is plainCharacter : Character?,
               at index : Int) {
        
        model.updateUsersGuesses(cipherCharacter: cipherCharacter,
                                 plaintextCharacter: plainCharacter,
                                 for: currentPuzzleHash!,
                                 at: index)
    }
    
    func gridTap(_ tile : Tile) {
        if tile.canBeEnabled{
            model.reveal(tile, gridPuzzleHash: currentGridPuzzleHash!)
        } else {
            model.move(tile, gridPuzzleHash: currentGridPuzzleHash!)
        }
    }
    
    func reset() -> Void{
        //if cipher puzzle
        if let currentPuzzleHash = currentPuzzleHash{
            model.reset(currentPuzzleHash)
        } else if let currentGrid = currentChapterGridPuzzle {
            reset(grid: currentGrid)
        }
    }
    
    
    func reset(grid : GridPuzzle){
        model.shuffle(grid)
    }
    
    //for debugging
    func solveCipher(_ puzzleID : UUID){
        model.solveCipher(puzzleID)
    }

    //MARK:-
    
    func firstChapterHash(for bookID : String) -> UUID?{
        let book = model.books.first{$0.productID == bookID}
        return book?.chapters.first?.id
    }

    func puzzleLines(charsPerLine : Int) -> [PuzzleLine]{
        let gameLines = currentPuzzle.ciphertext.asLines(of: charsPerLine).enumerated().map { (ciphertextLineNumber, ciphertextLine) -> PuzzleLine in

            let puzzleLine = ciphertextLine.enumerated().compactMap{ (index, char) -> GameInfo? in

                let ciphertextIndex = ciphertextLineNumber * charsPerLine + index

                if let newGameTriad = gameRules[Int(difficultyLevel)]?(char, ciphertextIndex) {

                    let characterPair = GameInfo(id: newGameTriad.id,
                                          cipherLetter: newGameTriad.cipherLetter,
                                          userGuessLetter: newGameTriad.userGuessLetter)
                    return characterPair
                }
                return nil
            }
            return PuzzleLine(id: ciphertextLineNumber, characters: puzzleLine)
        }
        return gameLines
    }
    
    func gameInfo(from puzzle : Puzzle?) -> [GameInfo]{
        guard let puzzle = puzzle else {return []}
        return puzzle.ciphertext.enumerated().compactMap{(index, char) in
            return gameRules[Int(difficultyLevel)]?(char,index)
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


struct DisplayedCipherPuzzle {
    let title: String
    let header: String
    let footer: String
    let puzzleCharacters : [GameInfo]
    let isSolved : Bool
    let id : UUID

    init?(_ puzzle : Puzzle?, puzzleCharacters : [GameInfo]){
        guard let puzzle = puzzle else {return nil}
        self.title = puzzle.title
        self.header = puzzle.header
        self.footer = puzzle.footer
        self.puzzleCharacters = puzzleCharacters
        self.isSolved = puzzle.isSolved
        self.id = puzzle.id
    }
}
