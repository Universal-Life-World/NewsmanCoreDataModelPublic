import Foundation
import CoreData

@available(iOS 13.0, *)
public extension NMBaseContent {
 
 struct TPositionKey: Hashable, Codable {
  public static let separator = ","
  let groupType: String
  let sortOrder: String?
  let keyPath: String?
  
  public init (raw: String) {
   let components = raw.components(separatedBy: Self.separator)
   self.groupType = components.first!
   self.sortOrder = components.dropFirst().first
   self.keyPath = components.last
   
  }
  
  public var rawString: String {
   var raw = groupType
   guard let sortOrder = sortOrder else { return raw }
   raw += Self.separator + sortOrder
   
   guard let keyPath = keyPath else { return raw }
   raw += Self.separator + keyPath
   
   return raw
  }
  
 }
 

 
 subscript<Root: NMBaseContent, Value>(groupType: ContentGroupType<Root, Value>) -> Int? {
  get {
   if case .none = groupType { return nil }
   return positions?[groupType.positionKey]
  }
  
  set {
   if case .none = groupType { return }
   var positions = (self.positions == nil) ? TContentPositions() : self.positions!
   positions[groupType.positionKey] = newValue
   self.positions = positions
  }
 }
 
 
 
 enum ContentGroupType<Root: NMBaseContent, Value>: Codable//,
//                        NMEnumCasesStringLocalizable,
// NMEnumOptionalCasesManageable

