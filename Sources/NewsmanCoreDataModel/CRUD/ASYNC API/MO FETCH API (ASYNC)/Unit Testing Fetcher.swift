
import Foundation
import CoreData
import Combine

@available(iOS 15.0, macOS 12.0, *)
public final class NMDateGroupTestableSnapshotFetchController<T: NSManagedObject>: NMSnapshotFetchController<T> {
 
 private var maxDaysToPublish: Int
 private var timerInterval: TimeInterval
 private var tolerance: TimeInterval
 
 public init(context: NSManagedObjectContext,
             fetchPredicate: NSPredicate = .always,
             sortDescriptors: [NSSortDescriptor],
             sectionNameKeyPath: String? = nil,
             cacheResults: Bool = false,
             maxDaysToPublish: Int = .max,
             timerInterval: TimeInterval = .oneMillisecond,
             tolerance: TimeInterval = .oneMillisecond * .oneMillisecond) {
  
  let configuration = NMSnapshotFetchControllerConfiguration(fetchPredicate: fetchPredicate,
                                                             sortDescriptors: sortDescriptors,
                                                             sectionNameKeyPath: sectionNameKeyPath,
                                                             cacheResults: cacheResults)
  
  self.maxDaysToPublish = maxDaysToPublish
  self.timerInterval = timerInterval
  self.tolerance = tolerance
  super.init(context: context, configuration: configuration)
  
 }
 
 internal override var newDayPublisher: AnyPublisher<Date, Never> {
  let date = Date()
  let startDay = Calendar.current.dateInterval(of: .day, for: date)!.end
  
   //  return (0...200)
   //   .publisher.map{startDay + TimeInterval($0) * .oneDay}
   //   .eraseToAnyPublisher()
   //
  var i = 0 {
   didSet {
    if i > maxDaysToPublish{ dateGroupStateUpdateSubscription?.cancel() }
   }
  }
  
  return Timer.publish(every: timerInterval,
                       tolerance: tolerance,
                       on: .main,
                       in: .common).autoconnect()
   .map {_ in
    defer { i += 1 }
    return startDay + TimeInterval(i) * .oneDay
   }.eraseToAnyPublisher()
 }
}
