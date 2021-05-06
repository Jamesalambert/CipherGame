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
                                              font: treasureFonts,
                                              images: treasureImages,
                                              blurStyle: treasureBlurStyle)
    
    private
    static func treasureColors(_ context : ColorContext) -> Color {
        
        let brown = Color(#colorLiteral(red: 0.3659802725, green: 0.2803014938, blue: 0.1922420252, alpha: 1))
        
        switch context.item{
        case .ciphertext:
            return  brown
        case .plaintext:
            return .black
        case .gameText:
            return ThemeStructure.myOrange
        case .puzzleLines:
            return ThemeStructure.myOrange
        case .highlight:
            return ThemeStructure.myOrange
        case .completed:
            return ThemeStructure.myOrange
        case .puzzleBackground:
            return context.colorScheme == .light ? Color.init(white: 0.95) : Color.black
        case .keyboardBackground:
            return Color.init(white: 0.95)
        case .keyboardLetters:
            return treasureColors(ColorContext(item: .plaintext, colorScheme: context.colorScheme))
        case .tappable:
            return brown
        default:
            return ThemeStructure.defaultColors(context)
        }
    }
    
    private
    static func treasureFonts(context : FontContext) -> Font {
                
        let themeFont = context.item != .plaintext ? "Lucida Calligraphy" : "Courier"
        
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
            return Font.custom(themeFont, size: 15)
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
    
    private
    static func treasureImages(context: ImageContext) -> Image? {
        switch context.item {
        case .puzzlePaper:
            return Image("parchment")
        default:
            return nil
        }
    }
    
    private
    static func treasureBlurStyle(colorscheme : ColorScheme) -> UIBlurEffect.Style {
        return .systemUltraThinMaterialLight
    }
    
}
