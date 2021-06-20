//
//  PuzzleThemes + Space.swift
//  CipherGame
//
//  Created by J Lambert on 06/05/2021.
//

import SwiftUI

extension ThemeManager {
    //    Space Theme ///////////////////////////////////
        
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
                return .gray
            case .plaintext:
                return ThemeStructure.yellow
            case .gameText:
                return ThemeStructure.myOrange
            case .puzzleLines:
                return ThemeStructure.cyan
            case .highlight:
                return ThemeStructure.myOrange
            case .completed:
                return .red
            case .puzzleBackground, .puzzlePaper:
                return .clear
            case .keyboardBackground:
                return .init(white: 0.1)
            case .keyboardLetters:
                return ThemeStructure.yellow
            case .tappable:
                return .white
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
        static func spaceBlurStyle(colorscheme : ColorScheme) -> Int {
//            UIBlurEffect.Style.systemUltraThinMaterialDark.rawValue
            return 16
        }
}
