//
//  ThemeClass.swift
//  IndexCards
//
//  Created by James Lambert on 05/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import SwiftUI

class ThemeManager {

    //MARK:- public
    func color(of item: Item, for themeName : BookTheme, in colorScheme : ColorScheme ) -> Color? {
        return Self.theme(for: themeName).color(ColorContext(item: item, colorScheme: colorScheme))
    }
    
    func size(of shape: ThemeShape, for themeName : BookTheme) -> Double? {
        return Self.theme(for: themeName).size(SizeContext(shape: shape))
    }
    
    func time(for animation: ThemeAnimation, for themeName : BookTheme) -> Double? {
        return Self.theme(for: themeName).time(TimeContext(animation: animation))
    }
    
    func font(for text : Font.TextStyle, item : Item = .plaintext, for themeName : BookTheme) -> Font? {
        return Self.theme(for: themeName).font(FontContext(item : item, text: text))
    }
    
    func image(for item: Item, for bookName: BookTheme) -> Image? {
        return Self.theme(for: bookName).images(ImageContext(item: item))
    }
    
    func blurStyle(for bookTheme : BookTheme, in colorScheme : ColorScheme) -> UIBlurEffect.Style {
        return Self.theme(for: bookTheme).blurStyle(colorScheme)
    }
    
    private
    static
    func theme(for bookTheme : BookTheme?) -> ThemeStructure {
        
        guard let bookTheme = bookTheme else { return defaultTheme }
        
        switch bookTheme {
        case .space:
            return spaceTheme
        case .treasure:
            return treasureTheme
        case .defaultTheme:
            return defaultTheme
        }
    }
    
    //MARK:-  --------Default Theme----------
    
    private
    static let defaultTheme = ThemeStructure(color: ThemeStructure.defaultColors,
                                             size: ThemeStructure.defaultSizes,
                                             time: ThemeStructure.defaultTimes,
                                             font: ThemeStructure.defaultFonts,
                                             images: ThemeStructure.defaultImages,
                                             blurStyle: ThemeStructure.defaultBlurStyle)
    //MARK:- Private
    struct ThemeStructure {
        
        static let myOrange = Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
        static let cyan = Color(#colorLiteral(red: 0, green: 0.6404201388, blue: 0.8557960391, alpha: 1))
        static let yellow = Color(#colorLiteral(red: 1, green: 0.9398623705, blue: 0.01244911458, alpha: 1))
        
        var color : (ColorContext) -> Color
        var size : (SizeContext) -> Double
        var time : (TimeContext) -> Double
        var font : (FontContext) -> Font
        var images : (ImageContext) -> Image?
        var blurStyle : (ColorScheme) -> UIBlurEffect.Style
        
        
        static func defaultColors(_ context : ColorContext) -> Color {            
            switch context.item{
            case .ciphertext:
                return context.colorScheme == .light ? Color.black : Color.init(white: 0.8)
            case .plaintext:
                return context.colorScheme == .light ? Color.blue : Self.myOrange
            case .gameText:
                return context.colorScheme == .light ? Self.myOrange : Color.blue
            case .puzzleLines:
                return context.colorScheme == .light ? Color.blue : Self.myOrange
            case .highlight:
                return context.colorScheme == .light ? Self.myOrange : Color.blue
            case .completed:
                return context.colorScheme == .light ? Self.myOrange : Color.blue
            case .puzzleBackground, .puzzlePaper:
                return context.colorScheme == .light ? Color.init(white: 0.95) : Color.black
            case .keyboardBackground:
                return context.colorScheme == .light ? Color.init(white: 0.8) : Color.init(white: 0.20)
            case .keyboardLetters:
                return context.colorScheme == .light ? Color.blue : Self.myOrange
            case .tappable:
                return context.colorScheme == .light ? Color.black : Color.init(white: 0.95) 
            case .buyButton:
                return Color.blue
            case .openButton:
                return Color.green
            }
        }
       
        static func defaultSizes(context : SizeContext) -> Double {
            let defaults : [SizeContext : Double] = [
                SizeContext(shape: .puzzlePadding) : 0.05
            ]
            return defaults[context] ?? 1.0
        }
        
        
        static func defaultTimes(context : TimeContext) -> Double {
            let defaults : [TimeContext : Double] = [
                TimeContext(animation: .text): 0.75
            ]
            return defaults[context] ?? 0.75
        }
        
        
        static func defaultFonts(context : FontContext) -> Font {
            return Font.system(context.text)
        }
        
        
        static func defaultImages(context : ImageContext) -> Image? {
            return nil
        }
        
        static func defaultBlurStyle(colorScheme: ColorScheme) -> UIBlurEffect.Style {
            return colorScheme == .light ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark
        }
    }

    //accessible in extension of this class
    struct ColorContext : Hashable {
        var item : Item
        var colorScheme : ColorScheme
    }

    struct SizeContext : Hashable {
        var shape : ThemeShape
    }

    struct TimeContext : Hashable {
        var animation : ThemeAnimation
    }

    struct FontContext : Hashable {
        var item : Item
        var text : Font.TextStyle
    }
    
    struct ImageContext : Hashable {
        var item : Item
    }
}


//MARK:- Public types
enum Item : Hashable {
    case tappable
    case ciphertext
    case gameText
    case plaintext
    case puzzleLines
    case highlight
    case completed
    case puzzleBackground
    case puzzlePaper
    case keyboardBackground
    case keyboardLetters
    case buyButton
    case openButton
}

enum ThemeShape {
    case puzzlePadding
}

enum ThemeAnimation{
    case text
}


enum BookTheme : Codable {

    case defaultTheme, space, treasure

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        switch rawValue{
        case "space": self = .space
        case "default": self = .defaultTheme
        case "treasure": self = .treasure
        default:
            self = .defaultTheme
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .space: try container.encode("space")
        case .defaultTheme: try container.encode("default")
        case .treasure: try container.encode("treasure")
        }
    }
}
