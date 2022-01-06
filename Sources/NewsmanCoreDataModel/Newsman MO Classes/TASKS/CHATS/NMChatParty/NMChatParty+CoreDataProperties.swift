//
//  NMChatParty+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMChatParty {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMChatParty> {
        return NSFetchRequest<NMChatParty>(entityName: "NMChatParty")
    }

    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var newsmanID: UUID?
    @NSManaged public var status: String?
    @NSManaged public var chatsOwned: NSSet?
    @NSManaged public var connections: NSSet?
    @NSManaged public var postedItems: NSSet?

}

// MARK: Generated accessors for chatsOwned
extension NMChatParty {

    @objc(addChatsOwnedObject:)
    @NSManaged public func addToChatsOwned(_ value: NMChatSession)

    @objc(removeChatsOwnedObject:)
    @NSManaged public func removeFromChatsOwned(_ value: NMChatSession)

    @objc(addChatsOwned:)
    @NSManaged public func addToChatsOwned(_ values: NSSet)

    @objc(removeChatsOwned:)
    @NSManaged public func removeFromChatsOwned(_ values: NSSet)

}

// MARK: Generated accessors for connections
extension NMChatParty {

    @objc(addConnectionsObject:)
    @NSManaged public func addToConnections(_ value: NMChatConnection)

    @objc(removeConnectionsObject:)
    @NSManaged public func removeFromConnections(_ value: NMChatConnection)

    @objc(addConnections:)
    @NSManaged public func addToConnections(_ values: NSSet)

    @objc(removeConnections:)
    @NSManaged public func removeFromConnections(_ values: NSSet)

}

// MARK: Generated accessors for postedItems
extension NMChatParty {

    @objc(addPostedItemsObject:)
    @NSManaged public func addToPostedItems(_ value: NMChatItem)

    @objc(removePostedItemsObject:)
    @NSManaged public func removeFromPostedItems(_ value: NMChatItem)

    @objc(addPostedItems:)
    @NSManaged public func addToPostedItems(_ values: NSSet)

    @objc(removePostedItems:)
    @NSManaged public func removeFromPostedItems(_ values: NSSet)

}
