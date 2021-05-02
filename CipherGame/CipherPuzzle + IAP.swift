//
//  CipherPuzzle + IAP.swift
//  CipherGame
//
//  Created by J Lambert on 01/05/2021.
//

import Foundation

extension CipherPuzzle {
    
    func loadPurchasedBooksFromKeychain(){
        //read keychain for IAP
        DispatchQueue.global(qos: .background).async {
            let purchasedBookIds = self.getpurchasesFromKeychain()
            DispatchQueue.main.async {
                self.model.add(books: purchasedBookIds)
            }
        }
    }
    
    
    func getpurchasesFromKeychain() -> [String] {
        let query : [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String: Self.kcServiceString,
            kSecMatchLimit as String : kSecMatchLimitAll,
            kSecReturnAttributes as String : true,
            kSecReturnData as String : true]
        
        //retrieve
        var item : CFTypeRef?
        let success = SecItemCopyMatching(query as CFDictionary, &item)
        guard success != errSecItemNotFound  else {
            print("not found")
            return []
        }
        guard success == errSecSuccess else {
            print("Keychain error")
            return []
        }
        //read item
        guard let result = item as? [[String : Any]] else {return []}
        let output : [String] = result.map{ result in
            guard let value = result[kSecValueData as String] as? Data else {return "b"}
            guard let string = String(data: value, encoding: .utf8) else {return "c"}
            return string
        }
        return output
    }
    
    
    //for debugging
    #if DEBUG
    func deleteAllPurchasesFromKeychain(){
        
        let productIDs = ["test.mysteryIsland",
                          "test.spaceBook"]
        
        for _ in productIDs {
            
            for _ in [1,2,3] {
                let query : [String : Any] = [
                    kSecClass as String : kSecClassGenericPassword,
                    kSecAttrService as String: Self.kcServiceString as Any,
                    //kSecAttrAccount as String : productID as Any,
                    kSecReturnAttributes as String : true,
                    kSecReturnData as String : true
                ]
                
                var itemToDelete : CFTypeRef?
                let _ = SecItemCopyMatching(query as CFDictionary, &itemToDelete)
                
                guard let result = itemToDelete as? [String : Any] else {return}
                guard let productIDData = result[kSecValueData as String] as? Data else {return}
                guard let productID = String(data: productIDData, encoding: .utf8) else {return}
                
                print("deleting these:")
                print(productID)
                
                let success = SecItemDelete(query as CFDictionary)
                guard success != errSecItemNotFound  else {
                    print("deleted Items")
                    return
                }
                guard success == errSecSuccess else {
                    print("Keychain error \(success)")
                    return
                }
            }
        }
    }
    #endif
}
