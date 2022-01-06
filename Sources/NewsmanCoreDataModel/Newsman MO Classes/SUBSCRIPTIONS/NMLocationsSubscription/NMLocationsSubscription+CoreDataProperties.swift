//
//  NMLocationsSubscription+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMLocationsSubscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMLocationsSubscription> {
        return NSFetchRequest<NMLocationsSubscription>(entityName: "NMLocationsSubscription")
    }

    @NSManaged public var zonesSearchRule: String?
    @NSManaged public var searchedZones: NSSet?

}

// MARK: Generated accessors for searchedZones
extension NMLocationsSubscription {

    @objc(addSearchedZonesObject:)
    @NSManaged public func addToSearchedZones(_ value: NMLocationSubscriptionZone)

    @objc(removeSearchedZonesObject:)
    @NSManaged public func removeFromSearchedZones(_ value: NMLocationSubscriptionZone)

    @objc(addSearchedZones:)
    @NSManaged public func addToSearchedZones(_ values: NSSet)

    @objc(removeSearchedZones:)
    @NSManaged public func removeFromSearchedZones(_ values: NSSet)

}
