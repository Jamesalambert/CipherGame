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
    
    var body: some Scene {
        WindowGroup {
            
            ContentView(viewModel: viewModel){
                //this is the save action being inited by a trailing closure
                viewModel.save()
            }
            .onAppear{
                viewModel.load()        //saved state
            }
        }
    }
}
