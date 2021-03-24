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
        let numberOfLines : Int = Int(ceil(Double(self.data.count / charsPerLine)))
        
        let data = self.data
        let cipherChars = data.map{item in item.cipherLetter}
        let userGuesses = data.map{item in item.userGuessLetter}
        
        //var index : Int = 0
        var output : String = ""
        
        
        func htmlTableRow(from array : [Character?], from start : Int, to end : Int, withClassName classLabel : String) -> String {
            
            var output : String = ""
            
            output += "<tr class='\(classLabel)'>"
            for charOffset in start...end {
                output += "<td>"
                output += array[charOffset].string()
                output += "</td>"
            }
            output += "</tr>\n"
            
            return output
        }
        

        output += "<html>\n"
        output += CipherPuzzle.cssStyling
        
        output += "<h1>\(String(currentPuzzleTitle ?? "error!"))</h1>"
        output += htmlLetterCount
        
        output += "<table id='ciphertext'>\n"
        
        for line in 0..<numberOfLines {
            let start = line * charsPerLine
            let end  = line * charsPerLine + charsPerLine
            output += htmlTableRow(from: cipherChars, from: start, to: end, withClassName: "cipherRow")
            output += htmlTableRow(from: userGuesses, from: start, to: end, withClassName: "guessRow")
        }

        output += "</table>\n"
        output += "</html>\n"
        
        print(output)
        return output
        
    }
    
    private
    var htmlLetterCount : String {
        
        let letterCount = self.letterCount
        var output = ""
        
        var characters : [String] = []
        var counts : [String] = []

        for pair in letterCount {
            characters.append(String(pair.0))
            counts.append(String(pair.1))
        }
        
        
        let userGuesses = String.alphabet.map {char in String(plaintext(for: char) ?? " ")}
        
        output += "<h2>Character count</h2>"
        output += "<table id='letterCount'>"
        
        for collection in zip([characters, userGuesses, counts], ["characters", "userGuesses", "counts"]) {
            output += "<tr id='\(collection.1)'>"
            for item in collection.0 {
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
        margin: 3cm 0cm 3cm 0cm;
    }

    h1 {
        padding-bottom: 2cm;
    }

    table {
        max-width: 100%;
        margin-left: auto;
        margin-right: auto;
        margin-bottom: 2cm;
        text-align: center;
    }
    
    #ciphertext {
        border-collapse: collapse;
    }

    .cipherRow td {
        padding-top : 0.5cm;
        color: red;
    }
        
    .guessRow td {
        border-bottom: 1px solid gray;
    }
    
    #letterCount {
        border-collapse: collapse;
        border-top: 1.5px solid black;
        border-bottom: 1.5px solid black;
    }

    #letterCount td{
        border-bottom: 0.5px solid gray;
        padding: 0.1cm 0.1cm 0.1cm 0.1cm;
    }
    
    #characters td {
        color : red;
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

extension Optional where Wrapped == Character {
    
    func string() -> String {
        if let currentValue = self {
            return String(currentValue)
        } else {
            return ""
        }
    }
}
