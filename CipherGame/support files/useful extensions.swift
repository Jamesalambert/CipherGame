//
//  useful extensions.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import SwiftUI

//TODO: need better theme management
extension Color {
    
    static let myOrange = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
    
    static
    func plaintext(for colorScheme : ColorScheme) -> Color {
        if colorScheme == .light {
            return Color(myOrange)
        } else {
            return Color(myOrange)
        }
    }
    
    static
    func ciphertext(for colorScheme : ColorScheme) -> Color {
        if colorScheme == .light {
            return black
        } else {
            return Color.init(white: 0.8)
        }
    }
    
    static
    func backgroundColor(for colorScheme : ColorScheme) -> Color {
        if colorScheme == .light {
            let lightGray = Color.init(white: 0.95)
            return lightGray
        } else {
            return black
        }
    }
    
    static
    func highlightColor(for colorScheme : ColorScheme) -> Color{
        if colorScheme == .light {
            return blue
        } else {
            return blue
        }
    }
    
    static
    func completedColor(for colorScheme : ColorScheme) -> Color{
        if colorScheme == .light {
            return blue
        } else {
            return yellow
        }
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


//used for the letter counts
extension String {
    
    static let alphabet = "abcdefghijklmnopqrstuvwxyz"
    
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
