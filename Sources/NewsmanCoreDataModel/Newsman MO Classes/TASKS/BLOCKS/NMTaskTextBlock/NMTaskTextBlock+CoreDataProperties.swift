//
//  NMTaskTextBlock+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTaskTextBlock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTaskTextBlock> {
        return NSFetchRequest<NMTaskTextBlock>(entityName: "NMTaskTextBlock")
    }

    @NSManaged public var task: NMTask?
    @NSManaged public var texts: NSSet?

}

// MARK: Generated accessors for texts
extension NMTaskTextBlock {

    @objc(addTextsObject:)
    @NSManaged public func addToTexts(_ value: NMText)

    @objc(removeTextsObject:)
    @NSManaged public func removeFromTexts(_ value: NMText)

    @objc(addTexts:)
    @NSManaged public func addToTexts(_ values: NSSet)

    @objc(removeTexts:)
    @NSManaged public func removeFromTexts(_ values: NSSet)

}
