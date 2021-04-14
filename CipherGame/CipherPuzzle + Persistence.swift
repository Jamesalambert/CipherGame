//
//  CipherPuzzle + Persistence.swift
//  CipherGame
//
//  Created by J Lambert on 06/04/2021.
//

import Foundation

extension CipherPuzzle {
     
    private static var documentsFolder : URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        }
        catch{
            fatalError("couldn't find Documents folder")
        }
        
    }
    
    private static var fileURL : URL {
        return documentsFolder.appendingPathComponent("cipherGame.data")
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            //if this fails we fall back to the blank Game() inited by the viewModel
            guard let data = try? Data(contentsOf: Self.fileURL) else {return}
            
            guard let savedGame = try? JSONDecoder().decode(Game.self, from: data) else {
                fatalError("couldn't decode data to type 'Game'")
            }
            DispatchQueue.main.async {
                self?.model = savedGame
                //set last open puzzle to the current one.
                self?.currentPuzzleHash = self?.model.lastOpenPuzzleHash
            }
        }
    }
    
    func save(){
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let model = self?.model else {
                fatalError("couldn't get data to save")
            }
            guard let dataToSave = try? JSONEncoder().encode(model) else {
                fatalError("couldn't encode game data")
            }
            do{
                let outfile = Self.fileURL
                try dataToSave.write(to: outfile)
            } catch {
                fatalError("can't write to file")
            }
            
//            See which fonts are installed!
//            for font in UIFont.familyNames{
//                for type in UIFont.fontNames(forFamilyName: font) {
//                    print(type)
//                }
//            }
        }
    }
}
