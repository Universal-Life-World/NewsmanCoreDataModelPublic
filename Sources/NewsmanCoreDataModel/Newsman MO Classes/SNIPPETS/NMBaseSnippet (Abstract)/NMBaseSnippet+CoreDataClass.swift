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
public class NMBaseSnippet : NSManagedObject
{
 // Declared primitive properties for mutating this object silently without KVO & MOCDC notifications.
 // MOCDC = .NSManagedObjectContextDidChange notification posted to the default local NotificationCenter.
 
 @NSManaged fileprivate var primitiveId: UUID?
 
 @NSManaged fileprivate var primitiveDate: Date?
 @NSManaged fileprivate var primitiveLastModifiedTimeStamp: Date?
 @NSManaged fileprivate var primitiveLastAccessedTimeStamp: Date?
 

 public var geoLocationSubscription: AnyCancellable?
 
 public weak var locationsProvider: NMGeoLocationsProvider?
 
 //MARK: Accessors for Snippet Status
 @NSManaged fileprivate var primitiveStatus: String
 public static let statusKey = "status"
 public fileprivate (set) var status: SnippetStatus
 {
  get {
   willAccessValue(forKey: Self.statusKey)
   guard let value = SnippetStatus(rawValue: primitiveStatus) else {
    fatalError("Invalid SnippetStatus enum value!")
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
 
 //MARK: Accessors for Snippet Priority
 @NSManaged fileprivate var primitivePriority: String
 public static let priorityKey = "priority"
 public var priority: SnippetPriority
 {
  get {
   willAccessValue(forKey: Self.priorityKey)
   guard let value = SnippetPriority(rawValue: primitivePriority) else {
    fatalError("Invalid SnippetPriority enum value")
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
 public fileprivate (set) var type: SnippetType
 {
  get {
   willAccessValue(forKey: Self.typeKey)
   guard let val = SnippetType(rawValue: primitiveType.int16Value) else {
    fatalError("Invalid SnippetType enum value")
   }
   didAccessValue(forKey: Self.typeKey)
   return val
  }
 
  set {
   willChangeValue(forKey: Self.typeKey)
   primitiveType = NSNumber(value: newValue.rawValue)
   didChangeValue(forKey: Self.typeKey)
   
  }
 }
 
 
 
 
 


 // initial silent set-up of snippets service properties.
 public override func awakeFromInsert()
 {
  super.awakeFromInsert()
  primitiveId = UUID()
 
  let now = Date()
  primitiveDate = now
  primitiveLastAccessedTimeStamp = now
  primitiveLastModifiedTimeStamp = now
  primitiveType = NSNumber(value: SnippetType(snippet: self).rawValue)
  
//  subscribeToLocationUpdate()
 
 }
 
 public override func willSave()
 {
  super.willSave()
  primitiveStatus = Self.SnippetStatus.privy.rawValue
  primitiveLastModifiedTimeStamp = Date()
 }
 
 public override func didAccessValue(forKey key: String?)
 {
  super.didAccessValue(forKey: key)
  primitiveLastAccessedTimeStamp = Date()
 }
 
 public override func didChangeValue(forKey key: String)
 {
  super.didChangeValue(forKey: key)
  primitiveLastModifiedTimeStamp = Date()
 }
}
