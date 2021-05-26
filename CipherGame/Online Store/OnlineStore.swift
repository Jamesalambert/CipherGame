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
    static let productsKey = "productIDs"
    
    @Published
    var productIDs : [String] = [] {
        didSet{
            getProductsFromAppStore()
        }
    }
    
    @Published
    var finishedTransactions : Bool = false
    
    @Published
    var booksForSale : [ProductInfo] = []
    
    @Published
    var stateDescription : String = ""
    
    @Published
    var state : StoreState = .inactive
    
    private
    var products = [SKProduct]()

    private
    var productRequest : SKProductsRequest?
    
    private
    func getProductsFromAppStore(){
        self.productRequest = SKProductsRequest(productIdentifiers: Set(productIDs))
        productRequest?.delegate = self
        productRequest!.start()
        stateDescription = "getting product list"
    }

    func getAvailableProductIds(){
        let defaults = UserDefaults.standard
        defaults.set(["test.mysteryIsland","test.spaceBook"], forKey: Self.productsKey)
        //TODO: retrieve product identifiers from the network
        guard let array =  UserDefaults.standard.object(forKey: Self.productsKey) as? [String] else {return}
        print(array)
        self.productIDs = array
    }
    
    func buyProduct(_ id : String){
        guard let product = self.products.first(where: {$0.productIdentifier == id}) else {
            print("Couldn't find product with id: \(id)")
            return
        }
        if SKPaymentQueue.canMakePayments(){
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            stateDescription = "starting payment"
            state = .busy(id)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        stateDescription = "restoring purchases"
    }
}


extension OnlineStore : SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        print("Found \(response.products.count) products")
        
        if response.products.count > 0 {
            DispatchQueue.main.async {
                self.booksForSale = response.products.map{ProductInfo(product: $0)}
                self.products = response.products
                self.stateDescription = "got \(response.products.count) products"
            }
        }
    }
    
    //SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var numberOfFinishedTransactions = 0
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                //do nothing
                break
            case .purchased, .restored:
                //unlock the item!
                let id = transaction.payment.productIdentifier
                let bookName = booksForSale.first(where: {$0.id == id})?.title
                
                storeRecieptInKeychain(for: bookName ?? "unknown book", newBookIdentifier: id)
                numberOfFinishedTransactions += 1
                
                state = .inactive
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            case .failed, .deferred:
                state = .inactive
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            @unknown default:
                state = .inactive
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            }
            stateDescription = "\(transaction.transactionState.rawValue)"
        }
        
        if numberOfFinishedTransactions > 0 {finishedTransactions.toggle()}
    }
    
    //needed for restoring transactions
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        stateDescription = "finished restoring purchases."
    }
    
}

struct ProductInfo : Identifiable{
    var id : String
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
        self.id = product.productIdentifier
    }
}

enum StoreState : Equatable {
    case inactive
    case busy (String)
}
