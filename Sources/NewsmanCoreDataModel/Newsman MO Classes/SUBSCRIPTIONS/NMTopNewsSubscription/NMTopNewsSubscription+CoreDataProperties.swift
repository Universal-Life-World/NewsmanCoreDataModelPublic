//
//  NMTopNewsSubscription+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTopNewsSubscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTopNewsSubscription> {
        return NSFetchRequest<NMTopNewsSubscription>(entityName: "NMTopNewsSubscription")
    }

    @NSManaged public var exclusionTags: NSMutableArray?
    @NSManaged public var exludeNewsmen: NSMutableArray?
    @NSManaged public var maxPopularity: Double
    @NSManaged public var minPopularity: Double
    @NSManaged public var searchedCategories: NSMutableArray?
    @NSManaged public var searchedPriorities: NSMutableArray?
    @NSManaged public var searchedStatuses: NSMutableArray?
    @NSManaged public var searchTags: NSMutableArray?
    @NSManaged public var targetNewsmen: NSMutableArray?
    @NSManaged public var topNewsToSearch: NSSet?

}

// MARK: Generated accessors for topNewsToSearch
extension NMTopNewsSubscription {

    @objc(addTopNewsToSearchObject:)
    @NSManaged public func addToTopNewsToSearch(_ value: NMTopNews)

    @objc(removeTopNewsToSearchObject:)
    @NSManaged public func removeFromTopNewsToSearch(_ value: NMTopNews)

    @objc(addTopNewsToSearch:)
    @NSManaged public func addToTopNewsToSearch(_ values: NSSet)

    @objc(removeTopNewsToSearch:)
    @NSManaged public func removeFromTopNewsToSearch(_ values: NSSet)

}
