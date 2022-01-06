import CoreData
import Foundation

#if !os(macOS)
import UIKit
#endif


public extension NSManagedObjectModel
{
 static var empty: Self { .init() }
}

public final class NMCoreDataModel
{
 public enum StoreType
 {
  case inMemorySQLight  // init SQLite store with "/dev/null" in memory for Unit Testing.
  case persistedSQLight // init SQLite persisted store on disk for production.
 }
 
 
 public let modelName: String
 public let storeType: StoreType
 
 public final var mom: NSManagedObjectModel
 {
  guard let momURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else { return .empty }
  guard let mom = NSManagedObjectModel(contentsOf: momURL) else { return .empty }
  return mom
 }
 
 public var context: NSManagedObjectContext { persistentContainer.viewContext }
 

 private func registerDataTransformers()
 {
  if #available(iOS 12.0, *) {
   GenericDataSecureTransformer<NSValue>.register()
  } else {
   // Fallback on earlier versions
  }
 
 if #available(iOS 12.0, *) {
  #if !os(macOS)
    GenericDataSecureTransformer<UIColor>.register()
  #endif
 } else {
   // Fallback on earlier versions
 }
 
 }
 
 public lazy var persistentContainer = { () -> NSPersistentContainer in
  
  registerDataTransformers()
  
  let container = NSPersistentContainer(name: modelName, managedObjectModel: mom)
 
  if storeType == .inMemorySQLight
  {
   container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
  }
 
  container.loadPersistentStores { (storeDescription, error) in
   if let error = error as NSError?{
    fatalError("Unresolved error \(error), \(error.userInfo)")
   }
  }
  return container
 }()
 
 public init(name: String = "Model", for storeType: StoreType = .persistedSQLight)
 {
  self.modelName = name
  self.storeType = storeType
 }
}
