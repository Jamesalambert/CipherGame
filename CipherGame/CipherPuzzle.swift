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
    
    @Published
    var currentPuzzleHash : UUID?{
        didSet{
            if let currentPuzzleHash = currentPuzzleHash {
                model.lastOpenPuzzleHash = currentPuzzleHash
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
        }
    }
    
    @Published
    var capType : Int = 3
    
    @Published
    var fontDesign : Font.Design = .monospaced
    
    @Published
    var showLessons : Bool = true

    var visiblePuzzles : [Puzzle] {
        guard let currentPuzzles = currentChapter?.puzzles else {return []}
        
        var output : [Int] = []
        
        for index in 0..<currentPuzzles.count{
            if index == 0 || currentPuzzles[index - 1].isSolved {
                output.append(index)
            }
        }
        return output.map{currentPuzzles[currentPuzzles.index(currentPuzzles.startIndex, offsetBy: $0, limitedBy: currentPuzzles.count) ?? 0]}
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
    
    
    var letterCount: [CharacterCount] {
        
        guard let currentCipherPuzzle = currentCipherPuzzle else {return []}
        
        var output : [(character:Character, count:Int)] = []
        for keyChar in currentCipherPuzzle.letterCount.keys {
            output.append((Character(keyChar), currentCipherPuzzle.letterCount[keyChar] ?? 0))
        }
        
        let counts =  output.sorted {
            if self.difficultyLevel == 0 {
                return ($0.count > $1.count) || (($0.count == $1.count) && ($0.character < $1.character))
            } else {
                return $0.character < $1.character
            }
        }
        
        return counts.map{(character, count) in CharacterCount(character: character, count: count)}
    }
    
    //MARK:- State
    var currentCipherPuzzle : Puzzle? {
        return currentChapter?.puzzles.first(where: {$0.id == currentPuzzleHash})
    }
    
    private
    var currentChapter : Chapter? {
        let chapters : [Chapter] = model.books.flatMap{$0.chapters}
        return chapters.first(where: {$0.id == currentChapterHash})
    }
 
    //MARK:- Intent
    
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
        guard let currentCipherPuzzle = currentCipherPuzzle else { return [] }

        let gameLines = currentCipherPuzzle.ciphertext.asLines(of: charsPerLine).enumerated().map { (ciphertextLineNumber, ciphertextLine) -> PuzzleLine in

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
    
    private
    func gameInfo(from puzzle : Puzzle?) -> [GameInfo]{
        guard let puzzle = puzzle else {return []}
        return puzzle.ciphertext.enumerated().compactMap{(index, char) in
            return gameRules[Int(difficultyLevel)]?(char,index)
        }
    }
    
    func plaintext(for ciphertext : Character) -> Character?{
        guard let currentCipherPuzzle = currentCipherPuzzle else {return nil}

        if let plaintextCharacter = currentCipherPuzzle.usersGuesses[String(ciphertext)] {
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
