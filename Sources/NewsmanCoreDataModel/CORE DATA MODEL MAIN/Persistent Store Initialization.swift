import CoreData
import Foundation
import Combine

#if !os(macOS)
import UIKit
#endif

@available(iOS 13.0, *)
public extension NSManagedObjectContext{
 
 static let locationsProviderKey = "locationsProvider"
 var locationsProvider: NMGeoLocationsProvider? {
  get { userInfo[Self.locationsProviderKey] as? NMGeoLocationsProvider }
  set { userInfo[Self.locationsProviderKey] = newValue }
 }
 
}

public extension NSManagedObjectModel{
 static var empty: Self { .init() }
}

@available(iOS 14.0, *)
public final class NMCoreDataModel {
 
 public lazy var dateGroupStateUpdater = { () -> PassthroughSubject<() -> (), Never> in
  let subject = PassthroughSubject<() -> (), Never>()
  let interval = RunLoop.SchedulerTimeType.Stride(Self.dateGroupStateUpdateInterval)
  let blocks = NSMutableArray()
  
  dateGroupStateUpdaterSubscription = subject
   .scan(blocks){
     $0.add($1)
     return $0
   }
   .debounce(for: interval, scheduler: RunLoop.main)
   .print()
   .sink{ [ unowned self ]  in
    let blocks = $0.copy() as! [() -> ()]
     context.perform { blocks.forEach{$0()} }
    $0.removeAllObjects()
   }
  
  return subject
  
 }()
 
 var dateGroupStateUpdaterSubscription: AnyCancellable?
 
 public static var dateGroupStateUpdateInterval: TimeInterval = 0.1
 
 private static var moms: [String: NSManagedObjectModel] = [:]
 
 private static let momIsq = DispatchQueue(label: "MOM isolation queue")
 
 static private subscript(named modelName: String) -> NSManagedObjectModel {
  momIsq.sync {
   if let existingMOM = Self.moms[modelName] { return existingMOM  }
   guard let momURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else { return .empty }
   guard let newMOM = NSManagedObjectModel(contentsOf: momURL) else { return .empty }
   Self.moms[modelName] = newMOM
   return newMOM
  }
 }
 
 
 public enum StoreType {
  case inMemorySQLight  // init SQLite store with "/dev/null" in memory for Unit Testing.
  case persistedSQLight // init SQLite persisted store on disk for production.
 }
 
 
 public let modelName: String
 public let storeType: StoreType
 public let locationsProvider: NMGeoLocationsProvider
 

 public var mom: NSManagedObjectModel { NMCoreDataModel[named: modelName] }
 
 private let mocIsq = DispatchQueue(label: "MOC access isolation queue", attributes: [.concurrent])
 
 @available(iOS 15.0, macOS 12.0, *)
 @MainActor public var mainContext: NSManagedObjectContext {
  get async {
   let context = persistentContainer.viewContext
   await context.perform{ context.locationsProvider = self.locationsProvider }
   return context
  }
 }

 public var context: NSManagedObjectContext {
  mocIsq.sync {
   let context = persistentContainer.viewContext
   context.performAndWait { context.locationsProvider = locationsProvider }
   return context
   
  }
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 @MainActor public var newBackgroundContext: NSManagedObjectContext {
  get async {
   let bgContext = persistentContainer.newBackgroundContext()
   await bgContext.perform { bgContext.locationsProvider = self.locationsProvider }
   return bgContext
   
  }
 }
 
 public var bgContext: NSManagedObjectContext {
  mocIsq.sync {
   let bgContext = persistentContainer.newBackgroundContext()
   bgContext.performAndWait { bgContext.locationsProvider = locationsProvider }
   return bgContext
   
  }
 }
 
 
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
 
  if storeType == .inMemorySQLight {
   container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
  }
 
  container.loadPersistentStores { (storeDescription, error) in
   if let error = error as NSError?{
    fatalError("Unresolved error \(error), \(error.userInfo)")
   }
  }
  return container
 }()
 
 private func createDateGroupStateUpdaterSubscription(){
  
 }
 
 public init(name: String = "Model",
             for storeType: StoreType = .persistedSQLight,
             locationsProvider: NMGeoLocationsProvider = NMGeoLocationsProvider()) {
  
  self.modelName = name
  self.storeType = storeType
  self.locationsProvider = locationsProvider
  
  
   
 }
   

}
