//
//  CipherSolverPage + Toolbar.swift
//  CipherGame
//
//  Created by J Lambert on 19/04/2021.
//

import SwiftUI


extension ContentView.CipherSolverPage {
    
    private
    func printCipherPage() {
        let formatter = UIMarkupTextPrintFormatter(markupText: viewModel.printableHTML)
        
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = viewModel.currentPuzzle.title
        
        printController.printInfo = printInfo
        printController.printFormatter = formatter
        
        printController.present(animated: true)
    }
    
    
    @ToolbarContentBuilder
    func toolbarView() -> some ToolbarContent {
        
            ToolbarItem(placement: .navigationBarTrailing){
                Menu{
                    if !viewModel.currentPuzzle.isSolved {
                        
                        #if DEBUG
                        Button("solve!"){
                            while !viewModel.currentPuzzle.isSolved {
                                withAnimation{
                                    viewModel.quickHint()
                                }
                            }
                        }
                        #endif
                        
                        Picker("difficulty", selection: $viewModel.difficultyLevel){
                            Text("easy").tag(UInt(0))
                            Text("medium").tag(UInt(1))
                            Text("hard").tag(UInt(2))
                        }
                        
                        if !viewModel.currentPuzzle.isSolved{
                            Button("quick hint"){
                                withAnimation{
                                    viewModel.quickHint()
                                }
                            }
                        }
                    }
                    
                    if viewModel.currentPuzzle.usersGuesses.count > 0 {
                        Button("reset puzzle"){
                            withAnimation{
                                resetPuzzle()
                            }
                        }
                    }
                } label: {
                    Label("difficulty", systemImage: "dial")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                Menu{
                    Picker("text display", selection: $viewModel.capType){
                        Text("CAPITALS").tag(3)
                        Text("lowercase").tag(0)
                    }
                    
//                        Picker("font style", selection: $viewModel.fontDesign){
//                            Text("typewriter").tag(Font.Design.monospaced)
//                            Text("rounded").tag(Font.Design.rounded)
//                            Text("serif").tag(Font.Design.serif)
//                        }
                } label: {
                    Label("text", systemImage: "textformat")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: printCipherPage, label: {
                    Label("print", systemImage: "printer")
                })
            }
    }
}
