//
//  DebugView.swift
//  CipherGame
//
//  Created by J Lambert on 28/05/2021.
//

import SwiftUI

extension ContentView {
    
    
    struct DebugView: View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        var body: some View {
        
            List{
                
                Section(header: Text("bookIDs in model").font(.title)){
                    ForEach(viewModel.model.activeBookIds, id:\.self){ bookID in
                        Text(bookID)
                    }
                }
                
                
                Section(header: Text("keychain").font(.title)){
                    Text(OnlineStore.shared.printKeychainData())
                    Button("clear keychain"){
                        OnlineStore.shared.deleteAllPurchasesFromKeychain()
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
    }
}


