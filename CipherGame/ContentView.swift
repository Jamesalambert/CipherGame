//
//  ContentView.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject
    var viewModel : CipherPuzzle
    
    func columns(screenWidth : CGFloat) -> [GridItem] {
        return Array(repeating: GridItem(.fixed(20)),
                     count: Int(screenWidth / 30))
    }
    
    
    
    var body: some View {
        GeometryReader{ geometry in
            LazyVGrid(columns: self.columns(screenWidth: geometry.size.width)) {
                ForEach(viewModel.currentPuzzle){ cipherPair in
                    
                    CipherSolverCharacterPair(cipherTextLetter: cipherPair.cipherLetter,
                                              plainTextLetter: viewModel.plaintext(for: cipherPair.cipherLetter),
                                              viewModel: viewModel)
                }
            }
        }
    }
    
    

    
    struct CipherSolverCharacterPair : View {
        
        var cipherTextLetter : Character
        var plainTextLetter : Character?
        var viewModel : CipherPuzzle
        
        private var plainTextToDisplay : String {
            if let plaintext = plainTextLetter{
                return String(plaintext)
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
            }
        }
        
        
        
        func updateModel(){
            guard let chosenLetter = letterGuess.first else {return}

            viewModel.updateUsersGuesses(cipherCharacter: cipherTextLetter, plaintextCharacter: chosenLetter)
        }
        
        
    }
    
    
    
    
    
    
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = CipherPuzzle()
        ContentView(viewModel: game)
    }
}
