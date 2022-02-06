import XCTest
import NewsmanCoreDataModel
import CoreData

@available(iOS 14.0, *)
final class NMCoreDataModelBasicTests: XCTestCase
{
 
 var sut: NMCoreDataModel!
 var kvo_tokens = Set<NSKeyValueObservation>()
 
 override class func setUp()
 {
  //print("CLASS function", #function)
 }
 
 override func setUpWithError() throws
 {
  //print(#function)
 }
 
 
 override func setUp()
 {
  //print(#function)
  sut = NMCoreDataModel(name: "Newsman", for: .inMemorySQLight)
  
 
 }
 
 override func tearDown()
 {
  //print(#function)
  sut = nil
  kvo_tokens.removeAll()
 }
 
 override func tearDownWithError() throws
 {
  //print(#function)
 }

 override class func tearDown()
 {
  //print("CLASS function", #function)
 }

 func test_that_in_memory_model_loaded_with_default_MOM() throws
 {
  sut = NMCoreDataModel(for: .inMemorySQLight)
  XCTAssertNotNil(sut.context.persistentStoreCoordinator)
  XCTAssertEqual(sut.context.persistentStoreCoordinator!.persistentStores.count, 1)
  XCTAssertEqual(sut.context.persistentStoreCoordinator!.managedObjectModel.entities.count, 0)
 }
 
 
 func test_that_when_loaded_with_named_MOM_entities_exist() throws
 {
  let MOC = sut.context
  let PSC = try XCTUnwrap(MOC.persistentStoreCoordinator)
 
  XCTAssertFalse(PSC.persistentStores.isEmpty)
 
  let MOM =  PSC.managedObjectModel
  let entities = MOM.entities
 
  XCTAssertFalse(entities.isEmpty)
  XCTAssertTrue(entities.contains{$0.isAbstract})
  
 }
 
 
 func test_that_when_loaded_with_named_MOM_PS_is_empty() throws
 {
  let MOC = sut.context
  let PSC = try XCTUnwrap(MOC.persistentStoreCoordinator)
  let MOM =  PSC.managedObjectModel
  let entities = MOM.entities
  
  let count = try entities.compactMap{$0.name}
                          .map{NSFetchRequest<NSFetchRequestResult>(entityName: $0)}
                          .reduce(0) { $0 + (try MOC.count(for: $1))}
 

  XCTAssertEqual(count, 0)
 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 func test_that_when_loaded_with_named_MOM_PS_contains_saved_objects() async throws
 {
  let MOC = sut.context
  let entityName = "NMBaseSnippet"
  
  let modelObjects = try await MOC.perform { () throws -> [NSManagedObject] in
   
   let objs = (1...10).map{ _ -> NSManagedObject in
     
    let ob = NMBaseSnippet(context: MOC)
    return ob
   }
   
   try MOC.save()
   return objs
  }
    

 
  let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
  let pred = NSPredicate(format: "SELF.type == %@", entityName)
  fr.predicate = pred
  let count = try MOC.count(for: fr)
 
  XCTAssertEqual(count, modelObjects.count)
 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 func test_object_saved_and_fetched_MO_has_the_same_identity() async throws
 {
  let MOC = sut.context
  let baseSnippet = try await MOC.perform{ () throws -> NMBaseSnippet in
   
   let ob = NMBaseSnippet(context: MOC)
   XCTAssertTrue(ob.objectID.isTemporaryID)
   try MOC.save()
   XCTAssertFalse(ob.objectID.isTemporaryID)
   return ob
  }
  
 
  let baseRequest = NMBaseSnippet.fetchRequest()
  let baseFetched = try XCTUnwrap( MOC.fetch(baseRequest).first)
  XCTAssertEqual(baseFetched.id,  baseSnippet.id)
  XCTAssertEqual(baseSnippet.objectID,  baseFetched.objectID)

 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 func test_primitive_properties_does_not_send_KVO_nonifications() async  throws
 {
 
  let MOC = sut.context
  //insert new NMBaseSnippet into context & save changes into persistent store.
  try await MOC.perform { () throws -> () in
   let _ = NMBaseSnippet(context: MOC)
   try MOC.save()
  }

  // fetch this single object
  let fr = NMBaseSnippet.fetchRequest()
  let base = try XCTUnwrap(MOC.fetch(fr).first)
  
  let ex1 = XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.nameTag), object: base)
  let ex2 = XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.about), object: base)
  let ex3 = XCTKVOExpectation(keyPath: NMBaseSnippet.statusKey, object: base)
  let ex4 = XCTKVOExpectation(keyPath: NMBaseSnippet.typeKey, object: base)
 
