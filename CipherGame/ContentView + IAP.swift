//
//  ContentView + IAP.swift
//  CipherGame
//
//  Created by J Lambert on 04/05/2021.
//

import SwiftUI

extension ContentView{
    
    @ViewBuilder
    func IAPContent() -> some View {
        Spacer()
        Text("More Adventures").font(.largeTitle)
        List{
            Section(footer: restorePurchasesButton())
            {
                ForEach(store.booksForSale) { bookForSale in
                    HStack{
                        Image("book").resizable().aspectRatio(contentMode: .fit).frame(width: 60)
                        VStack(alignment: .leading){
                            HStack{
                                Text(bookForSale.title).font(.title)
                                Spacer()
                                IAPButton(isShowingIAP: $isShowingIAP, bookForSale: bookForSale)
                            }
                            Text(bookForSale.description)
                        }
                        Spacer(minLength: 50)
                    }
                }
            }
            #if DEBUG
            Text(store.stateDescription).foregroundColor(Color.gray)
            #endif
        }
    }
    
    
    struct IAPButton : View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @EnvironmentObject
        var store : OnlineStore
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Binding
        var isShowingIAP : Bool
        
        var bookForSale : ProductInfo
        
        var body: some View{
            
            Button {
                if viewModel.installedBookIDs.contains(bookForSale.id){
                    isShowingIAP = false
                    viewModel.currentChapterHash = viewModel.firstChapterHash(for: bookForSale.id)
                } else {
                    store.buyProduct(bookForSale.id)
                }
            } label: {
                    HStack{
                        if store.state == StoreState.busy(bookForSale.id) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(EdgeInsets.sized(leading: 10))
                                .transition(.move(edge: .trailing))
                        }
                        Text(viewModel.installedBookIDs.contains(bookForSale.id) ? "open" : bookForSale.price)
                            .padding(EdgeInsets.sized(horizontally: 10, vertically: 5))
                    }
                    .background(viewModel.theme.color(of: viewModel.installedBookIDs.contains(bookForSale.id) ? .openButton : .buyButton, for: .defaultTheme, in: colorScheme))
                    .brightness(colorScheme == .light ? 0.30 : 0.0)
                    .foregroundColor(Color.white)
                    .font(Font.body.weight(.bold))
                    .cornerRadius(5)
//                            .transition(.opacity)
            }
        }
    }
    
    
    @ViewBuilder
    func restorePurchasesButton() -> some View {
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
    }
    
    
}
