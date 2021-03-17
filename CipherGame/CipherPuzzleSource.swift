//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game {
    
    static let space = Puzzle(title: "space", ciphertext: "Jhgsefhjsc,jbhqjbhcfwjq \nbhcfvjhbcercbkhjav jhvweghmawiqjjiw.")
    
    static let island = Puzzle(title: "Island", ciphertext: "erfcgyubDj \nbywgyqwy getvhcnxmlapow uhhvfrbh cbh2.")
    
    
    //MARK: - public
    var puzzles : [Puzzle] = [space, island]
    
//    var currentPuzzleIndex = 1 {
//        didSet{
//            if currentPuzzleIndex >= puzzles.count {
//                currentPuzzleIndex = puzzles.count - 1
//            } else if currentPuzzleIndex < 0 {
//                currentPuzzleIndex = 0
//            }
//        }
//    }
//
//    private
//    var currentPuzzle : Puzzle {
//        return puzzles[currentPuzzleIndex]
//    }
    //MARK:-
    
    mutating func updateUsersGuesses(cipherCharacter : Character, plaintextCharacter : Character, in puzzle : String){
        
        guard let currentPuzzleIndex = puzzles.firstIndex(where: {$0.title == puzzle}) else {return}
        
        puzzles[currentPuzzleIndex].usersGuesses[cipherCharacter] = plaintextCharacter
    }
}

struct Puzzle {
    var title : String
    var ciphertext : String
    
    var usersGuesses : Dictionary<Character, Character> = {
        
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        var output = Dictionary<Character, Character>()
        
        for char in alphabet {
            output[char] = nil
        }
        
        return output
    }() {
        didSet{
            print(usersGuesses)
        }
    }
}
