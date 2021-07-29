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
    
    @Published
    var selectedGridPuzzleID : UUID?
    
    func updateChapter(newChapter : ReadableChapter){
        guard let chapterIndex = self.chapterIndex else {return}
        book.chapters[chapterIndex] = newChapter
        save()
    }
    
    func updatePuzzle(newPuzzle : ReadablePuzzle){
        guard let chapterIndex = self.chapterIndex else {return}
        guard let puzzleIndex = self.puzzleIndex else {return}
        book.chapters[chapterIndex].puzzles[puzzleIndex] = newPuzzle
        save()
    }
    
    func updateGridPuzzle(newGrid : ReadableGridPuzzle){
        guard let chapterIndex = self.chapterIndex else {return}
        self.book.chapters[chapterIndex].gridPuzzle = newGrid
        save()
    }
    
    func addPuzzle(){
        guard let chapterIndex = self.chapterIndex else {return}
        
        var newPuzzle = ReadablePuzzle()
        newPuzzle.title = "puzzle title \(self.book.chapters[chapterIndex].puzzles.count + 1)"
        newPuzzle.keyAlphabet = self.shuffledAlphabet
        
        self.book.chapters[chapterIndex].puzzles.append(newPuzzle)
        save()
    }
    
    func deletePuzzle(puzzleID : UUID){
        guard let chapterIndex = self.chapterIndex else {return}
        guard let puzzleIndex = self.puzzleIndex else {return}
        book.chapters[chapterIndex].puzzles.remove(at: puzzleIndex)
        save()
    }
    
    func deleteChapter(chapterID : UUID){
        guard let chapterIndex = self.chapterIndex else {return}
        book.chapters.remove(at: chapterIndex)
        save()
    }
    
    func deleteGridPuzzle(puzzleID: UUID){
        guard let chapterIndex = self.chapterIndex else {return}
        self.book.chapters[chapterIndex].gridPuzzle = nil
        save()
    }
    
    func toggle(_ dependency : UUID){
        guard let chapterIndex = self.chapterIndex else {return}
        
        if let puzzleIndex = self.puzzleIndex {
            
            if book.chapters[chapterIndex].puzzles[puzzleIndex].dependencies.contains(dependency){
                book.chapters[chapterIndex].puzzles[puzzleIndex].dependencies.removeAll(where: {$0 == dependency})
            } else {
                book.chapters[chapterIndex].puzzles[puzzleIndex].dependencies.append(dependency)
            }
            
            
        } else if let gridPuzzle = book.chapters[chapterIndex].gridPuzzle,
                  gridPuzzle.id == self.selectedGridPuzzleID  {
            
            if gridPuzzle.dependencies.contains(dependency) {
                book.chapters[chapterIndex].gridPuzzle?.dependencies.removeAll(where: {$0 == dependency})
            } else {
                book.chapters[chapterIndex].gridPuzzle?.dependencies.append(dependency)
            }
        }
                
        save()
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
    
    var shuffledAlphabet: String {
        let alphabet : String = String.alphabet
        var result: String = ""
        
        for character in alphabet{
            let allowedLetters = alphabet.compactMap{
                return result.contains($0) || $0 == character ? nil : $0
            }
            if let nextChar = allowedLetters.randomElement(){
                result.append(nextChar)
            }
        }
        return result
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
        self.book = ReadableBook()
    }
}

