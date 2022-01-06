//
//  NMTextSnippet+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

extension NMTextSnippet
{
 @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTextSnippet>
 {
  NSFetchRequest<NMTextSnippet>(entityName: "NMTextSnippet")
 }

 @NSManaged public var textElementsPreviewMode: String?
 @NSManaged public var textElementsShowingSymbolsCount: Bool
 @NSManaged public var textFoldersPreviewMode: String?
 @NSManaged public var appliedTextEditingSettings: NMTextEditingSettings?
 @NSManaged public var copies: NSSet?
 @NSManaged public var original: NMTextSnippet?
 @NSManaged public var textFolders: NSSet?
 @NSManaged public var texts: NSSet?

}

// MARK: Generated accessors for copies
extension NMTextSnippet {

    @objc(addCopiesObject:)
    @NSManaged public func addToCopies(_ value: NMTextSnippet)

    @objc(removeCopiesObject:)
    @NSManaged public func removeFromCopies(_ value: NMTextSnippet)

    @objc(addCopies:)
    @NSManaged public func addToCopies(_ values: NSSet)

    @objc(removeCopies:)
    @NSManaged public func removeFromCopies(_ values: NSSet)

}

// MARK: Generated accessors for textFolders
extension NMTextSnippet {

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
extension NMTextSnippet {

    @objc(addTextsObject:)
    @NSManaged public func addToTexts(_ value: NMText)

    @objc(removeTextsObject:)
    @NSManaged public func removeFromTexts(_ value: NMText)

    @objc(addTexts:)
    @NSManaged public func addToTexts(_ values: NSSet)

    @objc(removeTexts:)
    @NSManaged public func removeFromTexts(_ values: NSSet)

}
