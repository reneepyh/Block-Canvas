//
//  WatchlistManager.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/21.
//

import Foundation
import CoreData

class WatchlistManager {
    static let shared = WatchlistManager()
    
    private init() {}
    
    // 建立container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SettingsManager")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveToWatchlist(discoverNFTAdded: DiscoverNFT) {
        let managedContext = WatchlistManager.shared.persistentContainer.viewContext
        
        print(NSPersistentContainer.defaultDirectoryURL())
        
        let entity = NSEntityDescription.entity(forEntityName: "WatchlistItem", in: managedContext)!
        // Initializes a managed object and inserts it into the specified managed object context.
        let watchlistItem = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
        
        watchlistItem.setValue(discoverNFTAdded.title, forKeyPath: "title")
        watchlistItem.setValue(discoverNFTAdded.authorName, forKey: "authorName")
        watchlistItem.setValue(discoverNFTAdded.contract, forKey: "contract")
        watchlistItem.setValue(discoverNFTAdded.nftDescription, forKey: "nftDescription")
        watchlistItem.setValue(discoverNFTAdded.thumbnailUri, forKey: "thumbnailUri")
        watchlistItem.setValue(discoverNFTAdded.displayUri, forKey: "displayUri")
        watchlistItem.setValue(discoverNFTAdded.id, forKey: "id")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchWatchlistItems() -> [NSManagedObject]? {
        let managedContext = WatchlistManager.shared.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchlistItem")
        
        do {
            let watchlistItems = try managedContext.fetch(fetchRequest)
            return watchlistItems
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func deleteWatchlistItem(with displayUri: String) {
        let managedContext = WatchlistManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchlistItem")
        fetchRequest.predicate = NSPredicate(format: "displayUri == %@", displayUri)
        
        do {
            if let managedObject = try managedContext.fetch(fetchRequest).first {
                managedContext.delete(managedObject)
                try managedContext.save()
            } else {
                print("Item with displayUri \(displayUri) not found in watchlist.")
            }
        } catch let error as NSError {
            print("Could not delete Watchlist item. \(error), \(error.userInfo)")
        }
    }
    
    func isInWatchlist(nft: DiscoverNFT) -> Bool {
        let managedContext = WatchlistManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchlistItem")
        fetchRequest.predicate = NSPredicate(format: "displayUri == %@", nft.displayUri)
        
        do {
            let matchingItems = try managedContext.fetch(fetchRequest)
            return matchingItems.count > 0
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }

}
