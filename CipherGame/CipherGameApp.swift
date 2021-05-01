//
//  CipherGameApp.swift
//  CipherGame
//
//  Created by J Lambert on 16/03/2021.
//

import SwiftUI

@main
struct CipherGameApp: App {
    
    @ObservedObject
    private var viewModel = CipherPuzzle()
    
    @ObservedObject
    private var store = OnlineStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel,
                        store: store){
                //this is the saveAction being inited by a trailing closure
                viewModel.save()
            }
            .onAppear{
                viewModel.load()
            }
        }
    }
}
