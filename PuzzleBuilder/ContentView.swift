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
                    Section(header: header()){
                        ForEach(chapters){chapter in
                            NavigationLink(chapter.title,
                                           destination: ChapterEditor(chapter: .constant(chapter)),
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
        
        
        private func header() -> some View {
            HStack{
                Text("chapters")
                Button{
                    let newChapter = ReadableChapter(title: "Chapter \(viewModel.book.chapters.count + 1)")
                    viewModel.book.chapters.append(newChapter)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    struct ChapterEditor: View {
        
        @EnvironmentObject var viewModel: BuilderViewModel
        
        @State var chapterTitle: String = ""
        
        @Binding var chapter: ReadableChapter
        
        var body: some View {
            VStack(alignment: .leading){
                TextField("chapter title", text: $chapterTitle, onCommit: save)
                NavigationView{
                        List{
                            Section(header: header()){
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
                            if let gridPuzzle = chapter.gridPuzzle {
                                Section(header: Text("grid puzzles")){
                                    NavigationLink("puzzle",
                                                   destination: GridPuzzleBuilder(readableGridPuzzle: .constant(gridPuzzle)),
                                                   tag: gridPuzzle.id,
                                                   selection: $viewModel.selectedGridPuzzleID)
                                        .contextMenu{
                                            Button("delete"){
                                                viewModel.deleteGridPuzzle(puzzleID : gridPuzzle.id)
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
        
        private func header() -> some View {
            HStack{
                Text("cipher puzzles")
                Button{
                    viewModel.addPuzzle()
                } label: {
                    Image(systemName: "plus")
                }
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
                TextField("key alphabet", text: $puzzleKeyAlphabet, onCommit: save )
                    .foregroundColor(check() ? .blue : .black)
                TextField("header", text: $puzzleHeader, onCommit: save)
                TextEditor(text: $puzzlePlaintext)
                    .onChange(of: puzzlePlaintext, perform: {_ in save()})
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
            var newPuzzle = puzzle
            newPuzzle.title         = puzzleTitle
            newPuzzle.keyAlphabet   = puzzleKeyAlphabet
            newPuzzle.header        = puzzleHeader
            newPuzzle.plaintext     = puzzlePlaintext
            newPuzzle.footer        = puzzleFooter
            viewModel.updatePuzzle(newPuzzle: newPuzzle)
        }
        
        private func check() -> Bool{
            let counts = String.alphabet.map{character in puzzleKeyAlphabet.number(of: character)}
            let verdict = counts.count == 26 && counts.allSatisfy({$0 == 1})
            return verdict
        }
    }

    
    
    struct GridPuzzleBuilder: View {
        
        @EnvironmentObject var viewModel: BuilderViewModel
        
        @Binding var readableGridPuzzle: ReadableGridPuzzle
        
        @State private var size: Int = 3
        @State private var type: GridSolution = .all
        @State private var solutionImage: String = ""
        @State private var image: String = ""
        
        var body: some View{
            VStack{
                HStack{
                    Picker("type", selection: $type){
                        ForEach(GridSolution.allCases, id:\.self){ type in
                            Text(type.rawValue)
                                .fixedSize()
                        }
                    }
                    Stepper("size", onIncrement: moreSquares, onDecrement: lessSquares)
                    Text(String(size))
                }
                TextField("image", text: $image)
                TextField("solutionImage", text: $solutionImage)
                    .onAppear{
                        self.type = readableGridPuzzle.type
                        self.size = readableGridPuzzle.size
                        self.solutionImage = readableGridPuzzle.solutionImage ?? ""
                        self.image = readableGridPuzzle.image ?? ""
                    }
            }
            .onChange(of: size, perform: {_ in save()})
            .onChange(of: type, perform: {_ in save()})
            .onChange(of: image, perform: {_ in save()})
            .onChange(of: solutionImage, perform: {_ in save()})
        }
        
        private func moreSquares(){
            if size < 6 {
                size = size + 1
            }
        }
        
        private func lessSquares(){
            if size > 0 {
                size = size - 1
            }
        }
        
        private func save(){
            var newGrid = self.readableGridPuzzle
            newGrid.type = type
            newGrid.size = size
            newGrid.image = image
            newGrid.solutionImage = solutionImage
            viewModel.updateGridPuzzle(newGrid: newGrid )
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
