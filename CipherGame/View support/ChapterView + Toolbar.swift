//
//  CipherSolverPage + Toolbar.swift
//  CipherGame
//
//  Created by J Lambert on 19/04/2021.
//

import SwiftUI


extension ContentView.ChapterViewer {
    
    private
    func printCipherPage() {
        
        withAnimation{self.printing = true}
        
        let formatter = UIMarkupTextPrintFormatter(markupText: viewModel.printableHTML)

        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        //printInfo.jobName = viewModel.puzzleTitle

        printController.printInfo = printInfo
        printController.printFormatter = formatter
        
        printController.present(animated: true){_,_,_ in
            withAnimation{self.printing = false}
        }
    }
    
    
    @ToolbarContentBuilder
    func cipherPuzzletoolbar(_ puzzle : DisplayedCipherPuzzle) -> some ToolbarContent {
        
            ToolbarItem(placement: .navigationBarTrailing){
                Menu{
                    if !puzzle.isSolved {
                        
                        #if DEBUG
                        Button("solve!"){
                            withAnimation{
                                viewModel.solveCipher(puzzle.id)
                            }
                        }
                        #endif
                        
                        if !puzzle.isSolved{
                            Picker("difficulty", selection: $viewModel.difficultyLevel){
                                Text("easy").tag(UInt(0))
                                Text("medium").tag(UInt(1))
                                Text("hard").tag(UInt(2))
                            }
                            Button("quick hint"){
                                withAnimation{
                                    viewModel.quickHint()
                                }
                            }
                        }
                    }
                    
                    #if DEBUG
                    Button{
                        Debug.animation.toggle()
                    } label: {
                        HStack{
                            Text(Debug.animation ? "Debug animations off" : "Debug animations on")
                        }
                    }
                    #endif
                    
                    Button("reset puzzle"){
                        withAnimation{
                            resetPuzzle()
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
    
    
    @ToolbarContentBuilder
    func gridPuzzleToolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing){
                
            Menu{
                #if DEBUG
                Button{
                    Debug.animation.toggle()
                } label: {
                    HStack{
                        Text(Debug.animation ? "Debug animations off" : "Debug animations on")
                    }
                }
                #endif
                
                Button("reset puzzle"){
                    withAnimation{
                        resetPuzzle()
                    }
                }
            } label: {
                Label("settings", systemImage: "dial")
            }
        }
    }
}
