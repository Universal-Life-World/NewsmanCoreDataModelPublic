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
public class NMBaseSnippet : NSManagedObject, Codable {
 
 @MainActor public lazy var undoManager = NMUndoManager(targetID: id)
 /* Spawns the undo manager instace lazily when it id used on the main global actor as the SELF.ID must be accessed from the main context thread. */
 
 public var fileManagerTask: Task<Void, Error>?
 public var updateGeoLocationsTask: Task<NSManagedObject, Error>?
 
 //GLS NEEDED PROPERTIES...
 public var geoLocationSubscription: AnyCancellable?
 public weak var locationsProvider: NMGeoLocationsProvider?
 
 
 public required convenience init(from decoder: Decoder) throws {
  
  guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
   throw ContextError.noDecodableContext(decoder: decoder, entity: .baseContent, operation: .JSONDecodingObject)
  }

  let container = try decoder.container(keyedBy: CodingKeys.self)
  
  let type = try container.decode(SnippetType.self, forKey: .type)
  self.init(entity: type.entity, insertInto: context)
  self.type = type
  try decode(from: container, into: context)
  
 }
 
 // Declared primitive properties for mutating this object silently without KVO & MOCDC notifications.
 // MOCDC = .NSManagedObjectContextDidChange notification posted to the default local NotificationCenter.
 @NSManaged fileprivate var primitiveId: UUID?
 @NSManaged fileprivate var primitiveDate: Date?
 @NSManaged fileprivate var primitiveLastModifiedTimeStamp: Date?
 @NSManaged fileprivate var primitiveLastAccessedTimeStamp: Date?
 @NSManaged fileprivate var primitiveType: NSNumber
 

 // initial silent set-up of snippets service properties.
 public override func awakeFromInsert() {
  super.awakeFromInsert()

  primitiveId = UUID()
  let now = Date()
  primitiveDate = now
  primitiveLastAccessedTimeStamp = now
  primitiveLastModifiedTimeStamp = now
  let typeIndex = SnippetType(snippet: self).rawValue
  primitiveType = NSNumber(value: typeIndex)
  sectionTypeIndex = "\(typeIndex)_" + String(describing: self) + "s"
  
 }
 
 //MARK: Accessors for Snippet Type
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

 public override var description: String {
  var description = String(describing: Swift.type(of: self))
  description.removeFirst(2)
  let ind = description.firstIndex(of: "S")!
  description.insert(" ", at: ind)
  return description
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
 

 public override func willSave() {
  super.willSave()
  silentStatus = .privy
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


