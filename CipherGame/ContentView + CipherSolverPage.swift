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
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        @State
        var chapter : Chapter
        
        @State
        var currentCiphertextCharacter : Character? = nil
        
        @State
        var selectedIndex : Int?
        
        @State
        var displayPhoneLetterPicker : Bool = false
        
        @State
        var displayTabletLetterPicker : Bool = false
        
        @State
        private
        var resettingPuzzle : Bool = false
        
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
                    HStack{
                        ForEach(viewModel.visiblePuzzles(for: chapter), id:\.self){ puzzle in
                            Button(puzzle.title){
                                withAnimation{
                                    viewModel.currentPuzzleHash = puzzle.id
                                }
                            }
                        }
                    }
                    
                    ZStack(alignment: .bottom){
                        ScrollView{
                            cipherPuzzleView(for: viewModel.currentPuzzle, with: geometry)
                                .padding()
                            
                            if viewModel.currentPuzzle.isSolved {
                                riddleOptions()
                                    .background(Blur(style: .systemUltraThinMaterialDark))
                                    .cornerRadius(10)
                                    .transition(.scale)
                                Spacer(minLength: 250)
                            }
                        }
                        
                        Group{
                            if displayPhoneLetterPicker{
                                PhoneLetterPicker(displayPhoneLetterPicker: $displayPhoneLetterPicker,
                                                  currentCiphertextCharacter: $currentCiphertextCharacter,
                                                  selectedIndex: $selectedIndex,
                                                  puzzle: viewModel.currentPuzzle)
                                    .transition(.move(edge: .bottom))
                                    .frame(height: Self.phoneLetterPickerHeight)
                                    .gesture(dismissPhoneKeyboard)
                            } else {
                                LetterCount(currentCiphertextCharacter: $currentCiphertextCharacter,
                                            puzzle: viewModel.currentPuzzle)
                                    .transition(.move(edge: .bottom))
                                    .frame(height: Self.letterCountHeight)
                            }
                        }
                        .background(Blur(style: .systemUltraThinMaterialDark))
                        .cornerRadius(5)
                        .frame(width: geometry.size.width,
                               height: Self.letterCountHeight,
                               alignment: .bottom)
                        
                    } //Zstack
                    .background(viewModel.theme.image(for: .puzzleBackground, for: bookTheme)?.resizable(capInsets: EdgeInsets.zero(), resizingMode: .tile))
                    .alert(isPresented: $resettingPuzzle){resetPuzzleAlert()}
                    .toolbar{toolbarView()}
                }
            }
        }
        
        
        @ViewBuilder
        func cipherPuzzleView(for puzzle : Puzzle, with geometry : GeometryProxy) -> some View {
            VStack(alignment: .center, spacing: nil){
                Text(puzzle.header)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                Spacer()
                    .frame(height: geometry.size.height/20)
                
                LazyVGrid(columns: columns(screenWidth: geometry.size.width),
                          spacing: 0,
                          pinnedViews: [.sectionHeaders]){
                    ForEach(viewModel.data(for: puzzle)){ cipherPair in
                        CipherSolverCharacterPair(
                            puzzle: puzzle,
                            currentCiphertextCharacter: $currentCiphertextCharacter,
                            selectedIndex: $selectedIndex,
                            displayPhoneLetterPicker: $displayPhoneLetterPicker,
                            displayTabletLetterPicker: $displayTabletLetterPicker,
                            cipherTextLetter: cipherPair.cipherLetter,
                            plainTextLetter: cipherPair.userGuessLetter,
                            indexInTheCipher: cipherPair.id)
                    }
                }
                Spacer().frame(height: geometry.size.height/20)
                Text(puzzle.footer)
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
            }
        }
        
        
        @ViewBuilder
        func riddleOptions() -> some View {
            VStack{
                Text("Let's talk to the rover's designer...")
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                Spacer()
                HStack{
                    Text("🪐")
                    Text("🌍")
                    Text("👾")
                }
                .font(viewModel.theme.font(for: .title, for: bookTheme))
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
                    .foregroundColor(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme))
            )
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
        
        func resetPuzzleAlert() -> Alert {
            Alert(title: Text("Reset puzzle?"),
                  message: Text("You'll loose all your work and it can't be undone!"),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("Reset")){
                    withAnimation{
                        viewModel.reset()
                    }
                  })
        }
        
        
        
        func resetPuzzle(){
            $resettingPuzzle.wrappedValue.toggle()
        }
    }

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

        @Binding
        var currentCiphertextCharacter : Character?

        @Binding
        var selectedIndex : Int?

        var puzzle : Puzzle

        var body: some View {
            VStack {
                drawKeyboard()
                    .padding()
                Button{
                    withAnimation{
                        viewModel.guess(currentCiphertextCharacter!, is: nil,
                                        at: selectedIndex!, for: puzzle)
                    }
                } label: {Label("delete", systemImage: "delete.left")
                    .foregroundColor(viewModel.theme.color(of: .keyboardLetters, for: bookTheme, in: colorScheme))
                }
                Spacer()
            }
//            .overlay(
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme)!),
//                alignment: .center)
        }
            
            

            
        @ViewBuilder
        func drawKeyboard() -> some View {
            VStack{
                ForEach(String.qwerty, id:\.self ){line in
                    HStack(spacing: 12){
                        ForEach(line.map{$0}, id:\.self){ character in
                            
                            Text(String(character)).onTapGesture {
                                withAnimation{
                                    viewModel.guess(currentCiphertextCharacter!, is: character,
                                                    at: selectedIndex!, for: puzzle)
        //                                    displayPhoneLetterPicker = false
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

