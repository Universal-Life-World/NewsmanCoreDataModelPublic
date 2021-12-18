import XCTest
import NewsmanCoreDataModel

final class NMCoreDataModelBasicTests: XCTestCase
{
 
 var sut: NMCoreDataModel!
 
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
 
 @available(macOS 12.0.0, *)
 func test_that_when_loaded_with_named_MOM_PS_contains_saved_objects() async throws
 {
  let MOC = sut.context
 
  let entityName = "NMBaseSnippet"
  
 
  let modelObjects = try await MOC.perform { () throws -> [NSManagedObject] in
   let objs = (1...10).map{ _ -> NSManagedObject in
     let ob = NSEntityDescription.insertNewObject(forEntityName: entityName, into: MOC)
     ob.setValue(UUID(), forKey: "id")
     ob.setValue(Date(), forKey: "date")
     ob.setValue(entityName, forKey: "type")
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
 
}

