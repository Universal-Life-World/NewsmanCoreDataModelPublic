import CoreData

@available(iOS 15.0, macOS 12.0, *)
public struct MixedContentGroupBuilder: BaseContentElementsBuilderable {
 
 public static var empty: Self { .init(elementsBuilders: []) }
 
 public let elementsBuilders: [ BaseContentElementsBuilderable ]
 
 public var build: @Sendable (NMMixedSnippet) async throws -> [BuilderTreeNodeRepresentable] {
  
  { @Sendable (snippet: NMMixedSnippet) async throws -> [BuilderTreeNodeRepresentable] in
   try await withThrowingTaskGroup(of: (Int, [BuilderTreeNodeRepresentable]?).self) { group in
    elementsBuilders.enumerated().forEach { (index, builder) in
     group.addTask {
      switch builder {
       case let builder as Photo:        return (index, [try await builder.buildMixed(snippet, nil)])
       case let builder as PhotoFolder:  return (index, [try await builder.buildMixed(snippet)])
        
       case let builder as Audio:        return (index, [try await builder.buildMixed(snippet, nil)])
       case let builder as AudioFolder:  return (index, [try await builder.buildMixed(snippet)])
     
       case let builder as Text:         return (index, [try await builder.buildMixed(snippet, nil)])
       case let builder as TextFolder:   return (index, [try await builder.buildMixed(snippet)])
        
       case let builder as Video:        return (index, [try await builder.buildMixed(snippet, nil)])
       case let builder as VideoFolder:  return (index, [try await builder.buildMixed(snippet)])
        
       case let builder as MixedFolder:  return (index, [try await builder.buildMixed(snippet)])
        
       case let builder as MixedContentGroupBuilder: return (index, try await builder.build(snippet))
        
       default: return (index, nil)
      }
      
     }
    }
    return try await group.reduce(into: []){$0.append($1)}.sorted{$0.0 < $1.0}.compactMap{$0.1}.flatMap{$0}
   }
  }
 }
}

@available(iOS 15.0, macOS 12.0, *)
@resultBuilder public struct MixedContentBuilder {
 
 public typealias TComponent = BaseContentElementsBuilderable
 public static func buildBlock(_ components: TComponent...) -> MixedContentGroupBuilder {
  MixedContentGroupBuilder(elementsBuilders: components)
 }
 
 public static func buildArray(_ components: [TComponent]) -> MixedContentGroupBuilder {
  MixedContentGroupBuilder(elementsBuilders: components)
 }
 
}


@available(iOS 15.0, macOS 12.0, *)
public typealias MixedContainer = NMMixedSnippetBuilder


@available(iOS 15.0, macOS 12.0, *)
public struct NMMixedSnippetBuilder: SnippetsBuilder {
 
 public typealias TUpdateMixedBlock = (NMMixedSnippet) throws -> ()

 
 let updates: TUpdateMixedBlock?
 let context: NSManagedObjectContext
 let persist: Bool
 
 let mixedBuilder: MixedContentGroupBuilder
 
 public typealias TMixedBuilder = () -> MixedContentGroupBuilder
 
 public init(context: NSManagedObjectContext,
             persist: Bool = true,
             updates: TUpdateMixedBlock? = nil ,
             @MixedContentBuilder mixedElements:  TMixedBuilder = { .empty }) {
  
  self.context = context
  self.persist = persist
  self.updates = updates
  self.mixedBuilder = mixedElements()
 
  
 }
 
 public var build: @Sendable () async throws -> [BuilderTreeNodeRepresentable] {
  { @Sendable () async throws -> [BuilderTreeNodeRepresentable] in
   let snippet = try await NMMixedSnippet.create(in: context, persist: persist, with: updates)
   let childNodes = try await mixedBuilder.build(snippet)
   return [SnippetBuilderNode(parent: snippet, childNodes: childNodes)]
  }
 }
 
}
