//
//  CipherViewModel+Printing.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import Foundation

extension CipherPuzzle{
    
    var printableHTML : String {
                
        let charsPerLine = 30
        let numberOfLines = Int(ceil(Double(self.data.count) / Double(charsPerLine)))
        let charsOnLastLine = self.data.count % charsPerLine
        
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
            let start = line * charsPerLine
            let end  = line * charsPerLine + (line == numberOfLines - 1 ? charsOnLastLine - 1 : charsPerLine)

            output += htmlTableRow(from: cipherChars[start...end], withClass: "cipherRow", id: nil)
            output += htmlTableRow(from: userGuesses[start...end], withClass: "guessRow", id: nil)
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
        let counts : [String] = letterCount.map {pair in String(pair.1)}
        
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
        
        output += "\n<tr class='\(classLabel ?? " ")' id='\(idLabel ?? " ")'>\n"
        for chars in array {
            output += "<td>" + chars + "</td>"
        }
        output += "\n</tr>\n"
        
        return output
    }
    
    
    static let cssStyling : String  = """

<head>
<style>
    body {
        text-align: center;
        font-family: @@@;
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
        height: 8mm;
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
    
    #userGuesses td {
        height: 8mm;
    }

</style>
</head>\n
"""

}

