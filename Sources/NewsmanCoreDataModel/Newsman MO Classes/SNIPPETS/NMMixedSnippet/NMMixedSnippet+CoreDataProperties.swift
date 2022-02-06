//
//  NMMixedSnippet+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


@available(iOS 13.0, *)
extension NMMixedSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMMixedSnippet> {
        return NSFetchRequest<NMMixedSnippet>(entityName: "NMMixedSnippet")
    }

    @NSManaged public var audioElementsPreviewMode: String?
    @NSManaged public var audioElementsShowsDuration: Bool
    @NSManaged public var audioElementsShowsPlayProgress: Bool
    @NSManaged public var audioFoldersPreviewMode: String?
    @NSManaged public var photoElementsPictureQualityType: String?
    @NSManaged public var photoElementsShowsPictureQuality: Bool
    @NSManaged public var photoElementsShowsTimeStamp: Bool
    @NSManaged public var photoFoldersPreviewMode: String?
    @NSManaged public var textElementsPreviewMode: String?
    @NSManaged public var textElementsShowingSymbolsCount: Bool
    @NSManaged public var textFoldersPreviewMode: String?
    @NSManaged public var videoElementsPreviewMode: String?
    @NSManaged public var videoElementsShowsDuration: Bool
    @NSManaged public var videoElementsShowsPlayProgress: Bool
    @NSManaged public var videoFoldersPreviewMode: String?
    @NSManaged public var appliedAudioRecordingSettings: NMAudioRecordingSettings?
    @NSManaged public var appliedPhotoCaptureSettings: NMPhotoCaptureSettings?
    @NSManaged public var appliedTextEditingSettings: NMTextEditingSettings?
    @NSManaged public var appliedVideoShootingSettings: NMVideoShootingSettings?
    @NSManaged public var audioFolders: NSSet?
    @NSManaged public var audios: NSSet?
    @NSManaged public var copies: NSSet?
    @NSManaged public var mixedFolders: NSSet?
    @NSManaged public var original: NMMixedSnippet?
    @NSManaged public var photoFolders: NSSet?
    @NSManaged public var photos: NSSet?
    @NSManaged public var textFolders: NSSet?
    @NSManaged public var texts: NSSet?
    @NSManaged public var videoFolders: NSSet?
    @NSManaged public var videos: NSSet?

}

 // MARK: Generated accessors for audioFolders
@available(iOS 13.0, *)
extension NMMixedSnippet {

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
extension NMMixedSnippet {

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
extension NMMixedSnippet {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMMixedSnippet)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMMixedSnippet)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for mixedFolders
@available(iOS 13.0, *)
extension NMMixedSnippet {

    @objc(addMixedFoldersObject:)
    @NSManaged public func addToMixedFolders(_ value: NMMixedFolder)

    @objc(removeMixedFoldersObject:)
    @NSManaged public func removeFromMixedFolders(_ value: NMMixedFolder)

    @objc(addMixedFolders:)
    @NSManaged public func addToMixedFolders(_ values: NSSet)

    @objc(removeMixedFolders:)
    @NSManaged public func removeFromMixedFolders(_ values: NSSet)

}

// MARK: Generated accessors for photoFolders
@available(iOS 13.0, *)
extension NMMixedSnippet {

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
@available(iOS 13.0, *)
extension NMMixedSnippet {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: NMPhoto)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: NMPhoto)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

// MARK: Generated accessors for textFolders
@available(iOS 13.0, *)
extension NMMixedSnippet {

    @objc(addTextFoldersObject:)
    @NSManaged public func addToTextFolders(_ value: NMTextFolder)

    @objc(removeTextFoldersObject:)
    @NSManaged public func removeFromTextFolders(_ value: NMTextFolder)

    @objc(addTextFolders:)
    @NSManaged public func addToTextFolders(_ values: NSSet)

    @objc(removeTextFolders:)
    @NSManaged public func removeFromTextFolders(_ values: NSSet)

}

// MARK: Generated accessors for texts
@available(iOS 13.0, *)
extension NMMixedSnippet {

    @objc(addTextsObject:)
    @NSManaged public func addToTexts(_ value: NMText)

    @objc(removeTextsObject:)
    @NSManaged public func removeFromTexts(_ value: NMText)

    @objc(addTexts:)
    @NSManaged public func addToTexts(_ values: NSSet)

    @objc(removeTexts:)
    @NSManaged public func removeFromTexts(_ values: NSSet)

}

// MARK: Generated accessors for videoFolders
@available(iOS 13.0, *)
extension NMMixedSnippet {

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
@available(iOS 13.0, *)
extension NMMixedSnippet {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: NMVideo)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: NMVideo)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}
