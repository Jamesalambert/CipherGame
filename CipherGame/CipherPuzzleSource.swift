//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game {
    
    var puzzles : Dictionary<String,String> = [
        "space" : "Jhgsefhjsc,jbhqjbhcfwjq \nbhcfvjhbcercbkhjav jhvweghmawiqjjiw.",
        "Island" : "erfcgyubDj \nbywgyqwy getvhcnxmlapow uhhvfrbh cbh2."
    ]
    
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
