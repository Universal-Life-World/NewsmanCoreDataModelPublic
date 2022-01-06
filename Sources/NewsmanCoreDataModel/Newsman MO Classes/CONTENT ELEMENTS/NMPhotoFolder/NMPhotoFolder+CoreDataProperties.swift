//
//  NMPhotoFolder+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMPhotoFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMPhotoFolder> {
        return NSFetchRequest<NMPhotoFolder>(entityName: "NMPhotoFolder")
    }

    @NSManaged public var defaultContentPreviewMode: String?
    @NSManaged public var appliedCaptureSettings: NMPhotoCaptureSettings?
    @NSManaged public var copies: NSSet?
    @NSManaged public var folderedPhotos: NSSet?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMPhotoFolder?
    @NSManaged public var photoSnippet: NMPhotoSnippet?

}

// MARK: Generated accessors for copies
extension NMPhotoFolder {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMPhotoFolder)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMPhotoFolder)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for folderedPhotos
extension NMPhotoFolder {

    @objc(addFolderedPhotosObject:)
    @NSManaged public func addToFolderedPhotos(_ value: NMPhoto)

    @objc(removeFolderedPhotosObject:)
    @NSManaged public func removeFromFolderedPhotos(_ value: NMPhoto)

    @objc(addFolderedPhotos:)
    @NSManaged public func addToFolderedPhotos(_ values: NSSet)

    @objc(removeFolderedPhotos:)
    @NSManaged public func removeFromFolderedPhotos(_ values: NSSet)

}
