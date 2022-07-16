//
//  NMAudioFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMAudioFolder)
public class NMAudioFolder: NMBaseContent {}

extension NMAudioFolder: NMUndoManageable{}

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



