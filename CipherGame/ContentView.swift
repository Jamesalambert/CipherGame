//
//  ContentView.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    var viewModel = CipherPuzzle()
    
    @Environment(\.colorScheme)
    var colorScheme : ColorScheme
    
    var body: some View {
        
            NavigationView {
                List(){
                    ForEach(viewModel.availableBooks){ bookTitle in
                        
                        Text(bookTitle.title).font(.system(.title))
                        
                        ForEach(viewModel.puzzleTitles(for: bookTitle.id)){ puzzleTitle in

                            NavigationLink(destination: CipherSolverPage().navigationTitle(puzzleTitle.title), tag: puzzleTitle.id, selection: $viewModel.currentPuzzleHash){
                                            label(for: puzzleTitle)
                            }
                        }
                    }
                }
            }.environmentObject(viewModel)
    }
    
    private func label(for puzzleTitle : PuzzleTitle) -> some View {
        var icon = ""
        if viewModel.puzzleIsCompleted(hash: puzzleTitle.id) {
            icon = "checkmark.circle.fill"
        }
        return Label(puzzleTitle.title, systemImage: icon)
    }
    
    
    //    MARK:- the puzzle
    struct CipherSolverPage : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @State
        var userMadeASelection : Bool = false
        
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
                        LazyVGrid(columns: columns(screenWidth: geometry.size.width) ,spacing: 0, pinnedViews: [.sectionHeaders]) {
                            ForEach(viewModel.data){ cipherPair in
                                    CipherSolverCharacterPair(
                                        userMadeASelection: $userMadeASelection,
                                        cipherTextLetter: cipherPair.cipherLetter,
                                        plainTextLetter: cipherPair.userGuessLetter,
                                        indexInTheCipher: cipherPair.id)
                            }
                        }
                    }.gesture(scrollViewTap)
                    .padding(.top, geometry.size.height/20)
                    
                    LetterCount(letterCount: viewModel.letterCount)
                        .frame(width: geometry.size.width, height: 100, alignment: .bottom)
                    
                }
                .background(Color.backgroundColor(for: colorScheme))
                .toolbar{
                    
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button(self.difficultyButtonTitle){
                            viewModel.difficultyLevel = (viewModel.difficultyLevel + 1) % 3
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
        
        
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.fixed(20)),
                         count: Int(screenWidth / 40))
        }
        
        func printCipherPage() {
            
            let formatter = UIMarkupTextPrintFormatter(markupText: viewModel.printableHTML)
            
            let printController = UIPrintInteractionController.shared
            
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = viewModel.currentPuzzle?.title ?? "cipher"
            
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
        
        @Binding
        var userMadeASelection : Bool
        var cipherTextLetter : Character
        var plainTextLetter : Character?
        var indexInTheCipher : Int?
        
        
        var plaintextLabelTap : some Gesture {
            TapGesture(count: 1).onEnded{
                //flip value
                wasTapped = true
                userMadeASelection = true
                viewModel.currentUserSelectionIndex = indexInTheCipher
                viewModel.currentCiphertextCharacter = cipherTextLetter
                print("tap")
            }
        }
        
        var body : some View {
            
            VStack{
                    Text(String(cipherTextLetter))
                        .gesture(plaintextLabelTap)
                        .fixedSize()
                    
                    Spacer()
                    
                    if wasTapped, userMadeASelection {
                        
                        NewTextField(letterGuess: $viewModel.userGuess,
                                        wasTapped: $wasTapped,
                                        textColor: UIColor(Color.highlightColor(for: colorScheme)),
                                        capType: $viewModel.capType)
                        
                    } else {
                        Text(plainTextLetter.string())
                                .gesture(plaintextLabelTap)
                                .foregroundColor(Color.plaintext(for: colorScheme))
                                .fixedSize()
                    }
                }
                .overlay(Rectangle()
                            .frame(width: 30, height: 1, alignment: .bottom)
                            .foregroundColor(.gray),
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

    

    

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let game = CipherPuzzle()
        Group {
            ContentView(viewModel: game)
        }
    }
}



