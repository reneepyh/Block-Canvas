//
//  HiddenManager.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/6.
//

import Foundation
import CoreData

class HiddenManager {
    static let shared = HiddenManager()
    
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
    
    func saveToHiddenNFTs(nft: NFTInfoForDisplay) {
        let managedContext = persistentContainer.viewContext
        print(NSPersistentContainer.defaultDirectoryURL())
        let entity = NSEntityDescription.entity(forEntityName: "HiddenItem", in: managedContext)!
        let hiddenNFTItem = NSManagedObject(entity: entity, insertInto: managedContext)
        
        hiddenNFTItem.setValue(nft.title, forKey: "title")
        hiddenNFTItem.setValue(nft.artist, forKey: "artist")
        hiddenNFTItem.setValue(nft.description, forKey: "nftDescription")
        hiddenNFTItem.setValue(nft.contract, forKey: "contract")
        hiddenNFTItem.setValue(nft.url.absoluteString, forKey: "displayUri")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func fetchHiddenNFTItems() -> [NSManagedObject]? {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HiddenItem")
        
        do {
            let hiddenNFTItems = try managedContext.fetch(fetchRequest)
            return hiddenNFTItems
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }

    func deleteHiddenNFTItem(with displayUri: String) {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HiddenItem")
        fetchRequest.predicate = NSPredicate(format: "displayUri == %@", displayUri)
        
        do {
            if let managedObject = try managedContext.fetch(fetchRequest).first {
                managedContext.delete(managedObject)
                try managedContext.save()
            } else {
                print("Item with displayUri \(displayUri) not found in hidden NFTs.")
            }
        } catch let error as NSError {
            print("Could not delete hidden NFT item. \(error), \(error.userInfo)")
        }
    }

    func isHiddenNFT(nft: NFTInfoForDisplay) -> Bool {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HiddenItem")
        fetchRequest.predicate = NSPredicate(format: "displayUri == %@", nft.url.absoluteString)
        
        do {
            let matchingItems = try managedContext.fetch(fetchRequest)
            return matchingItems.count > 0
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }

}
