// MARK: FETCH (READ) MO operations with model context with async API

import Combine
import CoreData
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif


extension NSDiffableDataSourceSnapshot: Equatable{
 public static func == (lhs: NSDiffableDataSourceSnapshot, rhs: NSDiffableDataSourceSnapshot) -> Bool {
  lhs.itemIdentifiers == rhs.itemIdentifiers && lhs.sectionIdentifiers == rhs.sectionIdentifiers
 }
}

@available(iOS 15.0, macOS 12.0, *)
public class NMSnapshotFetchController<T: NSManagedObject>: NSObject,
                                                            NSFetchedResultsControllerDelegate,
                                                            AsyncSequence {
 
 public typealias NMSnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
 
 public typealias Element = NMSnapshot
 
 public typealias NMSnapshotsStream = AsyncThrowingStream<NMSnapshot, Error>
 
 public typealias NMSnapshotsAsyncIterator = NMSnapshotsStream.Iterator
 
 public typealias NMSnapshotsContinuation = NMSnapshotsStream.Continuation
 
 public func makeAsyncIterator() -> NMSnapshotsAsyncIterator { snapshots.makeAsyncIterator() }
 
 let cacheName = UUID().uuidString
 
 unowned let context: NSManagedObjectContext
 
 var preSearchConfiguration: NMSnapshotFetchControllerConfiguration?
 
 public var configuration: NMSnapshotFetchControllerConfiguration {
  didSet {
   
   guard oldValue != configuration else { return }
   
   if oldValue.cacheResults { NSFetchedResultsController<T>.deleteCache(withName: cacheName) }
   
   let fpc =   (oldValue.fetchPredicate      != configuration.fetchPredicate)
   let sdc =   (oldValue.sortDescriptors     != configuration.sortDescriptors)
   let snkpc = (oldValue.sectionNameKeyPath  != configuration.sectionNameKeyPath)
   let crc =   (oldValue.cacheResults        != configuration.cacheResults)
   
   switch (fpc, sdc, snkpc, crc) {
    case (true, false, false, false):
     fetchRequest?.predicate = configuration.fetchPredicate
     context.perform { self.performFetch() }
     
    case (false, true, false, false):
     fetchRequest?.sortDescriptors = configuration.sortDescriptors
     context.perform { self.performFetch() }
     
    case (true, true, false, false):
  
     fetchRequest?.predicate = configuration.fetchPredicate
     fetchRequest?.sortDescriptors = configuration.sortDescriptors
     
     context.perform { self.performFetch() }
     
    case (_, _, _, true): fallthrough
     
    case (_, _, true, _):
     fetchResultsController = configueFetchResultsController()
     context.perform { self.performFetch() }
     
     
    default: break
   }
      
  }
 }
 

 
 private var continuation: NMSnapshotsContinuation? {
  didSet{
   context.perform { self.performFetch() }
  }
 }
 
 lazy var snapshots = { () -> NMSnapshotsStream in
  let snapshots = NMSnapshotsStream { continuation = $0 }
  return snapshots
 }()
 
 private func performFetch() {
  guard let frc = fetchResultsController else {
   continuation?.finish()
   return
  }
  
  do {
   try frc.performFetch()
   
  } catch {
   continuation?.finish(throwing: error)
  }
 }

 private lazy var fetchRequest = { () -> NSFetchRequest<T>? in
  guard let entityName = T.entity().name else { return nil }
  let fetchRequest = NSFetchRequest<T>(entityName: entityName)
  fetchRequest.predicate = configuration.fetchPredicate
  fetchRequest.sortDescriptors = configuration.sortDescriptors
  return fetchRequest
 }()
 
 private func configueFetchResultsController() -> NSFetchedResultsController<T>?{
  guard let fetchRequest = fetchRequest else { return nil }
  
  let frc = NSFetchedResultsController(fetchRequest: fetchRequest ,
                                       managedObjectContext: context,
                                       sectionNameKeyPath: configuration.sectionNameKeyPath,
                                       cacheName: configuration.cacheResults ? cacheName : nil)
  frc.delegate = self
  return frc
 }
 
 private lazy var fetchResultsController = configueFetchResultsController()
 
 @Published private var lastSnapshot: NMSnapshot?
 
 fileprivate var snapshotsObjectsPublisher: AnyPublisher<[NMDateGroupStateObservable], Never> {
  $lastSnapshot
   .compactMap{[ unowned self ] in
      $0?.itemIdentifiers
     .compactMap{ context.object(with: $0) as? NMDateGroupStateObservable}
     .filter{ $0.date != nil }
     .filter{ $0.isDeleted == false }
     .filter{ $0.managedObjectContext != nil }
   }.eraseToAnyPublisher()
 }
 
 var newDayPublisher: AnyPublisher<Date, Never> {
  let date = Date()
  let startDay = Calendar.current.dateInterval(of: .day, for: date)!.end
  let delay = RunLoop.SchedulerTimeType.Stride(date.distance(to: startDay))
  
  return Just(TimeInterval.oneDay)
   .delay(for: delay, scheduler: RunLoop.main)
   .flatMap{ Timer.publish(every: $0, tolerance: 1e-3, on: .main, in: .common).autoconnect() }
   .eraseToAnyPublisher()
 }
 
 fileprivate var dateGroupStateUpdatePublisher: AnyPublisher<([NMDateGroupStateObservable], Date), Never> {
  snapshotsObjectsPublisher
   .zip2Latest(with: newDayPublisher)
   .eraseToAnyPublisher()
 }
 
 var dateGroupStateUpdateSubscription: AnyCancellable?
 
 private func configueDateGroupStateUpdatePublisher(){
  guard dateGroupStateUpdateSubscription == nil else { return }
  
  dateGroupStateUpdateSubscription = dateGroupStateUpdatePublisher
   .sink{ [ unowned self ] (objects, today) in
    context.perform {
     objects.forEach{
      
      guard let date = $0.date else { return }
      let newGroup = NMBaseSnippet.DateGroup.current(of: date, at: today)
      
//      print($0.sectionDateIndexGroup, newGroup,
//            $0.date!.description(with: .current),
//            today.description(with: .current))
      
      $0.sectionDateIndexGroup = newGroup
      
     }
     
    
    }
    
   }
  
 }
 
 public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
  
  let snapshot = snapshot as NMSnapshot
  continuation?.yield(snapshot)
  lastSnapshot = snapshot
 }
 
 
 public convenience init(context: NSManagedObjectContext,
                         fetchPredicate: NSPredicate = .always,
                         sortDescriptors: [NSSortDescriptor],
                         sectionNameKeyPath: String? = nil,
                         cacheResults: Bool = false) {
 
  let configuration = NMSnapshotFetchControllerConfiguration(fetchPredicate: fetchPredicate,
                                                             sortDescriptors: sortDescriptors,
                                                             sectionNameKeyPath: sectionNameKeyPath,
                                                             cacheResults: cacheResults)
  self.init(context: context, configuration: configuration)
  

 }
 
 public init(context: NSManagedObjectContext, configuration: NMSnapshotFetchControllerConfiguration) {
  self.context = context
  self.configuration = configuration
  super.init()
  configueDateGroupStateUpdatePublisher()
 }
 
}



