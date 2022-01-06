//
//  NMReportVideoContainer+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMReportVideoContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportVideoContainer> {
        return NSFetchRequest<NMReportVideoContainer>(entityName: "NMReportVideoContainer")
    }

    @NSManaged public var parentContainer: NMReportElementsContainer?
    @NSManaged public var video: NMVideo?

}
