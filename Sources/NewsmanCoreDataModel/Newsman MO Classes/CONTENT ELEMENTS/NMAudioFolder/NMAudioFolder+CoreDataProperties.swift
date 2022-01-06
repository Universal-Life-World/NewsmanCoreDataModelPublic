//
//  NMAudioFolder+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMAudioFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMAudioFolder> {
        return NSFetchRequest<NMAudioFolder>(entityName: "NMAudioFolder")
    }

    @NSManaged public var defaultContentPreviewMode: String?
    @NSManaged public var appliedAudioRecordingSettings: NMAudioRecordingSettings?
    @NSManaged public var audioSnippet: NMAudioSnippet?
    @NSManaged public var copies: NSSet?
    @NSManaged public var folderedAudios: NSSet?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMAudioFolder?

}

// MARK: Generated accessors for copies
extension NMAudioFolder {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMAudioFolder)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMAudioFolder)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for folderedAudios
extension NMAudioFolder {

    @objc(addFolderedAudiosObject:)
    @NSManaged public func addToFolderedAudios(_ value: NMAudio)

    @objc(removeFolderedAudiosObject:)
    @NSManaged public func removeFromFolderedAudios(_ value: NMAudio)

    @objc(addFolderedAudios:)
    @NSManaged public func addToFolderedAudios(_ values: NSSet)

    @objc(removeFolderedAudios:)
    @NSManaged public func removeFromFolderedAudios(_ values: NSSet)

}
