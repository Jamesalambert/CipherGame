//
//  ThemeClass.swift
//  IndexCards
//
//  Created by James Lambert on 05/05/2020.
//  Copyright © 2020 James Lambert. All rights reserved.
//

import SwiftUI

class ThemeManager : ThemeDelegateProtocol {

    //MARK:- ThemeDelegateProtocol
    func color(of item: Item, for bookID : Int?, in colorScheme : ColorScheme ) -> Color? {
        return Self.theme(for: bookID).color(ColorContext(item: item, colorScheme: colorScheme))
    }
    
    func size(of shape: Shape, for bookID : Int?) -> Double? {
        return Self.theme(for: bookID).size(SizeContext(shape: shape))
    }
    
    func time(for animation: Animation, for bookID : Int?) -> Double? {
        return Self.theme(for: bookID).time(TimeContext(animation: animation))
    }
    
    func font(for text : TextType, for bookID : Int?) -> Font? {
        return Self.theme(for: bookID).font(FontContext(text: text))
    }
    //MARK:- End ThemeDelegate
        
    
    //defaults
    private
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
   
    
    private
    static func defaultSizes(context : SizeContext) -> Double {
        let defaults : [SizeContext : Double] = [
            SizeContext(shape: .puzzlePadding) : 0.05
        ]
        return defaults[context] ?? 1.0
    }
    
    
    private
    static func defaultTimes(context : TimeContext) -> Double {
        let defaults : [TimeContext : Double] = [
            TimeContext(animation: .text): 0.75
        ]
        return defaults[context] ?? 0.75
    }
    
    
    private
    static func defaultFonts(context : FontContext) -> Font {
        let defaults : [FontContext : Font] = [:]
        return defaults[context] ?? Font.system(.body)
    }    
    
    private
    static
    func theme(for bookID : Int?) -> ThemeStructure {
        switch bookID {
        default:
            return ThemeStructure(color: defaultColors,
                                  size: defaultSizes,
                                  time: defaultTimes,
                                  font: defaultFonts)
        }
    }
}



//MARK:- Protocol

protocol ThemeDelegateProtocol {
    func color(of item : Item, for BookID : Int?, in colorScheme : ColorScheme) -> Color?
    func size(of shape: Shape, for bookID : Int?) -> Double?
    func time(for animation: Animation, for bookID : Int?) -> Double?
    func font(for text : TextType, for BookID : Int?) -> Font?
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


//MARK:- Private
private struct ThemeStructure {
    var color : (ColorContext) -> Color
    var size : (SizeContext) -> Double
    var time : (TimeContext) -> Double
    var font : (FontContext) -> Font
}


private struct ColorContext : Hashable {
    var item : Item
    var colorScheme : ColorScheme
}

private struct SizeContext : Hashable {
    var shape : Shape
}

private struct TimeContext : Hashable {
    var animation : Animation
}

private struct FontContext : Hashable {
    var text : TextType
}


