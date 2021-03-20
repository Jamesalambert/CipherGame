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
    
    func columns(screenWidth : CGFloat) -> [GridItem] {
        return Array(repeating: GridItem(.fixed(20)),
                     count: Int(screenWidth / 40))
    }
    
    
    var body: some View {
        
        NavigationView {

            List(viewModel.availablePuzzles) { puzzleTitle in
                
                NavigationLink(puzzleTitle.title,
                               destination: GeometryReader{ geometry in
                                    ScrollView {
                                        CipherSolverPage(columns: columns(screenWidth: geometry.size.width))
                                    }
                },
                tag: puzzleTitle.title,
                selection: $viewModel.currentPuzzle).onTapGesture {
                    viewModel.currentPuzzle = puzzleTitle.title
                }
            }
        }.environmentObject(viewModel)
    }
    
    struct CipherSolverPage : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        var columns : [GridItem]
        
        var body : some View {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.data){ cipherPair in
                    
                    CipherSolverCharacterPair(
                        cipherTextLetter: cipherPair.cipherLetter,
                        plainTextLetter: cipherPair.userGuessLetter)
                }
            }
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
                
                if wasTapped {
                    
                    NewTextField(letterGuess: $viewModel.userGuess,
                                 ciphertextLetter: cipherTextLetter,
                                 puzzleTitle: $viewModel.currentPuzzle,
                                 wasTapped: $wasTapped)
                    
//                    TextField(plainTextToDisplay,
//                              text: $letterGuess,
//                              onCommit: {
//                                self.updateModel()
//                              })
//                    .multilineTextAlignment(.center)
//                    .autocapitalization(.none)
                } else {
                    Text(plainTextToDisplay)
                        .gesture(tapGesture)
                }
            
            }
            .padding(.bottom)
            .font(.system(.title))
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
