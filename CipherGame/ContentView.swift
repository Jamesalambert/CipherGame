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
                ForEach(viewModel.availableBooks){ book in
                    
                    Section(header: bookHeader(for: book),
                            footer: bookFooter(for: book)){
                        
                        ForEach(viewModel.puzzleTitles(for: book.id)){ puzzle in
                            NavigationLink(destination: CipherSolverPage()
                                                            .navigationTitle(puzzle.title),
                                           tag: puzzle.id,
                                           selection: $viewModel.currentPuzzleHash){
                                
                                puzzleEntry(for: puzzle)
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
    func bookHeader(for bookTitle : PuzzleTitle) -> some View {
        HStack{
            Spacer()
            Text(bookTitle.title.capitalized).font(.system(.title))
            Spacer()
        }
    }
    
    @ViewBuilder
    func puzzleEntry(for bookTitle : PuzzleTitle) -> some View {
        
        Text("\(bookTitle.index + 1). \(bookTitle.title)").lineLimit(1)
        
        if bookTitle.isSolved{
            Image(systemName: "checkmark.circle")
                .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTitle.theme, in: colorScheme))
        }
    }
    
    @ViewBuilder
    func bookFooter(for bookTitle : PuzzleTitle)-> some View {
        if bookTitle.title == "lessons" {
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



