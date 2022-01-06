//
//  NMLocationSubscriptionZone+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMLocationSubscriptionZone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMLocationSubscriptionZone> {
        return NSFetchRequest<NMLocationSubscriptionZone>(entityName: "NMLocationSubscriptionZone")
    }

    @NSManaged public var ck_metadata: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: Data?
    @NSManaged public var isActive: Bool
    @NSManaged public var isDeletable: Bool
    @NSManaged public var isHiddenOnMap: Bool
    @NSManaged public var lastActivationTimeStamp: Date?
    @NSManaged public var lastDeactivationTimeStamp: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var shouldBeExcluded: Bool
    @NSManaged public var tag: String?
    @NSManaged public var zoneScanRadius: Double
    @NSManaged public var subscription: NSSet?

}

// MARK: Generated accessors for subscription
extension NMLocationSubscriptionZone {

    @objc(addSubscriptionObject:)
    @NSManaged public func addToSubscription(_ value: NMLocationsSubscription)

    @objc(removeSubscriptionObject:)
    @NSManaged public func removeFromSubscription(_ value: NMLocationsSubscription)

    @objc(addSubscription:)
    @NSManaged public func addToSubscription(_ values: NSSet)

    @objc(removeSubscription:)
    @NSManaged public func removeFromSubscription(_ values: NSSet)

}
