//
//  NMTask+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMTask> {
        return NSFetchRequest<NMTask>(entityName: "NMTask")
    }

    @NSManaged public var about: String?
    @NSManaged public var acceptedBy: UUID?
    @NSManaged public var acceptedTimeStamp: Date?
    @NSManaged public var assignedTimeStamp: Date?
    @NSManaged public var assignedTo: UUID?
    @NSManaged public var cancelledBy: UUID?
    @NSManaged public var cancelledTimeStamp: Date?
    @NSManaged public var ck_metadata: Data?
    @NSManaged public var closedTimeStamp: Date?
    @NSManaged public var dateSearchFormatIndex: String?
    @NSManaged public var declinedBy: UUID?
    @NSManaged public var declinedTimeStamp: Date?
    @NSManaged public var finishedTimeStamp: Date?
    @NSManaged public var hiddenSectionsBitset: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var initiatedBy: UUID?
    @NSManaged public var initiatedTimeStamp: Date?
    @NSManaged public var isCancelable: Bool
    @NSManaged public var isDeletable: Bool
    @NSManaged public var isDraggable: Bool
    @NSManaged public var isHiddenFromSection: Bool
    @NSManaged public var isHideableFromSection: Bool
    @NSManaged public var isMergeable: Bool
    @NSManaged public var isSelected: Bool
    @NSManaged public var isShowingTaskDetailedCell: Bool
    @NSManaged public var isSuspendable: Bool
    @NSManaged public var isTrashable: Bool
    @NSManaged public var lastAccessedBy: UUID?
    @NSManaged public var lastAccessedTimeStamp: Date?
    @NSManaged public var lastModifiedBy: UUID?
    @NSManaged public var lastModifiedTimeStamp: Date?
    @NSManaged public var lastSuspendedTimeStamp: Date?
    @NSManaged public var lastSuspenedBy: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var longitude: Double
    @NSManaged public var nameTag: String?
    @NSManaged public var priority: String?
    @NSManaged public var sectionAlphaIndex: String?
    @NSManaged public var sectionDateIndex: String?
    @NSManaged public var sectionPriorityIndex: String?
    @NSManaged public var status: String?
    @NSManaged public var trashedTimeStamp: Date?
    @NSManaged public var audioBlock: NMTaskAudioBlock?
    @NSManaged public var chatSession: NMChatSession?
    @NSManaged public var photoBlock: NMTaskPhotoBlock?
    @NSManaged public var reportBlock: NMTaskReportBlock?
    @NSManaged public var textBlock: NMTaskTextBlock?
    @NSManaged public var videoBlock: NMTaskVideoBlock?

}
