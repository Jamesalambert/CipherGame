//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game : Codable {
    
    static let puzzleFolder = "puzzles"
    
    var activeBookIds : [String] = ["Lessons", "Rebecca's Garden"]
    var recordedIDOfFirstPuzzle = false
    
    //MARK: - public
    private(set)
    var books : [Book]
    var lastOpenPuzzleHash : UUID?
    var lastOpenChapterHash : UUID? {
        let chapters = books.flatMap{$0.chapters}
        return chapters.first(where: {chapter in
            chapter.puzzles.contains(where: {$0.id == lastOpenPuzzleHash})
        })?.id
    }
    //MARK:-
    
    mutating
    func reset(_ puzzleID : UUID){
        guard let currentPuzzleIndexPath = self.indexPath(for: puzzleID) else {return}

        let bookIndex = currentPuzzleIndexPath.bookIndex
        let chapterIndex = currentPuzzleIndexPath.chapterIndex
        let puzzleIndex = currentPuzzleIndexPath.puzzleIndex
    
        //reset guesses and indices
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].usersGuesses.removeAll()
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].guessIndices.removeAll()
        
        //reset user answers to riddles
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].userRiddleAnswers.removeAll()
        
        //reset grid puzzle if it exists
        books[bookIndex].chapters[chapterIndex].gridPuzzle?.reset()
    }
    
    mutating
    func updateUsersGuesses(cipherCharacter : Character,
                            plaintextCharacter : Character?,
                            for puzzleID : UUID,
                            at index : Int){
        
        guard let currentPuzzleIndexPath = self.indexPath(for: puzzleID) else {return}
        let bookIndex = currentPuzzleIndexPath.bookIndex
        let chapterIndex = currentPuzzleIndexPath.chapterIndex
        let puzzleIndex = currentPuzzleIndexPath.puzzleIndex
        
        //discard uppercase!
        let lowerPlainCharacter = plaintextCharacter.lowerCharOpt()
        let lowerCipherCharacter = String(cipherCharacter.lowerChar())
        
        //user entered a non-nil char
        if let lowerPlainCharacter = lowerPlainCharacter {
            
            //update model
            books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].usersGuesses[lowerCipherCharacter] = String(lowerPlainCharacter)
            
            if let _ = books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].guessIndices[lowerCipherCharacter] {
                books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].guessIndices[lowerCipherCharacter]?.insert(index)
            } else {
                books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].guessIndices[lowerCipherCharacter] = [index]
            }
            
            //check to see if puzzle has been solved and add a tile to the grid if it exists.
            if books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].isSolved{
                books[bookIndex].chapters[chapterIndex].gridPuzzle?.addTile()
            }
            
            //remove guess for ciphertext character
        } else {
            books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].usersGuesses.removeValue(forKey: lowerCipherCharacter)
            books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].guessIndices.removeValue(forKey: lowerCipherCharacter)
        }
    }
    
    mutating
    func add(answer : String, for puzzleID : UUID){
        guard let currentPuzzleIndexPath = self.indexPath(for: puzzleID) else {return}
        let bookIndex = currentPuzzleIndexPath.bookIndex
        let chapterIndex = currentPuzzleIndexPath.chapterIndex
        let puzzleIndex = currentPuzzleIndexPath.puzzleIndex
        
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].userRiddleAnswers.removeAll{$0 == answer}  //prevent duplicates
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].userRiddleAnswers.append(answer)
    }
    
    func userAnswers(for inputChapterHash : UUID) -> [String] {
        guard let theChapter : Chapter = books.flatMap({$0.chapters}).first(where: {$0.id == inputChapterHash}) else {return []}
        return theChapter.puzzles.flatMap{$0.userRiddleAnswers}
    }
    
    mutating
    func add(books : [String]){
        for bookName in books {
            if !activeBookIds.contains(bookName){
                activeBookIds.append(bookName)
                loadFromFile(bookName: bookName)
            }
        }
    }
    
    mutating
    func move(_ tile : Tile, gridPuzzleHash : UUID){
        guard let bookIndex = books.firstIndex(where: {book in
                                                    book.chapters.contains{ chapter in
                                                        chapter.gridPuzzle?.id == gridPuzzleHash}} ) else {return }
        guard let chapterIndex = books[bookIndex].chapters.firstIndex(where: {chapter in
                                                            chapter.gridPuzzle?.id == gridPuzzleHash}) else {return }
        
        books[bookIndex].chapters[chapterIndex].gridPuzzle?.move(tile)
    }

    
    mutating
    func reveal(_ tile : Tile, gridPuzzleHash : UUID){
        guard let bookIndex = books.firstIndex(where: {book in
                                                    book.chapters.contains{ chapter in
                                                        chapter.gridPuzzle?.id == gridPuzzleHash}} ) else {return }
        guard let chapterIndex = books[bookIndex].chapters.firstIndex(where: {chapter in
                                                            chapter.gridPuzzle?.id == gridPuzzleHash}) else {return }
        
        books[bookIndex].chapters[chapterIndex].gridPuzzle?.reveal(tile)
    }
    
    private
    func indexPath(for puzzleID: UUID)  -> (bookIndex: Int, chapterIndex: Int, puzzleIndex: Int)? {
        guard let bookIndex = books.firstIndex(where: {book in
                                                book.chapters.contains{ chapter in
                                                    chapter.puzzles.contains{ puzzle in
                                                        puzzle.id == puzzleID
                                                    }
                                                }} ) else {return nil}
        guard let chapterIndex = books[bookIndex].chapters.firstIndex(where: {chapter in
                                                            chapter.puzzles.contains{ puzzle in
                                                                puzzle.id == puzzleID
                                                            }
                                                        }) else {return nil}
        
        guard let puzzleIndex = books[bookIndex].chapters[chapterIndex].puzzles.firstIndex(where: {$0.id == puzzleID}) else {return nil}
        
        return (bookIndex, chapterIndex, puzzleIndex)
    }
    
    init(){
        self.books = []
        self.loadLocalBooks()
    }
    
    private
    mutating
    func loadLocalBooks(){
        for bookName in activeBookIds {
            loadFromFile(bookName: bookName)
        }
    }
    
    private
    mutating func loadFromFile(bookName : String) {
        var decodedBook : Book
        guard let JSONurl = Bundle.main.url(forResource: bookName, withExtension: "json") else {return}
        do {
            if let data = try String(contentsOf: JSONurl).data(using: .utf8) {
                
                let readableBook = try JSONDecoder().decode(ReadableBook.self, from: data)
                
                let chaptersOfPuzzles : [Chapter] = readableBook.chapters.map{ chapter in
                    let puzzles = chapter.puzzles.map{readablePuzzle in
                        
                        Puzzle(title: readablePuzzle.title,
                               plaintext: readablePuzzle.plaintext,
                               header: readablePuzzle.header,
                               footer: readablePuzzle.footer,
                               keyAlphabet: readablePuzzle.keyAlphabet,
                               riddle: readablePuzzle.riddle,
                               riddleAnswers: readablePuzzle.riddleAnswers,
                               riddleKey: readablePuzzle.riddleKey,
                               id: puzzleID())
                    }
                    
                    return Chapter(title: chapter.title,
                                   puzzles: puzzles,
                                   gridPuzzle: chapter.puzzleImageName != "" ? GridPuzzle(imageName: chapter.puzzleImageName,
                                                                                          hiddenTiles: puzzles.count) : nil)
                }
                
                decodedBook = Book(title: readableBook.title,
                                         chapters: chaptersOfPuzzles,
                                         theme: readableBook.theme,
                                         productID: bookName)
                self.books.append(decodedBook)
            }
        }
        catch {
            print("error Couldn't read input for \(bookName) json file:\n \(JSONurl)")
        }
    }
    
    
    
    private
    mutating
    func puzzleID() -> UUID {
        let id = UUID()
        if recordedIDOfFirstPuzzle {
            return id
        } else {
            lastOpenPuzzleHash = id
            recordedIDOfFirstPuzzle = true
            return id
        }
    }
}


