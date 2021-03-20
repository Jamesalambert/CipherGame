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
                                   destination: CipherSolverPage(),
                                   tag: puzzleTitle.title,
                                   selection: $viewModel.currentPuzzleTitle)
                }
                            
            }
        }.environmentObject(viewModel)
    }
    
    
    struct CipherSolverPage : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
                
        var body : some View {
            
            GeometryReader { geometry in
                VStack{
                    ScrollView {
                        LazyVGrid(columns: self.columns(screenWidth: geometry.size.width)) {
                            ForEach(viewModel.data){ cipherPair in
                                CipherSolverCharacterPair(
                                    cipherTextLetter: cipherPair.cipherLetter,
                                    plainTextLetter: cipherPair.userGuessLetter)
                            }
                        }
                    }
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
        var cipherTextLetter : Character
        
        var plainTextLetter : Character?
        
        private var plainTextToDisplay : String {
            if let plainTextLetter = plainTextLetter{
                return String(plainTextLetter)
            } else {
                return "_"
            }
        }
        
        var tapGesture : some Gesture {
            TapGesture(count: 1).onEnded{
                //flip value
                wasTapped = true
                viewModel.currentCiphertextCharacter = cipherTextLetter
            }
        }
        
        var body : some View {
            VStack{
                Text(String(cipherTextLetter))
                
                Spacer()
                
                if wasTapped {
                    NewTextField(letterGuess: $viewModel.userGuess,
                                 ciphertextLetter: cipherTextLetter,
                                 puzzleTitle: $viewModel.currentPuzzleTitle,
                                 wasTapped: $wasTapped)

                } else {
                    Text(plainTextToDisplay)
                        .gesture(tapGesture)
                }
            }
            .padding(.bottom)
            .font(.system(.title))
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
                                    PairCount(char: letterCount[index].0,
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
        var char : Character
        var count : Int
        
        var body : some View {
            VStack {
                
                if viewModel.currentCiphertextCharacter == char {
                    Text(String(char)).foregroundColor(.blue)
                    Text(String(count)).foregroundColor(.blue)
                } else {
                    Text(String(char))
                    Text(String(count))
                }
                
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
