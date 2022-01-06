//
//  NMContentCreationBaseSettings+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMContentCreationBaseSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMContentCreationBaseSettings> {
        return NSFetchRequest<NMContentCreationBaseSettings>(entityName: "NMContentCreationBaseSettings")
    }

    @NSManaged public var about: String?
    @NSManaged public var applicationTier: Int16
    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: TimeInterval
    @NSManaged public var id: UUID?
    @NSManaged public var isActive: Bool
    @NSManaged public var nameTag: String?
    @NSManaged public var type: Int16

}
