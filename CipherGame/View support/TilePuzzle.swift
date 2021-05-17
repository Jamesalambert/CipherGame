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
    
    var puzzleImage : UIImage
    
    var screenSize : CGSize
    
    var grid : GridPuzzle
    
    var body: some View {
        ZStack{
            if !grid.isSolved{
                tilePuzzleBackground()
                    .opacity(0.3)
                    .transition(.scale)
            }
            LazyVGrid(columns: self.columns(), spacing: 0){
                ForEach(grid.rows.flatMap{$0.tiles}){ tile in
                    TileView(tile: tile, grid: grid, image: puzzleImage)
//                        .animation(.interpolatingSpring(stiffness: 380, damping: 45))
                        .onTapGesture {
                            withAnimation{
                                viewModel.gridTap(tile)
                            }
                        }
                }
            }
        }
        .zIndex(0)
    }
    
    
    
    @ViewBuilder
    func tilePuzzleBackground() -> some View {
            switch grid.solutionType{
            case .rows:
                VStack(spacing:0){
                    ForEach(0..<grid.size){ index in
                        Self.tileColors[index]
                    }
                }
            case .columns:
                HStack(spacing:0){
                    ForEach(0..<grid.size){ index in
                        Self.tileColors[index]
                    }
                }
            case .all:
                ZStack{}
            }
    }
    
    
    
    func columns()->[GridItem]{
        let width = 0.8 * min(screenSize.height, screenSize.width) / CGFloat(grid.size)
        return Array(repeating: GridItem(.fixed(CGFloat(width)),
                                         spacing: CGFloat(0),
                                         alignment: .center),
                     count: grid.size)
    }

    
    

    struct TileView : View, Animatable {
        
        var tile : Tile
        var rotation : Double

        var isFaceUp : Bool{
            return rotation < 90
        }
        
        var animatableData: Double{
            get{rotation}
            set{rotation = newValue}
        }
        var grid : GridPuzzle
        var puzzleImage : UIImage
        
        init(tile : Tile, grid : GridPuzzle, image : UIImage){
            self.tile = tile
            self.grid = grid
            self.puzzleImage = image
            self.rotation = 0
            
            if grid.isSolved || (tile.isEnabled && tile.content == 0){
                self.rotation = 0       //image
            } else if tile.content == 1 && !grid.isSolved{
                self.rotation = 180      //blank
            } else if tile.content == 0 && !grid.isSolved && !tile.isEnabled{
                self.rotation = 180     //mystery
            }
        }
        
        var body: some View{
            if isFaceUp || tile.canBeEnabled {
                tileWithImage()
                    .rotation3DEffect(Angle.degrees(rotation), axis: (0,1,0))
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
                        .aspectRatio(1,contentMode: .fit)
                        .padding()
                }
                .overlay(RoundedRectangle(cornerRadius: TilePuzzle.tileCornerRadius).stroke(Color.black, lineWidth: 2)  )
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
                case .all:
                    Image(uiImage: puzzleImage.rect(row: tile.index[0], col: tile.index[1], size: grid.size))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(TilePuzzle.tileCornerRadius)
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
