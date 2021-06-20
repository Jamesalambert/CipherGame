//
//  BuilderViewModel + Persistence.swift
//  PuzzleBuilder
//
//  Created by J Lambert on 20/06/2021.
//

import Foundation

extension BuilderViewModel {
    private static var documentsFolder : URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        }
        catch{
            fatalError("couldn't find Documents folder")
        }
    }
    
    private static var fileURL : URL {
        return documentsFolder.appendingPathComponent("puzzleBuilder.json")
    }
    
    func load() {
        //load prior state
        DispatchQueue.global(qos: .background).async { [weak self] in
            //if this fails we fall back to the blank Game() inited by the viewModel
            guard let data = try? Data(contentsOf: Self.fileURL) else {return}
            guard let savedBook = try? JSONDecoder().decode(ReadableBook.self, from: data) else {
                fatalError("couldn't decode data to type 'Game'")
            }
            DispatchQueue.main.async {
                self?.book = savedBook
                self?.selectedChapterID = self?.book.chapters.first?.id
                self?.selectedPuzzleID = self?.book.chapters.first?.puzzles.first?.id
            }
        }
    }
    
    
    func save(){
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let book = self?.book else {
                fatalError("couldn't get data to save")
            }
            guard let dataToSave = try? JSONEncoder().encode(book) else {
                fatalError("couldn't encode game data")
            }
            do{
                let outfile = Self.fileURL
                try dataToSave.write(to: outfile)
            } catch {
                fatalError("can't write to file")
            }
        }
    }
}
