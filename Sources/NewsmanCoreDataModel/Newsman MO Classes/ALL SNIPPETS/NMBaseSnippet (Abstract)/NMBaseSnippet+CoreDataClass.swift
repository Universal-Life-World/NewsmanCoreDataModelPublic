//
//  NMBaseSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 21.12.2021.
//

import Foundation
import CoreData
import Combine
import CoreLocation



@available(iOS 13.0, *)
@objc(NMBaseSnippet)
public class NMBaseSnippet : NSManagedObject {
 
 public var fileManagerTask: Task<Void, Error>?
 
 public override var description: String {
  var description = String(describing: Swift.type(of: self))
  description.removeFirst(2)
  let ind = description.firstIndex(of: "S")!
  description.insert(" ", at: ind)
  return description
 }
 
 // Declared primitive properties for mutating this object silently without KVO & MOCDC notifications.
 // MOCDC = .NSManagedObjectContextDidChange notification posted to the default local NotificationCenter.
 
 @NSManaged fileprivate var primitiveId: UUID?
 @NSManaged fileprivate var primitiveDate: Date?
 @NSManaged fileprivate var primitiveLastModifiedTimeStamp: Date?
 @NSManaged fileprivate var primitiveLastAccessedTimeStamp: Date?
 

 //public static var geocoderType: NMGeocoderTypeProtocol.Type?
 
 //GLS NEEDED PROPERTIES...
 public var geoLocationSubscription: AnyCancellable?
 public weak var locationsProvider: NMGeoLocationsProvider?

 //MARK: Accessors for Snippet MO <.nameTag> field.
 @NSManaged fileprivate var primitiveNameTag: String?
 public static let nameTagKey = "nameTag"
 public static let normalizedSearchNameTagKey = "normalizedSearchNameTag"
 //the publicly exposed key for updating ASCII normalised variant of nameTag string for optimized predicate fetching using formats ... CONTAINS[n]... BEGINWITH[n]... etc.
 
 @objc public var nameTag: String? {
  get {
   willAccessValue(forKey: Self.nameTagKey)
   let value = primitiveNameTag
   didAccessValue(forKey: Self.nameTagKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.nameTagKey)
   primitiveNameTag = newValue
   sectionAlphaIndex = String(nameTag?.prefix(1) ?? "")
   setValue(newValue?.normalizedForSearch, forKey: Self.normalizedSearchNameTagKey) //NORMALIZED!
   didChangeValue(forKey: Self.nameTagKey)
   
  }
 }
 
  //MARK: Accessors for Snippet MO <.about> field.
 @NSManaged fileprivate var primitiveAbout: String?
 public static let aboutKey = "about"
 public static let normalizedSearchAboutKey = "normalizedSearchAbout"
  //the publicly exposed key for updating ASCII normalised variant of nameTag string for optimized predicate fetching using formats ... CONTAINS[n]... BEGINWITH[n]... etc.
 
 @objc public var about: String? {
  get {
   willAccessValue(forKey: Self.aboutKey)
   let value = primitiveAbout
   didAccessValue(forKey: Self.aboutKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.aboutKey)
   primitiveAbout = newValue
   setValue(newValue?.normalizedForSearch, forKey: Self.normalizedSearchAboutKey) //NORMALIZED!
   didChangeValue(forKey: Self.aboutKey)
   
  }
 }
 
 
 //MARK: Accessors for Snippet MO <.status> field.
 @NSManaged fileprivate var primitiveStatus: String
 public static let statusKey = "status"
 public fileprivate (set) var status: SnippetStatus {
  get {
   willAccessValue(forKey: Self.statusKey)
   guard let value = SnippetStatus(rawValue: primitiveStatus) else {
    fatalError("Invalid Snippet Status Primitive Value - [\(primitiveStatus)]")
   }
   didAccessValue(forKey: Self.statusKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.statusKey)
   primitiveStatus = newValue.rawValue
   didChangeValue(forKey: Self.statusKey)
   
  }
 }
 
 //MARK: Accessors for Snippet MO <.priority> field.
 @NSManaged fileprivate var primitivePriority: String
 public static let priorityKey = "priority"
 public var priority: SnippetPriority {
  get {
   willAccessValue(forKey: Self.priorityKey)
   guard let value = SnippetPriority(rawValue: primitivePriority) else {
    fatalError("Invalid Snippet Priority Primitive Property Value - [\(primitivePriority)]")
   }
   didAccessValue(forKey: Self.priorityKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.priorityKey)
   primitivePriority = newValue.rawValue
   didChangeValue(forKey: Self.priorityKey)
   
  }
 }
 
