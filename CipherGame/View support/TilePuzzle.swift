//
//  TilePuzzle.swift
//  CipherGame
//
//  Created by J Lambert on 07/05/2021.
//

import SwiftUI

struct TilePuzzle: View {
    
    @State
    private var grid : Grid = Grid()
    
    var body: some View {
        
        LazyVGrid(columns: self.columns()){
            ForEach(grid.rows){ row in
                ForEach(row.tiles){ tile in
                    Image(systemName: tile.content == "0" ? "circle.fill" : "circle")
                        .font(.system(size: 60))
                        .id(tile.id)
                        .onTapGesture {
                            withAnimation{
                                self.grid.move(id: tile.id)
                            }
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
                    if self.rows[row].tiles[column].content == "1"{
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
            let row1 = Row(tiles: "100".map{Tile(content: String($0))})
            let row2 = Row(tiles: "000".map{Tile(content: String($0))})
            let row3 = Row(tiles: "000".map{Tile(content: String($0))})
            self.rows = [row1,row2,row3]
        }
        
        
    }
    
    struct Row : Identifiable {
        var id = UUID()
        var tiles : [Tile]
    }
    
    struct Tile : Identifiable{
        var id = UUID()
        var content : String = ""
    }
    
    func columns()->[GridItem]{
        return Array(repeating: GridItem(.fixed(100), spacing: 0, alignment: .center), count: 3)
    }
    
}



struct TilePuzzle_Previews: PreviewProvider {
    static var previews: some View {
        TilePuzzle()
    }
}
