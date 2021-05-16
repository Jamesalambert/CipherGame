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
        var solutionType : GridSolution = .rows

        var isSolved : Bool {
            guard disabledTileIDs.count == 0 else {return false}
            return GridPuzzle.soultionChecker(self)
        }

        private
        var disabledTileIDs : [UUID] = []

        private
        var recentlyEnabledTileIDs : [UUID] = []

        func tileIsEnabled(_ tileID : UUID) -> Bool {
            return !disabledTileIDs.contains(tileID)
        }
        
        func tileIsRecentlyEnabled(_ tileID : UUID) -> Bool {
            return recentlyEnabledTileIDs.contains(tileID)
        }

        mutating
        func addTile(){
            guard let tileIDToAdd = disabledTileIDs.last else {return}
            self.disabledTileIDs = self.disabledTileIDs.dropLast(Int(1))
            
            let rowIndex = rows.firstIndex(where: {$0.tiles.contains{$0.id == tileIDToAdd}})
            let tileIndex = rows[rowIndex!].tiles.firstIndex(where: {$0.id == tileIDToAdd})
            let tileToAdd = self.rows[rowIndex!].tiles[tileIndex!]
            
            //change UUID
            let enabledTile = Tile(id: UUID(), index: tileToAdd.index, content: tileToAdd.content)
            self.rows[rowIndex!].tiles[tileIndex!] = enabledTile
            
            self.recentlyEnabledTileIDs.append(enabledTile.id)
            disabledTileIDs.append(enabledTile.id)
        }

        mutating
        func revealTile(id : UUID){
            let rowIndex = rows.firstIndex(where: {$0.tiles.contains{$0.id == id}})
            let tileIndex = rows[rowIndex!].tiles.firstIndex(where: {$0.id == id})
            let tileToAdd = self.rows[rowIndex!].tiles[tileIndex!]

            //change UUID
            let revealedTile = Tile(id: UUID(), index: tileToAdd.index, content: tileToAdd.content)
            self.rows[rowIndex!].tiles[tileIndex!] = revealedTile
            
            recentlyEnabledTileIDs.removeAll(where: {$0 == id})
            disabledTileIDs.removeAll(where: {$0 == id})
        }
        
        mutating
        func move(id : UUID) {
            guard !isSolved else {return}
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

        mutating
        func solve(){
            var tiles : [Tile] = rows.flatMap{$0.tiles}
            tiles = tiles.sorted(by: {!($0.index[0] < $1.index[0]) || ($0.index[1] < $1.index[1])})
            
            for rowIndex in 0..<self.size{
                let startIndex = rowIndex * self.size
                self.rows[rowIndex].tiles = Array(tiles[startIndex...startIndex + self.size - 1])
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

        //solution functions
        private
        static
        func soultionChecker(_ puzzle : GridPuzzle) -> Bool {
            switch puzzle.solutionType {
            case .all:
                return GridPuzzle.allChecker(rows: puzzle.rows)
            case .rows:
                return GridPuzzle.rowsChecker(rows: puzzle.rows)
            case .columns:
                return GridPuzzle.columnsChecker(rows: puzzle.rows)
            }
        }
        
        //all
        private
        static
        func allChecker(rows : [Row]) -> Bool{
            for (rowIndex, row) in rows.enumerated() {
                for (tileIndex, tile) in row.tiles.enumerated(){
                    if tile.index != [tileIndex, rowIndex] {
                        return false
                    }
                }
            }
            return true
        }
        
        private
        static
        func rowsChecker(rows : [Row]) ->Bool {
            rows.enumerated().allSatisfy{(rowIndex, row) -> Bool in
                row.tiles.allSatisfy{ tile in
                    tile.index[0] == rowIndex}
            }
        }
        
        private
        static
        func columnsChecker(rows : [Row]) ->Bool {
            rows.allSatisfy{ row in
                row.tiles.enumerated().allSatisfy{ (tileIndex, tile) in
                    tile.index[1] == tileIndex}
            }
        }
        //solution funcs
        
        
        init(imageName: String, size : Int = 4, hiddenTiles : Int = 5) {
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
    

enum GridSolution : Codable {
    
    case all
    case rows
    case columns
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try? container.decode(String.self)
        switch value{
        case "all": self = .all
        case "rows": self = .rows
        case "columns": self = .columns
        default:
            self = .all
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .all: try container.encode("all")
        case .rows: try container.encode("rows")
        case .columns: try container.encode("columns")
        }
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

