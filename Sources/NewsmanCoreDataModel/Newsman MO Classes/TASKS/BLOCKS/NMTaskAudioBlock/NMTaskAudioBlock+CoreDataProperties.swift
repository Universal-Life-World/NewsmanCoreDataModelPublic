//
//  NMTaskAudioBlock+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTaskAudioBlock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTaskAudioBlock> {
        return NSFetchRequest<NMTaskAudioBlock>(entityName: "NMTaskAudioBlock")
    }

    @NSManaged public var audios: NSSet?
    @NSManaged public var task: NMTask?

}

// MARK: Generated accessors for audios
extension NMTaskAudioBlock {

    @objc(addAudiosObject:)
    @NSManaged public func addToAudios(_ value: NMAudio)

    @objc(removeAudiosObject:)
    @NSManaged public func removeFromAudios(_ value: NMAudio)

    @objc(addAudios:)
    @NSManaged public func addToAudios(_ values: NSSet)

    @objc(removeAudios:)
    @NSManaged public func removeFromAudios(_ values: NSSet)

}
