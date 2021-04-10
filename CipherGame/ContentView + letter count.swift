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
        
        //var letterCount : [(character:Character, count:Int)]
        
        var body : some View {
            
            GeometryReader { geometry in
                
                VStack {
                    Text("Character Count")
                    
                    ScrollView(.horizontal) {
                        LazyVGrid(columns: self.columns(screenWidth: geometry.size.width), alignment: .center) {
                            
                                
                            ForEach(viewModel.characterCount) { letterCountTriple in
                                    let cipherChar = letterCountTriple.character
                                    PairCount(cipherChar: cipherChar,
                                              plainChar: viewModel.plaintext(for: cipherChar),
                                              count: letterCountTriple.count)
                                        .animation(.easeInOut)
                            }
                            
                        }.frame(minWidth: geometry.size.width) //centers the grid in the scrollview
                        //.background(Color.blue)
                    }//.background(Color.green)
                }//.background(Color.red)
            }
        }
        
        private
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.flexible(minimum: CGFloat(25), maximum: CGFloat(30))),
                         count: 26)
        }
        
    }
    
    
    struct PairCount : View, Hashable {

        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        var cipherChar : Character
        var plainChar : Character?
        var count : Int
        
        @Environment (\.colorScheme)
        var colorScheme : ColorScheme
        
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
        
        private
        var foregroundColor : Color? {
            if count == 0 {
                return Color.gray
            } else if viewModel.currentCiphertextCharacter == cipherChar.lowerChar() {
                return Color.highlightColor(for: colorScheme)
            }
            return Color.ciphertext(for: colorScheme)
        }
        
        //Hashable
        var id = UUID()
        static func == (lhs: ContentView.PairCount, rhs: ContentView.PairCount) -> Bool {
            return (lhs.id == rhs.id)
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        // Hashable
    }
}
