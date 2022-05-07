import XCTest
import NewsmanCoreDataModel

public func zip<A, B, C>(_ a: A, _ b: B, _ c: C) -> [(A.Element, B.Element, C.Element)]
               where A: Sequence, B: Sequence, C: Sequence {
 
 zip(a, zip(b,c)).map{($0.0, $0.1.0, $0.1.1)}
}

 //MARK: ALL SNIPPETS CREATION UNIT TESTS EXTENSION.
@available(iOS 15.0, macOS 12.0, *)
final class NMBaseSnippetsFetchingAsyncTests: NMBaseSnippetsAsyncTests {
 
 @MainActor lazy var window: UIWindow = { () -> UIWindow in
  let window = UIWindow(frame: UIScreen.main.bounds)
  window.makeKeyAndVisible()
  return window
 }()
 
 // Service method to be called on main thread setting window ROOT VC property with SUTS (snippets) table VC
 @MainActor func makeRootViewController(_ vc: UIViewController) async { window.rootViewController = vc }
 
 /* MARK: ---- ACRONYMS USED FOR TEST CASE DESCRIPTIONS BELOW -------
    MARK: (1) Diffable Data Source Snashot (NSDiffableDataSourceSnapshot) - DDSS
    MARK: (2) Snapshot Fetch Controller - SFC
    MARK: (3) CoreData NSFetchResultsController - FRC
    MARK: (4) Main thread NSManagedObjectContext - MMOC
    MARK: (5) Background thread NSManagedObjectContext - BGMOC
    MARK: (6) SUTS = NMBaseSnippet(s)
    MARK: (7) SUTS TVC = UIViewController with view == NMSnippetsTestableTableView
  
  */
 
 /* MARK: This test case tests that first DDSS is generated properly once the SFC is instantiated and queried for snapshots flow. The first DDSS should reflect the initial data state after initial fetch from MMOC. This test does not perform state reconcilation with associated table view!*/
 
 final func test_that_when_all_snippets_fetched_FIRST_DDSS_generated_properly_once() async throws {
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)

  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(keyPath: \NMBaseSnippet.nameTag, ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors)
  
  //ACTION...
  
  let snapshot = try await fetcher.first! //wait for 1st snapshot and finish...

  
  //ASSERT...
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == 1)
 
  //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 /* MARK: This test case tests that first DDSS is generated properly once the SFC is instantiated and queried for snapshots flow. The first DDSS should reflect the initial data state after initial fetch from MMOC. This test does perform state reconcilation with associated table view!*/
 
 final func test_when_FIRST_DDSS_fetched_and_applied_to_SUTS_TV_with_properly() async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  
   
  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(keyPath: \NMBaseSnippet.nameTag, ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors)
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
  
   //ASSERT...
   XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
   XCTAssertTrue(snapshot.numberOfSections == 1)
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   let tv_snapshot = dds.snapshot()
 
   XCTAssertEqual(tv_snapshot, snapshot)
   
   let TV_NS = dds.numberOfSections(in: tv)

   XCTAssertEqual(TV_NS, 1, "Testable TV must have only 1 section this test!")

   let itemsN =  dds.tableView(tv, numberOfRowsInSection: 0)

   XCTAssertEqual(itemsN, SUTS_COUNT, "Testable TV must have \(SUTS_COUNT) cells in this test!")
   
   let SUTS_TV_CELLS = ((0..<SUTS_COUNT)
    .compactMap{tv.cellForRow(at: IndexPath(row: $0, section: 0)) as? NMSnippetsTestableTableViewCell})
   
   XCTAssertEqual(SUTS_TV_CELLS.count, SUTS_COUNT)
   
   let cellNameTags = Set(SUTS_TV_CELLS.compactMap{ $0.nameTagLabelText })
   let SUTS_NameTags = Set(SUTS.compactMap{ $0.nameTag })
   
   XCTAssertEqual(cellNameTags, SUTS_NameTags)
   
   return true
   
  }
  
  //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
  // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
   
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 final func test_when_fetched_the_snapshot_generated_properly_once_with_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  
  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.nameTag)
  )
  
  
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    
    let nameTag = try XCTUnwrap(SUT.nameTag)
    
