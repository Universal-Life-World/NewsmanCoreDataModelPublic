//
//  NMBaseContent+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

#if !os(macOS)
import UIKit
#else
import AppKit
#endif

extension NMBaseContent
{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMBaseContent>
    {
     NSFetchRequest<NMBaseContent>(entityName: "NMBaseContent")
    }

    @NSManaged public var archivedTimeStamp: Date?
    @NSManaged public var arrowMenuPosition: NSValue?
    @NSManaged public var arrowMenuScaleFactor: Double
    @NSManaged public var arrowMenuTouchPoint: NSValue?
    @NSManaged public var ck_metadata: Data?
 
    #if !os(macOS)
    @NSManaged public var colorFlag: UIColor?
    #else
    @NSManaged public var colorFlag: NSColor?
    #endif
 
    @NSManaged public var date: Date?
    @NSManaged public var hiddenSectionsBitset: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isArrowMenuShowing: Bool
    @NSManaged public var isCopyable: Bool
    @NSManaged public var isDeletable: Bool
    @NSManaged public var isDragAnimating: Bool
    @NSManaged public var isDraggable: Bool
    @NSManaged public var isFolderable: Bool
    @NSManaged public var isHiddenFromSection: Bool
    @NSManaged public var isRateable: Bool
    @NSManaged public var isSelectable: Bool
    @NSManaged public var isSelected: Bool
    @NSManaged public var isTrashable: Bool
    @NSManaged public var lastAccessedTimeStamp: Date?
    @NSManaged public var lastModifiedTimeStamp: Date?
    @NSManaged public var lastRatedTimeStamp: Date?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var location: String?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var positions: NSMutableDictionary?
    @NSManaged public var priority: String?
    @NSManaged public var publishedTimeStamp: Date?
    @NSManaged public var ratedCount: Int64
    @NSManaged public var rating: Double
    //@NSManaged public var status: String? get/set using primitive
    //@NSManaged public var tag: String? get/set using primitive 
    @NSManaged public var trashedTimeStamp: Date?
    @NSManaged public var type: Int16
    @NSManaged public var attachedToChatItems: NSSet?
    @NSManaged public var connectedWithTopNews: NSSet?

}

// MARK: Generated accessors for attachedToChatItems
extension NMBaseContent {

    @objc(addAttachedToChatItemsObject:)
    @NSManaged public func addToAttachedToChatItems(_ value: NMChatItem)

    @objc(removeAttachedToChatItemsObject:)
    @NSManaged public func removeFromAttachedToChatItems(_ value: NMChatItem)

    @objc(addAttachedToChatItems:)
    @NSManaged public func addToAttachedToChatItems(_ values: NSSet)

    @objc(removeAttachedToChatItems:)
    @NSManaged public func removeFromAttachedToChatItems(_ values: NSSet)

}

// MARK: Generated accessors for connectedWithTopNews
extension NMBaseContent {

    @objc(addConnectedWithTopNewsObject:)
    @NSManaged public func addToConnectedWithTopNews(_ value: NMTopNews)

    @objc(removeConnectedWithTopNewsObject:)
    @NSManaged public func removeFromConnectedWithTopNews(_ value: NMTopNews)

    @objc(addConnectedWithTopNews:)
    @NSManaged public func addToConnectedWithTopNews(_ values: NSSet)

    @objc(removeConnectedWithTopNews:)
    @NSManaged public func removeFromConnectedWithTopNews(_ values: NSSet)

}
