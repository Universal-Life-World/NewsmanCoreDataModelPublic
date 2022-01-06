//
//  NMTaskBaseBlock+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTaskBaseBlock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTaskBaseBlock> {
        return NSFetchRequest<NMTaskBaseBlock>(entityName: "NMTaskBaseBlock")
    }

    @NSManaged public var ck_metadata: Data?
    @NSManaged public var deadline: Date?
    @NSManaged public var finishedTimeStamp: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var lastUpdatedTimeStamp: Date?
    @NSManaged public var startedTimeStamp: Date?
    @NSManaged public var status: String?
    @NSManaged public var target: Int16
    @NSManaged public var targetUnit: String?
    @NSManaged public var type: Int16

}
