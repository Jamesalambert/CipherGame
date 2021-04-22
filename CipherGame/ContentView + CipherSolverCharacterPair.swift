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
        
        @State
        private
        var wasTapped : Bool = false
        
        @Binding
        var puzzle : Puzzle
        
        @Binding
        var currentCiphertextCharacter : Character?

        @Binding
        var selectedIndex : Int?
        
        @Binding
        var displayPhoneLetterPicker : Bool
        
        @Binding
        var displayTabletLetterPicker : Bool
        
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
                            if displayTabletLetterPicker {
                                displayTabletLetterPicker = false
                            } else {
                                currentCiphertextCharacter = cipherTextLetter
                                selectedIndex = indexInTheCipher
                                
                                displayTabletLetterPicker = true
                                wasTapped = true
                            }
                        }
                    }
                    .popover(isPresented: $wasTapped,
                             attachmentAnchor: .point(.top),
                             arrowEdge: .top){letterPopover()}
                
            } else if UIDevice.current.userInterfaceIdiom == .phone{
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
            
            ZStack{
                //background colour
                viewModel.theme.color(of: .keyboardBackground, for: bookTheme, in: colorScheme)
                    .scaleEffect(1.5)
                    .shadow(radius: 3)
                
                ScrollView(.vertical){
                    Spacer()
                    drawKeyboard()
                    Spacer()
                    if plainTextLetter != nil {
                        Button{
                            withAnimation{
                                viewModel.guess(cipherTextLetter, is: nil,
                                                at: indexInTheCipher, for: puzzle)
                                displayTabletLetterPicker = false
                                wasTapped = false
                            }
                        } label: {
                            Label("delete", systemImage: "delete.left")
                                .font(.title)
                                .foregroundColor(viewModel.theme.color(of: .keyboardLetters,
                                                                       for: bookTheme, in: colorScheme))
                        }
                    }
                }.padding()
            }
        }
        
        @ViewBuilder
        func drawKeyboard() -> some View {
            VStack{
                ForEach(String.qwerty, id:\.self ){line in
                    HStack(spacing: 10){
                        ForEach(line.map{$0}, id:\.self){ character in
                            Text(String(character)).onTapGesture {
                                withAnimation{
                                    viewModel.guess(cipherTextLetter, is: character,
                                                    at: indexInTheCipher, for: puzzle)
                                    displayTabletLetterPicker = false
                                    wasTapped = false
                                }
                            }
                            .fixedSize()
                            .font(viewModel.theme.font(for: .title, for: bookTheme))
                            .foregroundColor(viewModel.theme.color(of: .keyboardLetters, for: bookTheme, in: colorScheme))
                            .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
                        }
                    }
                }
            }
        }
        
        private
        func foregroundColor(for colorScheme : ColorScheme) -> Color? {
            if currentCiphertextCharacter == cipherTextLetter.lowerChar() {
                return viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme)
            }
            return viewModel.theme.color(of: .ciphertext, for: bookTheme, in: colorScheme)
        }
    }
}
