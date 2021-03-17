//
//  CipherPuzzleSource.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import Foundation


struct Game {
    let puzzle = "jkgkuyerscky scjyugcfsjkfgwcj,cersfkjbhj,aqchj aceqwk \njyacfwj yqwfcgjky"
    
    
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
