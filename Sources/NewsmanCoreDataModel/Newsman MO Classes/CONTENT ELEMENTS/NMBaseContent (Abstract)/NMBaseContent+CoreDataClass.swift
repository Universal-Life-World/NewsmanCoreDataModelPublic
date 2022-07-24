//
//  NMBaseContent+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData
import Combine

@objc(NMBaseContent)
public class NMBaseContent: NSManagedObject, Codable {
 
 public required convenience init(from decoder: Decoder) throws {
  guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
   throw ContextError.noDecodableContext(decoder: decoder, entity: .baseContent, operation: .JSONDecodingObject)
  }
  
  self.init(context: context)
  try decode(using: decoder)
 }
 
 
 @MainActor public lazy var undoManager = NMUndoManager(targetID: id)
 /* Spawns the undo manager instace lazily when it id used on the main global actor as the SELF.ID must be accessed from the main context thread. */
 
 public var fileManagerTask: Task<Void, Error>?

 @NSManaged internal var primitiveId: UUID?
 @NSManaged fileprivate var primitiveDate: Date?
 @NSManaged fileprivate var primitiveLastModifiedTimeStamp: Date?
 @NSManaged fileprivate var primitiveLastAccessedTimeStamp: Date?
 
 //GLS NEEDED PROPERTIES...
 public var geoLocationSubscription: AnyCancellable?
 public weak var locationsProvider: NMGeoLocationsProvider?
 public var updateGeoLocationsTask: Task<NSManagedObject, Error>?
 
 
 
 //MARK: Accessors for Content Element Type
 @NSManaged fileprivate var primitiveType: NSNumber
 public static let typeKey = "type"
 @objc public fileprivate (set) var type: ContentType {
  get {
   willAccessValue(forKey: Self.typeKey)
   guard let enumValue = ContentType(rawValue: primitiveType.int16Value) else {
    fatalError("Invalid Content Type Primitive Value - [\(primitiveType.debugDescription)]")
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
 
 //MARK: Accessors for Content Element <.tag> field.
 @NSManaged fileprivate var primitiveTag: String?
 public static let tagKey = "tag"
 public static let normalizedSearchTagKey = "normalizedSearchTag"
  //the publicly exposed key for updating ASCII normalised variant of nameTag string for optimized predicate fetching using formats ... CONTAINS[n]... BEGINWITH[n]... etc.
 
 @objc public var tag: String? {
  get {
   willAccessValue(forKey: Self.tagKey)
   let value = primitiveTag
   didAccessValue(forKey: Self.tagKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.tagKey)
   primitiveTag = newValue
   setValue(newValue?.normalizedForSearch, forKey: Self.normalizedSearchTagKey) //NORMALIZED!
   didChangeValue(forKey: Self.tagKey)
   
  }
 }
 
 //MARK: Accessors for Content Element <.status> field.
 @NSManaged fileprivate var primitiveStatus: String
 
 public static let statusKey = "status"
 public fileprivate (set) var status: ContentStatus {
  get {
   willAccessValue(forKey: Self.statusKey)
   guard let value = ContentStatus(rawValue: primitiveStatus) else {
    fatalError("Invalid Content Element Status Primitive Value - [\(primitiveStatus)]")
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
 
 //MARK: Accessors for Content Element MO <.priority> field.
 @NSManaged fileprivate var primitivePriority: String
 public static let priorityKey = "priority"
 public var priority: ContentPriority {
  get {
   willAccessValue(forKey: Self.priorityKey)
   guard let value = ContentPriority(rawValue: primitivePriority) else {
    fatalError("Invalid Content Element Priority Primitive Property Value - [\(primitivePriority)]")
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
 
 
 //MARK: Accessors for Content Element Positions field.
 @NSManaged fileprivate var primitivePositions: NSMutableDictionary?
 public static let positionsKey = "positions"
 
 public typealias TContentPositions = [ TPositionKey : Int ]
 public var positions: TContentPositions? {
  
  get {
   willAccessValue(forKey: Self.positionsKey)
   guard let rawPos = primitivePositions as? [String: Int] else { return nil }
   let positions = rawPos.map{ (TPositionKey(raw: $0.key), $0.value) }
   didAccessValue(forKey: Self.positionsKey)
   return Dictionary(uniqueKeysWithValues: positions)
  }
  
  set {
   willChangeValue(forKey: Self.positionsKey)
   guard let positions = newValue else  {
    primitivePositions = nil
    return
   }
   
   let rawPos = positions.map { (key: $0.key.rawString, value: $0.value) }
   
   primitivePositions = NSMutableDictionary(dictionary: Dictionary(uniqueKeysWithValues: rawPos))
   didChangeValue(forKey: Self.positionsKey)
   
  }
 }
 
 
 public override func awakeFromInsert() {
  super.awakeFromInsert()
  
  primitiveId = UUID()
  let now = Date()
  primitiveDate = now
  primitiveLastAccessedTimeStamp = now
  primitiveLastModifiedTimeStamp = now
  let typeIndex = ContentType(contentElement: self).rawValue
  primitiveType = NSNumber(value: typeIndex)
  
  (self as? NMNormalizedSearchParentRepresentable)?.updateParentSearchChildrenString()
 }
 
 
 public override func didChangeValue(forKey key: String) {
  super.didChangeValue(forKey: key)
  primitiveLastModifiedTimeStamp = Date()
  (self as? NMNormalizedSearchParentRepresentable)?.updateParentSearchChildrenString()
 }
 
 public override func willSave() {
  super.willSave()
  primitiveLastModifiedTimeStamp = Date()
 }
 
 public override func willAccessValue(forKey key: String?) {
  super.willAccessValue(forKey: key)
  primitiveLastAccessedTimeStamp = Date()
 }
 
 private func updateParentSearchChildrenString(){
  guard let parentRep = self as? NMNormalizedSearchParentRepresentable else { return }
  parentRep.updateParentSearchChildrenString()
 }
 
 
 @available(iOS 15.0, macOS 12.0, *)
 private func deleteFileStorage(){
  
//  print(#function)
//  guard let storageManaged = self as? NMFileStorageManageable else { return }
//  let description = String(describing: Swift.type(of: self)) + "[\(id!.uuidString)]"
//  
//  Task.detached{
//   do{
//    try await storageManaged.removeFileStorage()
//    print("\(description) FILE STORAGE REMOVED SUCCESSFULLY!")
//    
//   } catch let error as ContextError {
//    print("\(description) <<<FILE STORAGE REMOVE ERROR>>> \(error.localizedDescription)")
//   }
//  }
   
  
 
//  storageManaged.removeFileStorage{ result in
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
 }
 
 public override func prepareForDeletion() {
  super.prepareForDeletion()
  updateParentSearchChildrenString()
  
  if #available(iOS 15.0, macOS 12.0, *) {
   deleteFileStorage()
  } else {
    // Fallback on earlier versions
  }
  
 }
}




