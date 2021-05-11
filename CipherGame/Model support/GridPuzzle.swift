//
//  CipherPuzzleSource + GridPuzzle.swift
//  CipherGame
//
//  Created by J Lambert on 09/05/2021.
//

import Foundation

    //Model
    struct GridPuzzle : Codable {
        
        var rows : [Row]
        let imageName : String
        let size : Int
        let numberOfHiddenTiles : Int
        var id = UUID()
        
        var isEnabled : Bool {
            return disabledTileIDs.count == 0
        }
        
        var isSolved : Bool {
            for (rowIndex, row) in self.rows.enumerated() {
                for (tileIndex, tile) in row.tiles.enumerated(){
                    if tile.index != [tileIndex, rowIndex] {
                        return false
                    }
                }
            }
            return true
        }
        
        private
        var disabledTileIDs : [UUID] = []
        
        func tileIsEnabled(_ tileID : UUID) -> Bool {
            return !disabledTileIDs.contains(tileID)
        }
        
        mutating
        func addTile(){
            guard let tileIDToAdd = disabledTileIDs.last else {return}
            let rowIndex = rows.firstIndex(where: {$0.tiles.contains{$0.id == tileIDToAdd}})
            let tileIndex = rows[rowIndex!].tiles.firstIndex(where: {$0.id == tileIDToAdd})
            let tileToAdd = self.rows[rowIndex!].tiles[tileIndex!]
            //change UUID
            self.rows[rowIndex!].tiles[tileIndex!] = Tile(id: UUID(), index: tileToAdd.index, content: tileToAdd.content)
            
            self.disabledTileIDs = self.disabledTileIDs.dropLast(Int(1))
        }
        
        mutating
        func move(id : UUID) {
            let (x, y) : (Int,Int) = tappedSquare(with: id)
            if canMove(x: x, y: y){
                let movedTile = rows[y].tiles[x]
                let emptyTile = emptySquare()
                self.rows[y].tiles[x] = self.rows[emptyTile.y].tiles[emptyTile.x]
                self.rows[emptyTile.y].tiles[emptyTile.x] = movedTile
            }
            #if DEBUG
            printState()
            #endif
        }
        
        mutating
        func reset(){
            
            //shuffle tiles
            let tiles : [Tile] = rows.flatMap{$0.tiles}.shuffled()
            
            for rowIndex in 0..<self.size{
                let startIndex = rowIndex * self.size
                self.rows[rowIndex].tiles = Array(tiles[startIndex...startIndex + self.size - 1])
            }
            
            //reset hidden tile IDs
            if self.numberOfHiddenTiles < tiles.count{
                self.disabledTileIDs = tiles[0..<self.numberOfHiddenTiles].map{$0.id}
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
            for column in 0..<self.size{
                for row in 0..<self.size{
                    if self.rows[row].tiles[column].content == 1 {
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        private
        func tappedSquare(with id : UUID) -> (x : Int, y : Int) {
            for column in 0..<self.size{
                for row in 0..<self.size{
                    if self.rows[row].tiles[column].id == id{
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        private
        func printState(){
            for row in rows{
                var rowString = ""
                for tile in row.tiles{
                    rowString += "\(tile.index[0]),\(tile.index[1]) "
                }
                print(rowString)
            }
            print("isSolved: \(isSolved)\n")
        }
        
        
        init(imageName: String, size : Int = 3, hiddenTiles : Int = 5) {
            var arr : [[Int]] = Array(repeating: Array(repeating: 0, count: size), count: size)
            arr[size - 1][0] = 1
            
            var rows : [Row] = []
            var tiles : [Tile] = []
            
            for (rowIndex, row) in arr.enumerated() {
                for (colIndex, value) in row.enumerated() {
                    tiles.append(Tile(index: [colIndex, rowIndex], content: value))
                }
            }
            
            tiles = tiles.shuffled()
            
            for startIndex in stride(from: 0, to: size * size, by: size) {
                rows.append(Row(tiles: Array(tiles[startIndex...startIndex.advanced(by: size - 1)])))
            }
            
            if hiddenTiles < tiles.count{
                self.disabledTileIDs = tiles[0..<hiddenTiles].map{$0.id}
            }

            self.size = size
            self.numberOfHiddenTiles = hiddenTiles
            self.rows = rows
            self.imageName = imageName
            #if DEBUG
            print("init")
            printState()
            #endif
        }
        
    }
    
    struct Row : Identifiable, Codable {
        var id = UUID()
        var tiles : [Tile]
    }
    
    struct Tile : Identifiable, Codable{
        var id = UUID()
        var index : [Int]
        var content : Int
    }

