//
//  NMText+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


@available(iOS 13.0, *)
extension NMText {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMText> {
        return NSFetchRequest<NMText>(entityName: "NMText")
    }

    @NSManaged public var defaultPreviewMode: String?
    @NSManaged public var showsSymbolsCount: Bool
    @NSManaged public var appliedTextEditingSettings: NMTextEditingSettings?
    @NSManaged public var copies: NSSet?
    @NSManaged public var mixedFolder: NMMixedFolder?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMText?
    @NSManaged public var reportsTextItems: NSSet?
    @NSManaged public var taskTextBlocks: NSSet?
    @NSManaged public var textFolder: NMTextFolder?
    @NSManaged public var textSnippet: NMTextSnippet?

}

// MARK: Generated accessors for copies
extension NMText {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMText)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMText)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for reportsTextItems
extension NMText {

    @objc(addReportsTextItemsObject:)
    @NSManaged public func addToReportsTextItems(_ value: NMReportTextContainer)

    @objc(removeReportsTextItemsObject:)
    @NSManaged public func removeFromReportsTextItems(_ value: NMReportTextContainer)

    @objc(addReportsTextItems:)
    @NSManaged public func addToReportsTextItems(_ values: NSSet)

    @objc(removeReportsTextItems:)
    @NSManaged public func removeFromReportsTextItems(_ values: NSSet)

}

// MARK: Generated accessors for taskTextBlocks
extension NMText {

    @objc(addTaskTextBlocksObject:)
    @NSManaged public func addToTaskTextBlocks(_ value: NMTaskTextBlock)

    @objc(removeTaskTextBlocksObject:)
    @NSManaged public func removeFromTaskTextBlocks(_ value: NMTaskTextBlock)

    @objc(addTaskTextBlocks:)
    @NSManaged public func addToTaskTextBlocks(_ values: NSSet)

    @objc(removeTaskTextBlocks:)
    @NSManaged public func removeFromTaskTextBlocks(_ values: NSSet)

}
