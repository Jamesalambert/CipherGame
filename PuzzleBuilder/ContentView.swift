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
    
    @Environment(\.scenePhase)
    var scenePhase : ScenePhase
    
    var body: some View {
        
        let JSONBinding = Binding(get: {viewModel.JSON},
                                  set: {
                                    let data = Data($0.utf8)
                                    do {
                                        let book = try JSONDecoder().decode(ReadableBook.self, from: data)
                                        viewModel.book = book
                                    } catch {
                                        print("couldn't encode as a book!")
                                    }
                                  })
        
        
        VStack(alignment: .leading){
            TextField("book title", text: $viewModel.book.title)
            Picker("theme", selection: $viewModel.book.theme){
                ForEach(BookTheme.allCases, id:\.self){ theme in
                    Text(theme.rawValue)
                }
            }
            ChapterList(chapters: $viewModel.book.chapters)
                .environmentObject(viewModel)
            
            ScrollView{
                TextField("JSON", text: JSONBinding)
            }
        }
        .padding()
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
            }
        }
        
        @ViewBuilder
        func header() -> some View {
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
                                               destination: PuzzleBuilder(puzzle: puzzle, chapter: chapter),
                                               tag: puzzle.id,
                                               selection: $viewModel.selectedPuzzleID)
                                    .contextMenu{
                                        Button("delete"){
                                            delete(puzzleID: puzzle.id)
                                        }
                                    }
                            }
                        }
                        if let gridPuzzle = chapter.gridPuzzle {
                            Section(header: Text("grid puzzles")){
                                NavigationLink(gridPuzzle.title,
                                               destination: GridPuzzleBuilder(readableGridPuzzle: .constant(gridPuzzle), chapter: chapter),
                                               tag: gridPuzzle.id,
                                               selection: $viewModel.selectedGridPuzzleID)
                                    .contextMenu{
                                        Button("delete"){
                                            delete(gridPuzzleID: gridPuzzle.id)
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
        
        @ViewBuilder
        func header() -> some View {
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
        func delete(puzzleID : UUID){
            viewModel.deletePuzzle(puzzleID : puzzleID)
        }
        
        private
        func delete(gridPuzzleID : UUID){
            viewModel.deleteGridPuzzle(puzzleID : gridPuzzleID)
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
        @State private var puzzleDependencies: [UUID] = []
        
        var puzzle : ReadablePuzzle
        var chapter: ReadableChapter
        
        var body: some View {
            Form{
                TextField("puzzle title", text: $puzzleTitle)
                HStack{
                    TextField("key alphabet", text: $puzzleKeyAlphabet)
                        .foregroundColor(check() ? .blue : .black)
                    if puzzleKeyAlphabet.count == 0 {
                        Button("new"){
                            puzzleKeyAlphabet = viewModel.shuffledAlphabet
                        }
                    }
                }
                
                TextField("header", text: $puzzleHeader)
                TextEditor(text: $puzzlePlaintext)
                if puzzlePlaintext.count > 20 {
                    HStack{Text("most common letters: "); LetterCount(plaintext: $puzzlePlaintext)}
                        .transition(.scale)
                }
                TextField("footer", text: $puzzleFooter)
                
                DependencyPicker(dependencies: $puzzleDependencies, chapter: chapter)
            }
            .padding()
            .onChange(of: puzzleTitle,       perform: {_ in save()})
            .onChange(of: puzzleKeyAlphabet, perform: {_ in save()})
            .onChange(of: puzzleHeader,      perform: {_ in save()})
            .onChange(of: puzzlePlaintext,   perform: {_ in save()})
            .onChange(of: puzzleFooter,      perform: {_ in save()})
            .onChange(of: puzzleDependencies, perform: {_ in save()})
            .onAppear{
                puzzleTitle         = puzzle.title
                puzzleKeyAlphabet   = puzzle.keyAlphabet
                puzzleHeader        = puzzle.header
                puzzleFooter        = puzzle.footer
                puzzlePlaintext     = puzzle.plaintext
                puzzleDependencies  = puzzle.dependencies
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
            newPuzzle.dependencies  = puzzleDependencies
            viewModel.updatePuzzle(newPuzzle: newPuzzle)
        }
        
        private func check() -> Bool{
            let counts = String.alphabet.map{character in puzzleKeyAlphabet.number(of: character)}
            let verdict = counts.count == 26 && counts.allSatisfy({$0 == 1})
            return verdict
        }
    }

    struct LetterCount : View {
        
        @Binding var plaintext: String
        
        var body : some View {
            Text(mostCommonLetters)
        }
        
        var mostCommonLetters : String{
            let counts: [(char : Character, count : Int)] = String.alphabet.map{character in
                (character, plaintext.number(of: character))
            }
            
            let sortedCounts = counts.sorted(by:
                {($0.count > $1.count) || (($0.count == $1.count) && ($0.char < $1.char))})
            
            return String(sortedCounts.filter({$0.count > 0}).map{$0.char})
        }
    }
    
    
    struct GridPuzzleBuilder: View {
        
        @EnvironmentObject var viewModel: BuilderViewModel
        
        @Binding var readableGridPuzzle: ReadableGridPuzzle
        
        @State private var title: String = ""
        @State private var size: Int = 3
        @State private var type: GridSolution = .all
        @State private var solutionImage: String = ""
        @State private var image: String = ""
        @State private var dependencies: [UUID] = []
        
        var chapter: ReadableChapter
        
        var body: some View{
            VStack(alignment: .leading){
                TextField("title", text: $title)
                Picker("type", selection: $type){
                    ForEach(GridSolution.allCases, id:\.self){ type in
                        Text(type.rawValue)
                            .fixedSize()
                            .frame(width: 50)
                    }
                }
                HStack{
                    Stepper("size", onIncrement: moreSquares, onDecrement: lessSquares)
                    Text(String(size))
                }
                TextField("image", text: $image)
                TextField("solutionImage", text: $solutionImage)
                DependencyPicker(dependencies: $dependencies, chapter: chapter)
            }
            .padding()
            .onChange(of: title, perform: {_ in save()})
            .onChange(of: size, perform: {_ in save()})
            .onChange(of: type, perform: {_ in save()})
            .onChange(of: image, perform: {_ in save()})
            .onChange(of: solutionImage, perform: {_ in save()})
            .onChange(of: dependencies, perform: {_ in save()})
            .onAppear{
                self.title          = readableGridPuzzle.title
                self.type           = readableGridPuzzle.type
                self.size           = readableGridPuzzle.size
                self.solutionImage  = readableGridPuzzle.solutionImage ?? ""
                self.image          = readableGridPuzzle.image ?? ""
                self.dependencies   = readableGridPuzzle.dependencies
            }
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
            newGrid.title = title
            newGrid.type = type
            newGrid.size = size
            newGrid.image = image
            newGrid.solutionImage = solutionImage
            newGrid.dependencies = dependencies
            viewModel.updateGridPuzzle(newGrid: newGrid)
        }
    }
    
    
    struct DependencyPicker : View {
        
        @EnvironmentObject
        var viewModel : BuilderViewModel
    
        @Binding var dependencies: [UUID]

        var chapter : ReadableChapter

        var puzzleData: [GameStage]{
            var output: [GameStage] = []
            
            output += chapter.puzzles
            
            if let gridPuzzle = chapter.gridPuzzle {
                output.append(gridPuzzle)
            }
            
            output.removeAll(where: {$0.id == viewModel.selectedGridPuzzleID || $0.id == viewModel.selectedPuzzleID})
            
            return output
        }

        var body: some View {
            Text("dependencies")
            List(puzzleData, id:\.id){ puzzle in
                Label(puzzle.title, systemImage: dependencies.contains(puzzle.id) ? "checkmark.circle.fill" : "circle")
                    .onTapGesture{toggle(dependency: puzzle.id)}
            }
        }
        
        
        private func toggle(dependency : UUID){
            if dependencies.contains(dependency){
                dependencies.removeAll(where: {$0 == dependency})
            } else {
                dependencies.append(dependency)
            }
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = BuilderViewModel()
        ContentView(viewModel: vm )
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
