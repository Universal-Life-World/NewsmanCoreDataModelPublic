//
//  NMTextEditingSettings+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTextEditingSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTextEditingSettings> {
        return NSFetchRequest<NMTextEditingSettings>(entityName: "NMTextEditingSettings")
    }

    @NSManaged public var appliedToMixedFolders: NSSet?
    @NSManaged public var appliedToMixedSnippets: NSSet?
    @NSManaged public var appliedToTextFolders: NSSet?
    @NSManaged public var appliedToTexts: NSSet?
    @NSManaged public var appliedToTextSnippets: NSSet?

}

// MARK: Generated accessors for appliedToMixedFolders
extension NMTextEditingSettings {

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
extension NMTextEditingSettings {

    @objc(addAppliedToMixedSnippetsObject:)
    @NSManaged public func addToAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(removeAppliedToMixedSnippetsObject:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ value: NMMixedSnippet)

    @objc(addAppliedToMixedSnippets:)
    @NSManaged public func addToAppliedToMixedSnippets(_ values: NSSet)

    @objc(removeAppliedToMixedSnippets:)
    @NSManaged public func removeFromAppliedToMixedSnippets(_ values: NSSet)

}

// MARK: Generated accessors for appliedToTextFolders
extension NMTextEditingSettings {

    @objc(addAppliedToTextFoldersObject:)
    @NSManaged public func addToAppliedToTextFolders(_ value: NMTextFolder)

    @objc(removeAppliedToTextFoldersObject:)
    @NSManaged public func removeFromAppliedToTextFolders(_ value: NMTextFolder)

    @objc(addAppliedToTextFolders:)
    @NSManaged public func addToAppliedToTextFolders(_ values: NSSet)

    @objc(removeAppliedToTextFolders:)
    @NSManaged public func removeFromAppliedToTextFolders(_ values: NSSet)

}

// MARK: Generated accessors for appliedToTexts
extension NMTextEditingSettings {

    @objc(addAppliedToTextsObject:)
    @NSManaged public func addToAppliedToTexts(_ value: NMText)

    @objc(removeAppliedToTextsObject:)
    @NSManaged public func removeFromAppliedToTexts(_ value: NMText)

    @objc(addAppliedToTexts:)
    @NSManaged public func addToAppliedToTexts(_ values: NSSet)

    @objc(removeAppliedToTexts:)
    @NSManaged public func removeFromAppliedToTexts(_ values: NSSet)

}

// MARK: Generated accessors for appliedToTextSnippets
extension NMTextEditingSettings {

    @objc(addAppliedToTextSnippetsObject:)
    @NSManaged public func addToAppliedToTextSnippets(_ value: NMTextSnippet)

    @objc(removeAppliedToTextSnippetsObject:)
    @NSManaged public func removeFromAppliedToTextSnippets(_ value: NMTextSnippet)

    @objc(addAppliedToTextSnippets:)
    @NSManaged public func addToAppliedToTextSnippets(_ values: NSSet)

    @objc(removeAppliedToTextSnippets:)
    @NSManaged public func removeFromAppliedToTextSnippets(_ values: NSSet)

}
