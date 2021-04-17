//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game : Codable {
    
    static let bookNames = ["lessons", "Rebecca's Garden"]
    static let firstPuzzle = (book: "lessons", puzzle: "pattern words")
    static let themeFor : [String : BookTheme] = [
        "lessons"           : .defaultTheme,
        "Rebecca's Garden"  : .space
    ]
    
    //MARK: - public
    private(set)
    var books : [Book]
    var lastOpenPuzzleHash : UUID?
    
    mutating
    func reset(_ puzzle : Puzzle){
        guard let currentPuzzleIndexPath = self.indexPath(for: puzzle) else {return}
        let bookIndex = currentPuzzleIndexPath.item
        let puzzleIndex = currentPuzzleIndexPath.section
        
        //reset guesses and indices
        books[bookIndex].puzzles[puzzleIndex].usersGuesses.removeAll()
        books[bookIndex].puzzles[puzzleIndex].guessIndices.removeAll()
    }
    
//    mutating
//    func update(cipherCharacter : Character,
//                            plaintextCharacter : Character?,
//                            in puzzle : Puzzle,
//                            at index : Int){
//    
//        
//        updateUsersGuesses(cipherCharacter: cipherCharacter,
//                           plaintextCharacter: plaintextCharacter,
//                           in: puzzle, at: index)
//    }
    
    
    mutating
    func updateUsersGuesses(cipherCharacter : Character,
                            plaintextCharacter : Character?,
                            in puzzle : Puzzle,
                            at index : Int){
        
        guard let currentPuzzleIndexPath = self.indexPath(for: puzzle) else {return}
        let bookIndex = currentPuzzleIndexPath.item
        let puzzleIndex = currentPuzzleIndexPath.section
        
        //discard uppercase!
        let lowerPlainCharacter = plaintextCharacter.lowerCharOpt()
        let lowerCipherCharacter = String(cipherCharacter.lowerChar())
        
        //user entered a non-nil char
        if let lowerPlainCharacter = lowerPlainCharacter {
            
            //update model
            books[bookIndex].puzzles[puzzleIndex].usersGuesses[lowerCipherCharacter] = String(lowerPlainCharacter)
            
            if let _ = books[bookIndex].puzzles[puzzleIndex].guessIndices[lowerCipherCharacter] {
                books[bookIndex].puzzles[puzzleIndex].guessIndices[lowerCipherCharacter]?.insert(index)
            } else {
                books[bookIndex].puzzles[puzzleIndex].guessIndices[lowerCipherCharacter] = [index]
            }
            
            //remove guess for ciphertext character
        } else {
            books[bookIndex].puzzles[puzzleIndex].usersGuesses.removeValue(forKey: lowerCipherCharacter)
            books[bookIndex].puzzles[puzzleIndex].guessIndices.removeValue(forKey: lowerCipherCharacter)
        }
    }
    
    private
    func indexPath(for puzzle: Puzzle) -> IndexPath? {
        guard let bookIndex = books.firstIndex(where: {book in book.puzzles.contains(puzzle)} ) else {return nil}
        guard let puzzleIndex = books[bookIndex].puzzles.firstIndex(of: puzzle) else {return nil}
        
        return IndexPath(item: bookIndex, section: puzzleIndex)
    }
    
    
    init(){
        self.books = []

        for bookName in Game.bookNames {
            
            guard let JSONurl = Bundle.main.url(forResource: bookName, withExtension: "json") else {return}
            
            do {
                if let data = try String(contentsOf: JSONurl).data(using: .utf8) {
                    
                    let puzzles = try JSONDecoder().decode([ReadablePuzzle].self, from: data)

                    let newPuzzles = puzzles.map{ puzzle in
                        
                        Puzzle(title: puzzle.title,
                               plaintext: puzzle.plaintext,
                               header: puzzle.header,
                               footer: puzzle.footer,
                               keyAlphabet: puzzle.keyAlphabet,
                               id: id(for: puzzle.title, in: bookName))
                        }
                    
                    self.books.append(Book(title: bookName,
                                           puzzles: newPuzzles,
                                           theme: Self.themeFor[bookName] ?? .defaultTheme))
                    print(bookName)
                }
            }
            catch {
                print("error Couldn't read input json file \(JSONurl)")
            }
        }
    }
    
    private
    mutating
    func id(for puzzleTitle : String, in bookTitle : String) -> UUID {
        let id = UUID()
        if Game.firstPuzzle.book == bookTitle && Game.firstPuzzle.puzzle == puzzleTitle {
            lastOpenPuzzleHash = id
        }
        return id
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
    var solution : String          //what the user needs to figure out (the message may not use all letters)
   
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
    
    init(title : String, plaintext: String, header: String, footer : String, keyAlphabet : String, id: UUID){
        
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
    var puzzles : [Puzzle]
    var id = UUID()
    var isSolved : Bool = false
    var theme : BookTheme = .defaultTheme
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ReadablePuzzle : Codable {
    var title : String
    var header : String
    var plaintext : String
    var footer : String
    var keyAlphabet : String
}

enum BookTheme : Int, Codable {
    case defaultTheme = 0
    case space = 1
}

