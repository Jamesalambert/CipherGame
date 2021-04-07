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
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @State
        private
        var userMadeASelection : Bool = false
        
        @State
        private
        var resettingPuzzle : Bool = false
        
        var scrollViewTap : some Gesture {
            TapGesture(count: 1).onEnded{
                userMadeASelection = false
                viewModel.currentCiphertextCharacter = nil
            }
        }
        
        var difficultyButtonTitle : String {
            switch viewModel.difficultyLevel {
            case 0:
                return "easy"
            case 1:
                return "medium"
            default:
                return "hard"
            }
        }
        
        
        var body : some View {
            
            GeometryReader { geometry in
                VStack{
                    
//Experimental
//                        List{
//                            ForEach(viewModel.puzzleLines){ puzzleLine in
//                                HStack{
//                                    Spacer()
//                                        .gesture(scrollViewTap)
//
//                                    Text(String(puzzleLine.id))
//
//                                    Spacer()
//                                        .gesture(scrollViewTap)
//
//                                    ForEach(puzzleLine.characters){ cipherPair in
//
//                                        CipherSolverCharacterPair(
//                                            userMadeASelection: $userMadeASelection,
//                                            cipherTextLetter: cipherPair.cipherLetter,
//                                            plainTextLetter: cipherPair.userGuessLetter,
//                                            indexInTheCipher: cipherPair.id)
//                                        .frame(width: geometry.size.width / 40, height: nil, alignment: .center)
//
//                                    }
//                                    Spacer()
//                                        .gesture(scrollViewTap)
//                                }
//                            }
//                        }
//                    //.gesture(scrollViewTap) // causes problems
                
                    
                    ScrollView {
                        
                        VStack(alignment: .leading, spacing: nil){
                            Text(viewModel.headerText).fixedSize(horizontal: false, vertical: true)
                            Spacer().frame(height: geometry.size.height/20)
                            
                            LazyVGrid(columns: columns(screenWidth: geometry.size.width) ,spacing: 0, pinnedViews: [.sectionHeaders]) {
                                ForEach(viewModel.data){ cipherPair in
                                        CipherSolverCharacterPair(
                                            userMadeASelection: $userMadeASelection,
                                            cipherTextLetter: cipherPair.cipherLetter,
                                            plainTextLetter: cipherPair.userGuessLetter,
                                            indexInTheCipher: cipherPair.id)
                                }
                            }
                            
                            
                            Spacer().frame(height: geometry.size.height/20)
                            Text(viewModel.footerText)
                        }

                    }.gesture(scrollViewTap)
                    .padding(.all, geometry.size.height/20)
                    
                    LetterCount(letterCount: viewModel.letterCount)
                        .frame(width: geometry.size.width, height: 100, alignment: .bottom)
                    
                }
                .alert(isPresented: $resettingPuzzle){
                    
                    Alert(title: Text("Reset puzzle?"),
                          message: Text("You'll loose all your work and it can't be undone!"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Reset")){
                            withAnimation{
                                viewModel.reset()
                            }
                          })
                }
                .background(Color.backgroundColor(for: colorScheme))
                .toolbar{
                    
                    ToolbarItem(placement: .navigationBarTrailing){
                        Menu{
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
                            
                            Picker("font style", selection: $viewModel.fontDesign){
                                Text("typewriter").tag(Font.Design.monospaced)
                                Text("rounded").tag(Font.Design.rounded)
                                Text("serif").tag(Font.Design.serif)
                            }
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
            }
        }
        
        
        private
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.fixed(20)),
                         count: Int(screenWidth / 40))
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
    
    
    
    
    
    struct CipherSolverCharacterPair : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @State
        private
        var wasTapped = false
        
        @State
        var isSolved : Bool = false
        
        @Binding
        var userMadeASelection : Bool
        var cipherTextLetter : Character
        var plainTextLetter : Character?
        var indexInTheCipher : Int?
        
        private
        var plaintextLabelTap : some Gesture {
            TapGesture(count: 1).onEnded{
                //flip value
                wasTapped = true
                userMadeASelection = true
                viewModel.currentUserSelectionIndex = indexInTheCipher
                viewModel.currentCiphertextCharacter = cipherTextLetter
            }
        }
        
        var body : some View {
            
            if viewModel.currentPuzzle.isSolved{
                plaintextOnly()
            } else {
                //spaces and punctuation aren't tappable/editable
                if cipherTextLetter.isPunctuation || cipherTextLetter.isWhitespace {
                    standardCipherPair(displayPlaintext: false)
                } else {
                    standardCipherPair(displayPlaintext: true)
                        .gesture(plaintextLabelTap)
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
                
                if wasTapped, userMadeASelection, displayPlaintext {
                    
                    NewTextField(letterGuess: $viewModel.userGuess,
                                    wasTapped: $wasTapped,
                                    textColor: UIColor(Color.highlightColor(for: colorScheme)),
                                    capType: $viewModel.capType)
                    
                } else {
                    Text(plainTextLetter.string())
                            .foregroundColor(Color.plaintext(for: colorScheme))
                        .frame(height : 30)
                            .fixedSize()
                            .transition(.slide)
                }
            }
            .overlay(Rectangle()
                        .frame(width: 30, height: 1, alignment: .bottom)
                        .foregroundColor(Color.plaintext(for: colorScheme)),
                        alignment: .bottom )
            .padding(.top)
            .font(.system(.title, design: viewModel.fontDesign))
            .foregroundColor(foregroundColor(for: colorScheme))
            .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
        }
    
        @ViewBuilder
        private
        func plaintextOnly() -> some View {
            VStack{

                Text(plainTextLetter.string())
                    .foregroundColor(Color.plaintext(for: colorScheme))
                .frame(height : 30)
                    .fixedSize()
                    .transition(.slide)
                
            }
            .overlay(Rectangle()
                        .frame(width: 30, height: 1, alignment: .bottom)
                        .foregroundColor(Color.plaintext(for: colorScheme)),
                        alignment: .bottom )
            .padding(.top)
            .font(.system(.title, design: viewModel.fontDesign))
            .foregroundColor(foregroundColor(for: colorScheme))
            .textCase(viewModel.capType == 3 ? .uppercase : .lowercase)
        }
        
        private
        func foregroundColor(for colorScheme : ColorScheme) -> Color {
            if viewModel.currentCiphertextCharacter == cipherTextLetter.lowerChar() {
                return Color.highlightColor(for: colorScheme)
            }
            return Color.ciphertext(for: colorScheme)
        }
        
        
    }
}
