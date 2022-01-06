//
//  NMReportContainerTemplate+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMReportContainerTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportContainerTemplate> {
        return NSFetchRequest<NMReportContainerTemplate>(entityName: "NMReportContainerTemplate")
    }

    @NSManaged public var lastUsedTimeStamp: Date?
    @NSManaged public var isHiddenFromSection: Bool
    @NSManaged public var isHideableFromSection: Bool
    @NSManaged public var isTrashable: Bool
    @NSManaged public var status: String?
    @NSManaged public var topLevelContainer: NMReportElementsContainer?

}
