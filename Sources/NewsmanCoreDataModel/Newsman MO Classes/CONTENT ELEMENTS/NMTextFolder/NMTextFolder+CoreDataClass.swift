//
//  NMTextFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData
import Combine

@objc(NMTextFolder)
public class NMTextFolder: NMBaseContent {}

@available(iOS 15.0, macOS 12.0, *)
extension NMTextFolder: NMUndoManageable{
 public var undoTargetOwner: NMUndoManageable? {
  get async { await managedObjectContext?.perform { [ unowned self ] in textSnippet ?? mixedSnippet} }
 }
 
 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> {
  
  let p1 = publisher(for: \.textSnippet,   options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p2 = publisher(for: \.mixedSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  
  return Publishers.Merge(p1, p2).eraseToAnyPublisher()
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
extension NMTextFolder: NMFileStorageManageable{
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerFolderedGroup()
 }
}

extension NMTextFolder: NMContentFolder{
 
 
 public typealias Element = NMText
 public typealias Snippet = NMTextSnippet
 
 @objc(container) public var snippet: NMTextSnippet? { textSnippet }
 
 @objc public func addToContainer(singleElements: [NMText]) {
  let newElements: NSSet = .init(array: singleElements)
  addToFolderedTexts(newElements)
  textSnippet?.addToTexts(newElements)
  mixedSnippet?.addToTexts(newElements)
 }
 
 public func removeFromContainer(singleElements: [NMText]) {
  removeFromFolderedTexts(.init(array: singleElements))
 }

 public var folderedElements: [NMText] {
  (folderedTexts?.allObjects ?? []).compactMap{$0 as? NMText}
 }
 
}


