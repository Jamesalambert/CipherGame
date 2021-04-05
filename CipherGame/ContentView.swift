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
                        
                        Section(header: bookSectionLabel(for: bookTitle) ){
                            
                            if !viewModel.hiddenBookHashes.contains(bookTitle.hashValue){
                                ForEach(viewModel.puzzleTitles(for: bookTitle.id)){ puzzleTitle in

                                    NavigationLink(destination: CipherSolverPage()
                                                                .navigationTitle(puzzleTitle.title),
                                                   tag: puzzleTitle.id,
                                                   selection: $viewModel.currentPuzzleHash){
                                        
                                        if puzzleTitle.isSolved {
                                            label(for: puzzleTitle)
                                                .labelStyle(DefaultLabelStyle())
                                        } else {
                                            label(for: puzzleTitle)
                                                .labelStyle(TitleOnlyLabelStyle())
                                        }
                                    }.transition(.slide)
                                }
                            }
                        }
                    }
                }
            }.environmentObject(viewModel)
    }
    
    @ViewBuilder
    private
    func bookSectionLabel(for bookTitle : PuzzleTitle) -> some View{
        HStack{
            if viewModel.hiddenBookHashes.contains(bookTitle.hashValue){
                Button(action: {show(bookHash: bookTitle.hashValue)}){
                    Label("show", systemImage: "arrowtriangle.right.fill")
                        .labelStyle(IconOnlyLabelStyle())
                }
            } else {
                Button(action: {hide(bookHash: bookTitle.hashValue)}){
                    Label("show", systemImage: "arrowtriangle.down.fill")
                        .labelStyle(IconOnlyLabelStyle())
                }
            }
            Text(bookTitle.title).font(.system(.title))
            Spacer()
        }
    }
    
    private
    func hide(bookHash : Int){
        withAnimation{
            viewModel.hiddenBookHashes.append(bookHash)
        }
    }
    private
    func show(bookHash : Int) {
        withAnimation{
            viewModel.hiddenBookHashes.removeAll(where: {$0 == bookHash})
        }
    }
    
    private
    func label(for puzzleTitle : PuzzleTitle) -> some View {
        let label = Label(puzzleTitle.title,
                          systemImage: "checkmark.circle.fill")
            .accentColor(Color.highlightColor(for: colorScheme))
        return label
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



