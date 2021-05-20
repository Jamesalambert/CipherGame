//
//  CipherSolverPage + Views.swift
//  CipherGame
//
//  Created by J Lambert on 28/04/2021.
//

import SwiftUI

extension ContentView.ChapterViewer {
    
    @ViewBuilder
    func puzzleChooser(for geometry : GeometryProxy) -> some View {
        
        VStack(spacing:0){
            ScrollView(.horizontal){
                HStack(alignment: .bottom){
                    Spacer()
                    Group{
                        ForEach(viewModel.visiblePuzzles){ puzzle in
                            cipherPuzzleChooserButton(for: puzzle)
                                .background(
                                    viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme)
                                        .opacity(puzzle.id == viewModel.currentPuzzleHash ? 0.3 : 0.1)
                                )
                        }
                        Spacer()
                        if let gridPuzzle = viewModel.currentChapterGridPuzzle {
                            gridPuzzleChooserButton(for: gridPuzzle)
                                .background(
                                    viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme)
                                        .opacity(gridPuzzle.id == viewModel.currentGridPuzzleHash ? 0.3 : 0.1)
                                )
                        }
                    }
                    .modifier(RoundSomeCorners(radius: ContentView.ChapterViewer.viewCornerRadius,
                                               corners: [.topLeft , .topRight] ))
                    .transition(.move(edge: .bottom))
                }
            }
            Rectangle()
                .fill(viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme)!)
                .frame(height: 3)
                .opacity(0.3)
        }
        .background(Blur(style: self.colorScheme == .dark ? .systemThickMaterialDark : .systemUltraThinMaterialLight))
    }
    
    @ViewBuilder
    func gridPuzzleChooserButton(for puzzle : GridPuzzle) -> some View {
        Button {
            withAnimation{
                viewModel.currentGridPuzzleHash = viewModel.currentChapterGridPuzzle?.id
            }
        } label: {
            buttonLabel(titled: "grid puzzle", isSolved: puzzle.isSolved)
        }
    }
    
    @ViewBuilder
    func cipherPuzzleChooserButton(for puzzle : Puzzle) -> some View {
        Button {
            withAnimation{
                viewModel.currentPuzzleHash = puzzle.id
            }
        } label: {
            buttonLabel(titled: puzzle.title, isSolved: puzzle.isSolved)
        }
    }
    
    @ViewBuilder
    func buttonLabel(titled title : String, isSolved : Bool) -> some View{
        HStack{
            Text(title)
                .lineLimit(1)
                .font(viewModel.theme.font(for: .subheadline, for: bookTheme))
                .foregroundColor(viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme))
            if isSolved{
                Image(systemName: "checkmark.circle")
                    .foregroundColor(viewModel.theme.color(of: .completed, for: bookTheme, in: colorScheme))
            }
        }
        .padding(EdgeInsets.sized(horizontally: 10, vertically: 15))
    }
    
    @ViewBuilder
    func riddleOptions(with geometry : GeometryProxy) -> some View {
        if viewModel.riddleAnswers.count > 1 {
            MultipleChoiceRiddle(geometry: geometry)
        }
    }
    
    struct MultipleChoiceRiddle : View {
        
        static let viewCornerRadius = CGFloat(10)
        
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
        
        var geometry : GeometryProxy
        
        @State
        private
        var typewriterString : String = ""
        
        var body: some View {
            VStack{
                Text(viewModel.riddle)
                    .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
                Spacer()
                VStack{
                    ForEach(viewModel.riddleAnswers, id:\.self){ answer in
                        Button{
                            if viewModel.userRiddleAnswers.isEmpty{
                                typewriter(completion: {
                                    withAnimation{
                                        lastUserChoice = answer
                                        viewModel.add(answer: lastUserChoice!)
                                    }
                                })
                            } else {
                                withAnimation{
                                    lastUserChoice = answer
                                    viewModel.add(answer: lastUserChoice!)
                                }
                            }
                        } label: {
                            Text(answer)
                                .foregroundColor(viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme))
                        }
                        .padding()
                        .background(viewModel.theme.color(of: .tappable,
                                                          for: bookTheme, in: colorScheme)?
                                        .opacity(lastUserChoice == answer ? 0.3 : 0.1)
                        )
                        .cornerRadius(Self.viewCornerRadius)
                    }
                }
                //typewriter text
                Text(lastUserChoice == nil ? typewriterString : message)
                    .frame(width: 0.5 * geometry.size.width, alignment: .center)
                    .foregroundColor(viewModel.theme.color(of: .gameText, for: bookTheme, in: colorScheme))
            }
            .padding()
            .background(Blur(style: viewModel.theme.blurStyle(for: bookTheme, in: colorScheme)))
            .cornerRadius(Self.viewCornerRadius)
            .font(Font.system(.body, design: .monospaced))
            .onAppear{lastUserChoice = viewModel.userRiddleAnswers.last}
        }
        
        private
        func typewriter(completion: @escaping () -> Void) {
            let serialQueue = DispatchQueue(label: "typewriter")
            for character in message {
                serialQueue.async{
                    typewriterString.append(character)
                    let delay = Double(arc4random_uniform(3)) / 10.0
                    Thread.sleep(forTimeInterval: delay)
                }
            }
            serialQueue.async {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    

    
}
