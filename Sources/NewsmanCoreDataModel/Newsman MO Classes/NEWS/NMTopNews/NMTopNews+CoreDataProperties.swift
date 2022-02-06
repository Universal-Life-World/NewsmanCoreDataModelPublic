//
//  NMTopNews+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTopNews {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTopNews> {
        return NSFetchRequest<NMTopNews>(entityName: "NMTopNews")
    }

    @NSManaged public var about: String?
    @NSManaged public var category: String?
    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var hiddenSectionsBitset: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isHidden: Bool
    @NSManaged public var moderatedTimeStamp: Date?
    @NSManaged public var popularity: Double
    @NSManaged public var priority: String?
    @NSManaged public var publishedTimeStamp: Date?
    @NSManaged public var sectionAlphaIndex: String?
    @NSManaged public var sectionDateIndex: String?
    @NSManaged public var sectionPriorityIndex: String?
    @NSManaged public var status: String?
    @NSManaged public var relatedContentItems: NSSet?
    @NSManaged public var relatedReports: NSSet?
    @NSManaged public var relatedSnippets: NSSet?
    @NSManaged public var relatedSubscriptions: NSSet?

}

// MARK: Generated accessors for relatedContentItems
extension NMTopNews {

    @objc(addRelatedContentItemsObject:)
    @NSManaged public func addToRelatedContentItems(_ value: NMBaseContent)

    @objc(removeRelatedContentItemsObject:)
    @NSManaged public func removeFromRelatedContentItems(_ value: NMBaseContent)

    @objc(addRelatedContentItems:)
    @NSManaged public func addToRelatedContentItems(_ values: NSSet)

    @objc(removeRelatedContentItems:)
    @NSManaged public func removeFromRelatedContentItems(_ values: NSSet)

}

// MARK: Generated accessors for relatedReports
extension NMTopNews {

    @objc(addRelatedReportsObject:)
    @NSManaged public func addToRelatedReports(_ value: NMReport)

    @objc(removeRelatedReportsObject:)
    @NSManaged public func removeFromRelatedReports(_ value: NMReport)

    @objc(addRelatedReports:)
    @NSManaged public func addToRelatedReports(_ values: NSSet)

    @objc(removeRelatedReports:)
    @NSManaged public func removeFromRelatedReports(_ values: NSSet)

}

// MARK: Generated accessors for relatedSnippets
@available(iOS 13.0, *)
extension NMTopNews {

    @objc(addRelatedSnippetsObject:)
    @NSManaged public func addToRelatedSnippets(_ value: NMBaseSnippet)

    @objc(removeRelatedSnippetsObject:)
    @NSManaged public func removeFromRelatedSnippets(_ value: NMBaseSnippet)

    @objc(addRelatedSnippets:)
    @NSManaged public func addToRelatedSnippets(_ values: NSSet)

    @objc(removeRelatedSnippets:)
    @NSManaged public func removeFromRelatedSnippets(_ values: NSSet)

}

// MARK: Generated accessors for relatedSubscriptions
extension NMTopNews {

    @objc(addRelatedSubscriptionsObject:)
    @NSManaged public func addToRelatedSubscriptions(_ value: NMTopNewsSubscription)

    @objc(removeRelatedSubscriptionsObject:)
    @NSManaged public func removeFromRelatedSubscriptions(_ value: NMTopNewsSubscription)

    @objc(addRelatedSubscriptions:)
    @NSManaged public func addToRelatedSubscriptions(_ values: NSSet)

    @objc(removeRelatedSubscriptions:)
    @NSManaged public func removeFromRelatedSubscriptions(_ values: NSSet)

}
