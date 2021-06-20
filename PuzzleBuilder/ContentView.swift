//
//  ContentView.swift
//  PuzzleBuilder
//
//  Created by J Lambert on 18/06/2021.
//

import SwiftUI


struct ContentView: View {
    
    @StateObject var viewModel : BuilderViewModel
        
    @State private var json: String = ""
    
    var body: some View {
        
        VStack(alignment: .leading){
            Form{
                TextField("book title", text: $viewModel.book.title)
                Picker("theme", selection: $viewModel.book.theme){
                    ForEach(BookTheme.allCases, id:\.self){ theme in
                        Text(theme.rawValue)
                    }
                }
            }
            ChapterList(chapters: $viewModel.book.chapters)
                .environmentObject(viewModel)
            
            ScrollView{
                TextField("JSON", text: .constant(viewModel.JSON))
            }
        }
    }
    
    
    struct ChapterList: View {
        
        @EnvironmentObject
        var viewModel : BuilderViewModel
        
        @Binding var chapters: [ReadableChapter]
        
        var body: some View {
            
            NavigationView{
                List{
                    Section(header: Text("Chapters"), footer: button()){
                        ForEach(chapters){chapter in
                            NavigationLink(chapter.title,
                                           destination: ChapterEditor(chapter: chapter),
                                           tag: chapter.id,
                                           selection: $viewModel.selectedChapterID)
                                .contextMenu{
                                    Button("delete"){
                                        viewModel.deleteChapter(chapterID: chapter.id)
                                    }
                                }
                        }
                    }
                }
            }.navigationTitle("Chapters")
        }
        
        
        private func button() -> some View {
            Button("add chapter"){
                let newChapter = ReadableChapter(title: "Chapter \(viewModel.book.chapters.count + 1)",
                                                 puzzles: [ReadablePuzzle()])
                viewModel.book.chapters.append(newChapter)
            }
        }
    }
    
    struct ChapterEditor: View {
        
        @EnvironmentObject var viewModel: BuilderViewModel
        
        @State var chapterTitle: String = ""
        
        var chapter: ReadableChapter
        
        var body: some View {
            VStack(alignment: .leading){
                TextField("chapter title", text: $chapterTitle, onCommit: save)
                NavigationView{
                        List{
                            Section(header: Text("Puzzles"),footer: button()){
                                ForEach(chapter.puzzles){puzzle in
                                    NavigationLink(puzzle.title,
                                                   destination: PuzzleBuilder(puzzle: puzzle),
                                                   tag: puzzle.id,
                                                   selection: $viewModel.selectedPuzzleID)
                                        .contextMenu{
                                            Button("delete"){
                                                viewModel.deletePuzzle(puzzleID: puzzle.id)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .onAppear{
                        chapterTitle = chapter.title
                    }
            }
        }
        
        private
        func button() -> some View {
            Button("Add Puzzle"){
                viewModel.addPuzzle()
            }
        }
        
        private
        func save(){
            var newChapter = chapter
            newChapter.title = chapterTitle
            newChapter.id = chapter.id
            viewModel.updateChapter(newChapter: newChapter)
        }
    }
    
    struct PuzzleBuilder: View {
        
        @EnvironmentObject
        var viewModel : BuilderViewModel
        
        @State private var puzzleTitle: String = ""
        @State private var puzzleKeyAlphabet: String = ""
        @State private var puzzleHeader: String = ""
        @State private var puzzleFooter: String = ""
        @State private var puzzlePlaintext: String = ""
                
        var puzzle : ReadablePuzzle
        
        var body: some View {
            Form{
                TextField("puzzle title", text: $puzzleTitle, onCommit: save)
                TextField("key alphabet", text: $puzzleKeyAlphabet, onCommit: save)
                TextField("header", text: $puzzleHeader, onCommit: save)
                TextEditor(text: $puzzlePlaintext)
                TextField("footer", text: $puzzleFooter, onCommit: save)
            }
            .onAppear{
                puzzleTitle         = puzzle.title
                puzzleKeyAlphabet   = puzzle.keyAlphabet
                puzzleHeader        = puzzle.header
                puzzleFooter        = puzzle.footer
                puzzlePlaintext     = puzzle.plaintext
            }
        }
        
        private
        func save(){
            var newPuzzle = ReadablePuzzle()
            newPuzzle.title         = puzzleTitle
            newPuzzle.keyAlphabet   = puzzleKeyAlphabet
            newPuzzle.header        = puzzleHeader
            newPuzzle.plaintext     = puzzlePlaintext
            newPuzzle.footer        = puzzleFooter
            newPuzzle.id            = puzzle.id
            viewModel.updatePuzzle(newPuzzle: newPuzzle)
        }
    }

    struct GridPuzzleBuilder: View {
        
        @EnvironmentObject
        var viewModel : BuilderViewModel
        
        @Binding var readableGridPuzzle: ReadableGridPuzzle
        
        var body: some View{
            Picker("type", selection: $readableGridPuzzle.type){
                ForEach(GridSolution.allCases, id:\.self){ type in
                    Text(type.rawValue)
                }
            }
            Stepper("size", onIncrement: moreSquares, onDecrement: lessSquares)
            
            TextField("image", text: $readableGridPuzzle.image ?? "")
            TextField("solutionImage", text: $readableGridPuzzle.solutionImage ?? "")
        }
        
        private func moreSquares(){
            self.readableGridPuzzle.size = self.readableGridPuzzle.size + 1
        }
        
        private func lessSquares(){
            self.readableGridPuzzle.size = self.readableGridPuzzle.size - 1
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
        
    static var previews: some View {
        ContentView(viewModel: BuilderViewModel())
    }
}

//extremely handy overload of the coalescing operator ?? to allow a binding on the lhs
//using this to bind a text field to the gridpuzzles image vars.

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
