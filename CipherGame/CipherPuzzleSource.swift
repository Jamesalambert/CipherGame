//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game : Codable {
    
    static let puzzleFolder = "puzzles"
    
    var activeBookIds : [String] = ["Lessons", "Rebecca's Garden", "queen of the zlogs"]
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
        guard let currentPuzzleIndexPath = self.indexPath(forPuzzle: puzzleID) else {return}

        let bookIndex = currentPuzzleIndexPath.bookIndex
        let chapterIndex = currentPuzzleIndexPath.chapterIndex
        let puzzleIndex = currentPuzzleIndexPath.puzzleIndex
    
        //reset guesses and indices
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].usersGuesses.removeAll()
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].guessIndices.removeAll()
        
        //reset grid puzzle if it exists
        books[bookIndex].chapters[chapterIndex].gridPuzzle?.reset()
    }
    
    mutating
    func shuffle(_ gridPuzzle : GridPuzzle){
        guard let currentPuzzleIndexPath = self.indexPath(forGrid: gridPuzzle.id) else {return}

        let bookIndex = currentPuzzleIndexPath.bookIndex
        let chapterIndex = currentPuzzleIndexPath.chapterIndex

        //reset grid puzzle if it exists
        books[bookIndex].chapters[chapterIndex].gridPuzzle?.shuffleTiles()
    }
    
    mutating
    func solveCipher(_ puzzleID : UUID){
        guard let currentPuzzleIndexPath = self.indexPath(forPuzzle: puzzleID) else {return}
        let bookIndex = currentPuzzleIndexPath.bookIndex
        let chapterIndex = currentPuzzleIndexPath.chapterIndex
        let puzzleIndex = currentPuzzleIndexPath.puzzleIndex
        books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].solve()
        
        //check to see if puzzle has been solved and add a tile to the grid if it exists.
        if books[bookIndex].chapters[chapterIndex].puzzles[puzzleIndex].isSolved{
            books[bookIndex].chapters[chapterIndex].gridPuzzle?.addTile()
        }
    }
    
    mutating
    func updateUsersGuesses(cipherCharacter : Character,
                            plaintextCharacter : Character?,
                            for puzzleID : UUID,
                            at index : Int){
        
        guard let currentPuzzleIndexPath = self.indexPath(forPuzzle: puzzleID) else {return}
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
    func indexPath(forPuzzle puzzleID: UUID)  -> (bookIndex: Int, chapterIndex: Int, puzzleIndex: Int)? {
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
    
    private
    func indexPath(forGrid gridPuzzleID: UUID) -> (bookIndex: Int, chapterIndex: Int)? {
        guard let bookIndex = books.firstIndex(where: {book in
            book.chapters.contains(where: {chapter in
                chapter.gridPuzzle?.id == gridPuzzleID
            })
        })
        else {return nil}
        
        guard let chapterIndex = books[bookIndex].chapters.firstIndex(where: {chapter in
            chapter.gridPuzzle?.id == gridPuzzleID
        })
        else {return nil}
        return (bookIndex, chapterIndex)
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
        
        //check in app bundle or Documents folder
        guard let JSONurl = url(for: bookName) else {return}
        
        var decodedBook : Book
        
        do {
            if let data = try String(contentsOf: JSONurl).data(using: .utf8) {
                
                let readableBook = try JSONDecoder().decode(ReadableBook.self, from: data)
                
                let chaptersOfPuzzles : [Chapter] = readableBook.chapters.map{ readableChapter in
                    let puzzles = readableChapter.puzzles.map{readablePuzzle in
                        Puzzle(puzzle: readablePuzzle)
                    }
                    
                    if let gridPuzzle = readableChapter.gridPuzzle {
                        return Chapter(title: readableChapter.title,
                                       puzzles: puzzles,
                                       gridPuzzle: GridPuzzle(puzzle: gridPuzzle) )
                    } else {
                        return Chapter(title: readableChapter.title,
                                       puzzles: puzzles,
                                       gridPuzzle: nil)
                    }
                }
                
                decodedBook = Book(title: readableBook.title,
                                         chapters: chaptersOfPuzzles,
                                         theme: readableBook.theme,
                                         productID: bookName)
                self.books.append(decodedBook)
            }
        }
        catch {
            //remove from active IDs if file wasn't found
            activeBookIds.removeAll(where: {$0 == bookName})
            print("error Couldn't read input for \(bookName) json file:\n \(JSONurl)")
        }
    }
    
    
    private
    func url(for bookID : String) -> URL? {
        if let JSONurl = Bundle.main.url(forResource: bookID, withExtension: "json") {
            return JSONurl
        } else {
            let docsURL = OnlineStore.documentsURL
                .appendingPathComponent("\(bookID)/\(bookID).json")
            return docsURL
        }
    }
    
    
//    private
//    mutating
//    func puzzleID() -> UUID {
//        let id = UUID()
//        if recordedIDOfFirstPuzzle {
//            return id
//        } else {
//            lastOpenPuzzleHash = id
//            recordedIDOfFirstPuzzle = true
//            return id
//        }
//    }
}


struct Puzzle : Hashable, Codable, Identifiable, GameStage{
    
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
    var dependencies : [UUID]
    
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
    
    mutating
    func solve(){
        let key = keyAlphabet.map{String($0)}.filter({ciphertext.number(of: Character($0)) != 0})
        let alphabet = String.alphabet.map({String($0)}).filter({plaintext.number(of: Character($0)) != 0})
        usersGuesses = Dictionary(uniqueKeysWithValues: zip(key,alphabet))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(puzzle : ReadablePuzzle){
        self = Puzzle(title: puzzle.title,
               plaintext: puzzle.plaintext,
               header: puzzle.header,
               footer: puzzle.footer,
               keyAlphabet: puzzle.keyAlphabet,
               id: puzzle.id,
               dependencies: puzzle.dependencies)
    }
    
    init(title : String, plaintext: String, header: String, footer : String,
         keyAlphabet : String, id: UUID, dependencies: [UUID]){
        
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
        self.id = id
        self.dependencies = dependencies
        
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

struct ReadableBook : Codable, Equatable {
    
    init(){
        title = "book title"
        theme = .defaultTheme
        chapters = [ReadableChapter(title: "Chapter 1")]
    }
    
    var title : String
    var theme : BookTheme
    var chapters : [ReadableChapter]
}

struct ReadableChapter :  Codable, Equatable, Identifiable, Hashable {
    
    init(title : String){
        self.title = title
        self.id = UUID()
        self.puzzles = [ReadablePuzzle()]
        self.gridPuzzle = ReadableGridPuzzle()
    }
    
    static func == (lhs: ReadableChapter, rhs: ReadableChapter) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var id : UUID
    var title : String
    var puzzles : [ReadablePuzzle]
    var gridPuzzle : ReadableGridPuzzle?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ReadablePuzzle : Codable, Equatable, Identifiable, Hashable, GameStage {
    
    var id = UUID()
    
    init(){
        title = "title"
        header = "header"
        footer = "footer"
        plaintext = "plaintext"
        keyAlphabet = "key alphabet"
        dependencies = []
    }
    
    var title : String
    var header : String
    var plaintext : String
    var footer : String
    var keyAlphabet : String
    var dependencies : [UUID]
    var isSolved: Bool = false
}

struct ReadableGridPuzzle : Codable, Identifiable, Equatable, GameStage {
    
    init(){
        title = "Grid puzzle"
        type = .all
        size = 4
        dependencies = []
    }
    
    var title: String
    var id = UUID()
    var type : GridSolution
    var size : Int
    var image : String?
    var solutionImage : String?
    var dependencies : [UUID]
    var isSolved: Bool = false
}

protocol GameStage {
    var isSolved: Bool {get}
    var id: UUID {get}
    var dependencies: [UUID] {get}
    var title: String {get}
}
