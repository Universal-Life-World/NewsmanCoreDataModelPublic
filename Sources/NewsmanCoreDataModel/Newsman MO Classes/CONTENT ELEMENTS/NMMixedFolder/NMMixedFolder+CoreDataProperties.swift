//
//  NMMixedFolder+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMMixedFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMMixedFolder> {
        return NSFetchRequest<NMMixedFolder>(entityName: "NMMixedFolder")
    }

    @NSManaged public var appliedAudioRecordingSettings: NMAudioRecordingSettings?
    @NSManaged public var appliedPhotoCaptureSettings: NMPhotoCaptureSettings?
    @NSManaged public var appliedTextEditingSettings: NMTextEditingSettings?
    @NSManaged public var appliedVideoShootingSettings: NMVideoShootingSettings?
    @NSManaged public var copies: NSSet?
    @NSManaged public var folderedAudios: NSSet?
    @NSManaged public var folderedPhotos: NSSet?
    @NSManaged public var folderedTexts: NSSet?
    @NSManaged public var folderedVideos: NSSet?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMMixedFolder?

}

// MARK: Generated accessors for copies
extension NMMixedFolder {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMMixedFolder)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMMixedFolder)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for folderedAudios
extension NMMixedFolder {

    @objc(addFolderedAudiosObject:)
    @NSManaged public func addToFolderedAudios(_ value: NMAudio)

    @objc(removeFolderedAudiosObject:)
    @NSManaged public func removeFromFolderedAudios(_ value: NMAudio)

    @objc(addFolderedAudios:)
    @NSManaged public func addToFolderedAudios(_ values: NSSet)

    @objc(removeFolderedAudios:)
    @NSManaged public func removeFromFolderedAudios(_ values: NSSet)

}

// MARK: Generated accessors for folderedPhotos
extension NMMixedFolder {

    @objc(addFolderedPhotosObject:)
    @NSManaged public func addToFolderedPhotos(_ value: NMPhoto)

    @objc(removeFolderedPhotosObject:)
    @NSManaged public func removeFromFolderedPhotos(_ value: NMPhoto)

    @objc(addFolderedPhotos:)
    @NSManaged public func addToFolderedPhotos(_ values: NSSet)

    @objc(removeFolderedPhotos:)
    @NSManaged public func removeFromFolderedPhotos(_ values: NSSet)

}

// MARK: Generated accessors for folderedTexts
extension NMMixedFolder {

    @objc(addFolderedTextsObject:)
    @NSManaged public func addToFolderedTexts(_ value: NMText)

    @objc(removeFolderedTextsObject:)
    @NSManaged public func removeFromFolderedTexts(_ value: NMText)

    @objc(addFolderedTexts:)
    @NSManaged public func addToFolderedTexts(_ values: NSSet)

    @objc(removeFolderedTexts:)
    @NSManaged public func removeFromFolderedTexts(_ values: NSSet)

}

// MARK: Generated accessors for folderedVideos
extension NMMixedFolder {

    @objc(addFolderedVideosObject:)
    @NSManaged public func addToFolderedVideos(_ value: NMVideo)

    @objc(removeFolderedVideosObject:)
    @NSManaged public func removeFromFolderedVideos(_ value: NMVideo)

    @objc(addFolderedVideos:)
    @NSManaged public func addToFolderedVideos(_ values: NSSet)

    @objc(removeFolderedVideos:)
    @NSManaged public func removeFromFolderedVideos(_ values: NSSet)

}
