
import Foundation

public extension NMBaseSnippet
{
 enum SnippetPriority: String, CaseIterable, NMEnumCasesStringLocalizable, NMEnumOptionalCasesManageable
 {
  public static var isolationQueue =  DispatchQueue(label: "Snippet Priority")
 
  static public var enabled = Dictionary(uniqueKeysWithValues: allCases.map{($0, true)})
  
  static let prioritySectionsMap: [Self: Int] =
  [
   .hottest : 0,  //priority index = 0_hottest
   .hot :     1,  //priority index = 1_hot
   .high :    2,  //priority index = 2_high
   .normal :  3,  //priority index = 3_normal
   .medium :  4,  //priority index = 4_medium
   .low :     5   //priority index = 5_low
  ]
  
  
  var section: Int { Self.prioritySectionsMap[self]!}
  
  static let strings: [String] = allCases.map{ $0.rawValue }
 
  case hottest =  "Hottest"
  case hot     =  "Hot"
  case high    =  "High"
  case normal  =  "Normal"
  case medium  =  "Medium"
  case low     =  "Low"

 }
 
}
