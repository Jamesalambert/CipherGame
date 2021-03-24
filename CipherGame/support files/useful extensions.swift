//
//  useful extensions.swift
//  CipherGame
//
//  Created by J Lambert on 24/03/2021.
//

import SwiftUI


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
