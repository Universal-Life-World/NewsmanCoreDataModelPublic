//
//  NMAudioSnippet+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


@available(iOS 13.0, *)
extension NMAudioSnippet
{
  @nonobjc public class func fetchRequest() -> NSFetchRequest<NMAudioSnippet> {
   NSFetchRequest<NMAudioSnippet>(entityName: "NMAudioSnippet")
  }

  @NSManaged public var audioElementsPreviewMode: String?
  @NSManaged public var audioElementsShowsDuration: NSNumber?
  @NSManaged public var audioElementsShowsPlayProgress: Bool
  @NSManaged public var audioFoldersPreviewMode: String?
  @NSManaged public var appliedAudioRecordingSettings: NMAudioRecordingSettings?
  @NSManaged public var audioFolders: NSSet?
  @NSManaged public var audios: NSSet?
  @NSManaged public var copies: NSSet?
  @NSManaged public var original: NMAudioSnippet?

}

// MARK: Generated accessors for audioFolders
@available(iOS 13.0, *)
extension NMAudioSnippet {

    @objc(addAudioFoldersObject:)
    @NSManaged public func addToAudioFolders(_ value: NMAudioFolder)

    @objc(removeAudioFoldersObject:)
    @NSManaged public func removeFromAudioFolders(_ value: NMAudioFolder)

    @objc(addAudioFolders:)
    @NSManaged public func addToAudioFolders(_ values: NSSet)

    @objc(removeAudioFolders:)
    @NSManaged public func removeFromAudioFolders(_ values: NSSet)

}

// MARK: Generated accessors for audios
@available(iOS 13.0, *)
extension NMAudioSnippet {

    @objc(addAudiosObject:)
    @NSManaged public func addToAudios(_ value: NMAudio)

    @objc(removeAudiosObject:)
    @NSManaged public func removeFromAudios(_ value: NMAudio)

    @objc(addAudios:)
    @NSManaged public func addToAudios(_ values: NSSet)

    @objc(removeAudios:)
    @NSManaged public func removeFromAudios(_ values: NSSet)

}



 // MARK: Generated accessors for copies
@available(iOS 13.0, *)
extension NMAudioSnippet {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMAudioSnippet)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMAudioSnippet)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}
