//
//  ContentView + letter count.swift
//  CipherGame
//
//  Created by J Lambert on 29/03/2021.
//

import SwiftUI

extension ContentView {
    
    static let LetterCountLetterWidth = CGFloat(20)
    
    struct LetterCount : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Binding
        var displayLetterCount : Bool
        
        var body : some View {
            GeometryReader { geometry in
                VStack(alignment: .center){
                    Button{
                        withAnimation(.standardUI){
                            displayLetterCount.toggle()
                        }
                    } label: {
                        Text("Letter Count")
                            .font(viewModel.theme.font(for: .subheadline, for: bookTheme))
                            .foregroundColor(viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme))
                            .padding(.top, 10)
                    }
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 0){
                            ForEach(viewModel.characterCount) { letterCountTriple in
                                    let cipherChar = letterCountTriple.character
                                    PairCount(cipherChar: cipherChar,
                                              plainChar: viewModel.plaintext(for: cipherChar),
                                              count: letterCountTriple.count)
                                        .frame(width: pairCountWidth(for: geometry))
                                        .animation(.easeInOut)
                                        .onTapGesture {
                                            withAnimation{
                                                viewModel.currentCiphertextCharacter = cipherChar
                                            }
                                        }
                            }
                        }
                        .frame(minWidth: geometry.size.width) //centers the stack in the scrollview
                    }
                }
            }
        }
        
        private
        func pairCountWidth(for geometry : GeometryProxy) -> CGFloat {
            let width = geometry.size.width / 26
            return max(width, 30)
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
        
        @Environment (\.colorScheme)
        var colorScheme : ColorScheme
        
        var body : some View {
            VStack {
                Group {
                    Text(String(cipherChar)).fontWeight(.semibold)
                        
                    Text(plainChar.string())
                        .foregroundColor(viewModel.theme.color(of: .plaintext, for: bookTheme, in: colorScheme))
                    Text(count > 0 ? String(count) : "-").lineLimit(1)
                }
                .fixedSize()
                .font(viewModel.theme.font(for: .body, for: bookTheme))
                //.font(.system(.body, design: viewModel.fontDesign))
                .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
                .foregroundColor(foregroundColor)
                .frame(height: ContentView.LetterCountLetterWidth )
            }
        }
        
        private
        var foregroundColor : Color? {
            if count == 0 {
                return Color.gray
            } else if viewModel.currentCiphertextCharacter == cipherChar.lowerChar() {
                return viewModel.theme.color(of: .highlight,
                                             for: bookTheme, in: colorScheme)
            }
            return viewModel.theme.color(of: .ciphertext,
                                         for: bookTheme, in: colorScheme)
        }
    }
}
