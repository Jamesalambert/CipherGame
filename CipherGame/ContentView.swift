//
//  ContentView.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    var viewModel : CipherPuzzle
        
    @Environment(\.colorScheme)
    var colorScheme : ColorScheme
    
    @Environment(\.scenePhase)
    var scenePhase : ScenePhase
    
    let saveAction : () -> Void
    
    @State
    private
    var deletingLessons : Bool = false
    
    var body: some View {
        
        NavigationView{
            List{
                ForEach(viewModel.installedBooks){ book in
                    
                    Section(header: bookHeader(for: book.title),
                            footer: bookFooter(for: book.title)){
                        
                        ForEach(book.puzzles){ puzzle in
                            NavigationLink(destination: CipherSolverPage(puzzle: puzzle )
                                                            .environment(\.bookTheme, book.theme)
                                                            .navigationTitle(puzzle.title),
                                           tag: puzzle.id,
                                           selection: $viewModel.currentPuzzleHash){
                                
                                puzzleEntry(for: puzzle, in: book)
                            }
                        }
                    }
                }
            }.navigationTitle("Code Books")
            .listStyle(InsetGroupedListStyle())
            .toolbar{toolbar()}
        }.environmentObject(viewModel)
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                saveAction()
            }
        }
    }
    
    @ViewBuilder
    func bookHeader(for bookTitle : String) -> some View {
        HStack{
            Spacer()
            Text(bookTitle.capitalized).font(.system(.title))
            Spacer()
        }
    }
    
    @ViewBuilder
    func puzzleEntry(for puzzle : Puzzle, in book : Book) -> some View {
        
        Text("\(puzzle.title)")
            .lineLimit(1)
        
        if puzzle.isSolved{
            Image(systemName: "checkmark.circle")
                .foregroundColor(viewModel.theme.color(of: .completed, for: book.theme, in: colorScheme))
        }
    }
    
    @ViewBuilder
    func bookFooter(for bookTitle : String)-> some View {
        if bookTitle == "lessons" {
            HStack{
                Spacer()
                Button("hide lessons"){
                    deletingLessons = true
                }.alert(isPresented: $deletingLessons){
        
                    Alert(title: Text("Hide lessons?"),
                          message: Text("you can undo this in settings"),
                          primaryButton: .default(Text("Hide them"), action: {
                            withAnimation{
                                viewModel.showLessons = false
                            }
                          }),
                          secondaryButton: .cancel())
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func toolbar() -> some View {
        Menu{
            Toggle("Show Lessons", isOn: $viewModel.showLessons.animation())
        } label : {
            Image(systemName: "gearshape")
        }
    }
    
    
}

    

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let game = CipherPuzzle()
        Group {
            ContentView(viewModel: game, saveAction: {})
        }
    }
}



