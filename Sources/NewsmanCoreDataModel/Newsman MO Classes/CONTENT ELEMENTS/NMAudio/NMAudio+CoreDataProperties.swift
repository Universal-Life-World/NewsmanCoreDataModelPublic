//
//  NMAudio+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


@available(iOS 13.0, *)
extension NMAudio {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMAudio> {
        return NSFetchRequest<NMAudio>(entityName: "NMAudio")
    }

    @NSManaged public var defaultPreviewMode: String?
    @NSManaged public var showsDuration: Bool
    @NSManaged public var showsPlayProgress: Bool
    @NSManaged public var appliedAudioRecordingSettings: NMAudioRecordingSettings?
    @NSManaged public var audioFolder: NMAudioFolder?
    @NSManaged public var audioSnippet: NMAudioSnippet?
    @NSManaged public var copies: NSSet?
    @NSManaged public var mixedFolder: NMMixedFolder?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMAudio?
    @NSManaged public var reportsAudioItems: NSSet?
    @NSManaged public var taskAudioBlocks: NSSet?

}

// MARK: Generated accessors for copies
extension NMAudio {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMAudio)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMAudio)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for reportsAudioItems
extension NMAudio {

    @objc(addReportsAudioItemsObject:)
    @NSManaged public func addToReportsAudioItems(_ value: NMReportAudioContainer)

    @objc(removeReportsAudioItemsObject:)
    @NSManaged public func removeFromReportsAudioItems(_ value: NMReportAudioContainer)

    @objc(addReportsAudioItems:)
    @NSManaged public func addToReportsAudioItems(_ values: NSSet)

    @objc(removeReportsAudioItems:)
    @NSManaged public func removeFromReportsAudioItems(_ values: NSSet)

}

// MARK: Generated accessors for taskAudioBlocks
extension NMAudio {

    @objc(addTaskAudioBlocksObject:)
    @NSManaged public func addToTaskAudioBlocks(_ value: NMTaskAudioBlock)

    @objc(removeTaskAudioBlocksObject:)
    @NSManaged public func removeFromTaskAudioBlocks(_ value: NMTaskAudioBlock)

    @objc(addTaskAudioBlocks:)
    @NSManaged public func addToTaskAudioBlocks(_ values: NSSet)

    @objc(removeTaskAudioBlocks:)
    @NSManaged public func removeFromTaskAudioBlocks(_ values: NSSet)

}
