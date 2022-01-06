//
//  NMBaseSubscription+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMBaseSubscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMBaseSubscription> {
        return NSFetchRequest<NMBaseSubscription>(entityName: "NMBaseSubscription")
    }

    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isDeletable: Bool
    @NSManaged public var isSelected: Bool
    @NSManaged public var lastAccessedTimeStamp: Date?
    @NSManaged public var lastActivatedTimeStamp: Date?
    @NSManaged public var lastDeactivatedTimeStamp: Date?
    @NSManaged public var lastModifiedTimeStamp: Date?
    @NSManaged public var status: String?
    @NSManaged public var tag: String?
    @NSManaged public var type: Int16

}
