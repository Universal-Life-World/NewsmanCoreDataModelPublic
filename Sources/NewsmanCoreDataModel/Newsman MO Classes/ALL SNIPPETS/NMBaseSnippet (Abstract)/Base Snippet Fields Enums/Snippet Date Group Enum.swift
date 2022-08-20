import Foundation
import Combine
import CoreData

protocol NMDateGroupStateObservable where Self: NSManagedObject {
 var sectionDateIndexGroup: NMBaseSnippet.DateGroup { get set }
 var date: Date? { get }
}

extension NMBaseSnippet: NMDateGroupStateObservable {}

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
 enum DateGroup: String, CaseIterable, NMEnumCasesStringLocalizable, Comparable, Codable {
  
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

