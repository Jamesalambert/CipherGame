//
//  OnlineStore.swift
//  CipherGame
//
//  Created by J Lambert on 30/04/2021.
//

import Foundation
import StoreKit

class OnlineStore : NSObject, ObservableObject {
    
    static let shared = OnlineStore()
    
    var productIDs = ["test.mysteryIsland"]
    
    @Published
    var booksForSale : [ProductInfo] = [] {
        didSet{
            booksForSale.forEach{ book in
                print(book.title)
                print(book.description)
                print(book.price)
            }
        }
    }
    
    func getProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }

    
}

extension OnlineStore : SKProductsRequestDelegate, SKPaymentQueueDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        if response.products.count > 0 {
            booksForSale = response.products.map{ProductInfo(product: $0)}
        }
    }
    
//    func paymentQueue(_ paymentQueue: SKPaymentQueue, shouldContinue transaction: SKPaymentTransaction, in newStorefront: SKStorefront) -> Bool {
//
//    }
    
}

extension SKProduct : Identifiable {}

struct ProductInfo : Identifiable{
    var id = UUID()
    
    var title : String = ""
    var price : String = ""
    var description : String = ""
    
    init(product : SKProduct){
        
        func formattedPrice(for product : SKProduct) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            return formatter.string(from: product.price) ?? "formatting error"
        }
        
        self.title = product.localizedTitle
        self.description = product.localizedDescription
        self.price = formattedPrice(for: product)
    }
}
