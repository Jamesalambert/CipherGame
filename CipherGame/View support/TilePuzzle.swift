//
//  TilePuzzle.swift
//  CipherGame
//
//  Created by J Lambert on 07/05/2021.
//

import SwiftUI
import UIKit

struct TilePuzzle: View {
    
    static let tileColors : [Color] = [Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)),Color(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)),Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)),Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)),Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))]
    static let tileCornerRadius = CGFloat(15)
    
    @EnvironmentObject
    var viewModel : CipherPuzzle
    
    @Environment(\.colorScheme)
    var colorScheme : ColorScheme
    
    @Environment(\.bookTheme)
    var bookTheme : BookTheme
    
    @Namespace
    private
    var namespace
    
    var puzzleImageName : String?
    
    var solvedPuzzleImageName : String?
    
    var screenSize : CGSize
    
    var tileWidth : CGFloat {
        0.8 * min(screenSize.height, screenSize.width) / CGFloat(grid.size)
    }
    
    var grid : GridPuzzle
    
    @State
    private
    var selectedTile : Tile?
    
    var body: some View {
        ZStack{
            if !grid.isSolved{
                tilePuzzleBackground()
                    .opacity(0.3)
                    .transition(.scale)
            }
            
            LazyVGrid(columns: self.columns(), spacing: 0){
                ForEach(grid.rows.flatMap{$0.tiles}){ tile in
                    if tile.id != selectedTile?.id{
                        TileView(tile: tile,
                                 grid: grid,
                                 imageName: puzzleImageName,
                                 solvedPuzzleImageName: solvedPuzzleImageName)
                            .matchedGeometryEffect(id: tile, in: namespace)
                            .onTapGesture {
                                withAnimation{
                                    if grid.isSolved && tile.content == 1 {
                                        selectedTile = tile
                                    } else {
                                        viewModel.gridTap(tile)
                                    }
                                }
                            }
                    } else {
                        ZStack{}
                    }
                }
            }
            
            if let selectedTile = selectedTile, let solvedPuzzleImageName = solvedPuzzleImageName {
                solvedPuzzleImage(for: solvedPuzzleImageName, matchedWith: selectedTile)
                    .transition(.snap)
                    .onTapGesture {
                        withAnimation{
                            self.selectedTile = nil
                        }
                    }
                    .zIndex(4)
            }
        }
    }
    
    @ViewBuilder
    func solvedPuzzleImage(for solvedPuzzleImageName : String, matchedWith tile : Tile) -> some View {
        Image(solvedPuzzleImageName)
            .resizable()
            .aspectRatio(1,contentMode: .fit)
            .matchedGeometryEffect(id: tile, in: self.namespace)
            .cornerRadius(TilePuzzle.tileCornerRadius)
            .frame(width: self.tileWidth * CGFloat(grid.size), height: self.tileWidth * CGFloat(grid.size))
    }
    
    @ViewBuilder
    func tilePuzzleBackground() -> some View {
        Group{
            switch grid.solutionType{
            case .rows:
                VStack(spacing:0){
                    puzzleColours
                }
            case .columns:
                HStack(spacing:0){
                    puzzleColours
                }
            case .all:
                ZStack{}
            }
        }
        .frame(width: (grid.solutionType == .rows ? 1.2 : 1.0) * tileWidth * CGFloat(grid.size),
               height: (grid.solutionType == .columns ? 1.2 : 1.0) * tileWidth * CGFloat(grid.size))
    }
    
    private
    var puzzleColours : some View {
        ForEach(0..<grid.size){ index in
            Self.tileColors[index]
        }
    }
    
    
    func columns()->[GridItem]{
        return Array(repeating: GridItem(.fixed(CGFloat(self.tileWidth)),
                                         spacing: CGFloat(0),
                                         alignment: .center),
                     count: grid.size)
    }

    
    

    struct TileView : View {
        
        var tile : Tile
        var isFaceUp : Bool
        var grid : GridPuzzle
        var puzzleImageName : String?
        var solvedPuzzleImageName : String?
        
        init(tile : Tile, grid : GridPuzzle, imageName : String?, solvedPuzzleImageName : String?){
            self.tile = tile
            self.grid = grid
            self.puzzleImageName = imageName
            self.solvedPuzzleImageName = solvedPuzzleImageName
            self.isFaceUp = true
            
            if grid.isSolved || (tile.isEnabled && tile.content == 0){
                self.isFaceUp = true      //image
            } else if tile.content == 1 && !grid.isSolved{
                self.isFaceUp = false      //blank
            } else if tile.content == 0 && !grid.isSolved && !tile.isEnabled{
                self.isFaceUp = false     //mystery
            }
        }
        
        var body: some View{
                if isFaceUp || tile.canBeEnabled {
                    tileWithImage()
                } else if tile.content == 0 {
                    mysteryTile()
                } else {
                    ZStack{}
                }
        }

        @ViewBuilder
        func tileWithImage() -> some View {
            if tile.canBeEnabled{
                ZStack{
                    Color.white.opacity(0.4)
                        .cornerRadius(TilePuzzle.tileCornerRadius)
                    Image(systemName: "hand.tap")
                        .resizable(capInsets: EdgeInsets.zero(), resizingMode: .stretch)
                        .aspectRatio(1,contentMode: .fill)
                        
                }
                .overlay(RoundedRectangle(cornerRadius: TilePuzzle.tileCornerRadius).stroke(Color.black, lineWidth: 2)  )
            } else if tile.content == 1 {
              //solved image tile
                    ZStack{
                        if let prizeImageName = self.solvedPuzzleImageName {
                            Image(prizeImageName)
                                .resizable(capInsets: EdgeInsets.zero(), resizingMode: .stretch)
                                .aspectRatio(1,contentMode: .fit)
                                .cornerRadius(TilePuzzle.tileCornerRadius)
                        }
                    }
            } else {
                switch grid.solutionType{
                case .rows, .columns:
                    RadialGradient(gradient: Gradient(
                                    colors: [tileColors[tile.index[grid.solutionType == .rows ? 0 : 1]],.white]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 900)
                        .opacity(0.7)
                        .aspectRatio(1, contentMode: .fill)
                        .cornerRadius(TilePuzzle.tileCornerRadius)
                        .transition(.flip)
                case .all:
                    Image(uiImage: (UIImage(named: puzzleImageName!)?.rect(row: tile.index[0], col: tile.index[1], size: grid.size))!)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(TilePuzzle.tileCornerRadius)
                    .transition(.flip)
                }
            }
        }

        @ViewBuilder
        func mysteryTile() -> some View {
            ZStack{
                Color.white.opacity(0.4)
                    .cornerRadius(TilePuzzle.tileCornerRadius)
                Image(systemName: "questionmark.circle")
                    .resizable(capInsets: EdgeInsets.zero(), resizingMode: .stretch)
                    .aspectRatio(1,contentMode: .fit)
                    .padding()
            }
            .overlay(RoundedRectangle(cornerRadius: TilePuzzle.tileCornerRadius).stroke(Color.black, lineWidth: 2)  )
        }
    }
}


