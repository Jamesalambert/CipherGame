//
//  ContentView.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

struct ContentView: View {
    
//    @StateObject
    var viewModel = CipherPuzzle()
    
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
                                        ScrollView {
                                        CipherSolverPage(
                                            viewModel: viewModel,
                                            columns: columns(screenWidth: geometry.size.width),
                                            puzzleTitle: puzzleTitle.title)
                                        }
                        )
                }
            }
        }
    }
    
    
    struct CipherSolverPage : View {
        
//        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        var columns : [GridItem]
        var puzzleTitle : String
        var body : some View {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.data(forPuzzle: puzzleTitle)){ cipherPair in
                    
                    CipherSolverCharacterPair(
                        viewModel: viewModel,
                        cipherTextLetter: cipherPair.cipherLetter,
                        plainTextLetter: cipherPair.userGuessLetter,
                        puzzleTitle: puzzleTitle)
                }
            }
        }
    }

    
    struct CipherSolverCharacterPair : View {
        
//        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @State
        private
        var letterGuess = ""
        
        @State
        private
        var wasTapped = false
        
        var cipherTextLetter : Character
        var plainTextLetter : Character?
        var puzzleTitle : String
        
                
        private var plainTextToDisplay : String {
            if let plainTextLetter = plainTextLetter{
                return String(plainTextLetter)
            } else {
                return " "
            }
        }
        
        var tapGesture : some Gesture {
            TapGesture(count: 1).onEnded{
                //flip value
                wasTapped = !wasTapped
            }
        }
        
        var body : some View {
            
            
            VStack{
                
                Text(String(cipherTextLetter))
                
                if wasTapped {
                    TextField(plainTextToDisplay,
                              text: $letterGuess,
                              onCommit: {
                                self.updateModel()
                              })
                    .multilineTextAlignment(.center)
                    .autocapitalization(.none)
                } else {
                    Text(plainTextToDisplay).gesture(tapGesture)
                }
            
            }
        }
        
        
        func showTextField() {
            
        }
        
        func updateModel(){
            guard let chosenLetter = letterGuess.first else {return}
            
            viewModel.updateUsersGuesses(cipherCharacter: cipherTextLetter,
                                         plaintextCharacter: chosenLetter,
                                         in: puzzleTitle)
            //reset temp variable
            letterGuess = ""
        }
        
        
        struct NewView : Identifiable {
            var id = UUID()
            var location : CGPoint
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
