//
//  ContentView + CipherSolverPage.swift
//  CipherGame
//
//  Created by J Lambert on 05/04/2021.
//

import SwiftUI

extension ContentView {
//    MARK:- the puzzle
    struct ChapterViewer : View {
        
        static let phoneLetterPickerHeight = CGFloat(160)
        static let letterCountHeight = CGFloat(100)
        static let viewCornerRadius = CGFloat(10.0)
        static let bodyLineSpacing = CGFloat(6)
        static let characterWidth = CGFloat(35)
        
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
        var printing : Bool = false
        
        @Binding
        var showLetterCount : Bool
        
        private
        var dismissPhoneKeyboard : some Gesture {
            DragGesture()
                .onChanged{ gesture in
                if  abs(gesture.translation.height) > abs(gesture.translation.width){
                    withAnimation{
                        displayPhoneLetterPicker = false
                    }
                }
            }
        }
        
        var body : some View {
            GeometryReader { geometry in
                ZStack(alignment: .bottom){
                    VStack{
                        puzzleChooser(for: geometry)
                        Spacer()
                        
                        if viewModel.currentPuzzleHash != nil {
                            ScrollView(.vertical){
                                VStack{
                                    Spacer(minLength : 50)
                                    cipherPuzzleListView(with: geometry)
                                        .id(viewModel.currentPuzzleHash)
                                        .toolbar(content: cipherPuzzletoolbar)
                                    
                                    if viewModel.isSolved {
                                        riddleOptions(with: geometry)
                                            .id(viewModel.currentPuzzleHash)
                                            .transition(.scale)
                                        Spacer(minLength: 250)
                                    }
                                }
                                .background(viewModel.theme.image(for: .puzzlePaper, for: bookTheme)?
                                                .resizable(capInsets: EdgeInsets.zero(), resizingMode: .tile))
                            }
                            .zIndex(0)
                        } else if let currentChapterGridPuzzle = viewModel.currentChapterGridPuzzle {
                            TilePuzzle(grid: currentChapterGridPuzzle, screenSize: geometry.size)
                                .toolbar(content: gridPuzzleToolbar)
                        }
                        Spacer(minLength: 50)
                    }
                    .alert(isPresented: $resettingPuzzle){resetPuzzleAlert()}
                    .background(viewModel.theme.color(of: .puzzleBackground, for: bookTheme, in: colorScheme))
                    .background(viewModel.theme.image(for: .puzzleBackground, for: bookTheme)?
                                    .resizable(capInsets: EdgeInsets.zero(), resizingMode: .tile))
                    .onTapGesture{deselect()}
                    
                    if viewModel.currentPuzzleHash != nil {
                        keyboardAndLettercount(for: geometry)
                            .zIndex(1) //without this the keyboard doesn't animate as it hides
                            .transition(.move(edge: .bottom))
                    }
                }
                
            }
        }
    
        
        @ViewBuilder
        func cipherPuzzleListView(with geometry : GeometryProxy) -> some View {
            VStack{
                Spacer()
                Text(viewModel.puzzleTitle)
                    .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
                    .font(viewModel.theme.font(for: .largeTitle, for: bookTheme))
                Spacer(minLength: 50)
                paragraph(text: viewModel.header)
                    .padding(EdgeInsets.sized(horizontally: geometry.size.width/7))
                Spacer(minLength: 50)
                
                LazyVStack(alignment: .leading){
                    ForEach(viewModel.puzzleLines(charsPerLine: Int(geometry.size.width / Self.characterWidth))){ puzzleLine in
                        HStack(alignment: .bottom){
                            Text(String(puzzleLine.id))
                                .frame(alignment:.leading)
                                .fixedSize()
                                .lineLimit(1)
                                .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
                            HStack{
                                ForEach(puzzleLine.characters){ character in
                                    CipherSolverCharacterPair(
                                        displayPhoneLetterPicker: $displayPhoneLetterPicker,
                                        displayTabletLetterPicker: $displayTabletLetterPicker,
                                        cipherTextLetter: character.cipherLetter,
                                        plainTextLetter: character.userGuessLetter,
                                        indexInTheCipher: character.id)
                                }
                            }
                            .overlay(Rectangle()
                                        .frame(height: 3, alignment: .bottom)
                                        .foregroundColor(viewModel.theme.color(of: .puzzleLines,
                                                                               for: bookTheme, in: colorScheme)),
                                    alignment: .bottom )
                        }//.background(Color.red)
                    }
                }
//                .background(Color.blue)
                .padding(EdgeInsets.sized(horizontally: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width/7 : 10))
                Spacer(minLength: 50)
                paragraph(text: viewModel.footer)
                    .padding(EdgeInsets.sized(horizontally: geometry.size.width/7))
            }
        }
        
        @ViewBuilder
        func paragraph(text : String) -> some View{
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(Self.bodyLineSpacing)
                .font(viewModel.theme.font(for: .body, for: bookTheme))
                .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
        }

        @ViewBuilder
        func keyboardAndLettercount(for geometry : GeometryProxy) -> some View {
            Group{
                if displayPhoneLetterPicker {
                    PhoneLetterPicker(displayPhoneLetterPicker: $displayPhoneLetterPicker)
                        .frame(height: Self.phoneLetterPickerHeight)
                        .highPriorityGesture(dismissPhoneKeyboard)
                } else {
                    LetterCount(displayLetterCount: $showLetterCount)
                        .frame(height: showLetterCount ? Self.letterCountHeight : 30)
                }
            }
            .background(Blur(style: viewModel.theme.blurStyle(for: bookTheme, in: colorScheme)))
            .cornerRadius(Self.viewCornerRadius)
        }
        
        private
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.fixed(20)),
                         count: Int(screenWidth / 35))
        }
        
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
        
        private
        func deselect() {
            withAnimation{
                self.viewModel.currentCiphertextCharacter = nil
                self.displayPhoneLetterPicker = false
            }
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




