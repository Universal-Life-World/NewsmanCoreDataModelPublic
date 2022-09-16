//
//  NMAudioFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData
import Combine

@objc(NMAudioFolder)
public class NMAudioFolder: NMBaseContent {}

@available(iOS 15.0, macOS 12.0, *)
extension NMAudioFolder: NMUndoManageable{
 
 public var undoTargetOwner: NMUndoManageable? {
  get async { await managedObjectContext?.perform { [ unowned self ] in audioSnippet ?? mixedSnippet } }
 }
 
 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> {
  
  let p1 = publisher(for: \.audioSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p2 = publisher(for: \.mixedSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  
  return Publishers.Merge(p1, p2).eraseToAnyPublisher()
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
extension NMAudioFolder: NMFileStorageManageable{
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerFolderedGroup()
 }
}

extension NMAudioFolder: NMContentFolder {
 
 public typealias Element = NMAudio
 public typealias Snippet = NMAudioSnippet
 
 @objc(container) public var snippet: NMAudioSnippet? { audioSnippet }
 
 @objc public var folderedElements: [NMAudio] {
  (folderedAudios?.allObjects ?? []).compactMap{ $0 as? NMAudio }
 }
 
 public func addToContainer(singleElements: [NMAudio]) {
  let newElements: NSSet = .init(array: singleElements)
  addToFolderedAudios(newElements)
  audioSnippet?.addToAudios(newElements)
  mixedSnippet?.addToAudios(newElements)
 }
 
 public func removeFromContainer(singleElements: [NMAudio]) {
  removeFromFolderedAudios(.init(array: singleElements))
 }
 
}



