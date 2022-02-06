//
//  NMAudioRecordingSettings+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMAudioRecordingSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMAudioRecordingSettings> {
        return NSFetchRequest<NMAudioRecordingSettings>(entityName: "NMAudioRecordingSettings")
    }

    @NSManaged public var appliedToAudioFolders: NSSet?
    @NSManaged public var appliedToAudios: NSSet?
    @NSManaged public var appliedToAudioSnippets: NSSet?
    @NSManaged public var appliedToMixedFolders: NSSet?
    @NSManaged public var appliedToMixedSnippets: NSSet?

}

// MARK: Generated accessors for appliedToAudioFolders
extension NMAudioRecordingSettings {

    @objc(addAppliedToAudioFoldersObject:)
    @NSManaged public func addToAppliedToAudioFolders(_ value: NMAudioFolder)

    @objc(removeAppliedToAudioFoldersObject:)
    @NSManaged public func removeFromAppliedToAudioFolders(_ value: NMAudioFolder)

    @objc(addAppliedToAudioFolders:)
    @NSManaged public func addToAppliedToAudioFolders(_ values: NSSet)

    @objc(removeAppliedToAudioFolders:)
    @NSManaged public func removeFromAppliedToAudioFolders(_ values: NSSet)

}

// MARK: Generated accessors for appliedToAudios
extension NMAudioRecordingSettings {

    @objc(addAppliedToAudiosObject:)
    @NSManaged public func addToAppliedToAudios(_ value: NMAudio)

    @objc(removeAppliedToAudiosObject:)
    @NSManaged public func removeFromAppliedToAudios(_ value: NMAudio)

    @objc(addAppliedToAudios:)
    @NSManaged public func addToAppliedToAudios(_ values: NSSet)

    @objc(removeAppliedToAudios:)
    @NSManaged public func removeFromAppliedToAudios(_ values: NSSet)

}

// MARK: Generated accessors for appliedToAudioSnippets
@available(iOS 13.0, *)
extension NMAudioRecordingSettings {

    @objc(addAppliedToAudioSnippetsObject:)
    @NSManaged public func addToAppliedToAudioSnippets(_ value: NMAudioSnippet)

    @objc(removeAppliedToAudioSnippetsObject:)
    @NSManaged public func removeFromAppliedToAudioSnippets(_ value: NMAudioSnippet)

    @objc(addAppliedToAudioSnippets:)
    @NSManaged public func addToAppliedToAudioSnippets(_ values: NSSet)

    @objc(removeAppliedToAudioSnippets:)
    @NSManaged public func removeFromAppliedToAudioSnippets(_ values: NSSet)

}

// MARK: Generated accessors for appliedToMixedFolders
extension NMAudioRecordingSettings {

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
extension NMAudioRecordingSettings {

    @objc(addAppliedToMixedSnippetsObject:)
    @NSManaged public func addToAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(removeAppliedToMixedSnippetsObject:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(addAppliedToMixedSnippets:)
    @NSManaged public func addToAppliedToMixedSnippets(_ values: NSSet)

    @objc(removeAppliedToMixedSnippets:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ values: NSSet)

}
