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
                                viewModel.currentCiphertextCharacter = cipherTextLetter
                                viewModel.selectedIndex = indexInTheCipher
                                displayTabletLetterPicker = true
                                wasTapped = true    //to locate the popover arrow
                            }
                        }
                    }
//                    .popover(isPresented: $wasTapped,
//                             attachmentAnchor: .point(.center),
//                             arrowEdge: .bottom){letterPopover()}
                
            } else if UIDevice.current.userInterfaceIdiom == .phone{
                standardCipherPair(displayPlaintext: true)
                    .onTapGesture {
                        withAnimation{
                            viewModel.currentCiphertextCharacter = cipherTextLetter
                            viewModel.selectedIndex = indexInTheCipher
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
                    .font(viewModel.theme.font(for: .title, item: .ciphertext, for: bookTheme))
         
                    ZStack{
                        if indexInTheCipher == viewModel.selectedIndex {
                            //selection highlight
                            viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme)
                                .opacity(0.1)
                                .cornerRadius(10)
                        } else {
                            Color.clear
                        }
                        Text(plainTextLetter.string())
                            .frame(height : 30)
                            .fixedSize()
                            .foregroundColor(viewModel.theme.color(of: .plaintext,
                                                                   for: bookTheme, in: colorScheme))
                            .font(viewModel.theme.font(for: .title, item: .plaintext, for: bookTheme))
                            .popover(isPresented: $wasTapped,
                                     attachmentAnchor: .point(.center),
                                     arrowEdge: .bottom){letterPopover()}
                    }
            }
            .padding(.top)
            .foregroundColor(foregroundColor(for: colorScheme))
            .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
        }
        
        @ViewBuilder
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
                                                at: indexInTheCipher)
                                viewModel.currentCiphertextCharacter = nil
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
                    HStack{
                        ForEach(line.map{$0}, id:\.self){ character in
                            Text(String(character))
                                .padding(10)
                                .background(viewModel.theme.color(of: .keyboardLetters, for: bookTheme, in: colorScheme).opacity(0.1))
                                .cornerRadius(10)
                                .onTapGesture {
                                    withAnimation{
                                        viewModel.guess(cipherTextLetter, is: character,
                                                        at: indexInTheCipher)
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
            if viewModel.currentCiphertextCharacter == cipherTextLetter.lowerChar() {
                return viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme)
            }
            return viewModel.theme.color(of: .ciphertext, for: bookTheme, in: colorScheme)
        }
    }
 
}
