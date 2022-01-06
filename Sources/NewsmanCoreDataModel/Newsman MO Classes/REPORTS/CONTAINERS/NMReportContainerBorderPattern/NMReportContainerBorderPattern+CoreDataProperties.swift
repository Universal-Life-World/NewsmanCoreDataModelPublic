//
//  NMReportContainerBorderPattern+CoreDataProperties.swift
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


extension NMReportContainerBorderPattern
{
  @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportContainerBorderPattern>
  {
   NSFetchRequest<NMReportContainerBorderPattern>(entityName: "NMReportContainerBorderPattern")
  }

  @NSManaged public var relativeWidth: Double
  @NSManaged public var relativeTopMargin: Double
  @NSManaged public var relativeBottomMargin: Double
  @NSManaged public var drawingIndex: Int16
  @NSManaged public var lineDashPattern: NSArray?
  @NSManaged public var lineDashPhase: Double
 
  #if !os(macOS)
  @NSManaged public var fillColor: UIColor?
  #else
  @NSManaged public var fillColor: NSColor?
  #endif
 
  @NSManaged public var patternType: String?
  @NSManaged public var isHidden: Bool
  @NSManaged public var container: NMReportElementsBaseContainer?
}
