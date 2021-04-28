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
                    Spacer(minLength: 10)
                    puzzleChooser(for: geometry)
                    ZStack(alignment: .bottom){
                        ScrollView{
                            cipherPuzzleView(with: geometry)
                                .padding()
                            if viewModel.currentPuzzle.isSolved {
                                riddleOptions()
                                    .background(Blur(style: .systemUltraThinMaterialDark))
                                    .cornerRadius(10)
                                    .transition(.scale)
                                Spacer(minLength: 250)
                            }
                        }
                        keyboardAndLettercount(for: geometry)
                    }
                    .alert(isPresented: $resettingPuzzle){resetPuzzleAlert()}
                    .toolbar{toolbarView()}
                }
                .background(viewModel.theme.image(for: .puzzleBackground, for: bookTheme)?
                                .resizable(capInsets: EdgeInsets.zero(), resizingMode: .tile))
            }
        }
        
        
        
        @ViewBuilder
        func cipherPuzzleView(with geometry : GeometryProxy) -> some View {
            VStack(alignment: .center, spacing: nil){
                Text(viewModel.currentPuzzle.header)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                Spacer()
                    .frame(height: geometry.size.height/20)
                
                LazyVGrid(columns: columns(screenWidth: geometry.size.width),
                          spacing: 0,
                          pinnedViews: [.sectionHeaders]){
                    ForEach(viewModel.data(for: viewModel.currentPuzzle)){ cipherPair in
                        CipherSolverCharacterPair(
                            displayPhoneLetterPicker: $displayPhoneLetterPicker,
                            displayTabletLetterPicker: $displayTabletLetterPicker,
                            cipherTextLetter: cipherPair.cipherLetter,
                            plainTextLetter: cipherPair.userGuessLetter,
                            indexInTheCipher: cipherPair.id)
                    }
                }
                Spacer().frame(height: geometry.size.height/20)
                Text(viewModel.currentPuzzle.footer)
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
            }
        }
        
        @ViewBuilder
        func keyboardAndLettercount(for geometry : GeometryProxy) -> some View {
            Group{
                if displayPhoneLetterPicker {
                    PhoneLetterPicker(displayPhoneLetterPicker: $displayPhoneLetterPicker)
                        .transition(.move(edge: .bottom))
                        .frame(height: Self.phoneLetterPickerHeight)
                        .gesture(dismissPhoneKeyboard)
                } else {
                    LetterCount()
                        .transition(.move(edge: .bottom))
                        .frame(height: Self.letterCountHeight)
                }
            }
            .background(Blur(style: .systemUltraThinMaterialDark))
            .cornerRadius(5)
            .frame(width: geometry.size.width,
                   height: Self.letterCountHeight,
                   alignment: .bottom)
        }
        
        @ViewBuilder
        func puzzleChooser(for geometry : GeometryProxy) -> some View {
            ScrollView(.horizontal){
                HStack(alignment: .bottom){
                    Spacer()
                    ForEach(viewModel.visiblePuzzles){ puzzle in
                        Button {
                            withAnimation{
                                viewModel.currentPuzzleHash = puzzle.id
                                viewModel.currentCiphertextCharacter = nil
                            }
                        } label: {
                            Text(puzzle.title)
                                .lineLimit(1)
                                .font(viewModel.theme.font(for: .subheadline, for: bookTheme))
                                .foregroundColor(viewModel.theme.color(of: .puzzleLines,
                                                    for: bookTheme, in: colorScheme))
                        }
                        .padding()
                        .background(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme)?
                                        .opacity( puzzle == viewModel.currentPuzzle ? 0.3 : 0.1))
                        .cornerRadius(10)
                    }
                    Spacer()
                }
            }
        }
        
        @ViewBuilder
        func riddleOptions() -> some View {
                if viewModel.currentPuzzle.riddleAnswers.count > 1 {
                    MultipleChoiceRiddle()
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .foregroundColor(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme)))
                }
        }
        
        
        struct MultipleChoiceRiddle : View {
            @EnvironmentObject
            var viewModel : CipherPuzzle
            
            @Environment(\.bookTheme)
            var bookTheme : BookTheme
            
            @Environment(\.colorScheme)
            var colorScheme : ColorScheme
            
            @State
            private
            var userChoice : String?
            
            private var message : String = "Now you have a new puzzle to solve...\nNow you have a new puzzle to solve..."
            
            @State
            private var displayedString : String = ""
            
            var body: some View {
                VStack{
                    Text(viewModel.currentPuzzle.riddle)
                        .font(viewModel.theme.font(for: .body, for: bookTheme))
                        .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                    Spacer()
                    HStack{
                        ForEach(viewModel.currentPuzzle.riddleAnswers, id:\.self){ answer in
                            Button{
                                withAnimation{
                                    userChoice = answer
                                    viewModel.add(answer: answer)
                                }
                            } label: {
                                Text(answer)
                            }.padding()
                            .background(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme)?
                                            .opacity( userChoice == answer ? 0.3 : 0))
                            .cornerRadius(10)
                        }
                    }
                    .font(viewModel.theme.font(for: .title, for: bookTheme))
                    
                    //animated text
                    if userChoice != nil {
                        Text(displayedString)
                            .fixedSize()
                            .font(viewModel.theme.font(for: .body, for: bookTheme))
                            .onAppear{typewriter()}
                    }
                }
            }
            
            private func typewriter() {
                for (index, character) in message.enumerated() {
                    DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + .milliseconds(index * 100)){
                        displayedString.append(character)
                    }
                }
            }
        }
        
//        @ViewBuilder
//        func multipleChoiceRiddle() -> some View {
//            VStack{
//                Text(viewModel.currentPuzzle.riddle)
//                    .font(viewModel.theme.font(for: .body, for: bookTheme))
//                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
//                Spacer()
//                HStack{
//                    ForEach(viewModel.currentPuzzle.riddleAnswers, id:\.self){ answer in
//                        Button{
//                            withAnimation{
//                                viewModel.add(answer: answer)
//                            }
//                        } label: {
//                            Text(answer).font(.title)
//                        }
//                    }
//                }
//                .font(viewModel.theme.font(for: .title, for: bookTheme))
//            }
//        }
        
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


