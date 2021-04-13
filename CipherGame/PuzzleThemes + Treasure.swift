//
//  PuzzleThemes + Treasure.swift
//  CipherGame
//
//  Created by J Lambert on 13/04/2021.
//

import SwiftUI

extension ThemeManager {
    
    static let treasureTheme = ThemeStructure(color: treasureColors,
                                              size: ThemeStructure.defaultSizes,
                                              time: ThemeStructure.defaultTimes,
                                              font: treasureFonts)
    
    private
    static func treasureColors(_ context : ColorContext) -> Color {
        let defaults : [ColorContext : Color] = [
            ColorContext(item: .ciphertext, colorScheme: .light) : Color.red,
            ColorContext(item: .ciphertext, colorScheme: .dark) : Color.red,
            
            ColorContext(item: .plaintext, colorScheme: .light) : Color.init(white: 0.6),
            ColorContext(item: .plaintext, colorScheme: .dark) : Color.init(white: 0.6),
            
            ColorContext(item: .puzzleBackground, colorScheme: .light) : Color.init(white: 0.95),
            ColorContext(item: .puzzleBackground, colorScheme: .dark) : Color.black,
            
            ColorContext(item: .highlight, colorScheme: .light) : Color.yellow,
            ColorContext(item: .highlight, colorScheme: .dark) : Color.yellow,
            
            ColorContext(item: .completed, colorScheme: .light) : Color.red,
            ColorContext(item: .completed, colorScheme: .dark) : Color.red,
        ]
        return defaults[context] ?? Color.red
    }
    
    
    private
    static func treasureFonts(context : FontContext) -> Font {
        let defaults : [FontContext : Font] = [:]
        return defaults[context] ?? Font.system(.body)
    }
    
    
    
}
