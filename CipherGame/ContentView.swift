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
        
        var body : some View {
            
            GeometryReader { geometry in
                VStack{
                    ScrollView {
                        LazyVGrid(columns: self.columns(screenWidth: geometry.size.width)) {
                            ForEach(viewModel.data){ cipherPair in
                                CipherSolverCharacterPair(
                                    userMadeASelection: $userMadeASelection,
                                    cipherTextLetter: cipherPair.cipherLetter,
                                    plainTextLetter: cipherPair.userGuessLetter)
                            }
                        }
                    }.gesture(scrollViewTap)
                    LetterCount(letterCount: viewModel.letterCount)
                        .frame(width: geometry.size.width, height: 100, alignment: .bottom)
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
        
        private var plainTextToDisplay : String {
            if let plainTextLetter = plainTextLetter{
                return String(plainTextLetter)
            } else {
                return "_"
            }
        }
        
        var plaintextLabelTap : some Gesture {
            TapGesture(count: 1).onEnded{
                //flip value
                wasTapped = true
                userMadeASelection = true
                viewModel.currentCiphertextCharacter = cipherTextLetter
            }
        }
        
        var body : some View {
            VStack{
                Text(String(cipherTextLetter))
                
                Spacer()
                
                if wasTapped, userMadeASelection {
                   
                  NewTextField(letterGuess: $viewModel.userGuess,
                               ciphertextLetter: cipherTextLetter,
                               puzzleTitle: $viewModel.currentPuzzleTitle,
                               wasTapped: $wasTapped,
                               textColor: UIColor(CipherPuzzle.highlightColor))
                    

                } else {
                    Text(plainTextToDisplay)
                        .gesture(plaintextLabelTap)
//                        .background(Color.green)
                }
            }
            .padding(.bottom)
            .font(.system(.title))
            .foregroundColor(viewModel.currentCiphertextCharacter == cipherTextLetter ?
                CipherPuzzle.highlightColor : nil)
        }
    }
    
    
    
    
    
    struct LetterCount : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        var letterCount : [(Character,Int)]
        
        var body : some View {
            
            GeometryReader { geometry in
                
                VStack{
                    Text("Character Count")
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(columns: self.columns(screenWidth: geometry.size.width)) {
                            
                            if letterCount.count > 0 {
                                
                                ForEach(0..<letterCount.count) { index in
                                    let cipherChar = letterCount[index].0
                                    PairCount(cipherChar: cipherChar,
                                              plainChar: viewModel.plaintext(for: cipherChar),
                                              count: letterCount[index].1)
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: nil, alignment: .bottom)
                    }
                }
                
            }
        }
        
        
        func columns(screenWidth : CGFloat) -> [GridItem] {
            return Array(repeating: GridItem(.adaptive(minimum: CGFloat(30), maximum: CGFloat(40))),
                        count: Int(screenWidth / 30))
        }
        
        
        
    }
        
    
        
    struct PairCount : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        var cipherChar : Character
        
        var plainChar : Character?
        
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
                    Text(String(count))
                    Text(userGuess)
                }.foregroundColor(
                    viewModel.currentCiphertextCharacter == cipherChar ?
                        CipherPuzzle.highlightColor : nil )
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
