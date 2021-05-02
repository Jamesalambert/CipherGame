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
    var store = OnlineStore.shared
        
    @Environment(\.colorScheme)
    var colorScheme : ColorScheme
    
    @Environment(\.scenePhase)
    var scenePhase : ScenePhase
    
    let saveAction : () -> Void
    
    @State
    private
    var deletingLessons : Bool = false
    
//    @State
//    private
//    var showInAppPurchases : Bool = false
    
    @State
    private
    var showLetterCount : Bool = true
    
    var body: some View {
        NavigationView{
            List{
                ForEach(viewModel.installedBooks){ book in
                    
                    Section(header: bookHeader(for: book.title),
                            footer: bookFooter(for: book.title)){
                        
                        ForEach(book.chapters){ chapter in
                            NavigationLink(destination: CipherSolverPage(showLetterCount: $showLetterCount)
                                                            .environment(\.bookTheme, book.theme)
                                                            .navigationTitle(chapter.title),
                                           tag: chapter.id,
                                           selection: $viewModel.currentChapterHash){
                                
                                puzzleEntry(for: chapter, in: book)
                            }
                        }
                    }
                }
                
                NavigationLink("More Books",
                               destination: IAPContent().onAppear{
                                store.getProducts()
                               })
                
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
    func IAPContent() -> some View {
        Text("More Mysteries to Solve!").font(.title)
        List{
            Section(footer:
                        HStack{
                            Spacer()
                            Button{
                                store.restorePurchases()
                            } label: {
                                Text("Restore previous purchases")
                                    .foregroundColor(Color.blue)
                            }
                            Spacer()
                        }
            )
            {
                ForEach(store.booksForSale) { bookForSale in
                    HStack{
                        Image("book").resizable().aspectRatio(contentMode: .fit).frame(width: 60)
                        VStack(alignment: .leading){
                            Text(bookForSale.title).font(.title)
                            Text(bookForSale.description)
                        }
                        
                        Spacer()
                        
                        Button {
                            if viewModel.availableBookNames.contains(bookForSale.id){
                                viewModel.currentChapterHash = viewModel.firstChapterHash(for: bookForSale.id)
                            } else {
                                store.buyProduct(bookForSale.id)
                            }
                        } label: {
                            Text(viewModel.availableBookNames.contains(bookForSale.id) ? "open" : bookForSale.price)
                                .padding()
                                .background(viewModel.availableBookNames.contains(bookForSale.id) ? Color.green : Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .transition(.opacity)
                                //.id(viewModel.availableBookNames.contains(bookForSale.id) ? "open" : bookForSale.price)
                                .id(bookForSale.id)
                        }
                    }
                }
            }
        }
        .onChange(of: store.finishedTransactions){_ in
            viewModel.loadPurchasedBooks()
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
                .foregroundColor(viewModel.theme.color(of: .completed, for: book.theme, in: colorScheme))
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

    

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let game = CipherPuzzle()
        let store = OnlineStore.shared
        Group {
            ContentView(viewModel: game, store: store, saveAction: {})
        }
    }
}



