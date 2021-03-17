//
//  ContentView.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    //@ObservedObject
    var viewModel : CipherPuzzle
    
    func columns(screenWidth : CGFloat) -> [GridItem] {
        return Array(repeating: GridItem(.fixed(20)),
                     count: Int(screenWidth / 30))
    }
    
    
    var body: some View {
        GeometryReader{ geometry in
            
            NavigationView {
                    
                List(viewModel.availablePuzzles) { puzzleTitle in
                        NavigationLink(puzzleTitle.title,
                                       destination:
                                        CipherSolverPage(
                                            columns: columns(screenWidth: geometry.size.width),
                                            viewModel: viewModel,
                                            puzzleTitle: puzzleTitle.title)
                        )
                    }
                
            }
        }
    }
    
    
    struct CipherSolverPage : View {
        
        var columns : [GridItem]
        var viewModel : CipherPuzzle
        var puzzleTitle : String
        
        var body : some View {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.data(forPuzzle: puzzleTitle)){ cipherPair in
                    
                    CipherSolverCharacterPair(
                        cipherTextLetter: cipherPair.cipherLetter,
                        plainTextLetter: cipherPair.userGuessLetter,
                        viewModel: viewModel,
                        puzzleTitle: puzzleTitle)
                }
            }
        }
        
        
    }

    
    struct CipherSolverCharacterPair : View {
        
        var cipherTextLetter : Character
        var plainTextLetter : Character?
        var viewModel : CipherPuzzle
        var puzzleTitle : String
        
        private var plainTextToDisplay : String {
            if let plainTextLetter = plainTextLetter{
                return String(plainTextLetter)
            } else {
                return ""
            }
        }
        
        @State private var letterGuess = ""
        
        var body : some View {
            VStack{
                
                Text(String(cipherTextLetter))
                
                TextField(plainTextToDisplay,
                          text: $letterGuess ,
                          onCommit: {
                            self.updateModel()
                })
                .multilineTextAlignment(.center)
                .autocapitalization(.none)
            }
        }
        
        
        func updateModel(){
            guard let chosenLetter = letterGuess.first else {return}
            
            viewModel.updateUsersGuesses(cipherCharacter: cipherTextLetter,
                                         plaintextCharacter: chosenLetter,
                                         in: puzzleTitle)
            //reset temp variable
            letterGuess = ""
        }
    }
 
    
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = CipherPuzzle()
        Group {
            ContentView(viewModel: game)
            ContentView(viewModel: game)
        }
    }
}
