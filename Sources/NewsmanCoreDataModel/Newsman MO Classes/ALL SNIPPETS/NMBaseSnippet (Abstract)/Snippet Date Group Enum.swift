import Foundation
import Combine
import CoreData


protocol NMDateGroupStateObservable where Self: NSManagedObject {
// var currentTimerCancellable: AnyCancellable?   { get set }
// var dateGroupStateUpdater: PassthroughSubject<() -> (), Never>? { get set }
 var sectionDateIndexGroup: NMBaseSnippet.DateGroup { get set }
 var date: Date? { get }
}

extension NMBaseSnippet: NMDateGroupStateObservable {}

//extension NMBaseSnippet: NMDateGroupStateObservable {
//
// func sheduleDateGroupTimerAfterFetch() {}
//
// func sheduleDateGroupTimer(from date: Date){
//
//  let startTime = Calendar.current.dateInterval(of: Self.fireDateCalendarComponent, for: date)!.end
//  let startDay = Calendar.current.dateInterval(of: .day, for: date)!.end
//  let delay = RunLoop.SchedulerTimeType.Stride(date.distance(to: startTime))
//  var dayCount = 0
//
//  currentTimerCancellable = Just(Self.currentTimerInterval)
//   .delay(for: delay, scheduler: RunLoop.main)
//   .flatMap{ Timer.publish(every: $0, tolerance: 0.001, on: .main, in: .common).autoconnect() }
//   .map {_ in startDay + TimeInterval(dayCount) * .oneDay}
//   .sink{ [ unowned self ] now in
//     dayCount += 1
//     managedObjectContext?.perform { [ weak self ] in
//      guard let self = self else { return }
//      let newGroup = self.sectionDateIndexGroup.nextInterval(date: date, now: now)
//      guard newGroup != self.sectionDateIndexGroup else { return }
//
//      let updateBlock = {[ weak self ] () -> () in self?.sectionDateIndexGroup = newGroup }
//
//      self.dateGroupStateUpdater?.send(updateBlock)
//     }
//
//    }
//
// }
//}

public extension TimeInterval {
 static let oneMillisecond = 1e-3
 static let oneNanosecond = 1e-9
 static let oneSecond = 1.0
 static let oneMinute = 60.0
 static let oneHour = oneMinute * 60
 static let oneDay = 24.0 * oneHour
 static let twoDays = oneDay * 2
 static let threeDays = oneDay * 3
 static let oneWeek = 7 * oneDay
 static let twoWeeks = 2 * oneWeek
 
}


@available(iOS 13.0, *)
public extension NMBaseSnippet {
 enum DateGroup: String, CaseIterable, NMEnumCasesStringLocalizable, Comparable {
  
  public static func current(of date: Date, at today: Date) -> Self {
    //check for .today
   let cc = Calendar.current
   
   let todayInt = cc.dateInterval(of: .day, for: date)!
   if today >= todayInt.start && today < todayInt.end { return .today }

    //check for .lastYear
   let thisYearInt = cc.dateInterval(of: .year, for: date)!
   let lastYearInt = cc.dateInterval(of: .year, for: thisYearInt.end)!
   if today >= lastYearInt.start && today < lastYearInt.end { return .lastYear }
   
    //case .lastMonth:
   let thisMonthInt = cc.dateInterval(of: .month, for: date)!
   let lastMonthInt = cc.dateInterval(of: .month, for: thisMonthInt.end)!
   if today >= lastMonthInt.start && today < lastMonthInt.end { return .lastMonth }
   
    //case .lastWeek:
   let lastWeekInt = cc.dateInterval(of: .weekOfMonth, for: date + .oneWeek)!
   if today >= lastWeekInt.start && today < lastWeekInt.end {
    return .lastWeek
    
   }
   
    //case .yesterday:
   let yestdInt = cc.dateInterval(of: .day, for: date + .oneDay)!
   if today >= yestdInt.start && today < yestdInt.end { return .yesterday }
   
    //case .beforeYesterday:
   let beforeYestInt = cc.dateInterval(of: .day, for: date + .twoDays)!
   if today >= beforeYestInt.start && today < beforeYestInt.end { return .beforeYesterday }
   
    //case .thisWeek:
   let thisWeekInt = cc.dateInterval(of: .weekOfMonth, for: date)!
   if today >= thisWeekInt.start && today < thisWeekInt.end { return .thisWeek }
   
    //case .thisMonth:
   if today >= thisMonthInt.start && today < thisMonthInt.end { return .thisMonth }
   
    //case .thisYear:
   if today >= thisYearInt.start && today < thisYearInt.end { return .thisYear }
   
   return .later
   
  }
  
  public static func < (lhs: NMBaseSnippet.DateGroup,
                        rhs: NMBaseSnippet.DateGroup) -> Bool { lhs.section < rhs.section }
 
  private static let dateGroupSectionsMap: [Self: Int] = [
    .today           : 0, //"0_Today"
    .yesterday       : 1, //"1_Yesterday"
    .beforeYesterday : 2, //"2_The Day Before Yesteday"
    .thisWeek        : 3, //"3_This Week"
    .lastWeek        : 4, //"4_Last Week"
    .thisMonth       : 5, //"5_This Month"
    .lastMonth       : 6, //"6_Last Month"
    .thisYear        : 7, //"7_This Year"
    .lastYear        : 8, //"8_Last Year"
    .later           : 9  //"9_Later"
  ]
  
  
  
  
  public var section: Int { Self.dateGroupSectionsMap[self]!}
  
  static let strings: [ String ] = allCases.map{ $0.rawValue }
  
  case today           = "0_Today"
  case yesterday       = "1_Yesterday"
  case beforeYesterday = "2_The Day Before Yesteday"
  case thisWeek        = "3_This Week"
  case lastWeek        = "4_Last Week"
  case thisMonth       = "5_This Month"
  case lastMonth       = "6_Last Month"
  case thisYear        = "7_This Year"
  case lastYear        = "8_Last Year"
  case later           = "9_Later"
  
  
 }
 
}

