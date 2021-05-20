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
        self.printing = true
        
        let formatter = UIMarkupTextPrintFormatter(markupText: viewModel.printableHTML)

        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = viewModel.puzzleTitle

        printController.printInfo = printInfo
        printController.printFormatter = formatter
        
        printController.present(animated: true){_,_,_ in
            self.printing = false
        }
    }
    
    
    @ToolbarContentBuilder
    func toolbarView() -> some ToolbarContent {
        
            ToolbarItem(placement: .navigationBarTrailing){
                Menu{
                    if !viewModel.isSolved {
                        
                        #if DEBUG
                        Button("solve!"){
                            withAnimation{
                                while !viewModel.isSolved {
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
                        
                        if !viewModel.isSolved{
                            Button("quick hint"){
                                withAnimation{
                                    viewModel.quickHint()
                                }
                            }
                        }
                    }
                    
                    if viewModel.userGuesses.count > 0 {
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
                        Text("Capitals").tag(3)
                        Text("Lowercase").tag(0)
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
                    Label("print", systemImage: self.printing ? "printer.fill" : "printer")
                })
            }
    }
}
