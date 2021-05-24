//
//  CipherViewModel+Printing.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import Foundation

extension CipherPuzzle{
    
    static let charsPerPrintedLine = 40
    
    var printableHTML : String {
        
        guard let currentCipherPuzzle = currentCipherPuzzle else {return ""}
        
        let puzzleLines = self.puzzleLines(charsPerLine: Self.charsPerPrintedLine)
        
        var cipherChars : [[String]] = []
        var userGuesses : [[String]] = []
        
        
        cipherChars = puzzleLines.map{line in line.characters.map{info in
            if self.capType == 3 {
                return info.cipherLetter.uppercased()
            } else {
                return String(info.cipherLetter)
            }
        }}
        
        userGuesses = puzzleLines.map{line in line.characters.map{info in
            if self.capType == 3 {
                return info.userGuessLetter?.uppercased() ?? " "
            } else {
                return info.userGuessLetter.string()
            }
        }}
        
        let printableLines = zip(cipherChars, userGuesses)
        
        var output : String = ""

        output += "<html>\n"
        output += Self.cssStyling.replacingOccurrences(of: "@@@", with: self.fontDesign.cssName())
        
        output += "\n<h1>\(String(currentCipherPuzzle.title.capitalized))</h1>\n"
        
        output += HTMLletterCountTable
        
        output += "<p class='text'>" + currentCipherPuzzle.header + "</p>"
        
        output += "\n<table id='ciphertext'>\n"
        
        for line in printableLines {
            output += htmlPuzzleRow(from: line.0, secondArray: line.1, withClass: "row", id: nil)
        }
        output += "\n</table>\n"

        output += "<p class='text'>" + currentCipherPuzzle.footer + "</p>"

        output += "\n</html>\n"
        
//        print(output)
        return output
    }

    private
    var HTMLletterCountTable : String {
                
        let letterCount = self.letterCount
        var output = ""
        
        let characters : [String] = letterCount.map {pair in String(pair.character)}
        let userGuesses : [String] = String.alphabet.map {char in String(plaintext(for: char) ?? " ")}
        var counts : [String] = letterCount.map {pair in String(pair.count)}
        
        //replace zeros with -
        counts = counts.map{number in number == "0" ? "-" : number}
        
        var rowsToPrint : [[String]] = []
        
        switch self.capType {
        case 3:
            rowsToPrint = [characters,userGuesses,counts].map{array in array.map {string in string.uppercased() }}
        default:
            rowsToPrint = [characters,userGuesses,counts]
        }
        
        output += "\n<h2>character count</h2>\n"
        output += "\n<table id='letterCount'>\n"
        
        for collection in zip(rowsToPrint, ["characters", "userGuesses", "counts"]) {
            output += htmlTableRow(from: collection.0, withClass: nil, id: collection.1)
        }

        output += "\n</table>\n"
        
        return output
    }
    
    
    fileprivate
    func htmlTableRow<T: Sequence>(from array : T, withClass classLabel : String?, id idLabel : String?) -> String where T.Iterator.Element : StringProtocol {
        
        var output : String = ""
        
        let classHTML = (classLabel != nil) ? "class='\(classLabel ?? "")'" : ""
        let idHTML = (idLabel != nil) ? "id='\(idLabel ?? "")'" : ""
        
        output += "\n<tr \(classHTML) \(idHTML)>\n"
        for chars in array {
            output += "<td>" + chars + "</td>"
        }
        output += "\n</tr>\n"
        
        return output
    }
    
    
    
    fileprivate
    func htmlPuzzleRow<T: Sequence>(from firstArray : T, secondArray : T, withClass classLabel : String?, id idLabel : String?) -> String where T.Iterator.Element : StringProtocol {
        
        let tableData = zip(firstArray, secondArray)
        
        var output : String = ""
        
        let classHTML = (classLabel != nil) ? "class='\(classLabel ?? "")'" : ""
        let idHTML = (idLabel != nil) ? "id='\(idLabel ?? "")'" : ""
        
        output += "\n<tr \(classHTML) \(idHTML)>\n"
        
        for (ciphertext, plaintext) in tableData {
            output += "<td>"
            output += "<p class='cipherRow'>" + ciphertext + "</p>"
            output += "<p class='guessRow'>" + plaintext + "</p>"
            output += "</td>\n"
        }
        output += "\n</tr>\n"
        return output
    }
    
    static let cssStyling = { () -> String in
        if let url = Bundle.main.path(forResource: "CipherPrint", ofType: "css"){
            do {
                return try String(contentsOfFile: url)
            }
            catch{
                return "unable fo find CipherPuzzle.css"
            }
        }
        return "couldn't find css file in bundle"
    }()
}

