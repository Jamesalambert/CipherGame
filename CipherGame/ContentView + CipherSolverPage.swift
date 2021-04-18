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
        
        static let phoneLetterPickerHeight = CGFloat(50)
        static let letterCountHeight = CGFloat(100)
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        @State
        var puzzle : Puzzle
        
        @State
        var currentCiphertextCharacter : Character? = nil

        @State
        var selectedIndex : Int?
        
        @State
        var displayPhoneLetterPicker : Bool = false
        
        @State
        private
        var resettingPuzzle : Bool = false
        
        var body : some View {
            GeometryReader { geometry in
                VStack{
                    cipherPuzzleView(with: geometry)
                        .padding(.all, geometry.size.height/20)
                        .background(viewModel.theme.image(for: .puzzleBackground, for: bookTheme)?.resizable(capInsets: EdgeInsets.zero(), resizingMode: .tile))
                    
                    if displayPhoneLetterPicker{
                        PhoneLetterPicker(displayPhoneLetterPicker: $displayPhoneLetterPicker,
                                      currentCiphertextCharacter: $currentCiphertextCharacter,
                                      selectedIndex: $selectedIndex,
                                      puzzle: $puzzle)
                            .background(viewModel.theme.color(of: .puzzleBackground, for: bookTheme, in: colorScheme))
                            .frame(height: Self.phoneLetterPickerHeight)
                    }
                    
                    LetterCount(currentCiphertextCharacter: $currentCiphertextCharacter,
                                puzzle: $puzzle)
                        .background(viewModel.theme.color(of: .puzzleBackground, for: bookTheme, in: colorScheme))
                        .frame(width: geometry.size.width, height: Self.letterCountHeight, alignment: .bottom)
                    
                    
                }
                .alert(isPresented: $resettingPuzzle){resetPuzzleAlert()}
                .toolbar{toolbarView()}
            
            }
        }
        
        @ViewBuilder
        func cipherPuzzleView(with geometry : GeometryProxy) -> some View {
                ScrollView {
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
                                            puzzle: $puzzle,
                                            currentCiphertextCharacter: $currentCiphertextCharacter,
                                            selectedIndex: $selectedIndex,
                                            displayPhoneLetterPicker: $displayPhoneLetterPicker,
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
        }
        
        
        
        @ToolbarContentBuilder
        func toolbarView() -> some ToolbarContent {
            
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        if !viewModel.currentPuzzle.isSolved {
                            
                            #if DEBUG
                            Button("solve!"){
                                while !viewModel.currentPuzzle.isSolved {
                                    withAnimation{
                                        viewModel.quickHint()
                                    }
                                }
                            }
                            #endif
                            
                            Picker("difficulty", selection: $viewModel.difficultyLevel){
                                Text("easy").tag(UInt(0))
                                Text("medium").tag(UInt(1))
                                Text("hard").tag(UInt(2))
                            }
                            
                            if !viewModel.currentPuzzle.isSolved{
                                Button("quick hint"){
                                    withAnimation{
                                        viewModel.quickHint()
                                    }
                                }
                            }
                        }
                        
                        if viewModel.currentPuzzle.usersGuesses.count > 0 {
                            Button("reset puzzle"){
                                withAnimation{
                                    resettingPuzzle = true
                                }
                            }
                        }
                    } label: {
                        Label("difficulty", systemImage: "dial")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        Picker("text display", selection: $viewModel.capType){
                            Text("CAPITALS").tag(3)
                            Text("lowercase").tag(0)
                        }
                        
//                        Picker("font style", selection: $viewModel.fontDesign){
//                            Text("typewriter").tag(Font.Design.monospaced)
//                            Text("rounded").tag(Font.Design.rounded)
//                            Text("serif").tag(Font.Design.serif)
//                        }
                    } label: {
                        Label("text", systemImage: "textformat")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: printCipherPage, label: {
                        Label("print", systemImage: "printer")
                    })
                }
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
        
        private
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.fixed(20)),
                         count: Int(screenWidth / 35))
        }
        
        private
        func printCipherPage() {
            let formatter = UIMarkupTextPrintFormatter(markupText: viewModel.printableHTML)
            
            let printController = UIPrintInteractionController.shared
            
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = viewModel.currentPuzzle.title
            
            printController.printInfo = printInfo
            printController.printFormatter = formatter
            
            printController.present(animated: true)
        }
    }
    
    
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

        @Binding
        var puzzle : Puzzle
    

        var body: some View {
            ScrollView(.horizontal){
                HStack{
                    ForEach(String.alphabet.map{$0}, id: \.self){character in
                        Button{
                            withAnimation{
                                viewModel.guess(currentCiphertextCharacter!, is: character,
                                                at: selectedIndex!, for: puzzle)
                                displayPhoneLetterPicker = false
                            }
                        } label: {
                            Text(String(character))
                                .font(viewModel.theme.font(for: .title, for: bookTheme))
                                .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                        }
                    }
                }
            }
        }
    }
    
    
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
                            displayTabletLetterPicker = true
                        }
                    }
                    .popover(isPresented: $displayTabletLetterPicker, attachmentAnchor: .point(.bottom), arrowEdge: .leading){letterPopover()}
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
                
                Button{
                    withAnimation{
                        viewModel.guess(cipherTextLetter, is: nil,
                                        at: indexInTheCipher, for: puzzle)
                        displayTabletLetterPicker = false
                    }
                } label: {
                    Label("clear", systemImage: "clear")
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
