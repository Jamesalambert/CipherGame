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
        
        switch context.item{
        case .ciphertext:
            return context.colorScheme == .light ? Color.black : Color.gray
        case .plaintext:
            return context.colorScheme == .light ? Color.blue : Color.orange
        case .puzzleLines:
            return Color.red
        case .highlight:
            return context.colorScheme == .light ? Color.orange : Color.blue
        case .completed:
            return context.colorScheme == .light ? Color.red : Color.red
        case .puzzleBackground:
            return context.colorScheme == .light ? Color.init(white: 0.95) : Color.black
        }
    }
    
    
    private
    static func treasureFonts(context : FontContext) -> Font {
        let defaults : [FontContext : Font] = [:]
        return defaults[context] ?? Font.system(.body)
    }
    
    
    
    
    
    static let spaceTheme = ThemeStructure(color: spaceColors,
                                              size: ThemeStructure.defaultSizes,
                                              time: ThemeStructure.defaultTimes,
                                              font: spaceFonts)
    
    private
    static func spaceColors(_ context : ColorContext) -> Color {
        
        switch context.item{
        case .ciphertext:
            return context.colorScheme == .light ? Color.black : Color.gray
        case .plaintext:
            return context.colorScheme == .light ? Color.blue : Color.orange
        case .puzzleLines:
            return Color.red
        case .highlight:
            return context.colorScheme == .light ? Color.orange : Color.blue
        case .completed:
            return context.colorScheme == .light ? Color.red : Color.red
        case .puzzleBackground:
            return context.colorScheme == .light ? Color.init(white: 0.95) : Color.black
        }
    }
    
    
    private
    static func spaceFonts(context : FontContext) -> Font {
                
        let themeFont = "LucidaConsole"
    
        switch context.text {
        case .title:
            return Font.custom(themeFont, size: 30)
        case .largeTitle:
            return Font.custom(themeFont, size: 40)
        case .title2:
            return Font.custom(themeFont, size: 30)
        case .title3:
            return Font.custom(themeFont, size: 30)
        case .headline:
            return Font.custom(themeFont, size: 30)
        case .subheadline:
            return Font.custom(themeFont, size: 20)
        case .body:
            return Font.custom(themeFont, size: 20)
        case .callout:
            return Font.custom(themeFont, size: 30)
        case .footnote:
            return Font.custom(themeFont, size: 20)
        case .caption:
            return Font.custom(themeFont, size: 20)
        case .caption2:
            return Font.custom(themeFont, size: 20)
        @unknown default:
            return Font.custom(themeFont, size: 30)
        }
    }
    
    
    
}
