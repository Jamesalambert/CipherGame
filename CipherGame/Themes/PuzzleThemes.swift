//
//  ThemeClass.swift
//  IndexCards
//
//  Created by James Lambert on 05/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import SwiftUI

class ThemeManager : ThemeDelegateProtocol {
    
    private
    static
    func theme(for bookTheme : BookTheme?) -> ThemeStructure {
        
        guard let bookTheme = bookTheme else { return defaultTheme }
        
        switch bookTheme {
        case .space:
            return spaceTheme
        default:
            return defaultTheme
        }
    }
    

    //MARK:- ThemeDelegateProtocol
    func color(of item: Item, for themeName : BookTheme, in colorScheme : ColorScheme ) -> Color? {
        return Self.theme(for: themeName).color(ColorContext(item: item, colorScheme: colorScheme))
    }
    
    func size(of shape: Shape, for themeName : BookTheme) -> Double? {
        return Self.theme(for: themeName).size(SizeContext(shape: shape))
    }
    
    func time(for animation: Animation, for themeName : BookTheme) -> Double? {
        return Self.theme(for: themeName).time(TimeContext(animation: animation))
    }
    
    func font(for text : Font.TextStyle, for themeName : BookTheme) -> Font? {
        return Self.theme(for: themeName).font(FontContext(text: text))
    }
    
    func image(for item: Item, for bookName: BookTheme) -> Image? {
        return Self.theme(for: bookName).images(ImageContext(item: item))
    }
    //MARK:- End ThemeDelegate
        
//  ---------Theme----------
    
    private
    static let defaultTheme = ThemeStructure(color: ThemeStructure.defaultColors,
                                             size: ThemeStructure.defaultSizes,
                                             time: ThemeStructure.defaultTimes,
                                             font: ThemeStructure.defaultFonts,
                                             images: ThemeStructure.defaultImages)

    
    //MARK:- Private
    struct ThemeStructure {
        
        static let myOrange = {Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))}()
        static let cyan = Color(#colorLiteral(red: 0, green: 0.6404201388, blue: 0.8557960391, alpha: 1))
        static let yellow = Color(#colorLiteral(red: 1, green: 0.9398623705, blue: 0.01244911458, alpha: 1))
        
        var color : (ColorContext) -> Color
        var size : (SizeContext) -> Double
        var time : (TimeContext) -> Double
        var font : (FontContext) -> Font
        var images : (ImageContext) -> Image?
        
        static func defaultColors(_ context : ColorContext) -> Color {            
            switch context.item{
            case .ciphertext:
                return context.colorScheme == .light ? Color.black : Color.init(white: 0.8)
            case .plaintext:
                return context.colorScheme == .light ? Color.blue : Self.myOrange
            case .puzzleLines:
                return context.colorScheme == .light ? Color.blue : Self.myOrange
            case .highlight:
                return context.colorScheme == .light ? Self.myOrange : Color.blue
            case .completed:
                return context.colorScheme == .light ? Self.myOrange : Color.blue
            case .puzzleBackground:
                return context.colorScheme == .light ? Color.init(white: 0.95) : Color.black
            case .keyboardBackground:
                return context.colorScheme == .light ? Color.init(white: 0.95) : Color.black
            case .keyboardLetters:
                return context.colorScheme == .light ? Color.blue : Self.myOrange
            case .tappable:
                return Color.blue 
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
    }

    //accessible in extension of this class
    struct ColorContext : Hashable {
        var item : Item
        var colorScheme : ColorScheme
    }

    struct SizeContext : Hashable {
        var shape : Shape
    }

    struct TimeContext : Hashable {
        var animation : Animation
    }

    struct FontContext : Hashable {
        var text : Font.TextStyle
    }
    
    struct ImageContext : Hashable {
        var item : Item
    }
}



//MARK:- Protocol

protocol ThemeDelegateProtocol {
    func color(of item : Item, for bookName : BookTheme, in colorScheme : ColorScheme) -> Color?
    func size(of shape: Shape, for bookName : BookTheme) -> Double?
    func time(for animation: Animation, for bookName : BookTheme) -> Double?
    func font(for text : Font.TextStyle, for bookName : BookTheme) -> Font?
    func image(for item : Item, for bookName : BookTheme) -> Image?
}

//MARK:- Public types
enum Item : Hashable {
    case tappable
    case ciphertext
    case plaintext
    case puzzleLines
    case highlight
    case completed
    case puzzleBackground
    case keyboardBackground
    case keyboardLetters
}

enum Shape {
    case puzzlePadding
}

enum Animation{
    case text
}



