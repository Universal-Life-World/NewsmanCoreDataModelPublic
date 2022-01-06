//
//  NMReport+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMReport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReport> {
        return NSFetchRequest<NMReport>(entityName: "NMReport")
    }

    @NSManaged public var about: String?
    @NSManaged public var archivedTimeStamp: Date?
    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var dateSearchFormatIndex: String?
    @NSManaged public var hiddenSectionsBitset: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isCopyable: Bool
    @NSManaged public var isDeletable: Bool
    @NSManaged public var isDragAnimating: Bool
    @NSManaged public var isDraggable: Bool
    @NSManaged public var isEditable: Bool
    @NSManaged public var isHiddenFromSection: Bool
    @NSManaged public var isHideableFromSection: Bool
    @NSManaged public var isMergeable: Bool
    @NSManaged public var isPublishable: Bool
    @NSManaged public var isRateable: Bool
    @NSManaged public var isSharable: Bool
    @NSManaged public var isTrashable: Bool
    @NSManaged public var lastAccessedTimeStamp: Date?
    @NSManaged public var lastModifiedTimeStamp: Date?
    @NSManaged public var lastRatedTimeStamp: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var longitude: Double
    @NSManaged public var nameTag: String?
    @NSManaged public var priority: String?
    @NSManaged public var publishedTimeStamp: Date?
    @NSManaged public var rate: Double
    @NSManaged public var ratedCount: Int64
    @NSManaged public var sectionAlphaIndex: String?
    @NSManaged public var sectionDateIndex: String?
    @NSManaged public var sectionPriorityIndex: String?
    @NSManaged public var status: String?
    @NSManaged public var trashedTimeStamp: Date?
    @NSManaged public var topLevelContainer: NMReportElementsContainer?
    @NSManaged public var connectedWithTopNews: NSSet?
    @NSManaged public var copies: NSSet?
    @NSManaged public var original: NMReport?
    @NSManaged public var taskReportBlocks: NSSet?

}

// MARK: Generated accessors for connectedWithTopNews
extension NMReport {

    @objc(addConnectedWithTopNewsObject:)
    @NSManaged public func addToConnectedWithTopNews(_ value: NMTopNews)

    @objc(removeConnectedWithTopNewsObject:)
    @NSManaged public func removeFromConnectedWithTopNews(_ value: NMTopNews)

    @objc(addConnectedWithTopNews:)
    @NSManaged public func addToConnectedWithTopNews(_ values: NSSet)

    @objc(removeConnectedWithTopNews:)
    @NSManaged public func removeFromConnectedWithTopNews(_ values: NSSet)

}

// MARK: Generated accessors for copies
extension NMReport {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMReport)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMReport)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for taskReportBlocks
extension NMReport {

    @objc(addTaskReportBlocksObject:)
    @NSManaged public func addToTaskReportBlocks(_ value: NMTaskReportBlock)

    @objc(removeTaskReportBlocksObject:)
    @NSManaged public func removeFromTaskReportBlocks(_ value: NMTaskReportBlock)

    @objc(addTaskReportBlocks:)
    @NSManaged public func addToTaskReportBlocks(_ values: NSSet)

    @objc(removeTaskReportBlocks:)
    @NSManaged public func removeFromTaskReportBlocks(_ values: NSSet)

}
