import CoreData
import Foundation
@available(macOS 10.13, *)
public final class NMCoreDataModel
{
 public enum StoreType
 {
  case inMemorySQLight
  case persistedSQLight
 }
 
 public let context: NSManagedObjectContext
  
 public init(name: String = "Model", for storeType: StoreType = .persistedSQLight)
 {
  let mom = { () -> NSManagedObjectModel in
   let defaultMOM = NSManagedObjectModel()
   
   guard let momURL = Bundle(for: NMCoreDataModel.self).url(forResource: name, withExtension: "momd") else
   {
    return defaultMOM
   }
   
   guard let mom = NSManagedObjectModel(contentsOf: momURL) else { return defaultMOM }
   
   return mom
  }
 
  let persistentContainer = { () -> NSPersistentContainer in
  
   let container = NSPersistentContainer(name: name, managedObjectModel: mom())
  
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
  
  self.context = persistentContainer.viewContext
 }
}
