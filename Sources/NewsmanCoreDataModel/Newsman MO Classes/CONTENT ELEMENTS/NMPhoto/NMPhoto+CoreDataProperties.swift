//
//  NMPhoto+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMPhoto> {
        return NSFetchRequest<NMPhoto>(entityName: "NMPhoto")
    }

    @NSManaged public var defaultPictureQualityType: String?
    @NSManaged public var showsCaptureQuality: Bool
    @NSManaged public var showsCaptureTimeStamp: Bool
    @NSManaged public var appliedCaptureSettings: NMPhotoCaptureSettings?
    @NSManaged public var copies: NSSet?
    @NSManaged public var mixedFolder: NMMixedFolder?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMPhoto?
    @NSManaged public var photoFolder: NMPhotoFolder?
    @NSManaged public var photoSnippet: NMPhotoSnippet?
    @NSManaged public var reportsPhotoItems: NSSet?
    @NSManaged public var taskPhotoBlocks: NSSet?

}

// MARK: Generated accessors for copies
extension NMPhoto {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMPhoto)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMPhoto)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for reportsPhotoItems
extension NMPhoto {

    @objc(addReportsPhotoItemsObject:)
    @NSManaged public func addToReportsPhotoItems(_ value: NMReportPhotoContainer)

    @objc(removeReportsPhotoItemsObject:)
    @NSManaged public func removeFromReportsPhotoItems(_ value: NMReportPhotoContainer)

    @objc(addReportsPhotoItems:)
    @NSManaged public func addToReportsPhotoItems(_ values: NSSet)

    @objc(removeReportsPhotoItems:)
    @NSManaged public func removeFromReportsPhotoItems(_ values: NSSet)

}

// MARK: Generated accessors for taskPhotoBlocks
extension NMPhoto {

    @objc(addTaskPhotoBlocksObject:)
    @NSManaged public func addToTaskPhotoBlocks(_ value: NMTaskPhotoBlock)

    @objc(removeTaskPhotoBlocksObject:)
    @NSManaged public func removeFromTaskPhotoBlocks(_ value: NMTaskPhotoBlock)

    @objc(addTaskPhotoBlocks:)
    @NSManaged public func addToTaskPhotoBlocks(_ values: NSSet)

    @objc(removeTaskPhotoBlocks:)
    @NSManaged public func removeFromTaskPhotoBlocks(_ values: NSSet)

}
