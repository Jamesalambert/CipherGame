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
                              solution: "escidpoumgvhaqrjntzfbwklyx") //random seed 1 python
    
    static let island = Puzzle(title: "Island", ciphertext: "erfcgyubdj \nbywgyqwy getvhcnxmlapow uhhvfrbh cbh2.", solution: "")
    
    
    //MARK: - public
    var puzzles : [Puzzle] = [space, island]
    
    mutating
    func updateUsersGuesses(cipherCharacter : Character,
                            plaintextCharacter : Character?,
                            in puzzle : String,
                            at index : Int){
        
        guard let currentPuzzleIndex = puzzles.firstIndex(where: {$0.title == puzzle}) else {return}
        
        //discard uppercase!
        let lowerPlainCharacter = plaintextCharacter.lowerCharOpt()
        let lowerCipherCharacter = cipherCharacter.lowerChar()
        
        //user entered a non-nil char
        if let lowerPlainCharacter = lowerPlainCharacter {

            var newGuessArray : [Int] = [index]
            if let guessIndices = puzzles[currentPuzzleIndex].usersGuesses[lowerCipherCharacter]?.1 {
                newGuessArray = guessIndices + newGuessArray
            }
            
            //update model
            puzzles[currentPuzzleIndex].usersGuesses[lowerCipherCharacter] = (lowerPlainCharacter, newGuessArray)
            
            //remove guess
        } else {
            puzzles[currentPuzzleIndex].usersGuesses.removeValue(forKey: lowerCipherCharacter)
        }
        
//        check to see if the puzzle is solved
        if self.isSolved(puzzles[currentPuzzleIndex]) {
            puzzles[currentPuzzleIndex].isSolved = true
        } else {
            puzzles[currentPuzzleIndex].isSolved = false
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
    
}




struct Puzzle {
        
    var title : String
    var ciphertext : String
    var solution : String
    var isSolved : Bool = false
    
    var usersGuesses : Dictionary<Character, (Character, [Int])> = Dictionary()
    
    func letterCount() -> [(Character,Int)] {
        var output : [(Character,Int)] = []
        
        for letter in String.alphabet {
            output.append((letter, self.ciphertext.number(of: letter)))
        }
        return output
    }
    
}

