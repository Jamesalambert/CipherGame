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
        case .treasure:
            return treasureTheme
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
    
    func font(for text : TextType, for themeName : BookTheme) -> Font? {
        return Self.theme(for: themeName).font(FontContext(text: text))
    }
    //MARK:- End ThemeDelegate
        
//  ---------Theme----------
    
    private
    static let defaultTheme = ThemeStructure(color: ThemeStructure.defaultColors,
                                             size: ThemeStructure.defaultSizes,
                                             time: ThemeStructure.defaultTimes,
                                             font: ThemeStructure.defaultFonts)

    
    //MARK:- Private
    struct ThemeStructure {
        var color : (ColorContext) -> Color
        var size : (SizeContext) -> Double
        var time : (TimeContext) -> Double
        var font : (FontContext) -> Font
        
        static func defaultColors(_ context : ColorContext) -> Color {
            let myOrange = {Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))}()
            let defaults : [ColorContext : Color] = [
                ColorContext(item: .ciphertext, colorScheme: .light) : Color.black,
                ColorContext(item: .ciphertext, colorScheme: .dark) : Color.init(white: 0.8),
                
                ColorContext(item: .plaintext, colorScheme: .light) : Color.blue,
                ColorContext(item: .plaintext, colorScheme: .dark) : myOrange,
                
                ColorContext(item: .puzzleBackground, colorScheme: .light) : Color.init(white: 0.95),
                ColorContext(item: .puzzleBackground, colorScheme: .dark) : Color.black,
                
                ColorContext(item: .highlight, colorScheme: .light) : Color.orange,
                ColorContext(item: .highlight, colorScheme: .dark) : Color.blue,
                
                ColorContext(item: .completed, colorScheme: .light) : Color.blue,
                ColorContext(item: .completed, colorScheme: .dark) : Color.yellow,
            ]
            return defaults[context] ?? Color.red
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
            let defaults : [FontContext : Font] = [:]
            return defaults[context] ?? Font.system(.body)
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
        var text : TextType
    } 
}



//MARK:- Protocol

protocol ThemeDelegateProtocol {
    func color(of item : Item, for bookName : BookTheme, in colorScheme : ColorScheme) -> Color?
    func size(of shape: Shape, for bookName : BookTheme) -> Double?
    func time(for animation: Animation, for bookName : BookTheme) -> Double?
    func font(for text : TextType, for bookName : BookTheme) -> Font?
}

//MARK:- Public types
enum Item : Hashable {
    case ciphertext
    case plaintext
    case puzzleLines
    case highlight
    case completed
    case puzzleBackground
}

enum Shape {
    case puzzlePadding
}

enum Animation{
    case text
}

enum TextType {
    case puzzleText
    case puzzleProse
    case title
}





