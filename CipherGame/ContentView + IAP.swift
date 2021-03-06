//
//  ContentView + IAP.swift
//  CipherGame
//
//  Created by J Lambert on 04/05/2021.
//

import SwiftUI

extension ContentView{
    
    struct IAPMenu : View {
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @EnvironmentObject
        var store : OnlineStore
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @Binding
        var isShowingIAP : Bool
        
        var body: some View{
            Spacer()
            Text("More Adventures").font(.largeTitle)
            List{
                Section(footer: restorePurchasesButton())
                {
                    ForEach(viewModel.store.booksForSale) { bookForSale in
                        HStack{
                            Image("book").resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 60)
                            VStack(alignment: .leading){
                                Text(bookForSale.title).font(.title)
                                Text(bookForSale.description)
                            }
                            Spacer(minLength: 50)
                            IAPButton(isShowingIAP: $isShowingIAP,
                                      bookForSale: bookForSale)
                        }
                    }
                }
                #if DEBUG
                Section(header: Text("debug")){
                    Text("store state: " + viewModel.store.stateDescription).foregroundColor(Color.gray)
                    Text("Downloads").font(.title)
                    ForEach(store.downloads, id:\.self){download in
                        Text("\(download.contentIdentifier) \t \(String(download.progress))")
                    }
                }
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
                        viewModel.openBook(with: bookForSale.id)
                    } else {
                        withAnimation{
                            viewModel.store.buyProduct(bookForSale.id)
                        }
                    }
                } label: {
                    VStack(alignment: .trailing){
                        HStack(spacing: 0){
                            
                            ActivityIndicator(bookForSale: bookForSale)
                            
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
            
            @EnvironmentObject
            var store : OnlineStore
            
            @State
            private var isSpinning = false
            
            let indicatorColour : Color = .white
            
            var bookForSale : ProductInfo
            var progress : Float {
                store.downloads.first(where: {$0.contentIdentifier == bookForSale.id})?.progress ?? 0
            }
            
            var isVisible : Bool {
                return store.state == StoreState.busy(bookForSale.id)
            }
            
            var body : some View {
                ZStack{
                    if isVisible {
                        Circle()
                            .trim(from: 0, to: CGFloat(0.3 + progress))
                            .stroke(lineWidth: 3)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 15, height: 15, alignment: .trailing)
                            .padding(EdgeInsets.sized(horizontally: 5, vertically: 0))
                            .rotationEffect(Angle.degrees(isSpinning ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isSpinning)
                            .onAppear{
                                self.isSpinning = true
                            }
                    }
                }
            }
        }
        
        @ViewBuilder
        func restorePurchasesButton() -> some View {
            HStack{
                Spacer()
                Button{
                    viewModel.store.restorePurchases()
                } label: {
                    Text("Restore previous purchases")
                        .foregroundColor(Color.blue)
                }
                Spacer()
            }
        }
    }
}





