
//  NMBaseContent+CoreDataClass.swift
//  NewsmanCoreDataModel
//  Created by Anton2016 on 06.01.2022.

import Foundation
import CoreData
import Combine


@objc(NMBaseContent)
public class NMBaseContent: NSManagedObject, Codable {
 
 public var fileManagerTask: Task<Void, Error>?
 
 
 /* Spawns the undo manager instace lazily when it is used
  the SELF.ID must be accessed from the context thread. */
 @objc public lazy var undoManager = { () -> NMUndoManager in
  var targetID: UUID?
  managedObjectContext?.performAndWait{ targetID = self.id }
  return NMUndoManager(targetID: targetID)
 }()
 
 
 
 //JSON Decoding conveniance required initialized to recreate content element MO from archive.
 fileprivate var container: KeyedDecodingContainer<CodingKeys>?
 //Decoding container as a flag to prompt how to mame initial set up of MO fields.
 
 public required convenience init(from decoder: Decoder) throws {
  guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
   throw ContextError.noDecodableContext(decoder: decoder, entity: .baseContent, operation: .JSONDecodingObject)
  }
  
  let container = try decoder.container(keyedBy: CodingKeys.self)
  let type = try container.decode(ContentType.self, forKey: .type) //decode & fix MO type.
  
  //print("\(#function) INIT DECODED! \(type.rawValue)")
  
  self.init(entity: type.entity, insertInto: nil) // init MO without inserting it into MOC!
  self.container = container                      // fix container as a flag to prompt how to init MO!
  self.type = type                                // init MO type as it is alredy decoded above.
  context.insert(self)                            // call awakeFromInsert() with fixed container as a flag.
  try decode(from: container, into: context)
 }
 
 @NSManaged fileprivate var primitiveId: UUID?
 @NSManaged fileprivate var primitiveDate: Date?
 @NSManaged fileprivate var primitiveLastModifiedTimeStamp: Date?
 @NSManaged fileprivate var primitiveLastAccessedTimeStamp: Date?
 @NSManaged fileprivate var primitiveType: NSNumber
 
 public override func awakeFromInsert() {
  super.awakeFromInsert()
  
  //if container is NOT NIL we recover object from JSON archive so no initial set-up needed here.
  guard container == nil else { return }
  
  //if container IS NIL we create new object inserted into context and perform initial set-up.
  primitiveId = UUID()
  let now = Date()
  primitiveDate = now
  primitiveLastAccessedTimeStamp = now
  primitiveLastModifiedTimeStamp = now
  let typeIndex = ContentType(contentElement: self).rawValue
  primitiveType = NSNumber(value: typeIndex)
  
  //print("\(#function) CREATING NEW! \(self)")
  
  (self as? NMNormalizedSearchParentRepresentable)?.updateParentSearchChildrenString()
 }
 
 
 //GLS NEEDED PROPERTIES...
 public var geoLocationSubscription: AnyCancellable?
 public weak var locationsProvider: NMGeoLocationsProvider?
 public var updateGeoLocationsTask: Task<NSManagedObject, Error>?
 
 
 //MARK: Accessors for Content Element Type
 public static let typeKey = "type"
 @objc public internal (set) var type: ContentType {
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
 
 //MARK: Silent Accessors for Content Element Type
  public var silentType: ContentType {
   get {
    guard let enumValue = ContentType(rawValue: primitiveType.int16Value) else {
     fatalError("Invalid Content Type Primitive Value - [\(primitiveType.debugDescription)]")
    }
   return enumValue
  }
  
  set { primitiveType = NSNumber(value: newValue.rawValue) }
 }
 
 
 public override func didChangeValue(forKey key: String) {
  super.didChangeValue(forKey: key)
  primitiveLastModifiedTimeStamp = Date()
  (self as? NMNormalizedSearchParentRepresentable)?.updateParentSearchChildrenString()
 }
 
 public override func willSave() {
  super.willSave()
  silentStatus = .privy
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




