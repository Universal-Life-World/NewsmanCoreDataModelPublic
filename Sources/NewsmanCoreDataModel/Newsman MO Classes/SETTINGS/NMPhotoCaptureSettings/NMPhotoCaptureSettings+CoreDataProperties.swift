//
//  NMPhotoCaptureSettings+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMPhotoCaptureSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMPhotoCaptureSettings> {
        return NSFetchRequest<NMPhotoCaptureSettings>(entityName: "NMPhotoCaptureSettings")
    }

    @NSManaged public var appliedToMixedFolders: NSSet?
    @NSManaged public var appliedToMixedSnippets: NSSet?
    @NSManaged public var appliedToPhotoFolders: NSSet?
    @NSManaged public var appliedToPhotos: NSSet?
    @NSManaged public var appliedToPhotoSnippets: NSSet?

}

// MARK: Generated accessors for appliedToMixedFolders
extension NMPhotoCaptureSettings {

    @objc(addAppliedToMixedFoldersObject:)
    @NSManaged public func addToAppliedToMixedFolders(_ value: NMMixedFolder)

    @objc(removeAppliedToMixedFoldersObject:)
    @NSManaged public func removeFromAppliedToMixedFolders(_ value: NMMixedFolder)

    @objc(addAppliedToMixedFolders:)
    @NSManaged public func addToAppliedToMixedFolders(_ values: NSSet)

    @objc(removeAppliedToMixedFolders:)
    @NSManaged public func removeFromAppliedToMixedFolders(_ values: NSSet)

}

// MARK: Generated accessors for appliedToMixedSnippets
@available(iOS 13.0, *)
extension NMPhotoCaptureSettings {

    @objc(addAppliedToMixedSnippetsObject:)
    @NSManaged public func addToAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(removeAppliedToMixedSnippetsObject:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(addAppliedToMixedSnippets:)
    @NSManaged public func addToAppliedToMixedSnippets(_ values: NSSet)

    @objc(removeAppliedToMixedSnippets:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ values: NSSet)

}

// MARK: Generated accessors for appliedToPhotoFolders
extension NMPhotoCaptureSettings {

    @objc(addAppliedToPhotoFoldersObject:)
    @NSManaged public func addToAppliedToPhotoFolders(_ value: NMPhotoFolder)

    @objc(removeAppliedToPhotoFoldersObject:)
    @NSManaged public func removeFromAppliedToPhotoFolders(_ value: NMPhotoFolder)

    @objc(addAppliedToPhotoFolders:)
    @NSManaged public func addToAppliedToPhotoFolders(_ values: NSSet)

    @objc(removeAppliedToPhotoFolders:)
    @NSManaged public func removeFromAppliedToPhotoFolders(_ values: NSSet)

}

// MARK: Generated accessors for appliedToPhotos
extension NMPhotoCaptureSettings {

    @objc(addAppliedToPhotosObject:)
    @NSManaged public func addToAppliedToPhotos(_ value: NMPhoto)

    @objc(removeAppliedToPhotosObject:)
    @NSManaged public func removeFromAppliedToPhotos(_ value: NMPhoto)

    @objc(addAppliedToPhotos:)
    @NSManaged public func addToAppliedToPhotos(_ values: NSSet)

    @objc(removeAppliedToPhotos:)
    @NSManaged public func removeFromAppliedToPhotos(_ values: NSSet)

}

 // MARK: Generated accessors for appliedToPhotoSnippets
@available(iOS 13.0, *)
extension NMPhotoCaptureSettings {

    @objc(addAppliedToPhotoSnippetsObject:)
    @NSManaged public func addToAppliedToPhotoSnippets(_ value: NMPhotoSnippet)

    @objc(removeAppliedToPhotoSnippetsObject:)
    @NSManaged public func removeFromAppliedToPhotoSnippets(_ value: NMPhotoSnippet)

    @objc(addAppliedToPhotoSnippets:)
    @NSManaged public func addToAppliedToPhotoSnippets(_ values: NSSet)

    @objc(removeAppliedToPhotoSnippets:)
    @NSManaged public func removeFromAppliedToPhotoSnippets(_ values: NSSet)

}