extension UIImage {
    func rect(row : Int, col: Int, size : Int) -> UIImage {
        guard let image = self.cgImage else {return self}
        let width = image.width
        let height = image.height
        let rectSize = CGSize(width: width / size, height: height / size)
        let origin = CGPoint(x: col * Int(rectSize.height), y: row * Int(rectSize.width))
        let croppedImage = image.cropping(to: CGRect(origin: origin, size: rectSize))!
        return UIImage(cgImage: croppedImage)
    }
}


struct Snap : AnimatableModifier {
    var animatableData: Double
    func body(content: Content) -> some View {
        content.opacity(1)
    }
}


struct Flip : AnimatableModifier {
    var animatableData: Double {
        get {rotation / 180}
        set {rotation = newValue * 180}
    }
    var rotation : Double
    func body(content: Content) -> some View {
        content.rotation3DEffect(Angle(degrees: rotation), axis: (0,1,0))
    }
}

extension AnyTransition{
    static var flip : AnyTransition {
        AnyTransition.modifier(
            active: Flip(rotation: 0),
            identity: Flip(rotation: 180))
    }
}

extension AnyTransition{
    static var snap : AnyTransition {
        AnyTransition.modifier(
            active: Snap(animatableData: 0),
            identity: Snap(animatableData: 1))
    }
}