struct Puzzle : Hashable, Codable, Identifiable{
    
    static func == (lhs: Puzzle, rhs: Puzzle) -> Bool {
        return lhs.id == rhs.id
    }

    var title : String
    var ciphertext : String
    var plaintext : String
    var header : String
    var footer : String
    var keyAlphabet : String        //the original key alphabet, use for encrypting
    var solution : String           //what the user needs to figure out (the message may not use all letters)
    var riddle : String
    var riddleAnswers : [String]    // first entry is the correct one
    var riddleKey : String          //if the user chooses this value as the answer to another riddle, this puzzle is shown
    var userRiddleAnswers : [String] = []
    
    var isSolved : Bool {
        var guesses : String = ""
        let alphabet = String.alphabet.map({String($0)})
        
        for letter in alphabet {
            let guess : String = alphabet.first(where: {char in usersGuesses[char] == letter}) ?? ""
            guesses.append(guess)
        }
        return guesses == solution
    }
    
    var id : UUID
    var usersGuesses : [String : String] = Dictionary()
    var guessIndices : [String : Set<Int>] = Dictionary()
    var letterCount : [String : Int]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(title : String, plaintext: String, header: String, footer : String,
         keyAlphabet : String, riddle : String, riddleAnswers: [String], riddleKey : String, id: UUID){
        
        //Helper functions
        func letterCount(in ciphertext : String) -> [String : Int]{
            var output : [String : Int] = [:]
            for letter in String.alphabet {
                output[String(letter)]  = Int(ciphertext.number(of: letter))
            }
            return output
        }

        func encryptCipher(_ plaintext : String, with key : String) -> String{
            
            let plaintext : [String] = plaintext.map{char in String(char)}
            let wheel : [Int : String] = {
                
                var dict : [Int : String] = [:]
                for (index,char) in key.enumerated(){
                    dict[index] = String(char)
                }
            return dict
            }()
            let alphabet : [String] = String.alphabet.map{char in String(char)}
            
            var ciphertext = ""
            
            for plainChar in plaintext {
                if alphabet.contains(plainChar){
                    //get index
                    var indexOfCharInAlphabet = 0
                    for index in 0..<alphabet.count{
                        if alphabet[index] == plainChar{
                            indexOfCharInAlphabet = index
                            break
                        }
                    }
                    ciphertext.append(wheel[indexOfCharInAlphabet] ?? "")
                } else {
                    ciphertext.append(plainChar)
                }
            }
            return ciphertext

        }
        //helper funcs
        
        self.title = title
        self.keyAlphabet = keyAlphabet
        self.plaintext = plaintext.lowercased()
        self.header = header
        self.footer = footer
        self.riddle = riddle
        self.riddleAnswers = riddleAnswers
        self.riddleKey = riddleKey
        self.id = id
        
        //remove whitespace except spaces
        var removeChars = CharacterSet.whitespacesAndNewlines
        removeChars.remove(charactersIn: " ") //leave spaces!
        
        //create ciphertext
        let ciphertext = encryptCipher(self.plaintext.removeCharacters(in: removeChars),
                                        with: keyAlphabet)
        
        self.ciphertext = ciphertext
        self.solution = keyAlphabet.filter{character in ciphertext.number(of: character) > 0}
        
        self.letterCount = letterCount(in: self.ciphertext)
    }
}

struct Book : Hashable, Codable, Identifiable{
    var title : String
    var chapters : [Chapter]
    var id = UUID()
    var isSolved : Bool = false
    var theme : BookTheme = .defaultTheme
    var productID : String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Chapter : Hashable, Codable, Identifiable {
    var title : String
    var puzzles : [Puzzle]
    var gridPuzzle : GridPuzzle?
    var isCompleted : Bool {
        return puzzles.allSatisfy{$0.isSolved}
    }
    var id = UUID()
    
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ReadableBook : Codable {
    var title : String
    var theme : BookTheme
    var chapters : [ReadableChapter]
}

struct ReadableChapter :  Codable {
    var title : String
    var puzzles : [ReadablePuzzle]
    var puzzleImageName : String
}

struct ReadablePuzzle : Codable {
    var title : String
    var header : String
    var plaintext : String
    var footer : String
    var keyAlphabet : String
    var riddle : String
    var riddleAnswers : [String] // first entry is the correct one
    var riddleKey : String //is the user chooses this value as the answer to another riddle, this puzzle is shown
}



