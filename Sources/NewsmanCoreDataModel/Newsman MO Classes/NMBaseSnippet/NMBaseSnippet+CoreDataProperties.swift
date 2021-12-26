//
//  NMBaseSnippet+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 21.12.2021.
//
//

import Foundation
import CoreData


extension NMBaseSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMBaseSnippet> {
       NSFetchRequest<NMBaseSnippet>(entityName: "NMBaseSnippet")
    }

    @NSManaged public var about: String?
    @NSManaged public var archivedTimeStamp: Date?
    @NSManaged public var ck_metadata: Data?
    @NSManaged public var contentElementsGroupingType: String?
    @NSManaged public var contentElementsInRow: Int16
    @NSManaged public var contentElementsSortOrder: String?
    @NSManaged public var contentElemetsSortingType: String?
    @NSManaged public var date: Date?
    @NSManaged public var dateSearchFormatIndex: String?
    @NSManaged public var deletedTimeStamp: Date?
    @NSManaged public var hiddenSectionsBitset: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isDragAnimated: Bool
    @NSManaged public var isHidden: Bool
    @NSManaged public var isSelected: Bool
    @NSManaged public var isShowingDisclosedCell: Bool
    @NSManaged public var lastAccessedTimeStamp: Date?
    @NSManaged public var lastModifiedTimeStamp: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var logitude: Double
    @NSManaged public var nameTag: String?
    @NSManaged public var priority: String?
    @NSManaged public var publishedTimeStamp: Date?
    @NSManaged public var sectionAlphaIndex: String?
    @NSManaged public var sectionDateIndex: String?
    @NSManaged public var sectionPriorityIndex: String?
    @NSManaged public var status: String?
    

    
}
