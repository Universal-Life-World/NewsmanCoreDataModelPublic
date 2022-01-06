//
//  NMReportTextContainer+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMReportTextContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportTextContainer> {
        return NSFetchRequest<NMReportTextContainer>(entityName: "NMReportTextContainer")
    }

    @NSManaged public var parentContainer: NMReportElementsContainer?
    @NSManaged public var text: NMText?

}
