
import Foundation

@available(iOS 13.0, *)
public extension NMBaseContent {
 enum ContentPriority: String, CaseIterable, Codable,
                       NMEnumCasesStringLocalizable,
                       NMEnumOptionalCasesManageable, Comparable {
  
  public static func < (lhs: ContentPriority, rhs: ContentPriority) -> Bool { lhs.section < rhs.section }
  
  public static var isolationQueue =  DispatchQueue(label: "Content Priority")
  
  static public var enabled = Dictionary(uniqueKeysWithValues: allCases.map{($0, true)})
  
  static let prioritySectionsMap: [Self: Int] = [
   .hottest : 0,  //priority index = 0_hottest
   .hot :     1,  //priority index = 1_hot
   .high :    2,  //priority index = 2_high
   .normal :  3,  //priority index = 3_normal
   .medium :  4,  //priority index = 4_medium
   .low :     5   //priority index = 5_low
  ]
  
  
  var section: Int { Self.prioritySectionsMap[self]!}
  
  static let strings: [String] = allCases.map{ $0.rawValue }
  
  case hottest =  "0_Hottest"
  case hot     =  "1_Hot"
  case high    =  "2_High"
  case normal  =  "3_Normal"
  case medium  =  "4_Medium"
  case low     =  "5_Low"
  
 }
 
}