  ex1.isInverted = true
  ex2.isInverted = true
  ex3.isInverted = true
  ex4.isInverted = true
 
  // mutate async its primitive properties...
 Task.detached {
   await withTaskGroup(of: Void.self, returning: Void.self)
   { group in
     group.addTask {
      await MOC.perform {
       base.setPrimitiveValue("Test", forKey: #keyPath(NMBaseSnippet.nameTag))
      }
     }
     group.addTask {
      await MOC.perform {
       base.setPrimitiveValue("About", forKey: #keyPath(NMBaseSnippet.about))
      }
     }
     group.addTask {
      await MOC.perform{
       base.setPrimitiveValue("New", forKey: NMBaseSnippet.statusKey)
      }
     }
    
     group.addTask {
     await MOC.perform {
      base.setPrimitiveValue(5, forKey: NMBaseSnippet.typeKey)
     }
    }
    
    // MARK: Assert additionally that its properties have been properly mutated in this task group.
    await group.waitForAll() //wait all tasks in group to complete mutating async MO properties!!!

    await MOC.perform {
     XCTAssertEqual(base.nameTag, "Test")
     XCTAssertEqual(base.about,   "About")
     XCTAssertEqual(base.status,  .new)
     XCTAssertEqual(base.type,    .mixed)
    }
    
   }
  
  }
 
  // await for KVO notifivations of above mutations...
  let result = XCTWaiter.wait(for: [ex1, ex2, ex3, ex4], timeout: 0.1)
 
  // MARK: ASSERT: There are no KVO notifications!
  XCTAssertEqual(result, .completed)
 
  
//  XCTAssertEqual(base.nameTag, "Test")
//  XCTAssertEqual(base.about,   "About")
//  XCTAssertEqual(base.status,  "New")
//  XCTAssertEqual(base.type,    .mixed)
 }
 
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 func test_primitive_properties_does_not_send_Context_Did_Change_notifications() async throws
 {
 
  let MOC = sut.context
  //insert new NMBaseSnippet into context & save changes into persistent store.
  try await MOC.perform { () throws -> () in
   let _ = NMBaseSnippet(context: MOC)
   try MOC.save()
  }

  // fetch this single object
  let fr = NMBaseSnippet.fetchRequest()
  let base = try XCTUnwrap(MOC.fetch(fr).first)
  
  let expect = XCTNSNotificationExpectation(name: .NSManagedObjectContextObjectsDidChange,
                                            object: MOC,
                                            notificationCenter: .default)
 
  Task.detached {
   await withTaskGroup(of: Void.self, returning: Void.self)
   { group in
     group.addTask {
      await MOC.perform {
       base.setPrimitiveValue("Test", forKey: #keyPath(NMBaseSnippet.nameTag))
      }
     }
     group.addTask {
      await MOC.perform {
       base.setPrimitiveValue("About", forKey: #keyPath(NMBaseSnippet.about))
      }
     }
     group.addTask {
      await MOC.perform{
       base.setPrimitiveValue("New", forKey:NMBaseSnippet.statusKey)
      }
     }
    
     group.addTask {
      await MOC.perform {
       base.setPrimitiveValue(5, forKey: NMBaseSnippet.typeKey)
      }
     }
    
   //MARK: ASSERT! its properties have been mutated properly!
    await group.waitForAll()

    await MOC.perform {
     XCTAssertEqual(base.nameTag, "Test")
     XCTAssertEqual(base.about,   "About")
     XCTAssertEqual(base.status,  .new)
     XCTAssertEqual(base.type,    .mixed)
    }
    
   }
  
  }
 
  // await for NSManagedObjectContextObjectsDidChange notifivations of above mutations...
  let result = XCTWaiter.wait(for: [expect], timeout: 0.1)
 
  //MARK: ASSERT! There are no NSManagedObjectContextObjectsDidChange notifications!
  XCTAssertNotEqual(result, .completed)
 
  
 
//  await handle.value
//  XCTAssertEqual(base.nameTag, "Test")
//  XCTAssertEqual(base.about,   "About")
//  XCTAssertEqual(base.status,  "New")
//  XCTAssertEqual(base.type,    .mixed)
 }
 
}

