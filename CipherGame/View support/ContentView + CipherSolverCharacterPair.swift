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
        
        var characterPairData : GameInfo
        
        private
        var ciphertextLetter : Character{
            return characterPairData.cipherLetter
        }
        private
        var plaintextLetter : Character?{
            return characterPairData.userGuessLetter
        }
        private
        var indexInTheCipher : Int{
            return characterPairData.id
        }

        var body : some View {
            if ciphertextLetter.isPunctuation || ciphertextLetter.isWhitespace {
                standardCipherPair(displayPlaintext: false)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                standardCipherPair(displayPlaintext: true)
                    .onTapGesture {
                        withAnimation{
                                viewModel.currentCiphertextCharacter = ciphertextLetter
                                viewModel.selectedIndex = indexInTheCipher
                                displayTabletLetterPicker = true
                                wasTapped = true    //to locate the popover arrow
                        }
                    }
            } else if UIDevice.current.userInterfaceIdiom == .phone{
                standardCipherPair(displayPlaintext: true)
                    .onTapGesture {
                        withAnimation{
                            viewModel.currentCiphertextCharacter = ciphertextLetter
                            viewModel.selectedIndex = indexInTheCipher
                            displayPhoneLetterPicker = true
                        }
                    }
            }
        }
        
        @ViewBuilder
        func standardCipherPair(displayPlaintext : Bool) -> some View {
            VStack{
                Text(String(ciphertextLetter))
                    .fixedSize()
                    .font(viewModel.theme.font(for: .title, item: .ciphertext, for: bookTheme))
                    .opacity(plaintextLetter == nil ? 1 : 0.3)
         
                    ZStack{
                        //highlight colour if the character is selected
                        if indexInTheCipher == viewModel.selectedIndex {
                            viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme)
                                .opacity(0.6)
                                .cornerRadius(2)
                        } else {
                            Color.clear
                        }
                            Text(plaintextLetter.string())
                                .fixedSize()
                                .frame(height : 30)
                                .foregroundColor(viewModel.theme.color(of: .plaintext,
                                                                       for: bookTheme, in: colorScheme))
                                .font(viewModel.theme.font(for: .title, item: .plaintext, for: bookTheme))
                    }
            }
            .popover(isPresented: $wasTapped,
                     attachmentAnchor: .point(.center),
                     arrowEdge: .top){letterPopover()}
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
                
                
                VStack{
                    HStack{
                        Spacer()
                        Button{
                            withAnimation{
                                dismissLetterPopover()
                            }
                        } label: {
                            Label("hide", systemImage: "xmark.circle")
                                .foregroundColor(viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme))
                                .padding(EdgeInsets.init(top: 10, leading: 20, bottom: 5, trailing: 20))
                        }
                    }
                    
                    drawKeyboard()
                        .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 10, trailing: 20))
                    
                    if plaintextLetter != nil {
                        Button{
                            withAnimation{
                                dismissLetterPopover()
                            }
                        } label: {
                            Label("delete", systemImage: "delete.left")
                                .foregroundColor(viewModel.theme.color(of: .keyboardLetters,
                                                                       for: bookTheme, in: colorScheme))
                                .padding(.bottom)
                        }
                    }
                }
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
                                        viewModel.guess(ciphertextLetter, is: character,
                                                        at: indexInTheCipher)
                                        displayTabletLetterPicker = false
                                        wasTapped = false
                                    }
                                }
//                                .matchedGeometryEffect(id: Character(extendedGraphemeClusterLiteral: character), in: ns)
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
        func dismissLetterPopover(){
            viewModel.guess(ciphertextLetter, is: nil, at: indexInTheCipher)
            viewModel.currentCiphertextCharacter = nil
            wasTapped = false
        }
        
        private
        func foregroundColor(for colorScheme : ColorScheme) -> Color? {
            if viewModel.currentCiphertextCharacter == ciphertextLetter.lowerChar() {
                return viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme)
            }
            return viewModel.theme.color(of: .ciphertext, for: bookTheme, in: colorScheme)
        }
    }
 
}
