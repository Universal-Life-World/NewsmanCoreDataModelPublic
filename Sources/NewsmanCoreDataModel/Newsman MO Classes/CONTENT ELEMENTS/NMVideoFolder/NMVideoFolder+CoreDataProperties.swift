//
//  NMVideoFolder+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


@available(iOS 13.0, *)
extension NMVideoFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMVideoFolder> {
        return NSFetchRequest<NMVideoFolder>(entityName: "NMVideoFolder")
    }

    @NSManaged public var defaultContentPreviewMode: String?
    @NSManaged public var appliedVideoShootingSettings: NMVideoShootingSettings?
    @NSManaged public var copies: NSSet?
    @NSManaged public var folderedVideos: NSSet?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMVideoFolder?
    @NSManaged public var videoSnippet: NMVideoSnippet?

}

// MARK: Generated accessors for copies
extension NMVideoFolder {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMVideoFolder)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMVideoFolder)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for folderedVideos
extension NMVideoFolder {

    @objc(addFolderedVideosObject:)
    @NSManaged public func addToFolderedVideos(_ value: NMVideo)

    @objc(removeFolderedVideosObject:)
    @NSManaged public func removeFromFolderedVideos(_ value: NMVideo)

    @objc(addFolderedVideos:)
    @NSManaged public func addToFolderedVideos(_ values: NSSet)

    @objc(removeFolderedVideos:)
    @NSManaged public func removeFromFolderedVideos(_ values: NSSet)

}
