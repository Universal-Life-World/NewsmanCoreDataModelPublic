import CoreData
import Foundation

#if !os(macOS)
import UIKit
#endif


public extension NSManagedObjectModel
{
 static var empty: Self { .init() }
}

@available(iOS 14.0, *)
public final class NMCoreDataModel
{
 
 private static var moms: [String: NSManagedObjectModel] = [:]
 
 private static let momIsq = DispatchQueue(label: "MOM isolation queue")
 
 static private subscript(named modelName: String) -> NSManagedObjectModel
 {
  momIsq.sync {
   if let existingMOM = Self.moms[modelName] { return existingMOM  }
   guard let momURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else { return .empty }
   guard let newMOM = NSManagedObjectModel(contentsOf: momURL) else { return .empty }
   Self.moms[modelName] = newMOM
   return newMOM
  }
 }
 
 
 public enum StoreType
 {
  case inMemorySQLight  // init SQLite store with "/dev/null" in memory for Unit Testing.
  case persistedSQLight // init SQLite persisted store on disk for production.
 }
 
 
 public let modelName: String
 public let storeType: StoreType
 public let locationsProvider: NMGeoLocationsProvider
 

 public var mom: NSManagedObjectModel { Self[named: modelName] }
 
 private let mocIsq = DispatchQueue(label: "MOC access isolation queue")
 
 public var context: NSManagedObjectContext { mocIsq.sync{ persistentContainer.viewContext } }
 
 private func registerDataTransformers()
 {
  //if #available(iOS 12.0, *) {
   GenericDataSecureTransformer<NSValue>.register()
//  } else {
//   // Fallback on earlier versions
//  }
 
// if #available(iOS 12.0, *) {
  #if !os(macOS)
    GenericDataSecureTransformer<UIColor>.register()
  #endif
 //} else {
   // Fallback on earlier versions
 //}
 
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
 
 public init(name: String = "Model",
             for storeType: StoreType = .persistedSQLight,
             locationsProvider: NMGeoLocationsProvider = NMGeoLocationsProvider())
 {
  self.modelName = name
  self.storeType = storeType
  self.locationsProvider = locationsProvider
 }
}
