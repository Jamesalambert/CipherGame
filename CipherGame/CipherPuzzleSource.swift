//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game {
    
    static let space = Puzzle(title: "space",
                              ciphertext: """
fr hrcefd fud amzzmqo itrmi yrb kmhh qddi fr ftewdh fr fmfeq, fud hetodzf arrq\
rp zefbtq. fud itrmi kez zbjjrzdi fr hrrv prt zmoqz rp hmpd rq fumz zfteqod arrq\
sbf imzejjdetdi futdd arqfuz mqfr mfz amzzmrq. fud dlecf hrcefmrq ceq sd prbqi\
mq yrbt zumj'z crajbfdt is rqd futdd futdd. fud itrmi heqidi wdty chrzd fr fumz\
hrcefmrq eqi mf arwdz zhrkhy zr zurbhi qrf sd pet ekey. fud itrmi uez e teimr sdecrq\
fuef zdqiz fud zead adzzeod dwdty fumtfy amqbfdz, fud adzzeod zeyz wmomheqcd rqd\
fkr futdd.
""",
                              solution: "escidpoumgvhaqrjntzfbwklyx",
                              id: 0) //random seed 1 python
    
    static let island = Puzzle(title: "Island",
                               ciphertext: "erfcgyubdj \nbywgyqwy getvhcnxmlapow uhhvfrbh cbh2.",
                               solution: "",
                               id: 1 )
    
    static let firstBook = Book(title: "first book",
                                puzzles: [space, island],
                                id: 0)
    
    //MARK: - public
//    var puzzles : [Puzzle] = [space, island]
    var books : [Book] = [firstBook]
    
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

            var newGuessArray : [Int] = [index]
            if let guessIndices = puzzle.usersGuesses[lowerCipherCharacter]?.1 {
                newGuessArray = guessIndices + newGuessArray
            }
            
            //update model
            books[bookIndex].puzzles[puzzleIndex].usersGuesses[lowerCipherCharacter] = (lowerPlainCharacter, newGuessArray)
            
            //remove guess
        } else {
            books[bookIndex].puzzles[puzzleIndex].usersGuesses.removeValue(forKey: lowerCipherCharacter)
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
        let guesses = String.alphabet.map{char in puzzle.usersGuesses[char]?.0}
        
        let userSolution = String(guesses.compactMap{$0})
        
        if userSolution == puzzle.solution {
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
    
}




struct Puzzle : Hashable{
    
    static func == (lhs: Puzzle, rhs: Puzzle) -> Bool {
        return lhs.id == rhs.id
    }

    var title : String
    var ciphertext : String
    var solution : String
    var isSolved : Bool = false
    var id : Int
    var usersGuesses : Dictionary<Character, (Character, [Int])> = Dictionary()
    
    func letterCount() -> [(Character,Int)] {
        var output : [(Character,Int)] = []
        
        for letter in String.alphabet {
            output.append((letter, self.ciphertext.number(of: letter)))
        }
        return output
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(solution)
        hasher.combine(isSolved)
    }
    
}

struct Book : Hashable{
   
    var title : String
    var puzzles : [Puzzle]
    var id : Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
}

