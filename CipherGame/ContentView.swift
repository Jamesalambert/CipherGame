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
    
    @StateObject
    var store : OnlineStore = OnlineStore.shared
        
    @Environment(\.colorScheme)
    var colorScheme : ColorScheme
    
    @Environment(\.scenePhase)
    var scenePhase : ScenePhase
    
    let saveAction : () -> Void
    
    @State
    private
    var deletingLessons : Bool = false
    
    @State
    private
    var showLetterCount : Bool = true
    
    @State
    var isShowingIAP : Bool = false
    
    var body: some View {
        NavigationView{
            List{
                ForEach(viewModel.installedBooks){ book in
                    
                    Section(header: bookHeader(for: book.title),
                            footer: bookFooter(for: book.title)){
                        
                        ForEach(book.chapters){ chapter in
                            NavigationLink(destination: NavigationLazyView(
                                            CipherSolverPage(puzzleLines: viewModel.puzzleLines(charsPerLine: 25),                                                          showLetterCount: $showLetterCount)
                                                                            .environment(\.bookTheme, book.theme)
                                                                            .navigationBarTitle("\(chapter.title)", displayMode: .inline))
                                           ,
                                           tag: chapter.id,
                                           selection: $viewModel.currentChapterHash){
                                puzzleEntry(for: chapter, in: book)
                            }
                        }
                    }
                }
                Button("More Books"){
                    isShowingIAP = true
                }
            }.navigationTitle("Puzzle Rooms")
            .listStyle(GroupedListStyle())
            .toolbar{toolbar()}
        }
        .environmentObject(viewModel)
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {saveAction()}
        }
        .onChange(of: store.finishedTransactions){_ in
            viewModel.loadPurchasedBooksFromKeychain()
        }
        .sheet(isPresented: $isShowingIAP){
            IAPContent()
                .environmentObject(viewModel)
                .environmentObject(store)
                .onAppear(perform: store.getAvailableProductIds)
        }
    }
    
    @ViewBuilder
    func bookHeader(for bookTitle : String) -> some View {
        HStack{Spacer(); Text(bookTitle); Spacer()}
            .font(.system(.title))
    }
    
    @ViewBuilder
    func puzzleEntry(for chapter : Chapter, in book : Book) -> some View {
        
        Text("\(chapter.title)")
            .lineLimit(1)
        
        if chapter.isCompleted{
            Image(systemName: "checkmark.circle")
                .foregroundColor(colorScheme == .light ? .orange : .green)
        }
    }
    
    @ViewBuilder
    func bookFooter(for bookTitle : String)-> some View {
        if bookTitle == "Lessons" {
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
            #if DEBUG
            Button("clear Keychain"){
                viewModel.deleteAllPurchasesFromKeychain()
            }
            Button("print Keychain"){
                print(viewModel.getpurchasesFromKeychain())
            }
            #endif
        } label : {
            Image(systemName: "gearshape")
        }
    }
}

    
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = CipherPuzzle()
        let store = OnlineStore.shared
        Group {
            ContentView(viewModel: game, store: store, saveAction: {})
        }
    }
}
#endif



struct NavigationLazyView<Content : View> : View {
    let build : () -> Content
    init(_ build: @autoclosure @escaping () -> Content){
        self.build = build
    }
    
    var body : Content{
        build()
    }
}
