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
                                   selection: $viewModel.currentPuzzle)
                }
                            
            }
        }.environmentObject(viewModel)
    }
    
    
    
    struct CipherSolverPage : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
                
        var body : some View {
            
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: self.columns(screenWidth: geometry.size.width)) {
                        ForEach(viewModel.data){ cipherPair in
                            CipherSolverCharacterPair(
                                cipherTextLetter: cipherPair.cipherLetter,
                                plainTextLetter: cipherPair.userGuessLetter)
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
        
//        @State
//        private
//        var letterGuess = ""
        
        @State
        private
        var wasTapped = false
        var cipherTextLetter : Character
        
        var plainTextLetter : Character?
        var puzzleTitle : String {
            return viewModel.currentPuzzle!
        }
        
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
                                 puzzleTitle: $viewModel.currentPuzzle,
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
}






//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let game = CipherPuzzle()
//        Group {
//            ContentView(viewModel: game)
//        }
//    }
//}
