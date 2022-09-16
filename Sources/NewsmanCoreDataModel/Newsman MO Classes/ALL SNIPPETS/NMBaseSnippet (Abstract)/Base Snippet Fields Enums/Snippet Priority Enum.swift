
import Foundation

@available(iOS 13.0, *)
public extension NMBaseSnippet {
 enum SnippetPriority: String, CaseIterable, Codable,
                       NMEnumCasesStringLocalizable,
                       NMEnumOptionalCasesManageable, Comparable {
  public static func < (lhs: SnippetPriority, rhs: SnippetPriority) -> Bool { lhs.section < rhs.section }
  
  public static var isolationQueue =  DispatchQueue(label: "Snippet Priority")
 
  static public var enabled = Dictionary(uniqueKeysWithValues: allCases.map{($0, true)})
  
  static let prioritySectionsMap: [Self: Int] = [
   .hottest : 0,  //priority index = 0_Hottest
   .hot :     1,  //priority index = 1_Hot
   .high :    2,  //priority index = 2_High
   .normal :  3,  //priority index = 3_Normal // default set by MOM when owner cerated in context!
   .medium :  4,  //priority index = 4_Medium
   .low :     5   //priority index = 5_Low
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
