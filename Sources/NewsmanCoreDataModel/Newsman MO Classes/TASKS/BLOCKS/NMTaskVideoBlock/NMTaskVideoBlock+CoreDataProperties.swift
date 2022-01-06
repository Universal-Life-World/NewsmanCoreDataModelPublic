//
//  NMTaskVideoBlock+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTaskVideoBlock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTaskVideoBlock> {
        return NSFetchRequest<NMTaskVideoBlock>(entityName: "NMTaskVideoBlock")
    }

    @NSManaged public var task: NMTask?
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for videos
extension NMTaskVideoBlock {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: NMVideo)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: NMVideo)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}
