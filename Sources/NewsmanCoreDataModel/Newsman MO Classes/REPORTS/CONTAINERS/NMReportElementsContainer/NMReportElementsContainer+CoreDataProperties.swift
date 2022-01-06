//
//  NMReportElementsContainer+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMReportElementsContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportElementsContainer> {
        return NSFetchRequest<NMReportElementsContainer>(entityName: "NMReportElementsContainer")
    }

    @NSManaged public var audioContainers: NSSet?
    @NSManaged public var report: NMReport?
    @NSManaged public var videoContainers: NSSet?
    @NSManaged public var textContainers: NSSet?
    @NSManaged public var photoContainers: NSSet?
    @NSManaged public var childContainers: NSSet?
    @NSManaged public var parentContainer: NMReportElementsContainer?
    @NSManaged public var template: NMReportContainerTemplate?

}

// MARK: Generated accessors for audioContainers
extension NMReportElementsContainer {

    @objc(addAudioContainersObject:)
    @NSManaged public func addToAudioContainers(_ value: NMReportAudioContainer)

    @objc(removeAudioContainersObject:)
    @NSManaged public func removeFromAudioContainers(_ value: NMReportAudioContainer)

    @objc(addAudioContainers:)
    @NSManaged public func addToAudioContainers(_ values: NSSet)

    @objc(removeAudioContainers:)
    @NSManaged public func removeFromAudioContainers(_ values: NSSet)

}

// MARK: Generated accessors for videoContainers
extension NMReportElementsContainer {

    @objc(addVideoContainersObject:)
    @NSManaged public func addToVideoContainers(_ value: NMReportVideoContainer)

    @objc(removeVideoContainersObject:)
    @NSManaged public func removeFromVideoContainers(_ value: NMReportVideoContainer)

    @objc(addVideoContainers:)
    @NSManaged public func addToVideoContainers(_ values: NSSet)

    @objc(removeVideoContainers:)
    @NSManaged public func removeFromVideoContainers(_ values: NSSet)

}

// MARK: Generated accessors for textContainers
extension NMReportElementsContainer {

    @objc(addTextContainersObject:)
    @NSManaged public func addToTextContainers(_ value: NMReportTextContainer)

    @objc(removeTextContainersObject:)
    @NSManaged public func removeFromTextContainers(_ value: NMReportTextContainer)

    @objc(addTextContainers:)
    @NSManaged public func addToTextContainers(_ values: NSSet)

    @objc(removeTextContainers:)
    @NSManaged public func removeFromTextContainers(_ values: NSSet)

}

// MARK: Generated accessors for photoContainers
extension NMReportElementsContainer {

    @objc(addPhotoContainersObject:)
    @NSManaged public func addToPhotoContainers(_ value: NMReportPhotoContainer)

    @objc(removePhotoContainersObject:)
    @NSManaged public func removeFromPhotoContainers(_ value: NMReportPhotoContainer)

    @objc(addPhotoContainers:)
    @NSManaged public func addToPhotoContainers(_ values: NSSet)

    @objc(removePhotoContainers:)
    @NSManaged public func removeFromPhotoContainers(_ values: NSSet)

}

// MARK: Generated accessors for childContainers
extension NMReportElementsContainer {

    @objc(addChildContainersObject:)
    @NSManaged public func addToChildContainers(_ value: NMReportElementsContainer)

    @objc(removeChildContainersObject:)
    @NSManaged public func removeFromChildContainers(_ value: NMReportElementsContainer)

    @objc(addChildContainers:)
    @NSManaged public func addToChildContainers(_ values: NSSet)

    @objc(removeChildContainers:)
    @NSManaged public func removeFromChildContainers(_ values: NSSet)

}
