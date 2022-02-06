//
//  NMVideoShootingSettings+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMVideoShootingSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMVideoShootingSettings> {
        return NSFetchRequest<NMVideoShootingSettings>(entityName: "NMVideoShootingSettings")
    }

    @NSManaged public var appliedToMixedFolders: NSSet?
    @NSManaged public var appliedToMixedSnippets: NSSet?
    @NSManaged public var appliedToVideoFolders: NSSet?
    @NSManaged public var appliedToVideos: NSSet?
    @NSManaged public var appliedToVideoSnippets: NSSet?

}

// MARK: Generated accessors for appliedToMixedFolders
extension NMVideoShootingSettings {

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
extension NMVideoShootingSettings {

    @objc(addAppliedToMixedSnippetsObject:)
    @NSManaged public func addToAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(removeAppliedToMixedSnippetsObject:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(addAppliedToMixedSnippets:)
    @NSManaged public func addToAppliedToMixedSnippets(_ values: NSSet)

    @objc(removeAppliedToMixedSnippets:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ values: NSSet)

}

// MARK: Generated accessors for appliedToVideoFolders
extension NMVideoShootingSettings {

    @objc(addAppliedToVideoFoldersObject:)
    @NSManaged public func addToAppliedToVideoFolders(_ value: NMVideoFolder)

    @objc(removeAppliedToVideoFoldersObject:)
    @NSManaged public func removeFromAppliedToVideoFolders(_ value: NMVideoFolder)

    @objc(addAppliedToVideoFolders:)
    @NSManaged public func addToAppliedToVideoFolders(_ values: NSSet)

    @objc(removeAppliedToVideoFolders:)
    @NSManaged public func removeFromAppliedToVideoFolders(_ values: NSSet)

}

// MARK: Generated accessors for appliedToVideos
extension NMVideoShootingSettings {

    @objc(addAppliedToVideosObject:)
    @NSManaged public func addToAppliedToVideos(_ value: NMVideo)

    @objc(removeAppliedToVideosObject:)
    @NSManaged public func removeFromAppliedToVideos(_ value: NMVideo)

    @objc(addAppliedToVideos:)
    @NSManaged public func addToAppliedToVideos(_ values: NSSet)

    @objc(removeAppliedToVideos:)
    @NSManaged public func removeFromAppliedToVideos(_ values: NSSet)

}

// MARK: Generated accessors for appliedToVideoSnippets
@available(iOS 13.0, *)
extension NMVideoShootingSettings {

    @objc(addAppliedToVideoSnippetsObject:)
    @NSManaged public func addToAppliedToVideoSnippets(_ value: NMVideoSnippet)

    @objc(removeAppliedToVideoSnippetsObject:)
    @NSManaged public func removeFromAppliedToVideoSnippets(_ value: NMVideoSnippet)

    @objc(addAppliedToVideoSnippets:)
    @NSManaged public func addToAppliedToVideoSnippets(_ values: NSSet)

    @objc(removeAppliedToVideoSnippets:)
    @NSManaged public func removeFromAppliedToVideoSnippets(_ values: NSSet)

}
