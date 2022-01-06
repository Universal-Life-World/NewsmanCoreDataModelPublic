//
//  NMChatItem+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMChatItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMChatItem> {
        return NSFetchRequest<NMChatItem>(entityName: "NMChatItem")
    }

    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isDragAnimating: Bool
    @NSManaged public var isHiddenToOthers: Bool
    @NSManaged public var isSelected: Bool
    @NSManaged public var message: String?
    @NSManaged public var postedTimeStamp: Date?
    @NSManaged public var status: String?
    @NSManaged public var trashedTimeStamp: Date?
    @NSManaged public var attachments: NSSet?
    @NSManaged public var chatSession: NMChatSession?
    @NSManaged public var postedBy: NMChatParty?

}

// MARK: Generated accessors for attachments
extension NMChatItem {

    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: NMBaseContent)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: NMBaseContent)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)

}
