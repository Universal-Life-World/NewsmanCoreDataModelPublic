//
//  NMChatSession+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMChatSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMChatSession> {
        return NSFetchRequest<NMChatSession>(entityName: "NMChatSession")
    }

    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var status: String?
    @NSManaged public var connections: NSSet?
    @NSManaged public var items: NSSet?
    @NSManaged public var owner: NMChatParty?
    @NSManaged public var task: NMTask?

}

// MARK: Generated accessors for connections
extension NMChatSession {

    @objc(addConnectionsObject:)
    @NSManaged public func addToConnections(_ value: NMChatConnection)

    @objc(removeConnectionsObject:)
    @NSManaged public func removeFromConnections(_ value: NMChatConnection)

    @objc(addConnections:)
    @NSManaged public func addToConnections(_ values: NSSet)

    @objc(removeConnections:)
    @NSManaged public func removeFromConnections(_ values: NSSet)

}

// MARK: Generated accessors for items
extension NMChatSession {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: NMChatItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: NMChatItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
