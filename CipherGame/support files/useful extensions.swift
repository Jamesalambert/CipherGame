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
    
    func initial(_ number : Int) -> [Element]{
        return self.dropLast(self.count - number)
    }
    
    func asLines(of length : Int) -> [[Element]] {
        if self.count <= length {
            return [self.map{$0}]
        } else {
            return [self.initial(length)] + Array(self.dropFirst(length)).asLines(of: length)
        }
    }
    
    func sample(of number : Int) -> [Element] {
        var choices : Set<Element> = []
        while choices.count < number {
            choices.insert(self.randomElement()!)
        }
        return Array(choices)
    }

    func number(of item : Element) -> Int {
        return self.filter{$0 == item}.count
    }
}


//used for the letter counts
extension String {
    
    static let alphabet = "abcdefghijklmnopqrstuvwxyz"
    static let qwerty = ["qwertyuiop",
                         "asdfghjkl",
                         "zxcvbnm"]
    
    func removeCharacters(in set : CharacterSet) -> String {
        return self.filter{ (character) -> Bool in
            character.unicodeScalars.contains(where: {
                !set.contains($0) })
        }
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

extension EdgeInsets {
    static
    func zero() -> EdgeInsets {
        return EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
    }
    
    static
    func sized(horizontally width : CGFloat? = 0, vertically height : CGFloat? = 0) -> EdgeInsets {
        return EdgeInsets(top: height ?? 0, leading: width ?? 0, bottom: height ?? 0, trailing: width ?? 0)
    }
    
    static
    func sized(leading : CGFloat? = 0, trailing : CGFloat? = 0, top : CGFloat? = 0 , bottom : CGFloat? = 0) -> EdgeInsets{
        return EdgeInsets(top: top ?? 0, leading: leading ?? 0, bottom: bottom ?? 0, trailing: trailing ?? 0)
    }
}

extension OSStatus {
    var string : String {
        let errorString : CFString? = SecCopyErrorMessageString(self, nil)
        return (errorString as String?) ?? ""
    }
}
