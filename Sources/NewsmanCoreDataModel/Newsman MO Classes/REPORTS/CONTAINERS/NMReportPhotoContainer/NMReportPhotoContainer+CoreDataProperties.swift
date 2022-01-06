//
//  NMReportPhotoContainer+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMReportPhotoContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportPhotoContainer> {
        return NSFetchRequest<NMReportPhotoContainer>(entityName: "NMReportPhotoContainer")
    }

    @NSManaged public var photo: NMPhoto?
    @NSManaged public var parentContainer: NMReportElementsContainer?

}
