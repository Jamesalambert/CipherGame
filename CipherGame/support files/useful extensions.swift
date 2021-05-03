//
//  useful extensions.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import SwiftUI

extension CGRect {
    var center : CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

//used for hard setting
extension Array where Element == Int {
    
    func containsItem(within distance : Int, of index : Int)-> Bool {
        if self.first(where: { item in abs(item - index) <= distance}) != nil {
            return true
        }
        return false
    }
}


extension Set where Element == Int {
    func containsItem(within distance : Int, of index : Int)-> Bool {
       return self.contains(where: { item in abs(item - index) <= distance})
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
    
    func upperCharOpt() -> Self {
        if let currentValue = self {
            return Character(String(currentValue).uppercased())
        } else {
            return self
        }
    }
    
    func lowerCharOpt() -> Self {
        if let currentValue = self {
            return Character(String(currentValue).lowercased())
        } else {
            return self
        }
    }

}


extension Character {
    func upperChar() -> Character {
        return Character(String(self).uppercased())
    }
    
    func lowerChar() -> Character {
        return Character(String(self).lowercased())
    }
    
}

extension Collection where Element : Hashable {
    
    func count(for item : Element) -> Int {
        return reduce(0) { (total, nextItem) -> Int in
            nextItem == item ? total + 1 : total}
    }
}


//used for the letter counts
extension String {
    
    static let alphabet = "abcdefghijklmnopqrstuvwxyz"
    static let qwerty = ["qwertyuiop",
                         "asdfghjkl",
                         "zxcvbnm"]
    
    
    func number(of character : Character) -> Int{
        return reduce(0) { (total, nextChar) -> Int in
            nextChar == character ? total + 1 : total
        }
    }
    

    func removeCharacters(in set : CharacterSet) -> String {
        
        return self.filter{ (character) -> Bool in
            character.unicodeScalars.contains(where: {
                !set.contains($0) })
        }
    }
    
    func asLines(of length : Int) -> [String] {
        
        let result = stride(from: 0, to: self.count, by: length).map{ lineBreakIndex in
            
            self[self.index(self.startIndex, offsetBy: lineBreakIndex) ..<
                    self.index(self.startIndex, offsetBy: min(lineBreakIndex + length, self.count))]
        }
        return result.map{String($0)}
    }
    
    
}

extension Font.Design {
    func cssName() -> String {
        switch self {
        case .default:
            return "ui-sans-serif"
        case .monospaced:
            return "ui-monospace"
        case .rounded:
            return "ui-sans-serif"
        case .serif:
            return "ui-serif"
        default:
            return "ui-sans-serif"
        }
    }
}

