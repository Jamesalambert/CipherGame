//
//  ContentView.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    //private
    var debugAnimation : Bool = false
        
    @StateObject
    var viewModel : CipherPuzzle
    
    @ObservedObject
    var store = OnlineStore.shared
        
    @Environment(\.colorScheme)
    var colorScheme : ColorScheme
    
    @Environment(\.scenePhase)
    var scenePhase : ScenePhase
    
    let saveAction : () -> Void
    
    @State
    private
    var deletingLessons : Bool = false
    
    @State
    var isShowingIAP : Bool = false
    
    @State
    var isShowingDebug : Bool = false
    
    var body: some View {
        NavigationView{
            List{
                ForEach(viewModel.installedBooks){ book in
                    
                    Section(header: bookHeader(for: book.title),
                            footer: bookFooter(for: book.title)){
                        ForEach(book.chapters){ chapter in
                            
                            NavigationLink(destination: NavigationLazyView(
                                            ChapterViewer(chapter: chapter, cipherPuzzle: viewModel.displayedCipherPuzzle)
                                                .environment(\.bookTheme, book.theme)
                                                .navigationBarTitle("\(chapter.title)", displayMode: .inline)),
                                           tag: chapter.id,
                                           selection: $viewModel.currentChapterHash){
                                TitleView(for: chapter, in: book)
                            }
                        }
                    }
                }
//                Button("More Books"){isShowingIAP = true}
                #if DEBUG
                Button("debug"){isShowingDebug = true}
                #endif
            }
            .navigationTitle("Puzzle Rooms")
            .listStyle(GroupedListStyle())
            .toolbar{toolbar()}
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                loadPurchsesFromKeychain()
                saveAction()
            }
        }
        .onChange(of: viewModel.store.finishedTransactions){_ in
            loadPurchsesFromKeychain()
        }
        .sheet(isPresented: $isShowingIAP){
            IAPMenu(isShowingIAP: $isShowingIAP)
                .environmentObject(viewModel.store)
                .onAppear(perform: viewModel.store.getAvailableProductIds)
        }
        .sheet(isPresented: $isShowingDebug){DebugView()}
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    func bookHeader(for bookTitle : String) -> some View {
        HStack{Spacer(); Text(bookTitle); Spacer()}
            .font(.system(.title))
    }
    
    @ViewBuilder
    func TitleView(for chapter : Chapter, in book : Book) -> some View {
        
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
                viewModel.store.deleteAllPurchasesFromKeychain()
            }
            Button("print Keychain"){
                print(viewModel.store.printKeychainData())
            }
            #endif
        } label : {
            Image(systemName: "gearshape")
        }
    }
    
    private
    func loadPurchsesFromKeychain(){
        viewModel.store.loadPurchasedBooksFromKeychain{ purchasedBookIds in
            withAnimation(.standardUI){
                viewModel.model.add(books: purchasedBookIds)
            }
        }
    }
    
    
}

    
#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let game = CipherPuzzle()
//        Group {
//            ContentView(viewModel: game, saveAction: {})
//        }
//    }
//}
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
