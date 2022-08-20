//
//  NMBaseSnippet+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 21.12.2021.
//
//

import Foundation
import CoreData

@available(iOS 13.0, *)
extension NMBaseSnippet {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<NMBaseSnippet> {
    NSFetchRequest<NMBaseSnippet>(entityName: "NMBaseSnippet")
  }

  @NSManaged public var archivedTimeStamp: Date?
  @NSManaged public var ck_metadata: Data?
  @NSManaged public var contentElementsGroupingType: String?
  @NSManaged public var contentElementsInRow: Int16
  @NSManaged public var contentElementsSortingType: String?
  @NSManaged public var contentElementsSortOrder: String?
  @NSManaged public /*private (set)*/ var date: Date?
  @NSManaged public var dateSearchFormatIndex: String?
  @NSManaged public var hiddenSectionsBitset: Int16
  @NSManaged public var id: UUID?
  @NSManaged public var isContentCopyable: Bool
  @NSManaged public var isContentEditable: Bool
  @NSManaged public var isContentPublishable: Bool
  @NSManaged public var isContentSharable: Bool
  @NSManaged public var isDeletable: Bool
  @NSManaged public var isDragAnimating: Bool
  @NSManaged public var isDraggable: Bool
  @NSManaged public var isHiddenFromSection: Bool
  @NSManaged public var isHideableFromSection: Bool
  @NSManaged public var isMergeable: Bool
  @NSManaged public var isSelected: Bool
  @NSManaged public var isShowingSnippetDetailedCell: Bool
  @NSManaged public var isTrashable: Bool
  @NSManaged public internal (set) var lastAccessedTimeStamp: Date?
  @NSManaged public internal (set) var lastModifiedTimeStamp: Date?
  
  @NSManaged public  var location: String?
  @NSManaged public  var longitude: NSNumber?
  @NSManaged public  var latitude: NSNumber?
 
  //@NSManaged public var about: String?   //get/set using primitive property!
  //@NSManaged public var nameTag: String? //get/set using primitive property!
  //@NSManaged public var priority: String?//get/set using primitive property!
  //@NSManaged public var sectionDateIndex: String?
  //@NSManaged public var status: String? //get/set using primitive property!
  //@NSManaged public var type: Int16 //get/set using primitive property!
 
  @NSManaged public var publishedTimeStamp: Date?
  @NSManaged public var sectionAlphaIndex: String?
  
  @NSManaged public var sectionPriorityIndex: String?
  @NSManaged public var sectionTypeIndex: String?
  @NSManaged public var showsContentElementsPositions: Bool
  @NSManaged public var showsHiddenContentElements: Bool
  
  @NSManaged public var trashedTimeStamp: Date?
  
  @NSManaged public var connectedWithTopNews: NSSet?

}


 // MARK: Generated accessors for connectedWithTopNews

@available(iOS 13.0, *)
extension NMBaseSnippet {

    @objc(addConnectedWithTopNewsObject:)
    @NSManaged public func addToConnectedWithTopNews(_ value: NMTopNews)

    @objc(removeConnectedWithTopNewsObject:)
    @NSManaged public func removeFromConnectedWithTopNews(_ value: NMTopNews)

    @objc(addConnectedWithTopNews:)
    @NSManaged public func addToConnectedWithTopNews(_ values: NSSet)

    @objc(removeConnectedWithTopNews:)
    @NSManaged public func removeFromConnectedWithTopNews(_ values: NSSet)

}
