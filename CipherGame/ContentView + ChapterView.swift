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
        private
        var displayPhoneLetterPicker : Bool = false
        
        @State
        private
        var displayTabletLetterPicker : Bool = false
        
        @State
        private
        var resettingPuzzle : Bool = false
        
        @State
        var printing : Bool = false
        
        @State
        private
        var showLetterCount : Bool = true
        
        var chapter : Chapter
        
        var cipherPuzzle : DisplayedCipherPuzzle?
        
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
                        
                        if let cipherPuzzle = cipherPuzzle {
                            ScrollView(.vertical){
                                VStack{
                                    Spacer(minLength : 50)
                                    cipherPuzzleListView(cipherPuzzle, with: geometry)
                                        .id(cipherPuzzle.id)
                                        .toolbar(content: {cipherPuzzletoolbar(cipherPuzzle)})
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
        func cipherPuzzleListView(_ cipherPuzzle : DisplayedCipherPuzzle, with geometry : GeometryProxy) -> some View {
            VStack{
                Spacer()
                
                Text(cipherPuzzle.title)
                    .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
                    .font(viewModel.theme.font(for: .largeTitle, for: bookTheme))

                paragraph(text: cipherPuzzle.header)
                    .padding(EdgeInsets.sized(horizontally: geometry.size.width/7))
                
                
                LazyVStack(alignment: .leading){
                    
                    let puzzleLines = enumeratedLines(from: cipherPuzzle.puzzleCharacters,
                                                      charsPerLine: Int(geometry.size.width / Self.characterWidth))
                    let showLineNumbers = puzzleLines.count > 4
                    
                    ForEach(puzzleLines){ puzzleLine in
                        HStack(alignment: .bottom){
                            
                            //line numbers
                            if showLineNumbers {
                            Text(String(puzzleLine.id + 1))
                                .frame(alignment:.leading)
                                .fixedSize()
                                .lineLimit(1)
                                .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
                            }
                            HStack{
                                ForEach(puzzleLine.characters){ characterPair in
                                    CipherSolverCharacterPair(
                                        displayPhoneLetterPicker: $displayPhoneLetterPicker,
                                        displayTabletLetterPicker: $displayTabletLetterPicker,
                                        cipherTextLetter: characterPair.cipherLetter,
                                        plainTextLetter: characterPair.userGuessLetter,
                                        indexInTheCipher: characterPair.id)
                                }
                            }
                            .overlay(Rectangle()
                                        .frame(height: 3, alignment: .bottom)
                                        .foregroundColor(viewModel.theme.color(of: .puzzleLines,
                                                                               for: bookTheme, in: colorScheme)),
                                    alignment: .bottom )
                        }
                    }
                }
                .padding(EdgeInsets.sized(horizontally: UIDevice.current.userInterfaceIdiom == .pad ? geometry.size.width/7 : 10))

                paragraph(text: cipherPuzzle.footer)
                    .padding(EdgeInsets.sized(horizontally: geometry.size.width/7))
            }
        }
        
        @ViewBuilder
        func paragraph(text : String) -> some View{
            Spacer(minLength: 50)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(Self.bodyLineSpacing)
                .font(viewModel.theme.font(for: .body, for: bookTheme))
                .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
            Spacer(minLength: 50)
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
            .background(Blur(style: UIBlurEffect.Style(rawValue: viewModel.theme.blurStyle(for: bookTheme, in: colorScheme)) ?? .regular))
            .cornerRadius(Self.viewCornerRadius)
        }
        
        private
        func enumeratedLines(from puzzleData : [GameInfo], charsPerLine : Int) -> [PuzzleLine]{
            let lines = puzzleData.asLines(of: charsPerLine)
            return lines.enumerated().map{(lineNumber, line) in PuzzleLine(id: lineNumber, characters: line)}
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
                self.viewModel.selectedIndex = nil
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




