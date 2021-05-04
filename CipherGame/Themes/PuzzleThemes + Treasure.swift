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
                                              blurStyle: ThemeStructure.defaultBlurStyle)
    
    private
    static func treasureColors(_ context : ColorContext) -> Color {
        
        switch context.item{
        case .ciphertext:
            return  Color.black
        case .plaintext:
            return  Color.gray
        case .puzzleLines:
            return Color.red
        case .highlight:
            return Color.orange
        case .completed:
            return Color.red
        case .puzzleBackground:
            return Color.white
        case .keyboardBackground:
            return context.colorScheme == .light ? Color.init(white: 0.95) : Color.black
        case .keyboardLetters:
            return treasureColors(ColorContext(item: .plaintext, colorScheme: context.colorScheme))
        case .tappable:
            return Color.orange
        default:
            return ThemeStructure.defaultColors(context)
        }
    }
    
    private
    static func treasureFonts(context : FontContext) -> Font {
                
        let themeFont = "Lucida Calligraphy"
    
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
        case .puzzleBackground:
            return Image("parchment")
        default:
            return nil
        }
    }
    
    
    
//    Space Theme ////////////////////////////////////
    
    
    static let spaceTheme = ThemeStructure(color: spaceColors,
                                              size: ThemeStructure.defaultSizes,
                                              time: ThemeStructure.defaultTimes,
                                              font: spaceFonts,
                                              images: spaceImages,
                                              blurStyle: spaceBlurStyle)
    
    private
    static func spaceColors(_ context : ColorContext) -> Color {
        switch context.item{
        case .ciphertext:
            return Color.gray
        case .plaintext:
            return ThemeStructure.yellow
        case .puzzleLines:
            return ThemeStructure.cyan
        case .highlight:
            return ThemeStructure.myOrange
        case .completed:
            return Color.red
        case .puzzleBackground:
            return Color.black
        case .keyboardBackground:
            return Color.init(white: 0.1)
        case .keyboardLetters:
            return ThemeStructure.yellow
        case .tappable:
            return Color.white
        case .buyButton:
            return ThemeStructure.defaultColors(context)
        case .openButton:
            return ThemeStructure.defaultColors(context)
        }
    }
    
    
    private
    static func spaceFonts(context : FontContext) -> Font {
                
        let themeFont = "Lucida Console"
    
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
    static func spaceImages(context: ImageContext) -> Image? {
        switch context.item {
        case .puzzleBackground:
            return Image("stars")
        default:
            return nil
        }
    }
    
    private
    static func spaceBlurStyle(colorscheme : ColorScheme) -> UIBlurEffect.Style {
        return .systemUltraThinMaterialDark
    }
    
    
}
