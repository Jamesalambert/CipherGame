//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game {
    
    static let space = Puzzle(title: "space",
                              plaintext: """
fr hrcefd fud amzzmqo itrmi yrb kmhh qddi fr ftewdh fr fmfeq, fud hetodzf arrq\
rp zefbtq. fud itrmi kez zbjjrzdi fr hrrv prt zmoqz rp hmpd rq fumz zfteqod arrq\
sbf imzejjdetdi futdd arqfuz mqfr mfz amzzmrq. fud dlecf hrcefmrq ceq sd prbqi\
mq yrbt zumj'z crajbfdt is rqd futdd futdd. fud itrmi heqidi wdty chrzd fr fumz\
hrcefmrq eqi mf arwdz zhrkhy zr zurbhi qrf sd pet ekey. fud itrmi uez e teimr sdecrq\
fuef zdqiz fud zead adzzeod dwdty fumtfy amqbfdz, fud adzzeod zeyz wmomheqcd rqd\
fkr futdd.
""",
                              keyAlphabet: "escidpoumgvhaqrjntzfbwklyx") //random seed 1 python
    
    static let island = Puzzle(title: "Island",
                               plaintext: "erfcgyubdj \nbywgyqwy \tgetvhcnxmlapow uhhvfrbh cbh2.",
                               keyAlphabet: "b")
    
    static let firstBook = Book(title: "first book",
                                puzzles: [space, island])
    
    //MARK: - public
    var books : [Book]// = [firstBook]
    
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
        let lowerCipherCharacter = cipherCharacter.lowerChar()
        
        //user entered a non-nil char
        if let lowerPlainCharacter = lowerPlainCharacter {
            
            //update model
            books[bookIndex].puzzles[puzzleIndex].usersGuesses[String(lowerCipherCharacter)] = String(lowerPlainCharacter)
            
            if let _ = books[bookIndex].puzzles[puzzleIndex].guessIndices[String(lowerCipherCharacter)] {
                books[bookIndex].puzzles[puzzleIndex].guessIndices[String(lowerCipherCharacter)]?.insert(index)
            } else {
                books[bookIndex].puzzles[puzzleIndex].guessIndices[String(lowerCipherCharacter)] = [index]
            }
            
            //remove guess for ciphertext character
        } else {
            books[bookIndex].puzzles[puzzleIndex].usersGuesses.removeValue(forKey: String(lowerCipherCharacter))
            books[bookIndex].puzzles[puzzleIndex].guessIndices.removeValue(forKey: String(lowerCipherCharacter))
        }
        
//        check to see if the puzzle is solved
        if self.isSolved(books[bookIndex].puzzles[puzzleIndex]) {
            books[bookIndex].puzzles[puzzleIndex].isSolved = true
        } else {
            books[bookIndex].puzzles[puzzleIndex].isSolved = false
        }
    }
    
    private
    func isSolved(_ puzzle : Puzzle) -> Bool {
        
        //get user's guesses
        let guesses : String = String.alphabet.compactMap{char in (puzzle.usersGuesses[String(char)])}.joined()
        
        //let userSolution = guesses.compactMap{$0}
        
        if guesses == puzzle.solution {
            return true
        }
        
        return false
    }
    
    private
    func indexPath(for puzzle: Puzzle) -> IndexPath? {
        guard let bookIndex = books.firstIndex(where: {book in book.puzzles.contains(puzzle)} ) else {return nil}
        guard let puzzleIndex = books[bookIndex].puzzles.firstIndex(of: puzzle) else {return nil}
        
        return IndexPath(item: bookIndex, section: puzzleIndex)
    }
    
    
    init(){
        self.books = []
        guard let JSONurl = Bundle.main.url(forResource: "puzzles", withExtension: "json") else {return}
        do {
            if let data = try String(contentsOf: JSONurl).data(using: .utf8) {
                
                let puzzles = try JSONDecoder().decode([ReadablePuzzle].self, from: data)
                self.books = [Book(title: "first book",
                                   puzzles: puzzles.map{ puzzle in
                                    
                                    Puzzle(title: puzzle.title,
                                           plaintext: puzzle.plaintext,
                                           keyAlphabet: puzzle.keyAlphabet)
                                })]
            }
        }
        catch {
            print("error Couldn't read inut json file \(JSONurl)")
        }
    }
    
    
    
    
}




struct Puzzle : Hashable, Codable{
    
    static func == (lhs: Puzzle, rhs: Puzzle) -> Bool {
        return lhs.id == rhs.id
    }

    var title : String
    var ciphertext : String
    var plaintext : String
    private
    var keyAlphabet : String        //the original key alphabet
    
    var solution : String {
        return keyAlphabet.filter{character in ciphertext.number(of: character) > 0}
    }
    
    var isSolved : Bool = false
    var id = UUID()
    var usersGuesses : [String : String] = Dictionary()
    var guessIndices : [String : Set<Int>] = Dictionary()
    
    func letterCount() -> [(Character,Int)] {
        var output : [(Character,Int)] = []
        
        for letter in String.alphabet {
            output.append((letter, ciphertext.number(of: letter)))
        }
        return output
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(title : String, plaintext: String, keyAlphabet : String){
        
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
        
        self.title = title
        self.keyAlphabet = keyAlphabet
        self.plaintext = plaintext
        
        //remove most whitespace
        var removeChars = CharacterSet.whitespacesAndNewlines
        removeChars.remove(charactersIn: " ") //leave spaces!
        
        //create ciphertext
        self.ciphertext = encryptCipher(plaintext.removeCharacters(in: removeChars),
                                        with: keyAlphabet)
    }
    
    
        
    
    
}

struct Book : Hashable, Codable{
   
    var title : String
    var puzzles : [Puzzle]
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

struct ReadablePuzzle : Codable {
    var title : String
    var plaintext : String
    var keyAlphabet : String
}


