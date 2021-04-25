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
                print(currentPuzzleHash)
            }
        }
    }
    
    @Published
    var currentChapterHash : UUID? {
        didSet{
            //choose new puzzle
            guard let currentChapter = installedBooks.flatMap{$0.chapters}.filter({$0.id == currentChapterHash}).first else {return}
            currentPuzzleHash = visiblePuzzles(for: currentChapter).first?.id
        }
    }
    
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
            return Puzzle(title: "A", plaintext: "A",header: "A", footer: "A", keyAlphabet: "a", riddle: "", riddleAnswers: [], riddleKey: "", id: UUID())}
        
        let chapters : [Chapter] = model.books.flatMap{book in book.chapters}
        let puzzles : [Puzzle] = chapters.flatMap{$0.puzzles}
        
        guard let currentPuzzle = puzzles.first(where: {$0.id == currentPuzzleHash}) else {
            return Puzzle(title: "B", plaintext: "B",header: "B", footer: "B", keyAlphabet: "b", riddle: "?", riddleAnswers: [], riddleKey: "", id: UUID())}
        
        return currentPuzzle
    }
    
    var installedBooks : [Book] {
        let books = model.books
        if showLessons {
            return books
        } else {
            let booksWithoutLessons = books.drop(while: {$0.title == "lessons"})
            return Array(booksWithoutLessons)
        }
    }
    
    
    func visiblePuzzles(for chapter : Chapter) -> [Puzzle] {
        let defaultPuzzles = chapter.puzzles.filter{puzzle in puzzle.riddleKey == ""}
        let unlockedPuzzles = chapter.userRiddleAnswers.compactMap{guessedKey in
            chapter.puzzles.first(where: {puzzle in puzzle.riddleKey == guessedKey})
        }
        return defaultPuzzles + unlockedPuzzles
    }
    
    
    
    func guess(_ cipherCharacter : Character, is plainCharacter : Character?,
               at index : Int, for puzzle : Puzzle ) {
        
        model.updateUsersGuesses(cipherCharacter: cipherCharacter,
                                 plaintextCharacter: plainCharacter,
                                 in: puzzle,
                                 at: index)
    }
    
    func data(for puzzle : Puzzle) -> [GameInfo] {
        var puzzleData = Array<GameInfo>()

        for (index, char) in puzzle.ciphertext.enumerated() {
            
            //need current puzzle here because it talks to the model!
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
    
var charsPerLine : Int = 30

    
    func puzzlines(for width : CGFloat) -> [PuzzleLine] {
        charsPerLine = Int(width / 30)
        return puzzleLines
    }

    var puzzleLines : [PuzzleLine]{
//        guard let currentPuzzle = self.currentPuzzle else {return []}

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
            print(plaintextCharacter)
            return Character(plaintextCharacter)
        }
        return nil
    }
    
    init() {
        self.model = Game()
        self.currentPuzzleHash = self.model.lastOpenPuzzleHash
        self.currentChapterHash = self.model.lastOpenChapterHash
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
