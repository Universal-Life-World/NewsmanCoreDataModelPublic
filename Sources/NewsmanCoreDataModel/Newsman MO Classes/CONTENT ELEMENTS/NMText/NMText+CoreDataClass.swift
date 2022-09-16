//
//  NMText+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData
import Combine

@objc(NMText) public class NMText: NMBaseContent{ }

@available(iOS 15.0, macOS 12.0, *)
extension NMText: NMUndoManageable {
 
 public var undoTargetOwner: NMUndoManageable? {
  get async {
   await managedObjectContext?.perform { [ unowned self ] in
    textFolder ?? mixedFolder ?? textSnippet ?? mixedSnippet
   }
  }
 }

 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> {
  
  let p1 = publisher(for: \.textSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p2 = publisher(for: \.textFolder,   options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p3 = publisher(for: \.mixedFolder,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p4 = publisher(for: \.mixedSnippet, options: [.new]).compactMap{ $0 as NMUndoManageable? }
  
  return Publishers.Merge4(p1, p2, p3, p4).eraseToAnyPublisher()
 }
  
}

@available(iOS 15.0, macOS 12.0, *)
extension NMText: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMText: NMContentElement {
 
 public typealias Folder = NMTextFolder
 public typealias Snippet = NMTextSnippet
 
 @objc(container) public var snippet: NMTextSnippet? { textSnippet }
 @objc public var folder: NMTextFolder?   { textFolder }
 
}

//extension NMText {
// public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
//}
