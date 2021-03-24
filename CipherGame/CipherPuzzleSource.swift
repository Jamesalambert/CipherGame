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
        
        if let plaintextCharacter = plaintextCharacter {
            
            var newGuessArray : [Int] = [index]
            
            if let guessIndices = puzzles[currentPuzzleIndex].usersGuesses[cipherCharacter]?.1 {
                newGuessArray = guessIndices + newGuessArray
            }
            //update model
            puzzles[currentPuzzleIndex].usersGuesses[cipherCharacter] = (plaintextCharacter, newGuessArray)
            
        } else {
            //remove from guesses
            puzzles[currentPuzzleIndex].usersGuesses.removeValue(forKey: cipherCharacter)
        }
    }
}




struct Puzzle {
        
    var title : String
    var ciphertext : String
    var solution : String
    
    var usersGuesses : Dictionary<Character, (Character, [Int])> = Dictionary()
    
    func letterCount() -> [(Character,Int)] {
        var output : [(Character,Int)] = []
        
        for letter in String.alphabet {
            output.append((letter, self.ciphertext.number(of: letter)))
        }
        return output
    }
    
}

