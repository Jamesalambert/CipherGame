//
//  PuzzleBuilderApp.swift
//  PuzzleBuilder
//
//  Created by J Lambert on 18/06/2021.
//

import SwiftUI

@main
struct PuzzleBuilderApp: App {
    
    @ObservedObject private var viewModel = BuilderViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel){
                viewModel.save()
            }
            .onAppear{
                viewModel.load()
            }
        }
    }
}
