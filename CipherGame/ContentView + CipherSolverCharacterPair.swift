//
//  ContentView + CipherSolverCharacterPair.swift
//  CipherGame
//
//  Created by J Lambert on 19/04/2021.
//

import SwiftUI

extension ContentView {
    
    struct CipherSolverCharacterPair : View {
                
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        @Binding
        var puzzle : Puzzle
        
        @Binding
        var currentCiphertextCharacter : Character?

        @Binding
        var selectedIndex : Int?
        
        @Binding
        var displayPhoneLetterPicker : Bool
        
        @State
        private
        var displayTabletLetterPicker : Bool = false
        
        var cipherTextLetter : Character
        var plainTextLetter : Character?
        var indexInTheCipher : Int

        var body : some View {
            
            if cipherTextLetter.isPunctuation || cipherTextLetter.isWhitespace {
                standardCipherPair(displayPlaintext: false)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                
                standardCipherPair(displayPlaintext: true)
                    .onTapGesture {
                        withAnimation{
                            currentCiphertextCharacter = cipherTextLetter
                            displayTabletLetterPicker.toggle()
                        }
                    }
                    .popover(isPresented: $displayTabletLetterPicker, attachmentAnchor: .point(.top), arrowEdge: .top){letterPopover()}
                
            } else {
                standardCipherPair(displayPlaintext: true)
                    .onTapGesture {
                        withAnimation{
                            currentCiphertextCharacter = cipherTextLetter
                            selectedIndex = indexInTheCipher
                            displayPhoneLetterPicker = true
                        }
                    }
            }
        }
        
        
        
        @ViewBuilder
        private
        func standardCipherPair(displayPlaintext : Bool) -> some View {
            VStack{
                Text(String(cipherTextLetter))
                    .fixedSize()
                Spacer()
                
                if displayPlaintext {
                    Text(plainTextLetter.string())
                        .frame(height : 30)
                        .foregroundColor(viewModel.theme.color(of: .plaintext,
                                                               for: bookTheme, in: colorScheme))
                        .fixedSize()
                }
                
            }
            .overlay(Rectangle()
                        .frame(width: 30, height: 2, alignment: .bottom)
                        .foregroundColor(viewModel.theme.color(of: .puzzleLines,
                                                               for: bookTheme, in: colorScheme)),
                     alignment: .bottom )
            .padding(.top)
            .font(viewModel.theme.font(for: .title, for: bookTheme))
            .foregroundColor(foregroundColor(for: colorScheme))
            .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
        }
        
        
        private
        func letterPopover() -> some View {
            ScrollView(.vertical){
                
                Button("close"){displayTabletLetterPicker = false}
                
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(20)), count: 13)){
                    ForEach(String.alphabet.map{$0}, id: \.self){ character in
                        Button{
                            withAnimation{
                                viewModel.guess(cipherTextLetter, is: character,
                                                at: indexInTheCipher, for: puzzle)
                                displayTabletLetterPicker = false
                            }
                        } label: {
                            Text(String(character))
                                .font(viewModel.theme.font(for: .title, for: bookTheme))
                                .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                        }
                    }
                }
                
                if plainTextLetter != nil {
                    Button{
                        withAnimation{
                            viewModel.guess(cipherTextLetter, is: nil,
                                            at: indexInTheCipher, for: puzzle)
                            displayTabletLetterPicker = false
                        }
                    } label: {
                        Label("clear", systemImage: "clear")
                    }
                }
                
                
            }.padding()
        }
        
        
//        private
//        func LetterMenu() -> some View {
//            Group{
//                Button("-"){
//                    withAnimation{
//                        viewModel.guess(cipherTextLetter, is: nil,
//                                        at: indexInTheCipher, for: puzzle)
//                    }
//                }
//
//                ForEach(String.alphabet.map{$0}, id: \.self){ character in
//                    Button {
//                        withAnimation{
//                            viewModel.guess(cipherTextLetter, is: character,
//                                            at: indexInTheCipher, for: puzzle)
//                        }
//                    } label: {
//                        let option = String(character)
//                        Text(option)
//                    }
//                }
//            }
//            .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
//        }
  
        
        private
        func foregroundColor(for colorScheme : ColorScheme) -> Color? {
            if currentCiphertextCharacter == cipherTextLetter.lowerChar() {
                return viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme)
            }
            return viewModel.theme.color(of: .ciphertext, for: bookTheme, in: colorScheme)
        }
    }
}