//    print(nameTag)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(nameTag, sectionName)
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
   }
  }
  
 
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 final func test_when_1st_DDSS_fetched_and_applied_to_SUTS_TV_DDS_with_section_name_equal_SUT_nameTag() async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  
  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.nameTag))
  
   //ACTION...
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
   
    //ASSERT...
   XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
   XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   let tv_snapshot = dds.snapshot()
   
   XCTAssertEqual(tv_snapshot, snapshot, "SUTS TV snapshot must be the the same as this one!")
   
   let TV_NS = dds.numberOfSections(in: tv)
   
   XCTAssertEqual(TV_NS, SECTIONS_COUNT, "Testable TV must \(SECTIONS_COUNT) sections in this test!")
   
   try await modelMainContext.perform {
    for SUT in SUTS {
     
     let nameTag = try XCTUnwrap(SUT.nameTag)
     
     let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
     XCTAssertEqual(nameTag, sectionName)
     
     let section = try XCTUnwrap(snapshot.indexOfSection(sectionName))
     
     let tv_section_title = dds.tableView(tv, titleForHeaderInSection: section)
     XCTAssertEqual(tv_section_title, nameTag)
     
     let cellIndexPath = IndexPath(row: 0, section: section)
     
     let cell = try XCTUnwrap(tv.cellForRow(at: cellIndexPath) as? NMSnippetsTestableTableViewCell)
     let cellNameTag = try XCTUnwrap(cell.nameTagLabelText)
     
     XCTAssertEqual(nameTag, cellNameTag)
     
     XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
     let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
     XCTAssertEqual(SUT_ID, SUT.objectID)
    }
   }
   
   return true
  }
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }

 final func test_when_fetched_the_snapshot_generated_properly_once_with_alfa_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_NAMES = ["Audio", "Base", "Mixed", "Photo", "Text", "Video"]
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
 
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    let nameTag = try XCTUnwrap(SUT.nameTag)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(sectionName, String(nameTag.prefix(1)))
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
    let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
    let nameTagIndex = try XCTUnwrap(SUTS_NAMES.firstIndex(of:nameTag))
    XCTAssertEqual(sectionIndex, nameTagIndex)
   }
  }
  
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 
 final func test_when_1st_DDSS_fetched_with_ALFA_sections_TV_with_DDS_has_proper_state() async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_NAMES = ["Audio", "Base", "Mixed", "Photo", "Text", "Video"]
  
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
  
  
   //ACTION...
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
   
    //ASSERT...
   XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
   XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   let tv_snapshot = dds.snapshot()
   
   XCTAssertEqual(tv_snapshot, snapshot, "SUTS TV snapshot must be the the same as this one!")
   
   let TV_NS = dds.numberOfSections(in: tv)
   
   XCTAssertEqual(TV_NS, SECTIONS_COUNT, "Testable TV must \(SECTIONS_COUNT) sections in this test!")
   
   try await modelMainContext.perform {
    for SUT in SUTS {
     let nameTag = try XCTUnwrap(SUT.nameTag)
     let sectionTitle = String(nameTag.prefix(1))
     let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
     XCTAssertEqual(sectionName, sectionTitle)
     XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
     let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
     XCTAssertEqual(SUT_ID, SUT.objectID)
     let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
     let nameTagIndex = try XCTUnwrap(SUTS_NAMES.firstIndex(of:nameTag))
     XCTAssertEqual(sectionIndex, nameTagIndex)
     
     let tv_section_title = dds.tableView(tv, titleForHeaderInSection: sectionIndex)
     XCTAssertEqual(tv_section_title, sectionTitle)
     
     let cellIndexPath = IndexPath(row: 0, section: sectionIndex)
     
     
     let cell = try XCTUnwrap(tv.cellForRow(at: cellIndexPath) as? NMSnippetsTestableTableViewCell)
     let cellNameTag = try XCTUnwrap(cell.nameTagLabelText)
     
     XCTAssertEqual(nameTag, cellNameTag)
     
    }
   }
  
   return true
  }
  
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 final func test_when_context_did_change_with_alfa_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_NAMES = ["Audio", "Base", "Mixed", "Photo", "Text", "Video"]
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
 
  
   //ACTION...
  
  var count = 0
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
   defer { count += 1 }
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   return try await modelMainContext.perform {
    switch count {
     case 0:
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      
      for SUT in SUTS {
       let nameTag = try XCTUnwrap(SUT.nameTag)
       let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
       let alphaIndex = String(nameTag.prefix(1))
       XCTAssertEqual(sectionName, alphaIndex )
       XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
       let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
       XCTAssertEqual(SUT_ID, SUT.objectID)
       let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
       let nameTagIndex = try XCTUnwrap(SUTS_NAMES.firstIndex(of:nameTag))
       XCTAssertEqual(sectionIndex, nameTagIndex)
       
       if alphaIndex == "A" {
        Task.detached {
         try await Task.sleep(milliseconds: 100)
         await modelMainContext.perform { SUT.nameTag = "Video" }
         
        }
       }
      }
      
      
     case 1:
      XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT - 1)
      
      for SUT in SUTS {
       let nameTag = try XCTUnwrap(SUT.nameTag)
       let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
       let alphaIndex = String(nameTag.prefix(1))
       XCTAssertEqual(sectionName, alphaIndex )
       if alphaIndex == "V" {
        XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 2)
       } else {
        XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
        
       }
       
       Task.detached {
        try await Task.sleep(milliseconds: 100)
        await modelMainContext.perform { SUTS.forEach{ $0.nameTag = "A" } }
  
       }
       
      }
      
      case 2:
       XCTAssertEqual(snapshot.numberOfSections, 1)
       let sectionName = try XCTUnwrap(snapshot.sectionIdentifiers.first)
       XCTAssertEqual(sectionName, "A")
       XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), SUTS_COUNT)
       let cells = (0..<SUTS_COUNT)
                    .map{ IndexPath(row: $0, section: 0) }
                    .compactMap{ tv.cellForRow(at: $0) as? NMSnippetsTestableTableViewCell }
       
       XCTAssertEqual(cells.count, SUTS_COUNT)
       XCTAssertTrue(cells.allSatisfy{ $0.nameTagLabelText == "A" })
      
       let tv_section_title = dds.tableView(tv, titleForHeaderInSection: 0)
       XCTAssertEqual(tv_section_title, "A")
       
       
     default: break
    }
    
    return count == 2
   }
  }
  
  
  
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
 
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
  
 }//final func test_when_context_did_change_with_alfa_sections...
 
 final func test_when_fetched_the_snapshot_generated_properly_once_with_PRIORITY_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_PRIORITIES: [NMBaseSnippet.SnippetPriority] = [.hottest, .hot, .high, .normal, .medium, .low]

  
  await modelMainContext.perform {
   zip(SUTS, SUTS_PRIORITIES).forEach { pair in
    pair.0.nameTag = pair.1.rawValue
    pair.0.priority = pair.1
   }
  }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: NMBaseSnippet.priorityKey)
  
  
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    let nameTag = try XCTUnwrap(SUT.nameTag)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(sectionName, nameTag)
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
    
    
    let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
    //print (sectionName, sectionIndex)
    let nameTagIndex = try XCTUnwrap(SUTS_PRIORITIES.firstIndex(of: SUT.priority))
    XCTAssertEqual(sectionIndex, nameTagIndex)
   }
  }
  
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 final func test_when_fetched_the_snapshot_generated_properly_once_with_TYPES_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.sectionTypeIndex), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionTypeIndex))
  
  
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    let typeTitle = try XCTUnwrap(SUT.sectionTypeIndex)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(sectionName, typeTitle)
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
    
    
    let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
    let typeIndex = Int(SUT.type.rawValue)
    XCTAssertEqual(sectionIndex, typeIndex)
    
    let titlePrefix = try XCTUnwrap(Int(typeTitle.prefix(1)))
    XCTAssertEqual(sectionIndex, titlePrefix)
   }
  }
  
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 
 final func test_when_context_did_change_with_DATE_GROUP_sections () async throws {
 
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 1
  let SUTS_NAMES = ["A", "B", "C", "D", "E", "F"]
  
  let NOW = Date()
  let CC = Calendar.current
  let EOY = try XCTUnwrap(CC.dateInterval(of: .year, for: NOW)?.end)
  let DAYS_COUNT = try XCTUnwrap(CC.dateComponents([.day], from: NOW, to: EOY).day) + 1
  
  
  await modelMainContext.perform {
   zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 }
  }
  
  let sortDescriptors = [NSSortDescriptor(key: NMBaseSnippet.sectionDateIndexKey, ascending: true)]
  let SKP = NMBaseSnippet.sectionDateIndexKey
  let fetcher = NMDateGroupTestableSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                                          sortDescriptors: sortDescriptors,
                                                                          sectionNameKeyPath: SKP)
  
  //ACTION...
  
  var SNAPSHOT_COUNT = 0
  
  let randomSnapshot = Int.random(in: 1..<DAYS_COUNT)

  for try await snapshot in fetcher  {
   
   XCTAssertEqual(snapshot.numberOfItems, SUTS_COUNT)
   XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT)
   
   let sectionIDs = Set(snapshot.sectionIdentifiers)
   
   XCTAssertEqual(sectionIDs.count, SECTIONS_COUNT)
   
   let sectionID = try XCTUnwrap(sectionIDs.first)
   let dateGroup = try XCTUnwrap(NMBaseSnippet.DateGroup(rawValue: sectionID))
   
   if SNAPSHOT_COUNT == randomSnapshot {
    await modelMainContext.perform { SUTS.randomElement()?.nameTag = "X" }
   }
   
   if SNAPSHOT_COUNT > randomSnapshot  {
    await modelMainContext.perform {
     let SUTS = snapshot.itemIdentifiers.compactMap{ modelMainContext.object(with: $0) as? NMBaseSnippet}
     XCTAssertTrue(SUTS.contains{ $0.nameTag == "X" })
    }
   }
   
   
   if dateGroup == .lastYear {
    XCTAssertEqual(SNAPSHOT_COUNT, DAYS_COUNT + 1)
    break
   }
   
   SNAPSHOT_COUNT += 1

  }
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
  
 }//final func test_when_context_did_change_with_alfa_sections...
 
 /* MARK: Thest that when all 6 snippet types date group fields are periodically modified on day by day basis the new diffable data source snapshots are emitted properly by async stream fetcher object and thereafter when new objects inserted and deleted. */
 
 final func test_when_context_did_change_with_DATE_GROUP_sections_INSERTIONS_and_DELETIONS () async throws {

  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 1
  let SUTS_NAMES = ["A", "B", "C", "D", "E", "F"]

  let NOW = Date()
  let CC = Calendar.current
  let EOY = try XCTUnwrap(CC.dateInterval(of: .year, for: NOW)?.end)
  let DAYS_COUNT = try XCTUnwrap(CC.dateComponents([.day], from: NOW, to: EOY).day) + 1

  let randomEntity = [NMBaseSnippet.self,
                      NMTextSnippet.self,
                      NMPhotoSnippet.self,
                      NMVideoSnippet.self,
                      NMAudioSnippet.self,
                      NMMixedSnippet.self].randomElement()!



  await modelMainContext.perform {
   zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 }
  }

  let sortDescriptors = [NSSortDescriptor(key: NMBaseSnippet.sectionDateIndexKey, ascending: true)]

  let SKP = NMBaseSnippet.sectionDateIndexKey

  let fetcher = NMDateGroupTestableSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                                          sortDescriptors: sortDescriptors,
                                                                          sectionNameKeyPath: SKP)

   //ACTION...

  var SNAPSHOT_COUNT = 0

  let insertSnapshot = Int.random(in: 1...DAYS_COUNT / 2)
  let deleteSnapshot = Int.random(in: DAYS_COUNT / 2 + 2..<DAYS_COUNT + 2)

  for try await snapshot in fetcher  {

   let sectionIDs = Set(snapshot.sectionIdentifiers)

   switch SNAPSHOT_COUNT {
    case 0..<insertSnapshot, (deleteSnapshot + 1)... :
     XCTAssertEqual(sectionIDs.count, SECTIONS_COUNT)
     XCTAssertEqual(snapshot.numberOfItems, SUTS_COUNT)
     XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT)

    case insertSnapshot:
     try await model.create(persist: true, entityType: randomEntity) {
      ($0 as? NMBaseSnippet)?.nameTag = "INS"
      ($0 as? NMBaseSnippet)?.date = Date() + .oneDay * TimeInterval(insertSnapshot)
     }
     
     
    case insertSnapshot + 1:
     //print (SNAPSHOT_COUNT, snapshot.sectionIdentifiers)
     XCTAssertEqual(snapshot.numberOfItems, SUTS_COUNT + 1)
     XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT + 1)
     
     
    case insertSnapshot + 2:
     await modelMainContext.perform {
      let SUTS = snapshot.itemIdentifiers.compactMap{modelMainContext.object(with: $0) as? NMBaseSnippet}
      XCTAssertTrue(SUTS.contains{ $0.nameTag == "INS" })
     }
     
    case deleteSnapshot:
     try await modelMainContext.perform {
      let SUT_INS = try XCTUnwrap(snapshot.itemIdentifiers
                                          .compactMap{modelMainContext.object(with: $0) as? NMBaseSnippet}
                                          .first{$0.nameTag == "INS"})
      modelMainContext.delete(SUT_INS)
     }
     
   
  
    default: break
   }




   let sectionID = try XCTUnwrap(sectionIDs.first)
   let dateGroup = try XCTUnwrap(NMBaseSnippet.DateGroup(rawValue: sectionID))

   
   if dateGroup == .lastYear {
    XCTAssertEqual(SNAPSHOT_COUNT, DAYS_COUNT + 2)
    break
   }

   SNAPSHOT_COUNT += 1

  }


   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)


 }//final func test_when_context_did_change_with_alfa_sections...
 
 
 final func test_when_SORT_ORDER_TOGGLED_with_alfa_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)

  let SUTS_NAMES = ["Aaaa", "Abbb", "Accc", "Addd", "Aeee", "Afff"]
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
  
  
   //ACTION...
  
  var count = 0
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
   defer { count += 1 }
   
   //let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   
   //let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   return await modelMainContext.perform {
    
    XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
    XCTAssertTrue(snapshot.numberOfSections == 1)
    
    let snippetsTVCells = ((0..<SUTS_COUNT)
     .compactMap{tv.cellForRow(at: IndexPath(row: $0, section: 0)) as? NMSnippetsTestableTableViewCell})
    
    print(snippetsTVCells.map(\.frame))
    
    XCTAssertEqual(snippetsTVCells.count, SUTS_COUNT)
    
    let snapshotSnippets = snapshot.itemIdentifiers.compactMap{ modelMainContext.object(with: $0) as? NMBaseSnippet}
    
    let snapshotItemsTags = snapshotSnippets.compactMap(\.nameTag)
    let cellNameTags = snippetsTVCells.compactMap(\.nameTagLabelText)
    
    let orderedAbouts = Array(1...SUTS_COUNT).map{ String($0)}
    
    let snapshotAbouts = snapshotSnippets.compactMap(\.about)
    
    let cellsAbouts = snippetsTVCells.compactMap(\.aboutLabelText)
    
    switch count {
      
     case 0:
      XCTAssertEqual(snapshotItemsTags, SUTS_NAMES)
      XCTAssertEqual(cellNameTags, SUTS_NAMES)
                                     
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.toggleSortOrder()
      }
      
     case 1:
      XCTAssertEqual(snapshotItemsTags, SUTS_NAMES.reversed())
      XCTAssertEqual(cellNameTags, SUTS_NAMES.reversed())
      
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await modelMainContext.perform {
     
        while true {
         let shuffled = orderedAbouts.shuffled()
         if ( shuffled != orderedAbouts ) {
          zip(SUTS, shuffled).forEach{ $0.0.nameTag = "A"; $0.0.about = $0.1 }
          break
         }
        }
       }
      }
     
     case 2:
      
      XCTAssertNotEqual(snapshotAbouts, orderedAbouts)
      XCTAssertNotEqual(cellsAbouts, orderedAbouts)
     
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.apply(sortOrder: .descending(keyPath: \NMBaseSnippet.about))
       
      }
      
     case 3:
      XCTAssertEqual(snapshotAbouts, orderedAbouts.reversed())
      XCTAssertEqual(cellsAbouts, orderedAbouts.reversed())
      
     default: break
      
    }
    
    return count == 3
   }
  }
  
  
  
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
  
 }//final func test_when_context_did_change_with_alfa_sections...
 
 
}//final class NMBaseSnippetsFetchingAsyncTests: NMBaseSnippetsAsyncTests
