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
 
  //E == Encodable, D == Decodable
  //(1) Main managed properties group ***********************************************************
  @NSManaged public /*private (set)*/ var date: Date?    //E11, D11
  @NSManaged public /*private (set)*/ var id:   UUID?    //E12, D12
 
  //@NSManaged public var status: String?  //get/set using primitive property!  //E13, D13
  //@NSManaged public var nameTag: String? //get/set using primitive property!  //E14, D14
  //@NSManaged public var type: Int16      //get/set using primitive property!  //E15, D15
 
  @NSManaged public var latitude: NSNumber?              // E16, D16
  @NSManaged public var longitude: NSNumber?             // E16, D16
  @NSManaged public var location: String?                // E17, D17
 
  //@NSManaged public var priority: String?//get/set using primitive property!  //E18, D18
  //@NSManaged public var about: String?   //get/set using primitive property!  //E19, D19
  @NSManaged public var ck_metadata: Data?               // E110, D110
  @NSManaged public var hiddenSectionsBitset: Int16      // E110, D111
  //*********************************************************************************************
 
  //(2) Time stamps group ***********************************************************************
  @NSManaged public internal (set) var lastAccessedTimeStamp: Date? //E21, D21
  @NSManaged public internal (set) var lastModifiedTimeStamp: Date? //E22, D22
 
  @NSManaged public var publishedTimeStamp: Date?                   //E23, D23
  @NSManaged public var trashedTimeStamp: Date?                     //E24, D24
  @NSManaged public var archivedTimeStamp: Date?                    //E25, D25
  //*********************************************************************************************
  
  //(3) is...able to do group *******************************************************************
  @NSManaged public var isDeletable: Bool                    //E31, D31
  @NSManaged public var isDragAnimating: Bool                //E32, D32
  @NSManaged public var isDraggable: Bool                    //E33, D33
  @NSManaged public var isTrashable: Bool                    //E34, D34
  @NSManaged public var isHiddenFromSection: Bool            //E35, D35
  @NSManaged public var isHideableFromSection: Bool          //E36, D36
  @NSManaged public var isSelected: Bool                     //E37, D37
  @NSManaged public var isContentCopyable: Bool              //E38, D38
  @NSManaged public var isContentEditable: Bool              //E39, D39
  @NSManaged public var isContentPublishable: Bool           //E310, D310
  @NSManaged public var isContentSharable: Bool              //E311, D311
  @NSManaged public var isMergeable: Bool                    //E312, D312
  @NSManaged public var isShowingSnippetDetailedCell: Bool   //E313, D313
  //*********************************************************************************************
 
  //(4) Index fields group **********************************************************************
  //@NSManaged public var sectionDateIndex: String?  //get/set using primitive(silent) accessors! //D41
 
  @NSManaged public var sectionAlphaIndex: String?   //set via nameTag accessors automatically
  //primitiveSectionAlphaIndex = String(nameTag?.prefix(1) ?? "")
 
  @NSManaged public var sectionPriorityIndex: String?//priority indexed via prefix of rawValue: i_Xxx..
  //when Snippet is first created priority field is set to default string value in MOM: "3_Normal"
  //this field is set to default string value in MOM: "3"
  //when it is decoded (recovered) from JSON it is set via silentPriority setter!
  //priority index = 0 - priority: "0_Hottest"
  //priority index = 1 - priority: "1_Hot"
  //priority index = 2 - priority: "2_High"
  //priority index = 3 - priority: "3_Normal" // Default set in MOM!
  //priority index = 4 - priority: "4_Medium"
  //priority index = 5 - priority: "5_Low"                                         //D42
 
  @NSManaged public var sectionTypeIndex: String?   //type indexed via prefix: (type.rawValue)_...
  //primitiveSectionTypeIndex = "\(typeIndex)_" + String(describing: self) + "s"
  //case base  = 0 // "0_Base Snippets"
  //case photo = 1 // "1_Photo Snippets"
  //case video = 2 // "2_Video Snippets"
  //case audio = 3 // "3_Audio Snippets"
  //case text  = 4 // "4_Text Snippets"
  //case mixed = 5 // "5_Mixed Snippets"
 
  @NSManaged public var dateSearchFormatIndex: String?
  //*********************************************************************************************
 
  //(5) UI elements reflection group ************************************************************
  //@NSManaged public var contentElementsGroupingType: String?//get/set using primitive   //E51 D51
  @NSManaged public var contentElementsInRow: Int16                                       //E52 D52
 
//  @NSManaged public var contentElementsSortingType: String? //not used
//  @NSManaged public var contentElementsSortOrder: String? //not used
 
  @NSManaged public var showsContentElementsPositions: Bool   //E53 D53
  @NSManaged public var showsHiddenContentElements: Bool      //E54 D54
 
  //*********************************************************************************************
  
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
