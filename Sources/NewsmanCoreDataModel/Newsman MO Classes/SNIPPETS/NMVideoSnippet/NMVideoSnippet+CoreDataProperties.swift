//
//  NMVideoSnippet+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

extension NMVideoSnippet
{
 @nonobjc public class func fetchRequest() -> NSFetchRequest<NMVideoSnippet>
 {
  NSFetchRequest<NMVideoSnippet>(entityName: "NMVideoSnippet")
 }
 
 //***************************************************************************
 // MARK: Properties for modeled relationships:
 //***************************************************************************
 @NSManaged public var appliedVideoShootingSettings: NMVideoShootingSettings?
 @NSManaged public var original: NMVideoSnippet?
 @NSManaged public var copies: NSSet?
 @NSManaged public var videoFolders: NSSet?
 @NSManaged public var videos: NSSet?
 //***************************************************************************

 //***************************************************************************
 // MARK: Properties for modeled attributes:
 //***************************************************************************
 @NSManaged public var videoElementsPreviewMode: String?
 @NSManaged public var videoElementsShowsDuration: Bool
 @NSManaged public var videoElementsShowsPlayProgress: Bool
 @NSManaged public var videoFoldersPreviewMode: String?
  //***************************************************************************
 
}

//***************************************************************************
// MARK: Generated accessors for copies
//***************************************************************************
extension NMVideoSnippet {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMVideoSnippet)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMVideoSnippet)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for videoFolders
extension NMVideoSnippet {

    @objc(addVideoFoldersObject:)
    @NSManaged public func addToVideoFolders(_ value: NMVideoFolder)

    @objc(removeVideoFoldersObject:)
    @NSManaged public func removeFromVideoFolders(_ value: NMVideoFolder)

    @objc(addVideoFolders:)
    @NSManaged public func addToVideoFolders(_ values: NSSet)

    @objc(removeVideoFolders:)
    @NSManaged public func removeFromVideoFolders(_ values: NSSet)

}

// MARK: Generated accessors for videos
extension NMVideoSnippet {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: NMVideo)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: NMVideo)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}
