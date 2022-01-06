//
//  NMReportElementsBaseContainer+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

#if !os(macOS)
import UIKit
#else
import AppKit
#endif

extension NMReportElementsBaseContainer
{

  @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportElementsBaseContainer>
  {
   NSFetchRequest<NMReportElementsBaseContainer>(entityName: "NMReportElementsBaseContainer")
  }

  @NSManaged public var canvasSize: NSValue?
  @NSManaged public var ck_metadata: Data?
  @NSManaged public var date: Date?
  @NSManaged public var id: UUID?
  @NSManaged public var isCanvasResizeable: Bool
  @NSManaged public var isDeletable: Bool
  @NSManaged public var isDragAnimating: Bool
  @NSManaged public var isDraggable: Bool
  @NSManaged public var isEditable: Bool
  @NSManaged public var isHiddenFromCanvas: Bool
  @NSManaged public var isHideableFromCanvas: Bool
  @NSManaged public var tag: String?
  @NSManaged public var type: Int16
  @NSManaged public var layoutMargins: NSValue?
  @NSManaged public var isSelected: Bool
  @NSManaged public var lastModifiedTimeStamp: Date?
  @NSManaged public var lastAccessedTimeStamp: Date?
  @NSManaged public var borderWidth: Double
 
  #if !os(macOS)
  @NSManaged public var borderColor: UIColor?
  #else
  @NSManaged public var borderColor: NSColor?
  #endif
 
  @NSManaged public var appliedBorderPatterns: NSSet?

}

// MARK: Generated accessors for appliedBorderPatterns
extension NMReportElementsBaseContainer {

    @objc(addAppliedBorderPatternsObject:)
    @NSManaged public func addToAppliedBorderPatterns(_ value: NMReportContainerBorderPattern)

    @objc(removeAppliedBorderPatternsObject:)
    @NSManaged public func removeFromAppliedBorderPatterns(_ value: NMReportContainerBorderPattern)

    @objc(addAppliedBorderPatterns:)
    @NSManaged public func addToAppliedBorderPatterns(_ values: NSSet)

    @objc(removeAppliedBorderPatterns:)
    @NSManaged public func removeFromAppliedBorderPatterns(_ values: NSSet)

}
