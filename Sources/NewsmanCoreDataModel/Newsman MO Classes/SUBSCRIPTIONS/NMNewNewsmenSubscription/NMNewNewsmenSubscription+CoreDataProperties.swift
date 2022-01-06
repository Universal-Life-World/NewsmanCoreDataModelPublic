//
//  NMNewNewsmenSubscription+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMNewNewsmenSubscription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMNewNewsmenSubscription> {
        return NSFetchRequest<NMNewNewsmenSubscription>(entityName: "NMNewNewsmenSubscription")
    }

    @NSManaged public var newsCategories: NSMutableArray?

}