 {
  
  private enum ContentGroupTypeCodingKeys: String, CodingKey {
   case groupType, sortKeyPath, sortOrder
  }
  
  private enum GroupType: String, Codable{
   case none
   case plain
   case byPriority
   case byColorFlag
   case dateGroups
   case alphaGroups
   case byContentType
  
  }
  
  private enum SortKeyPath: String, Codable {
   case byNameTag
   case byDate
   case byPriority
   case byColorFlag
   case byPosition
   case byContentType

  }
  
  private enum SortOrder: String, Codable {
   case ascending, descending
  }
  

  private typealias TEncodingContainer = KeyedEncodingContainer<ContentGroupTypeCodingKeys>
  private typealias TDecodingContainer = KeyedDecodingContainer<ContentGroupTypeCodingKeys>
  
  private typealias TSortOrder = NMSortOrder<Root, Value>
  private typealias TKeyPath = TSortOrder.SortKeyPath
  
  private func encode(keyPath: TKeyPath, to container: inout TEncodingContainer) throws {
   
   switch keyPath {
    case \.tag:        try container.encode(SortKeyPath.byNameTag,     forKey: .sortKeyPath)
    case \.date:       try container.encode(SortKeyPath.byDate,        forKey: .sortKeyPath)
    case \.priority:   try container.encode(SortKeyPath.byPriority,    forKey: .sortKeyPath)
    case \.colorFlag:  try container.encode(SortKeyPath.byColorFlag,   forKey: .sortKeyPath)
    case \.positions:  try container.encode(SortKeyPath.byPosition,    forKey: .sortKeyPath)
    case \.type:       try container.encode(SortKeyPath.byContentType, forKey: .sortKeyPath)
    default: break
   }
  }
  
  private func rawString(keyPath: TKeyPath) -> String? {
   
   switch keyPath {
    case \.tag:        return SortKeyPath.byNameTag.rawValue
    case \.date:       return SortKeyPath.byDate.rawValue
    case \.priority:   return SortKeyPath.byPriority.rawValue
    case \.colorFlag:  return SortKeyPath.byColorFlag.rawValue
    case \.positions:  return SortKeyPath.byPosition.rawValue
    case \.type:       return SortKeyPath.byContentType.rawValue
    default: return nil
   }
  }
  
  
  private func encode(sortedBy: TSortOrder, to container: inout TEncodingContainer) throws {
   
   switch sortedBy {
    case let .ascending(keyPath: kp):
     try container.encode(SortOrder.ascending, forKey: .sortOrder)
     try encode(keyPath: kp, to: &container)
     
    case let .descending(keyPath: kp):
     try container.encode(SortOrder.descending, forKey: .sortOrder)
     try encode(keyPath: kp, to: &container)
     
   }
  }
  
  private func rawString(sortedBy: TSortOrder) -> String? {
   
   switch sortedBy {
    case let .ascending(keyPath: kp):
     let sortOrderRaw = SortOrder.ascending.rawValue
     guard let keyPathRaw  = rawString(keyPath: kp) else { return nil }
     return sortOrderRaw + TPositionKey.separator + keyPathRaw
     
    case let .descending(keyPath: kp):
     let sortOrderRaw = SortOrder.descending.rawValue
     guard let keyPathRaw = rawString(keyPath: kp) else { return nil }
     return sortOrderRaw + TPositionKey.separator + keyPathRaw
     
     
   }
  }
  
  
  private func encode(groupType: Self, to container: inout TEncodingContainer) throws {
   
   switch groupType{
    case .none:
     try container.encode(GroupType.none, forKey: .groupType)
     
    case let .plain(sortedBy: sortedBy):
     try container.encode(GroupType.plain, forKey: .groupType)
     try encode(sortedBy: sortedBy, to: &container)
     
    case .byPriority(sortedBy: let sortedBy):
     try container.encode(GroupType.byPriority, forKey: .groupType)
     try encode(sortedBy: sortedBy, to: &container)
     
    case .byColorFlag(sortedBy: let sortedBy):
     try container.encode(GroupType.byColorFlag, forKey: .groupType)
     try encode(sortedBy: sortedBy, to: &container)
     
    case .dateGroups(sortedBy: let sortedBy):
     try container.encode(GroupType.dateGroups, forKey: .groupType)
     try encode(sortedBy: sortedBy, to: &container)
     
    case .alphaGroups(sortedBy: let sortedBy):
     try container.encode(GroupType.alphaGroups, forKey: .groupType)
     try encode(sortedBy: sortedBy, to: &container)
     
    case .byContentType(sortedBy: let sortedBy):
     try container.encode(GroupType.byContentType, forKey: .groupType)
     try encode(sortedBy: sortedBy, to: &container)
   }
  }
  
  public var positionKey: TPositionKey {.init(raw: rawString)}
  
  public var rawString: String {
   
   switch self {
    case .none: return GroupType.none.rawValue
     
    case let .plain(sortedBy: sortedBy):
     let groupTypeRaw = GroupType.plain.rawValue
     guard let sortOrderRaw = rawString(sortedBy: sortedBy) else { return GroupType.none.rawValue }
     return groupTypeRaw + TPositionKey.separator + sortOrderRaw
     
    case .byPriority(sortedBy: let sortedBy):
     let groupTypeRaw = GroupType.byPriority.rawValue
     guard let sortOrderRaw = rawString(sortedBy: sortedBy) else { return GroupType.none.rawValue }
     return groupTypeRaw + TPositionKey.separator + sortOrderRaw
     
    case .byColorFlag(sortedBy: let sortedBy):
     let groupTypeRaw = GroupType.byColorFlag.rawValue
     guard let sortOrderRaw = rawString(sortedBy: sortedBy) else { return GroupType.none.rawValue }
     return groupTypeRaw + TPositionKey.separator + sortOrderRaw
     
    case .dateGroups(sortedBy: let sortedBy):
     let groupTypeRaw = GroupType.dateGroups.rawValue
     guard let sortOrderRaw = rawString(sortedBy: sortedBy) else { return GroupType.none.rawValue }
     return groupTypeRaw + TPositionKey.separator + sortOrderRaw
     
    case .alphaGroups(sortedBy: let sortedBy):
     let groupTypeRaw = GroupType.alphaGroups.rawValue
     guard let sortOrderRaw = rawString(sortedBy: sortedBy) else { return GroupType.none.rawValue }
     return groupTypeRaw + TPositionKey.separator + sortOrderRaw
     
    case .byContentType(sortedBy: let sortedBy):
     let groupTypeRaw = GroupType.byContentType.rawValue
     guard let sortOrderRaw = rawString(sortedBy: sortedBy) else { return GroupType.none.rawValue }
     return groupTypeRaw + TPositionKey.separator + sortOrderRaw
   }
  }
  
  
  
  private static func decodedKeyPath(from container: TDecodingContainer) -> TKeyPath? {
   
   guard let keyPath = try? container.decode(SortKeyPath.self, forKey: .sortKeyPath) else { return nil }
   
   switch keyPath {
    case .byNameTag     :  return \Root.tag       as? KeyPath<Root, Value>
    case .byDate        :  return \Root.date      as? KeyPath<Root, Value>
    case .byPriority    :  return \Root.priority  as? KeyPath<Root, Value>
    case .byColorFlag   :  return \Root.colorFlag as? KeyPath<Root, Value>
    case .byPosition    :  return \Root.positions as? KeyPath<Root, Value>
    case .byContentType :  return \Root.type      as? KeyPath<Root, Value>
   
   }
  }
  
  private static func decodedSortOrder(from container: TDecodingContainer) -> TSortOrder? {
   
   guard let keyPath = Self.decodedKeyPath(from: container) else { return nil }
   guard let sortOrder = try? container.decode(SortOrder.self, forKey: .sortOrder) else { return nil }
   
   switch sortOrder {
    case .ascending   :  return .ascending  (keyPath: keyPath)
    case .descending  :  return .descending (keyPath: keyPath)
   }
   
  }
  
  private static func decodedGroupType(from container: TDecodingContainer) throws -> Self {
   
   let sortOrder = Self.decodedSortOrder(from: container)
   let groupType = try container.decode(GroupType.self, forKey: .groupType)
   
   switch (groupType, sortOrder) {
    case let (.plain,         sortOrder?): return .plain         (sortedBy: sortOrder)
    case let (.byPriority,    sortOrder?): return .byPriority    (sortedBy: sortOrder)
    case let (.byColorFlag,   sortOrder?): return .byColorFlag   (sortedBy: sortOrder)
    case let (.dateGroups,    sortOrder?): return .dateGroups    (sortedBy: sortOrder)
    case let (.alphaGroups,   sortOrder?): return .alphaGroups   (sortedBy: sortOrder)
    case let (.byContentType, sortOrder?): return .byContentType (sortedBy: sortOrder)
    default: return .none
   }
   
  }
  
  public func encode(to encoder: Encoder) throws {
   var container = encoder.container(keyedBy: ContentGroupTypeCodingKeys.self)
   try encode(groupType: self, to: &container)
  }
  
  public init(from decoder: Decoder) throws {
   let container = try decoder.container(keyedBy: ContentGroupTypeCodingKeys.self)
   self = try Self.decodedGroupType(from: container)
  
  }
  
  //public static var isolationQueue =  DispatchQueue(label: "Content Group Type Priority")
  
  //static public var enabled = Dictionary(uniqueKeysWithValues: allCases.map{($0, true)})
  
  
  //static let strings: [String] = allCases.map{ $0.rawValue }
  
  case none
  case plain         (sortedBy: NMSortOrder<Root, Value>)
  case byPriority    (sortedBy: NMSortOrder<Root, Value>)
  case byColorFlag   (sortedBy: NMSortOrder<Root, Value>)
  case dateGroups    (sortedBy: NMSortOrder<Root, Value>)
  case alphaGroups   (sortedBy: NMSortOrder<Root, Value>)
  case byContentType (sortedBy: NMSortOrder<Root, Value>)
  
 }
 
 
}

