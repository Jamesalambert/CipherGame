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
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Binding
        var currentCiphertextCharacter : Character?
        
        var body : some View {
            GeometryReader { geometry in
                VStack {
                    
                    Text("Character Count")
                        .font(viewModel.theme.font(for: .subheadline, for: bookTheme))
                        .foregroundColor(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme))
                    
                    ScrollView(.horizontal) {
                        LazyVGrid(columns: self.columns(screenWidth: geometry.size.width), alignment: .center) {
                            ForEach(viewModel.characterCount) { letterCountTriple in
                                    let cipherChar = letterCountTriple.character
                                    PairCount(cipherChar: cipherChar,
                                              plainChar: viewModel.plaintext(for: cipherChar),
                                              count: letterCountTriple.count, currentCiphertextCharacter: $currentCiphertextCharacter)
                                        .animation(.easeInOut)
                            }
                            
                        }.frame(minWidth: geometry.size.width) //centers the grid in the scrollview
                        //.background(Color.blue)
                    }//.background(Color.green)
                }.background(viewModel.theme.color(of: .puzzleBackground, for: bookTheme, in: colorScheme))
            }
        }
        
        private
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.flexible(minimum: CGFloat(25), maximum: CGFloat(30))),
                         count: 26)
        }
        
    }
    
    
    struct PairCount : View {

        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        var cipherChar : Character
        var plainChar : Character?
        var count : Int
        
        @Binding
        var currentCiphertextCharacter : Character?
        
        @Environment (\.colorScheme)
        var colorScheme : ColorScheme
        
        var body : some View {
            VStack {
                Group {
                    Text(String(cipherChar)).fontWeight(.semibold)
                        
                    Text(count > 0 ? String(count) : "-").lineLimit(1)

                    Text(plainChar.string()).foregroundColor(viewModel.theme.color(of: .plaintext,
                                                                                   for: bookTheme, in: colorScheme))
                }
                .font(viewModel.theme.font(for: .body, for: bookTheme))
                //.font(.system(.body, design: viewModel.fontDesign))
                .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
                .foregroundColor(foregroundColor)
                
                Spacer()
            }
        }
        
        private
        var foregroundColor : Color? {
            if count == 0 {
                return Color.gray
            } else if currentCiphertextCharacter == cipherChar.lowerChar() {
                return viewModel.theme.color(of: .highlight,
                                             for: bookTheme, in: colorScheme)
            }
            return viewModel.theme.color(of: .ciphertext,
                                         for: bookTheme, in: colorScheme)
        }
    }
}
