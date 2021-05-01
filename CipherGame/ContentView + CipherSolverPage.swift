//
//  ContentView + CipherSolverPage.swift
//  CipherGame
//
//  Created by J Lambert on 05/04/2021.
//

import SwiftUI

extension ContentView {
//    MARK:- the puzzle
    struct CipherSolverPage : View {
        
        static let letterAnimation = 0.75
        static let phoneLetterPickerHeight = CGFloat(160)
        static let letterCountHeight = CGFloat(120)
        static let viewCornerRadius = CGFloat(10.0)
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        @State
        var displayPhoneLetterPicker : Bool = false
        
        @State
        var displayTabletLetterPicker : Bool = false
        
        @State
        private
        var resettingPuzzle : Bool = false
        
        @State
        private
        var displayLetterCount : Bool = true
        
        private
        var dismissPhoneKeyboard : some Gesture {
            DragGesture().onChanged{ gesture in
                if  abs(gesture.translation.height) > abs(gesture.translation.width){
                    withAnimation{
                        displayPhoneLetterPicker = false
                    }
                }
            }
        }
        
        var body : some View {
            GeometryReader { geometry in
                VStack{
                    Spacer(minLength: 10)
                    puzzleChooser(for: geometry)
                    ZStack(alignment: .bottom){
                        ScrollView{
                            VStack{
                                cipherPuzzleView(with: geometry)
                                    .padding()
                                if viewModel.isSolved {
                                    riddleOptions()
                                        .transition(.scale)
                                    Spacer(minLength: 250)
                                }
                            }
                        }
                        keyboardAndLettercount(for: geometry)
                    }
                    .alert(isPresented: $resettingPuzzle){resetPuzzleAlert()}
                    .toolbar{toolbarView()}
                }
                .background(viewModel.theme.image(for: .puzzleBackground, for: bookTheme)?
                                .resizable()
                                .aspectRatio(contentMode: .fill))
                                //.resizable(capInsets: EdgeInsets.zero(), resizingMode: .tile))
            }
        }
        

        @ViewBuilder
        func cipherPuzzleView(with geometry : GeometryProxy) -> some View {
            VStack(alignment: .center, spacing: nil){
                Text(viewModel.header)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                Spacer()
                    .frame(height: geometry.size.height/20)
                
                LazyVGrid(columns: columns(screenWidth: geometry.size.width),
                          spacing: 0,
                          pinnedViews: [.sectionHeaders]){
                    ForEach(viewModel.data){ cipherPair in
                        CipherSolverCharacterPair(
                            displayPhoneLetterPicker: $displayPhoneLetterPicker,
                            displayTabletLetterPicker: $displayTabletLetterPicker,
                            cipherTextLetter: cipherPair.cipherLetter,
                            plainTextLetter: cipherPair.userGuessLetter,
                            indexInTheCipher: cipherPair.id)
                    }
                }
                Spacer().frame(height: geometry.size.height/20)
                Text(viewModel.footer)
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
            }
        }
        
        @ViewBuilder
        func keyboardAndLettercount(for geometry : GeometryProxy) -> some View {
            Group{
                if displayPhoneLetterPicker {
                    PhoneLetterPicker(displayPhoneLetterPicker: $displayPhoneLetterPicker)
                        .frame(height: Self.phoneLetterPickerHeight)
                        .cornerRadius(Self.viewCornerRadius)
                        .transition(.move(edge: .bottom))
                        .gesture(dismissPhoneKeyboard)
                } else {
                    LetterCount(displayLetterCount: $displayLetterCount)
                        .frame(height: displayLetterCount ? Self.letterCountHeight : 30)
                        .transition(.move(edge: .bottom))
                }
            }
            .background(Blur(style: .systemUltraThinMaterialDark))
            .frame(width: geometry.size.width,
                   height: Self.letterCountHeight,
                   alignment: .bottom)
        }
        
        
        private
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.fixed(20)),
                         count: Int(screenWidth / 35))
        }
        
        
        //        test using a list vs a grid. Buggy but maybe helpful.
        //        @ViewBuilder
        //        func cipherPuzzleViewEXP(with geometry : GeometryProxy) -> some View {
        //            List{
        //
        //                Text(viewModel.headerText)
        //                    .fixedSize(horizontal: false, vertical: true)
        //                    .font(viewModel.theme.font(for: .body, for: bookTheme))
        //                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
        //
        //                ForEach(viewModel.puzzleLines){ puzzleLine in
        //                    HStack(alignment: .bottom, spacing: 0){
        //                        Spacer()
        //                        Text(String(puzzleLine.id))
        //                        Spacer()
        //                        ForEach(puzzleLine.characters){ cipherPair in
        //                            CipherSolverCharacterPair(
        //                                tappedIndex: $tappedIndex,
        //                                userMadeASelection: $userMadeASelection,
        //                                cipherTextLetter: cipherPair.cipherLetter,
        //                                plainTextLetter: cipherPair.userGuessLetter,
        //                                indexInTheCipher: cipherPair.id)
        //                                .frame(width: geometry.size.width / 40, height: nil, alignment: .center)
        //                        }
        //                        Spacer()
        //                    }
        //
        //                    if line(puzzleLine.id, contains: tappedIndex){
        //                        LetterPicker()
        //                    }
        //
        //                }
        //
        //                Text(viewModel.footerText)
        //                    .font(viewModel.theme.font(for: .body, for: bookTheme))
        //                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
        //
        //
        //            }
        //
        //        }
        //
        //        private func line(_ line : Int, contains index : Int) -> Bool {
        //            return line == Int(floor(Double(index / viewModel.charsPerLine)))
        //        }
        
        private
        func resetPuzzleAlert() -> Alert {
            Alert(title: Text("Reset puzzle?"),
                  message: Text("You'll loose all your work and it can't be undone!"),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("Reset")){
                    withAnimation{viewModel.reset()}
                  })
        }
        
        func resetPuzzle(){
            $resettingPuzzle.wrappedValue.toggle()
        }
    }
}


private struct BookThemeKey : EnvironmentKey {
    static let defaultValue: BookTheme = .defaultTheme
}

extension EnvironmentValues {
    var bookTheme : BookTheme {
        get { 
            self[BookThemeKey.self]
        }
        set {
            self[BookThemeKey.self] = newValue
        }
    }
}

extension EdgeInsets {
    static
    func zero() -> EdgeInsets {
        return EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
    }
}


