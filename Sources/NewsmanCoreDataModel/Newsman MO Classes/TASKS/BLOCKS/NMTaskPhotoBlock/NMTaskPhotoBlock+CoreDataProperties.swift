//
//  NMTaskPhotoBlock+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTaskPhotoBlock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTaskPhotoBlock> {
        return NSFetchRequest<NMTaskPhotoBlock>(entityName: "NMTaskPhotoBlock")
    }

    @NSManaged public var photos: NSSet?
    @NSManaged public var task: NMTask?

}

// MARK: Generated accessors for photos
extension NMTaskPhotoBlock {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: NMPhoto)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: NMPhoto)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
