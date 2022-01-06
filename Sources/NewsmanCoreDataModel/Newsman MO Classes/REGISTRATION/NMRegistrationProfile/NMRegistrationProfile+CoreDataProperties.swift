//
//  NMRegistrationProfile+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMRegistrationProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMRegistrationProfile> {
        return NSFetchRequest<NMRegistrationProfile>(entityName: "NMRegistrationProfile")
    }

    @NSManaged public var avatar: Data?
    @NSManaged public var background: String?
    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var email: String?
    @NSManaged public var id: UUID?
    @NSManaged public var lastLoginTimeStamp: Date?
    @NSManaged public var lastLogoutTimeStamp: Date?
    @NSManaged public var lastModifiedTimeStamp: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var login: String?
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var nickname: String?
    @NSManaged public var password: String?
    @NSManaged public var phone: String?
    @NSManaged public var status: String?
    @NSManaged public var surname: String?
    @NSManaged public var targetNewsCategories: NSMutableArray?
    @NSManaged public var willAcceptTasksFrom: Date?

}
