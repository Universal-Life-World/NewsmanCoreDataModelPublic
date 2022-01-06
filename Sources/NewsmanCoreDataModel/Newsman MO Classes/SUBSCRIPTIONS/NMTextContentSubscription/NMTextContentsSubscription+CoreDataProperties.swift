//
//  NMTextContentsSubscription+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTextContentsSubscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTextContentsSubscription> {
        return NSFetchRequest<NMTextContentsSubscription>(entityName: "NMTextContentsSubscription")
    }

    @NSManaged public var excludeNewsmen: NSMutableArray?
    @NSManaged public var exclusionTags: NSMutableArray?
    @NSManaged public var newsCategories: NSMutableArray?
    @NSManaged public var searchTags: NSMutableArray?
    @NSManaged public var targetNewsmen: NSMutableArray?

}
