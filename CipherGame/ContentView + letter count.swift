//
//  ContentView + letter count.swift
//  CipherGame
//
//  Created by J Lambert on 29/03/2021.
//

import SwiftUI

extension ContentView {
    
    
    
struct LetterCount : View {
    
    @EnvironmentObject
    var viewModel : CipherPuzzle
    var letterCount : [(Character,Int)]
    
    var body : some View {
        
        GeometryReader { geometry in
            
            VStack {
                //Divider()
                Text("Character Count")
                
                ScrollView(.horizontal) {
                    LazyVGrid(columns: self.columns(screenWidth: geometry.size.width)) {
                        
                        if letterCount.count > 0 {
                            
                            ForEach(0..<letterCount.count) { index in
                                let cipherChar = letterCount[index].0
                                PairCount(cipherChar: cipherChar,
                                            plainChar: viewModel.plaintext(for: cipherChar),
                                            count: letterCount[index].1)
                            }
                        }
                    }//.background(Color.blue)
                }//.background(Color.green)
            }//.background(Color.red)
        
        }
    }
    
    
    func columns(screenWidth : CGFloat) -> [GridItem] {
        return Array(repeating: GridItem(.flexible(minimum: CGFloat(25), maximum: CGFloat(30))),
                    count: 26)
    }
    
}
        
    
struct PairCount : View {
    
    @EnvironmentObject
    var viewModel : CipherPuzzle
    
    var cipherChar : Character
    
    var plainChar : Character?
    
    @Environment (\.colorScheme)
    var colorScheme : ColorScheme
    
    var count : Int
    
    var body : some View {
        VStack {
            Group {
                Text(String(cipherChar))
                    
                Text(count > 0 ? String(count) : "-").lineLimit(1)
                    
                Text(plainChar.string()).foregroundColor(Color.plaintext(for: colorScheme))
            }.font(.system(.body, design: viewModel.fontDesign))
            .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
            .foregroundColor(foregroundColor)
            Spacer()
        }
    }
    
    var foregroundColor : Color? {
        if count == 0 {
            return Color.gray
        } else if viewModel.currentCiphertextCharacter == cipherChar.lowerChar() {
            return Color.highlightColor(for: colorScheme)
        }
        return Color.ciphertext(for: colorScheme)
    }
    
}
}
