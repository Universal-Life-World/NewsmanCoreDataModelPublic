//
//  NMPhotoSnippet+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMPhotoSnippet
{
 @nonobjc public class func fetchRequest() -> NSFetchRequest<NMPhotoSnippet>
 {
  NSFetchRequest<NMPhotoSnippet>(entityName: "NMPhotoSnippet")
 }

 @NSManaged public var photoElementsPictureQualityType: String?
 @NSManaged public var photoElementsShowsPictureQuality: Bool
 @NSManaged public var photoElementsShowsTimeStamp: Bool
 @NSManaged public var photoFoldersPreviewMode: String?
 @NSManaged public var appliedCaptureSettings: NMPhotoCaptureSettings?
 @NSManaged public var copies: NSSet?
 @NSManaged public var original: NMPhotoSnippet?
 @NSManaged public var photoFolders: NSSet?
 @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for copies
extension NMPhotoSnippet {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMPhotoSnippet)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMPhotoSnippet)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for photoFolders
extension NMPhotoSnippet {

    @objc(addPhotoFoldersObject:)
    @NSManaged public func addToPhotoFolders(_ value: NMPhotoFolder)

    @objc(removePhotoFoldersObject:)
    @NSManaged public func removeFromPhotoFolders(_ value: NMPhotoFolder)

    @objc(addPhotoFolders:)
    @NSManaged public func addToPhotoFolders(_ values: NSSet)

    @objc(removePhotoFolders:)
    @NSManaged public func removeFromPhotoFolders(_ values: NSSet)

}

// MARK: Generated accessors for photos
extension NMPhotoSnippet {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: NMPhoto)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: NMPhoto)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
