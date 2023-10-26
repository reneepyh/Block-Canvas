//
//  WatchlistItem+CoreDataProperties.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/21.
//
//

import Foundation
import CoreData


extension WatchlistItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchlistItem> {
        return NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
    }

    @NSManaged public var thumbnailUri: String?
    @NSManaged public var contract: String?
    @NSManaged public var displayUri: String?
    @NSManaged public var title: String?
    @NSManaged public var authorName: String?
    @NSManaged public var nftDescription: String?

}

extension WatchlistItem : Identifiable {

}
