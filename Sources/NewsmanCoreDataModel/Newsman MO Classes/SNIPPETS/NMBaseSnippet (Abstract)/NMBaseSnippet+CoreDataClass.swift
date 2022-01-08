//
//  NMBaseSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 21.12.2021.
//

import Foundation
import CoreData

@objc(NMBaseSnippet)
public class NMBaseSnippet: NSManagedObject
{
 // Declared primitive properties for mutating this object silently without KVO & MOCDC notifications.
 // MOCDC = .NSManagedObjectContextDidChange notification posted to the default local NotificationCenter.
 
 @NSManaged fileprivate var primitiveId: UUID?
 @NSManaged fileprivate var primitiveType: NSNumber
 @NSManaged fileprivate var primitiveDate: Date?
 @NSManaged fileprivate var primitiveLastModifiedTimeStamp: Date?
 @NSManaged fileprivate var primitiveLastAccessedTimeStamp: Date?
 
 public static let typeKey = "type"
 
 public var type: SnippetType
 {
  get {
   willAccessValue(forKey: NMBaseSnippet.typeKey)
   guard let val = SnippetType(rawValue: primitiveType.int16Value) else {
    fatalError("invalid enum value")
   }
   didAccessValue(forKey: NMBaseSnippet.typeKey)
   return val
  }
 
  set {
   willChangeValue(forKey: NMBaseSnippet.typeKey)
   primitiveType = NSNumber(value: newValue.rawValue)
   didChangeValue(forKey: NMBaseSnippet.typeKey)
   
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
 
  initFileStorage()

 }
 
 private func initFileStorage(){}
 
 public override func willSave()
 {
  super.willSave()
  primitiveLastModifiedTimeStamp = Date()
 }
}
