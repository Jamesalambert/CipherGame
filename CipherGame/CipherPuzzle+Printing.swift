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
        output += HTMLletterCountTable
        
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
    var HTMLletterCountTable : String {
        
        let letterCount = self.letterCount
        var output = ""
        
        let characters : [String] = letterCount.map {pair in String(pair.0)}
        let userGuesses = String.alphabet.map {char in String(plaintext(for: char) ?? " ")}
        let counts : [String] = letterCount.map {pair in String(pair.1)}
              
        output += "<h2>Character count</h2>"
        output += "<table id='letterCount'>"
        
        for collection in zip([characters, userGuesses, counts],
                              ["characters", "userGuesses", "counts"]) {
            
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

