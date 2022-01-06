//
//  NMChatConnection+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMChatConnection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMChatConnection> {
        return NSFetchRequest<NMChatConnection>(entityName: "NMChatConnection")
    }

    @NSManaged public var ck_metadata: Data?
    @NSManaged public var dateEntered: Date?
    @NSManaged public var dateExited: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var status: String?
    @NSManaged public var party: NMChatParty?
    @NSManaged public var session: NMChatSession?

}
