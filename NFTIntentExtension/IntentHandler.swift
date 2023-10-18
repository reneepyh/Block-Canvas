//
//  IntentHandler.swift
//  NFTIntentExtension
//
//  Created by Renee Hsu on 2023/10/1.
//

import Intents

struct NFTInfoForWidget: Codable {
    let url: URL
    let title: String
    let artist: String
    let description: String
}

class IntentHandler: INExtension, SelectNFTIntentHandling {
    func provideNFTNameOptionsCollection(for intent: SelectNFTIntent, with completion: @escaping (INObjectCollection<SelectNFT>?, Error?) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.CML8K54JBW.reneehsu.Block-Canvas")
        print(sharedDefaults?.object(forKey: "nftInfoForDisplay") as? Data)
        if let savedData = sharedDefaults?.object(forKey: "nftInfoForDisplay") as? Data {
            let decoder = JSONDecoder()
            if let loadedNFTInfo = try? decoder.decode([NFTInfoForWidget].self, from: savedData) {
                let nftDisplayOptions = loadedNFTInfo.map { NFTInfoForWidget in
                    let nft = SelectNFT(identifier: String(describing: NFTInfoForWidget.url), display: NFTInfoForWidget.title)
                    nft.nftName = NFTInfoForWidget.title
                    
                    return nft
                }
                
                let collections = INObjectCollection(items: nftDisplayOptions)
                completion(collections, nil)
            }
        }
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