 //MARK: Accessors for Snippet Type
 @NSManaged fileprivate var primitiveType: NSNumber
 public static let typeKey = "type"
 @objc public fileprivate (set) var type: SnippetType {
  get {
   willAccessValue(forKey: Self.typeKey)
   guard let enumValue = SnippetType(rawValue: primitiveType.int16Value) else {
    fatalError("Invalid Snippet Type Primitive Value - [\(primitiveType.debugDescription)]")
   }
   didAccessValue(forKey: Self.typeKey)
   return enumValue
  }
 
  set {
   willChangeValue(forKey: Self.typeKey)
   primitiveType = NSNumber(value: newValue.rawValue)
   didChangeValue(forKey: Self.typeKey)
   
  }
 }
 

 
// var currentTimerCancellable: AnyCancellable?
// var dateGroupStateUpdater: PassthroughSubject<() -> (), Never>?
//

// public static var currentTimerInterval: TimeInterval = .oneDay
// public static var fireDateCalendarComponent: Calendar.Component = .day
// 
 //MARK: Accessors for Snippet Date Group Index
 
 
 @NSManaged fileprivate var primitiveSectionDateIndex: String
 public static let sectionDateIndexKey = "sectionDateIndex"
 public internal (set) var sectionDateIndexGroup: DateGroup {
  get {
   willAccessValue(forKey: Self.sectionDateIndexKey)
   guard let enumValue = DateGroup(rawValue: primitiveSectionDateIndex) else {
    fatalError("Invalid Snippet Creation Date Group Primitive value - [\(primitiveSectionDateIndex)]")
   }
   didAccessValue(forKey: Self.sectionDateIndexKey)
   return enumValue
  }
  
  set {
//   guard newValue.rawValue != primitiveSectionDateIndex else { return }
   willChangeValue(forKey: Self.sectionDateIndexKey)
   //if ( newValue == .later ) { currentTimerCancellable?.cancel() }
   primitiveSectionDateIndex = newValue.rawValue
   didChangeValue(forKey: Self.sectionDateIndexKey)
   
  }
 }
 
 
 public var updateGeoLocationsTask: Task<NSManagedObject, Error>?
 
 private func updateDateGroupAfterFetch(){
  
  guard let dateCreated = date else { fatalError("Snippet Creation Date MUST NOT BE NIL!") }
  
  let fetchDate = Date()
  let newSectionDateIndex = DateGroup.current(of: dateCreated, at: fetchDate).rawValue
  if primitiveSectionDateIndex != newSectionDateIndex {
   primitiveSectionDateIndex = newSectionDateIndex
  }
 }
 
 public override func awakeFromFetch(){
  super.awakeFromFetch()
  //sheduleDateGroupTimerAfterFetch()
  
  //updateDateGroupAfterFetch()
  //print ("\(#function)")
  if #available(iOS 15.0, macOS 12.0, *) {
    updateGeoLocationsAfterFetch()
  } else {
    // Fallback on earlier versions
  }
 }
 

 

 // initial silent set-up of snippets service properties.
 public override func awakeFromInsert() {
  super.awakeFromInsert()
  primitiveId = UUID()
 
  let now = Date()
  primitiveDate = now
  //sheduleDateGroupTimer(from: now)
  primitiveLastAccessedTimeStamp = now
  primitiveLastModifiedTimeStamp = now
  let typeIndex = SnippetType(snippet: self).rawValue
  primitiveType = NSNumber(value: typeIndex)
  sectionTypeIndex = "\(typeIndex)_" + String(describing: self) + "s"
  
//  subscribeToLocationUpdate()
 
 }
 

 public override func willSave() {
  super.willSave()
  primitiveStatus = Self.SnippetStatus.privy.rawValue
  primitiveLastModifiedTimeStamp = Date()
 }
 
 
 public override func didAccessValue(forKey key: String?) {
  super.didAccessValue(forKey: key)
  primitiveLastAccessedTimeStamp = Date()
  
//  if #available(iOS 15.0, macOS 12.0, *) {
//   if key == #keyPath(NMBaseSnippet.latitude) ||
//      key == #keyPath(NMBaseSnippet.longitude) ||
//       key == #keyPath(NMBaseSnippet.location) {
//     updateGeoLocationsAfterFetch()
//   }
//  } else {
//    // Fallback on earlier versions
//  }

 }
 
 public override func didChangeValue(forKey key: String) {
  super.didChangeValue(forKey: key)
  primitiveLastModifiedTimeStamp = Date()
 }
 
 
// private func removeFileStorage(){
//  guard let storageManaged = self as? NMFileStorageManageable else { return }
//
//  let description = String(describing: Swift.type(of: self)) + "[\(id!.uuidString)]"
//  storageManaged.removeFileStorage{  result in
//
//   switch result {
//    case .success():
//     print("\(description) FILE STORAGE REMOVED SUCCESSFULLY!")
//
//    case .failure(let error):
//     print("\(description) <<<FILE STORAGE REMOVE ERROR>>> \(error.localizedDescription)")
//   }
//
//  }
// }
 
 
 
 public override func prepareForDeletion() {
  super.prepareForDeletion()
  //removeFileStorage()
 }
}


