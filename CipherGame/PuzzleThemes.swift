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
    func color(of item: Item, for bookID : Int, in colorScheme : ColorScheme ) -> Color? {
        return Self.theme(for: bookID).color(for: item, in: colorScheme)
    }
    
    func size(of shape: Shape, for bookID : Int) -> Double? {
        return Self.theme(for: bookID).size(for: shape)
    }
    
    func time(for animation: Animation, for bookID : Int) -> Double? {
        return Self.theme(for: bookID).time(for: animation)
    }
    
    func font(for text : TextType, for bookID : Int) -> Font? {
        return Self.theme(for: bookID).font(for: text)
    }
    //MARK:- End ThemeDelegate
        
    
    //defaults
    static let myOrange = {Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))}()
    
    fileprivate
    static
    let defaultColors : [ColorContext : Color] = [
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
    
    fileprivate
    static
    let defaultSizes : [SizeContext : Double] = [
        SizeContext(shape: .puzzlePadding) : 0.05
    ]
    
    fileprivate
    static
    let defaultTimes : [TimeContext : Double] = [
        TimeContext(animation: .text): 0.75
    ]
    
    fileprivate
    static
    let defaultFonts : [FontContext : Font] = [:]
        
    private
    static
    func theme(for bookID : Int) -> ThemeStructure {
        
        switch bookID {
        default:
            return ThemeStructure(colors: defaultColors,
                                  sizes: defaultSizes,
                                  times: defaultTimes,
                                  fonts: defaultFonts)
        }
        
    }
  
   
}



//MARK:- Protocol

protocol ThemeDelegateProtocol {
    func color(of item : Item, for BookID : Int, in colorScheme : ColorScheme) -> Color?
    func size(of shape: Shape, for bookID : Int) -> Double?
    func time(for animation: Animation, for bookID : Int) -> Double?
    func font(for text : TextType, for BookID : Int) -> Font?
}



//MARK:- types
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
    
    let colors : [ColorContext : Color]
    let sizes : [SizeContext : Double]
    let times : [TimeContext : Double]
    let fonts : [FontContext : Font]
    
    func color(for item : Item, in colorScheme : ColorScheme) -> Color? {
        return colors[ColorContext(item: item, colorScheme: colorScheme)]
    }
    
    func size(for shape : Shape) -> Double? {
        return sizes[SizeContext(shape: shape)]
    }
    
    func time(for item : Animation) -> Double? {
        return times[TimeContext(animation: item)]
    }
    
    func font(for text : TextType) -> Font? {
        return fonts[FontContext(text: text)]
    }
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


