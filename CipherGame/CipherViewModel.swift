//
//  CipherViewModel.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI


class CipherPuzzle : ObservableObject {
    
    //static let blank : Character = " "
    
    @Published
    private
    var model : Game = Game()
    
    @Published
    var currentPuzzleTitle : String? = "space"
    
    var currentPuzzle : Puzzle? {
        guard let currentPuzzleTitle = self.currentPuzzleTitle else {return nil}
        guard let currentPuzzle = model.puzzles.first(where: {$0.title == currentPuzzleTitle}) else {return nil}
        return currentPuzzle
    }
    
    @Published
    var currentCiphertextCharacter : Character? = nil
    
    @Published
    var currentUserSelectionIndex : Int? = nil
    
    @Published
    var gameLevel : Int = 0 {
        didSet{
            if gameLevel > gameRules.count {
                gameLevel = gameRules.count - 1
            } else if gameLevel < 0 {
                gameLevel = 0
            }
        }
    }
    
    //MARK: - public API
    var availablePuzzles : [PuzzleTitle] {
        
        var out : [PuzzleTitle] = []
        for (index, puzzle) in model.puzzles.enumerated() {
            out.append(PuzzleTitle(id: index,
                                   title: puzzle.title))
        }
        return out
    }
    
    
    var userGuess : Character? {
        
        get {
            guard let current = currentCiphertextCharacter else {return nil}
            return self.plaintext(for: current)
        }
        
        set {
            guard let newValue = newValue else {return}
            
            model.updateUsersGuesses(cipherCharacter: currentCiphertextCharacter!,
                                     plaintextCharacter: newValue,
                                     in: currentPuzzleTitle!,
                                     at: currentUserSelectionIndex!)
        }
    }
    
    var data : [GameInfo] {
     
        guard self.currentPuzzle != nil else {return []}
        
        var puzzleData = Array<GameInfo>()
        
        for (index, char) in self.currentPuzzle!.ciphertext.enumerated() {
            
            if let newPair = gameRules[gameLevel]?(char, index) {
                puzzleData.append(newPair)
            }
        }
        
        return puzzleData
    }
    
    var letterCount : [(Character, Int)] {return currentPuzzle?.letterCount() ?? []}
    
    func plaintext(for ciphertext : Character) -> Character?{
                
        return currentPuzzle!.usersGuesses[ciphertext]?.0
    }
    
    var printableHTML : String {
        
//        guard let currentPuzzle = currentPuzzle else {return "couldn't find puzzle!"}
        
        let charsPerLine = 30
        let lines : Int = Int(ceil(Double(self.data.count / charsPerLine)))
        let data = self.data
        
        var index : Int = 0
        var output : String = ""
        
        output += "<html>\n"
        output += CipherPuzzle.cssStyling
        
        output += "<h1>\(String(currentPuzzleTitle ?? "error!"))</h1>"
        output += htmlLetterCount
        
        output += "<table id='ciphertext'>\n"
        
        for line in 0..<lines {
            
            output += "<tr>"
            for charOffset in 0...charsPerLine {
                index = line * charsPerLine + charOffset
 
                output += "<td>"
                output += String(data[index].cipherLetter)
                output += "</td>"

            }
            output += "</tr>\n"
        }

        output += "</table>\n"
        output += "</html>\n"
        
        print(output)
        return output

    }
    
    private
    var htmlLetterCount : String {
        
//        var index : Int = 0
        let letterCount = self.letterCount
        var output = ""
        
        var characters : [String] = []
        var counts : [String] = []

        for pair in letterCount {
            characters.append(String(pair.0))
            counts.append(String(pair.1))
        }
        
        output += "<h2>Character count</h2>"
        output += "<table id='letterCount'>"
        
        for collection in [characters, counts] {
            output += "<tr>"
            for item in collection {
                output += "<td>"
                output += String(item)
                output += "</td>"
            }
            output += "</tr>\n"
        }

        output += "</table>\n"
        
        return output
    }
    
    
    //MARK:- private
    
    private
    func easyGameInfo(for ciphertext : Character, at index : Int) -> GameInfo? {
        
        let newPair = GameInfo(id: index,
                               cipherLetter: ciphertext,
                               userGuessLetter: plaintext(for: ciphertext))
        return newPair
    }
    
    
    private
    func mediumGameInfo(for ciphertext : Character, at index: Int) -> GameInfo? {
        
        if String.alphabet.contains(ciphertext) {
            return easyGameInfo(for: ciphertext, at: index)
        }
        return nil
    }
    
    
    
    private
    func hardGameInfo(for ciphertext : Character, at index: Int) -> GameInfo? {
        
        var mediumLevel = mediumGameInfo(for: ciphertext, at: index)
        
        if let guessIndices = currentPuzzle?.usersGuesses[ciphertext]?.1 {
            if guessIndices.containsItem(within: 20, of: index){
                return mediumLevel
            }
        }
        
        mediumLevel?.userGuessLetter = nil
        return mediumLevel
    }
    
    
    private
    var gameRules : [ Int : (Character, Int) -> GameInfo? ]{
        return [0 : easyGameInfo,
                1 : mediumGameInfo,
                2 : hardGameInfo]
    }
    
    
    //MARK:- structs
    
    struct PuzzleTitle : Identifiable, Hashable {
        var id : Int
        var title : String
    }
    
}

struct GameInfo : Identifiable {
    
    var id: Int
    
    var cipherLetter : Character
    var userGuessLetter : Character?
}

extension CipherPuzzle {
    static let cssStyling : String  = """
    <head>
            <style>
            body {
                text-align: center;
                font-family: -apple-system, sans-serif;
            }

             table {
              max-width: 100%;
              margin-left: auto;
              margin-right: auto;
              //margin-top: 10vh;
              margin-bottom: 10vh;
            text-align: center;
            }
            
            #ciphertext td {
                padding-bottom: 20px;
                border-bottom: 1px solid gray;
            }

            #letterCount td{
                border-bottom: 1px solid gray;
                padding-bottom: 20px;
            }
            

            </style>
            </head>\n
"""
}


extension Color {
    static let blue = Color.blue
    static let orange = Color.orange
    
    static func highlightColor(for colorScheme : ColorScheme) -> Color{
        if colorScheme == .light {
            return orange
        } else {
            return blue
        }
    }
}

extension Array where Element == Int {
    
    func containsItem(within distance : Int, of index : Int)-> Bool {
        if self.first(where: { item in abs(item - index) <= distance}) != nil {
            return true
        }
        return false
    }
    
    
}
