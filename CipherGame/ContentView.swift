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
            
            List{
                ForEach(viewModel.availablePuzzles) { puzzleTitle in
                    NavigationLink(puzzleTitle.title,
                                   destination: CipherSolverPage().navigationTitle(puzzleTitle.title),
                                   tag: puzzleTitle.title,
                                   selection: $viewModel.currentPuzzleTitle)
                }
            }
        }.environmentObject(viewModel)
    }
    
    
    struct CipherSolverPage : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @State
        var userMadeASelection : Bool = false
        
        var scrollViewTap : some Gesture {
            TapGesture(count: 1).onEnded{
                userMadeASelection = false
                viewModel.currentCiphertextCharacter = nil
            }
        }
        
        var difficultyButtonTitle : String {
            switch viewModel.gameLevel {
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
                        Button(self.difficultyButtonTitle){
                            viewModel.gameLevel = (viewModel.gameLevel + 1) % 3
                        }
                    }
                }
                
            }
        }
        
        
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.fixed(20)),
                         count: Int(screenWidth / 40))
        }
        
    }

    
    struct CipherSolverCharacterPair : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @State
        private
        var wasTapped = false
        
        @Binding
        var userMadeASelection : Bool
        var cipherTextLetter : Character
        var plainTextLetter : Character?
        var indexInTheCipher : Int?
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        private var plainTextToDisplay : String {
            if let plainTextLetter = plainTextLetter{
                return String(plainTextLetter)
            } else {
                return ""
            }
        }
        
        var plaintextLabelTap : some Gesture {
            TapGesture(count: 1).onEnded{
                
                if String.alphabet.contains(cipherTextLetter){
                    //flip value
                    wasTapped = true
                    userMadeASelection = true
                    viewModel.currentUserSelectionIndex = indexInTheCipher
                    viewModel.currentCiphertextCharacter = cipherTextLetter
                }
                
            }
        }
        
        var body : some View {
            VStack{
                Text(String(cipherTextLetter))
                
                Spacer()
                
                if wasTapped, userMadeASelection {
                    
                    NewTextField(letterGuess: $viewModel.userGuess,
                                 ciphertextLetter: cipherTextLetter,
                                 puzzleTitle: viewModel.currentPuzzleTitle,
                                 wasTapped: $wasTapped,
                                 textColor: UIColor(Color.highlightColor(for: colorScheme)))
                    
                    
                } else {
                    Text(plainTextToDisplay)
                    //                        .background(Color.green)
                }
            }
            .gesture(plaintextLabelTap)
            .overlay(Rectangle()
                        .frame(width: 30, height: 1, alignment: .bottom)
                        .foregroundColor(.gray),
                     alignment: .bottom )
            .padding(.bottom)
            .font(.system(.title))
            .foregroundColor(viewModel.currentCiphertextCharacter == cipherTextLetter ?
                                Color.highlightColor(for: colorScheme) : nil)
        }
    }
    
    
    
    
    
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
        
        var userGuess : String {
            if let plainChar = plainChar {
                return String(plainChar)
            }
            return ""
        }
        
        var count : Int
        
        var body : some View {
            VStack {
                
                Group {
                    Text(String(cipherChar))
                    Text(String(count)).lineLimit(1)
                    Text(userGuess)
                }.foregroundColor(
                    viewModel.currentCiphertextCharacter == cipherChar ?
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
