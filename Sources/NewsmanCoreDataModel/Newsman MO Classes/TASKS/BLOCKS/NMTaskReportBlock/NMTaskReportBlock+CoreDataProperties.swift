//
//  NMTaskReportBlock+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTaskReportBlock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTaskReportBlock> {
        return NSFetchRequest<NMTaskReportBlock>(entityName: "NMTaskReportBlock")
    }

    @NSManaged public var reports: NSSet?
    @NSManaged public var task: NMTask?

}

// MARK: Generated accessors for reports
extension NMTaskReportBlock {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: NMReport)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: NMReport)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}
