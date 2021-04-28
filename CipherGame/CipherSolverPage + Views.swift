//
//  CipherSolverPage + Views.swift
//  CipherGame
//
//  Created by J Lambert on 28/04/2021.
//

import SwiftUI

extension ContentView.CipherSolverPage {
    
    @ViewBuilder
    func puzzleChooser(for geometry : GeometryProxy) -> some View {
        ScrollView(.horizontal){
            HStack(alignment: .bottom){
                Spacer()
                ForEach(viewModel.visiblePuzzles){ puzzle in
                    Button {
                        withAnimation{
                            viewModel.currentPuzzleHash = puzzle.id
                            viewModel.currentCiphertextCharacter = nil
                        }
                    } label: {
                        Text(puzzle.title)
                            .lineLimit(1)
                            .font(viewModel.theme.font(for: .subheadline, for: bookTheme))
                            .foregroundColor(viewModel.theme.color(of: .puzzleLines,
                                                for: bookTheme, in: colorScheme))
                    }
                    .padding()
                    .background(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme)?
                                    .opacity( puzzle == viewModel.currentPuzzle ? 0.3 : 0.1))
                    .cornerRadius(10)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func riddleOptions() -> some View {
            if viewModel.currentPuzzle.riddleAnswers.count > 1 {
                MultipleChoiceRiddle()
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme)))
            }
    }
    
    
    struct MultipleChoiceRiddle : View {
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        @Environment(\.bookTheme)
        var bookTheme : BookTheme
        
        @Environment(\.colorScheme)
        var colorScheme : ColorScheme
        
        @State
        private
        var lastUserChoice : String?
        
        var message : String = "Now you have a new puzzle to solve"
        
        @State
        private
        var displayedString : String = ""
        
        var body: some View {
            VStack{
                Text(viewModel.currentPuzzle.riddle.capitalized)
                    .font(viewModel.theme.font(for: .body, for: bookTheme))
                    .foregroundColor(viewModel.theme.color(of: .highlight, for: bookTheme, in: colorScheme))
                Spacer()
                HStack{
                    ForEach(viewModel.currentPuzzle.riddleAnswers, id:\.self){ answer in
                        Button{
                            withAnimation{
                                lastUserChoice = answer
                                viewModel.add(answer: lastUserChoice!)
                            }
                        } label: {
                            Text(answer)
                        }.padding()
                        .background(viewModel.theme.color(of: .puzzleLines, for: bookTheme, in: colorScheme)?
                                        .opacity( viewModel.currentChapter.userRiddleAnswers.last == answer ? 0.3 : 0))
                        .cornerRadius(10)
                    }
                }
                .font(viewModel.theme.font(for: .title, for: bookTheme))
                
                //animated text
                if lastUserChoice != nil {
                    Text(displayedString)
                        .fixedSize()
                        .font(viewModel.theme.font(for: .body, for: bookTheme))
                        .onAppear{typewriter()}
                }
            }
        }
        
        private
        func typewriter() {
            let serialQueue = DispatchQueue(label: "typewriter")
            for character in message {
                serialQueue.async{
                    displayedString.append(character)
                    let delay = Double(arc4random_uniform(4)) / 10.0
                    Thread.sleep(forTimeInterval: delay)
                }
            }
        }
    }
}
