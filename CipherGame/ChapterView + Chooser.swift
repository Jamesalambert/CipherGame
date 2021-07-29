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
                        ForEach(viewModel.visiblePuzzles, id:\.id){ puzzle in
                            puzzleChooserButton(for: puzzle)
                                .background(
                                    viewModel.theme.color(of: .tappable, for: bookTheme, in: colorScheme)
                                        .opacity(puzzle.id == viewModel.currentPuzzleHash ? 0.3 : 0.1)
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
    func puzzleChooserButton(for puzzle : GameStage) -> some View {
        Button {
            withAnimation{
                viewModel.choosePuzzle(id: puzzle.id)
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
}
