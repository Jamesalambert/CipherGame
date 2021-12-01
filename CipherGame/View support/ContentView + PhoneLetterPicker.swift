//
//  ContentView + PhoneLetterPicker.swift
//  CipherGame
//
//  Created by J Lambert on 26/04/2021.
//

import SwiftUI

extension ContentView {
    //    MARK:- the phone keyboard
        struct PhoneLetterPicker : View {

            @EnvironmentObject
            var viewModel : CipherPuzzle
            
            @Environment(\.bookTheme)
            var bookTheme : BookTheme
            
            @Environment(\.colorScheme)
            var colorScheme : ColorScheme

            @Binding
            var displayPhoneLetterPicker : Bool

            var body: some View {
                VStack{
                    
                    Button{
                        withAnimation{
                            displayPhoneLetterPicker = false
                        }
                    } label: {
                        Label("hide", systemImage: "chevron.compact.down")
                            .labelStyle(.iconOnly)
                            .foregroundColor(viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme))
                            .padding(EdgeInsets.init(top: 10, leading: 20, bottom: 5, trailing: 20))
                    }
                    
                    drawKeyboard()
                        .padding(.horizontal)
                    
                    Button{
                        withAnimation{
                            viewModel.guess(viewModel.currentCiphertextCharacter!, is: nil,
                                            at: viewModel.selectedIndex!)
                        }
                    } label: {Label("delete", systemImage: "delete.left")
                        .foregroundColor(viewModel.theme.color(of: .keyboardLetters, for: bookTheme, in: colorScheme))
                    }
                }
            }
            
            @ViewBuilder
            func drawKeyboard() -> some View {
                VStack{
                    ForEach(String.qwerty, id:\.self ){line in
                        HStack(spacing: 12){
                            ForEach(line.map{$0}, id:\.self){ character in
                                
                                Text(String(character))
                                    .onTapGesture {
                                        withAnimation{
                                            viewModel.guess(viewModel.currentCiphertextCharacter!,
                                                            is: character,
                                                            at: viewModel.selectedIndex!)
                                                    displayPhoneLetterPicker = false
                                    }
                                }
                                .fixedSize(horizontal: false, vertical: true)
                                .font(viewModel.theme.font(for: .title, for: bookTheme))
                                .foregroundColor(viewModel.theme.color(of: .keyboardLetters, for: bookTheme, in: colorScheme))
                                .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
                            }
                        }
                    }
                }
            }
            
            private func columns(for geometry : GeometryProxy) -> [GridItem]{
                let numberOfCols = geometry.size.width > 480 ? 13 : 9
                
                let letterWidth = Int(geometry.size.width / CGFloat(Double(numberOfCols) * 1.4))
                return Array(repeating: GridItem(.fixed(CGFloat(letterWidth))),
                             count: numberOfCols)
            }
        }
}


