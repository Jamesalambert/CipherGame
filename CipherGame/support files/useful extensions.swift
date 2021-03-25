//
//  useful extensions.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import SwiftUI

//TODO: need better theme management
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
    
    func upperChar() -> Self {
        if let currentValue = self {
            return Character(String(currentValue).uppercased())
        } else {
            return self
        }
    }
    
    func lowerChar() -> Self {
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
}
