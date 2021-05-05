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
                            Text(bookForSale.title).font(.title)
                            Text(bookForSale.description)
                        }
                        Spacer(minLength: 50)
                        IAPButton(isShowingIAP: $isShowingIAP, bookForSale: bookForSale)
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
                    withAnimation{
                        store.buyProduct(bookForSale.id)
                    }
                }
            } label: {
                    VStack(alignment: .trailing){
                        HStack{
                            ActivityIndicator(isActive: store.state == StoreState.busy(bookForSale.id))
                                .frame(width: 20 ,
                                       height: 20,
                                       alignment: .center)
                                .padding(EdgeInsets.sized(horizontally: 5, vertically: 2))
                                .opacity(store.state == StoreState.busy(bookForSale.id) ? 1 : 0)

                            Text(viewModel.installedBookIDs.contains(bookForSale.id) ? "open" : bookForSale.price)
                                .padding(EdgeInsets.sized(horizontally: 10, vertically: 5))
                        }
                        .background(viewModel.theme.color(of: viewModel.installedBookIDs.contains(bookForSale.id) ? .openButton : .buyButton, for: .defaultTheme, in: colorScheme))
                        .brightness(colorScheme == .light ? 0.30 : 0.0)
                        .foregroundColor(Color.white)
                        .font(Font.body.weight(.bold))
                        .cornerRadius(5)
                    }
            }
        }
    }
    
    struct ActivityIndicator : View {
        var indicatorColour : Color = .white
        var isActive : Bool
        var body : some View {
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(lineWidth: 5)
                    .rotationEffect(Angle.degrees(isActive ? 360 : 0))
                    .animation(isActive ? .linear(duration: 1).repeatForever(autoreverses: false) : .default)
                    .aspectRatio(1, contentMode: .fit)
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
