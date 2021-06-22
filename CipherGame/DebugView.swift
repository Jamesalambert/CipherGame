//
//  DebugView.swift
//  CipherGame
//
//  Created by J Lambert on 28/05/2021.
//

import SwiftUI

extension ContentView {
    
    
    struct DebugView: View {
        
        @EnvironmentObject
        var viewModel : CipherPuzzle
        
        var body: some View {
        
            List{
                
                Section(header: Text("bookIDs in model").font(.title)){
                    ForEach(viewModel.model.activeBookIds, id:\.self){ bookID in
                        Text(bookID)
                    }
                }
                
                
                Section(header: Text("keychain").font(.title)){
                    Text(OnlineStore.shared.printKeychainData())
                    Button("clear keychain"){
                        OnlineStore.shared.deleteAllPurchasesFromKeychain()
                    }
                }
                
                Section(header: Text("Docs folder")){
                    ForEach(contents(of: OnlineStore.documentsURL.path), id:\.self){file in
                        Text(file)
                    }
                    
                }
                Section(header: Text("/test.spaceBook/").font(.title)){
                    ForEach(OnlineStore.shared.contents(of: OnlineStore.documentsURL.appendingPathComponent("test.spaceBook/").path), id:\.self){file in
                        Text(file)
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        
        
        private
        func contents(of url : String) -> [String]{
            do{
                let contents = try FileManager.default.contentsOfDirectory(atPath: url)
                return contents
            } catch {
                print("couldn't find folder! \(url)")
                return []
            }
        }   
    }
}


