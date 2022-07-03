//
//  NMVideo+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


@available(iOS 13.0, *)
extension NMVideo {

   @nonobjc public class func fetchRequest() -> NSFetchRequest<NMVideo> {
     NSFetchRequest<_>(entityName: "NMVideo")
    }

    @NSManaged public var defaultPreviewMode: String?
    @NSManaged public var showsDuration: Bool
    @NSManaged public var showsPlayProgress: Bool
    @NSManaged public var appliedVideoShootingSettings: NMVideoShootingSettings?
    @NSManaged public var copies: NSSet?
    @NSManaged public var mixedFolder: NMMixedFolder?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMVideo?
    @NSManaged public var reportsVideoItems: NSSet?
    @NSManaged public var taskVideoBlocks: NSSet?
    @NSManaged public var videoFolder: NMVideoFolder?
    @NSManaged public var videoSnippet: NMVideoSnippet?

}

// MARK: Generated accessors for copies
extension NMVideo {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMVideo)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMVideo)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for reportsVideoItems
extension NMVideo {

    @objc(addReportsVideoItemsObject:)
    @NSManaged public func addToReportsVideoItems(_ value: NMReportVideoContainer)

    @objc(removeReportsVideoItemsObject:)
    @NSManaged public func removeFromReportsVideoItems(_ value: NMReportVideoContainer)

    @objc(addReportsVideoItems:)
    @NSManaged public func addToReportsVideoItems(_ values: NSSet)

    @objc(removeReportsVideoItems:)
    @NSManaged public func removeFromReportsVideoItems(_ values: NSSet)

}

// MARK: Generated accessors for taskVideoBlocks
extension NMVideo {

    @objc(addTaskVideoBlocksObject:)
    @NSManaged public func addToTaskVideoBlocks(_ value: NMTaskVideoBlock)

    @objc(removeTaskVideoBlocksObject:)
    @NSManaged public func removeFromTaskVideoBlocks(_ value: NMTaskVideoBlock)

    @objc(addTaskVideoBlocks:)
    @NSManaged public func addToTaskVideoBlocks(_ values: NSSet)

    @objc(removeTaskVideoBlocks:)
    @NSManaged public func removeFromTaskVideoBlocks(_ values: NSSet)

}
