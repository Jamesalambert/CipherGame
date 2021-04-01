//
//  CipherViewModel+Printing.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import Foundation

extension CipherPuzzle{
    
    static let charsPerLine = 40
    
    var printableHTML : String {
                
        //let charsPerLine = 40
        let numberOfLines = Int(ceil(Double(self.data.count) / Double(CipherPuzzle.charsPerLine)))
        let charsOnLastLine = self.data.count % CipherPuzzle.charsPerLine
        
        let data = self.data
        var cipherChars : [String] = []
        var userGuesses : [String] = []
        
        switch self.capType {
        case 3:
            cipherChars = data.map{item in String(item.cipherLetter).uppercased()}
            userGuesses = data.map{item in String(item.userGuessLetter ?? " ").uppercased()}
        default:
            cipherChars = data.map{item in String(item.cipherLetter)}
            userGuesses = data.map{item in String(item.userGuessLetter ?? " ")}
        }
        
        
        //var index : Int = 0
        var output : String = ""

        output += "<html>\n"
        output += CipherPuzzle.cssStyling.replacingOccurrences(of: "@@@", with: self.fontDesign.cssName())
        
        output += "\n<h1>\(String(currentPuzzle?.title.capitalized ?? "error!"))</h1>\n"
        output += HTMLletterCountTable
        
        output += "\n<table id='ciphertext'>\n"
        
        for line in 0..<numberOfLines {
            let start = line * CipherPuzzle.charsPerLine
            let end  = line * CipherPuzzle.charsPerLine + (line == numberOfLines - 1 ? charsOnLastLine - 1 : CipherPuzzle.charsPerLine)

            output += htmlPuzzleRow(from: cipherChars[start...end], secondArray: userGuesses[start...end], withClass: "row", id: nil)
        }

        output += "\n</table>\n"
        output += "\n</html>\n"
        
//        print(output)
        return output
        
    }

    private
    var HTMLletterCountTable : String {
        
        let letterCount = self.letterCount
        var output = ""
        
        let characters : [String] = letterCount.map {pair in String(pair.0)}
        let userGuesses : [String] = String.alphabet.map {char in String(plaintext(for: char) ?? " ")}
        var counts : [String] = letterCount.map {pair in String(pair.1)}
        
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

