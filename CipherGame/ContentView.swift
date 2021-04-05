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
            List{
                ForEach(viewModel.availableBooks){ bookTitle in
                    
                    Section(header: Text(bookTitle.title.capitalized).font(.system(.title))){
                        
                        ForEach(viewModel.puzzleTitles(for: bookTitle.id)){ puzzleTitle in
                            
                            NavigationLink(destination: CipherSolverPage()
                                            .navigationTitle(puzzleTitle.title),
                                           tag: puzzleTitle.id,
                                           selection: $viewModel.currentPuzzleHash){
                                Text(puzzleTitle.title)
                                
                                if puzzleTitle.isSolved{
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(Color.highlightColor(for: colorScheme))
                                }
                            }.transition(.slide)
                        }
                    }
                }
            }.listStyle(SidebarListStyle())
        }.environmentObject(viewModel)
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



