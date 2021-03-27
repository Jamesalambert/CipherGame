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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.availableBooks){ bookTitle in
                    
                    Text(bookTitle.title).font(.system(.title))
                        
                    ForEach(viewModel.puzzleTitles(for: bookTitle.id)){ puzzleTitle in
                        NavigationLink(puzzleTitle.title,
                                       destination: CipherSolverPage().navigationTitle(puzzleTitle.title),
                                       tag: puzzleTitle.id,
                                       selection: $viewModel.currentPuzzleHash)
                    
                    }
                }
            }
        }.environmentObject(viewModel)
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
                    ScrollView {
                        LazyVGrid(columns: self.columns(screenWidth: geometry.size.width), spacing: 0) {
                            ForEach(viewModel.data){ cipherPair in
                                CipherSolverCharacterPair(
                                    userMadeASelection: $userMadeASelection,
                                    cipherTextLetter: cipherPair.cipherLetter,
                                    plainTextLetter: cipherPair.userGuessLetter,
                                    indexInTheCipher: cipherPair.id)
                            }
                        }
                    }.gesture(scrollViewTap)
                   
                    LetterCount(letterCount: viewModel.letterCount)
                        .frame(width: geometry.size.width, height: 100, alignment: .bottom)
               
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button(action: {
                            viewModel.difficultyLevel = (viewModel.difficultyLevel + 1) % 3
                        }, label: {
                            Text(self.difficultyButtonTitle)
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing ) {
                        Button(action: {
                            if viewModel.capType == .allCharacters {
                                viewModel.capType = .none
                            } else {
                                viewModel.capType = .allCharacters
                            }
                            
                        }, label: {
                                Image(systemName: "textformat")
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing){
                        GeometryReader { geometry in
                            Button(action: {
                                print(animatingFrom: geometry.frame(in: CoordinateSpace.local))
                            }, label: {
                                if colorScheme == ColorScheme.light{
                                    Image(systemName: "printer.fill")
                                } else {
                                    Image(systemName: "printer")
                                }
                            })
                        }
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
        func print(animatingFrom rect : CGRect) {
            
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
            }
        }
        
        var body : some View {
            VStack{
                Text(String(cipherTextLetter))
                    
                Spacer()
                
                if wasTapped, userMadeASelection {
                    
                    NewTextField(letterGuess: $viewModel.userGuess,
                                 wasTapped: $wasTapped,
                                 textColor: UIColor(Color.highlightColor(for: colorScheme)),
                                 capType: $viewModel.capType)
                    
                } else {
                    Text(plainTextLetter.string())
                }
            }
            .textCase(viewModel.capType == .allCharacters ? .uppercase : .lowercase)
            .gesture(plaintextLabelTap)
            .overlay(Rectangle()
                        .frame(width: 30, height: 1, alignment: .bottom)
                        .foregroundColor(.gray),
                     alignment: .bottom )
            .padding(.bottom)
            .font(.system(.title, design: viewModel.fontDesign))
            .foregroundColor(viewModel.currentCiphertextCharacter == cipherTextLetter.lowerChar() ?
                                Color.highlightColor(for: colorScheme) : nil)
        }
    }
    
    
//    MARK:- letter count view
    struct LetterCount : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        var letterCount : [(Character,Int)]
        
        var body : some View {
            
            GeometryReader { geometry in
                
                VStack {
                    Divider()
                    Text("Character Count")
                    
                    ScrollView(.horizontal) {
                        LazyVGrid(columns: self.columns(screenWidth: geometry.size.width)) {
                            
                            if letterCount.count > 0 {
                                
                                ForEach(0..<letterCount.count) { index in
                                    let cipherChar = letterCount[index].0
                                    PairCount(cipherChar: cipherChar,
                                              plainChar: viewModel.plaintext(for: cipherChar),
                                              count: letterCount[index].1)
                                }
                            }
                        }//.background(Color.blue)
                    }//.background(Color.green)
                }//.background(Color.red)
            }
        }
        
        
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.flexible(minimum: CGFloat(25), maximum: CGFloat(30))),
                        count: 26)
        }
        
        
        
    }
        
    
    
    struct PairCount : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        var cipherChar : Character
        
        var plainChar : Character?
        
        @Environment (\.colorScheme)
        var colorScheme : ColorScheme
        
        var count : Int
        
        var body : some View {
            VStack {
                
                Group {
                    Text(String(cipherChar))
                    Text(String(count)).lineLimit(1)
                    Text(plainChar.string())
                }
                .font(.system(.body, design: viewModel.fontDesign))
                .textCase(viewModel.capType == .allCharacters ? .uppercase : .lowercase)
                .foregroundColor(
                    viewModel.currentCiphertextCharacter == cipherChar.lowerChar() ?
                        Color.highlightColor(for: colorScheme) : nil )
                Spacer()
            }
        }
    }
        

}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let game = CipherPuzzle()
//        Group {
//            ContentView(viewModel: game)
//        }
//    }
//}



