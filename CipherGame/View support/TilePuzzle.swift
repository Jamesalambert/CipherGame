//
//  TilePuzzle.swift
//  CipherGame
//
//  Created by J Lambert on 07/05/2021.
//

import SwiftUI
import UIKit

struct TilePuzzle: View {
    
    var puzzleImage : UIImage
    
    @State
    private var grid : Grid = Grid()
    
    var body: some View {
        LazyVGrid(columns: self.columns(width: 250), spacing:0){
            ForEach(grid.rows){ row in
                ForEach(row.tiles){ tile in
                    if tile.content == 0 {
                    Image(uiImage: puzzleImage.rect(x: tile.index.x, y: tile.index.y))
//                        .font(.system(size: 60))
                        .id(tile.id)
                        .onTapGesture {
                            withAnimation{
                                self.grid.move(id: tile.id)
                            }
                        }
                    } else {
                        ZStack{}
                    }
                }
            }
        }
    }
    
    struct Grid {
        
        var rows : [Row]
        
        mutating
        func move(id : UUID) {
            let (x, y) : (Int,Int) = tappedSquare(with: id)
            if canMove(x: x, y: y){
                let movedTile = rows[y].tiles[x]
                let emptyTile = emptySquare()
                self.rows[y].tiles[x] = self.rows[emptyTile.y].tiles[emptyTile.x]
                self.rows[emptyTile.y].tiles[emptyTile.x] = movedTile
            }
        }
        
        private
        func canMove(x : Int, y : Int) -> Bool{
            let emptySquare = emptySquare()
            var adjacentPoints : [(Int,Int)] = []
            adjacentPoints.append((emptySquare.x + 1, emptySquare.y))
            adjacentPoints.append((emptySquare.x, emptySquare.y + 1))
            adjacentPoints.append((emptySquare.x - 1, emptySquare.y))
            adjacentPoints.append((emptySquare.x, emptySquare.y - 1))
            
            return adjacentPoints.contains{$0 == (x,y)}
        }
        
        private
        func emptySquare() -> (x : Int, y : Int) {
            for column in 0...2{
                for row in 0...2{
                    if self.rows[row].tiles[column].content == 1 {
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        private
        func tappedSquare(with id : UUID) -> (x : Int, y : Int) {
            for column in 0...2{
                for row in 0...2{
                    if self.rows[row].tiles[column].id == id{
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        init() {
            let arr : [[Int]] = [[0,0,0],[0,0,0],[1,0,0]]
            
            var rows : [Row] = []
            
            for (rowIndex, row) in arr.enumerated() {
                var tiles : [Tile] = []
                for (colIndex, value) in row.enumerated() {
                    tiles.append(Tile(index: (x: colIndex, y: rowIndex), content: value))
                }
                rows += [Row(tiles: tiles)]
            }
            self.rows = rows
        }
    }
    
    
    
    struct Row : Identifiable {
        var id = UUID()
        var tiles : [Tile]
    }
    
    struct Tile : Identifiable{
        var id = UUID()
        var index : (x: Int, y: Int)
        var content : Int
    }
    
    func columns(width: Int)->[GridItem]{
        return Array(repeating: GridItem(.fixed(CGFloat(width)), spacing: 0, alignment: .center), count: 3)
    }
    
}



struct TilePuzzle_Previews: PreviewProvider {
    static var previews: some View {
        TilePuzzle(puzzleImage: UIImage(named: "phoneImage")!)
    }
}



extension UIImage {
    func rect(x : Int, y: Int) -> UIImage {
        guard let image = self.cgImage else {return self}
        let width = image.width
        let height = image.height
        let rectSize = CGSize(width: width / 3, height: height / 3)
        
        let origin = CGPoint(x: x * Int(rectSize.width), y: y * Int(rectSize.height))
        
        let croppedImage = image.cropping(to: CGRect(origin: origin, size: rectSize))!
        return UIImage(cgImage: croppedImage)
    }
}
