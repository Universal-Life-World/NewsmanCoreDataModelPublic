//
//  NMTextFolder+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTextFolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTextFolder> {
        return NSFetchRequest<NMTextFolder>(entityName: "NMTextFolder")
    }

    @NSManaged public var defaultContentPreviewMode: String?
    @NSManaged public var appliedTextEditingSettings: NMTextEditingSettings?
    @NSManaged public var copies: NSSet?
    @NSManaged public var folderedTexts: NSSet?
    @NSManaged public var mixedSnippet: NMMixedSnippet?
    @NSManaged public var original: NMTextFolder?
    @NSManaged public var textSnippet: NMTextSnippet?

}

// MARK: Generated accessors for copies
extension NMTextFolder {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMTextFolder)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMTextFolder)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for folderedTexts
extension NMTextFolder {

    @objc(addFolderedTextsObject:)
    @NSManaged public func addToFolderedTexts(_ value: NMText)

    @objc(removeFolderedTextsObject:)
    @NSManaged public func removeFromFolderedTexts(_ value: NMText)

    @objc(addFolderedTexts:)
    @NSManaged public func addToFolderedTexts(_ values: NSSet)

    @objc(removeFolderedTexts:)
    @NSManaged public func removeFromFolderedTexts(_ values: NSSet)

}
