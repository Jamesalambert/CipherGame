//
//  BuilderViewModel.swift
//  PuzzleBuilder
//
//  Created by J Lambert on 18/06/2021.
//

import Foundation
import SwiftUI


class BuilderViewModel: ObservableObject{
    
    @Published
    var book : ReadableBook
    
    @Published
    var selectedChapterID : UUID?
    
    @Published
    var selectedPuzzleID : UUID?
    
    func updateChapter(newChapter : ReadableChapter){
        guard let chapterIndex = self.chapterIndex else {return}
        book.chapters[chapterIndex] = newChapter
    }
    
    func updatePuzzle(newPuzzle : ReadablePuzzle){
        guard let chapterIndex = self.chapterIndex else {return}
        guard let puzzleIndex = self.puzzleIndex else {return}
        book.chapters[chapterIndex].puzzles[puzzleIndex] = newPuzzle
    }
    
    func addPuzzle(){
        guard let chapterIndex = self.chapterIndex else {return}
        
        var newPuzzle = ReadablePuzzle()
        newPuzzle.title = "puzzle title \(self.book.chapters[chapterIndex].puzzles.count + 1)"
        
        self.book.chapters[chapterIndex].puzzles.append(newPuzzle)
    }
    
    var JSON : String {
        do{
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(book)
            if let string = String(data: jsonData, encoding: .utf8){
                return string
            }
        } catch {
            print("error getting JSON")
        }
        return ""
    }
    
    
    private var chapterIndex : Int? {
        guard let selectedChapterID = self.selectedChapterID else {return nil}

        guard let chapterIndex = book.chapters.indices.first(where: {book.chapters[$0].id == selectedChapterID})
        else {
            print("couldn't find chapter!.")
            return nil
        }
        return chapterIndex
    }
    
    private var puzzleIndex : Int? {
        guard let selectedPuzzleID = self.selectedPuzzleID else {return nil}
        guard let chapterIndex = self.chapterIndex else {return nil}
        
        guard let puzzleIndex = book.chapters[chapterIndex].puzzles.indices.first(where: {book.chapters[chapterIndex].puzzles[$0].id == selectedPuzzleID})
        else {
            print("couldn't find puzzle! with id: \(selectedPuzzleID).")
            print("puzzle ids in \(self.book.chapters[self.chapterIndex!].title):")
            print("\(self.book.chapters[self.chapterIndex!].puzzles.map{$0.id})")
            return nil
        }
        return puzzleIndex
    }
    
    
    
    init(){
        let book = ReadableBook()
        self.book = book
    }
    
}
