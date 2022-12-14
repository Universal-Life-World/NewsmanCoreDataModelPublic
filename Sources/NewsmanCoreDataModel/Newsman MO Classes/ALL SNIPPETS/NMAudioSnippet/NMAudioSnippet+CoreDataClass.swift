//
//  NMAudioSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMAudioSnippet) public class NMAudioSnippet: NMBaseSnippet {}

@available(iOS 15.0, macOS 12.0, *)
extension NMAudioSnippet: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMAudioSnippet: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerChildrenTaskGroup()
 }
}

extension NMAudioSnippet: NMContentElementsContainer {
 
 public typealias Element = NMAudio
 public typealias Folder = NMAudioFolder
 
 public func addToContainer(singleElements: [NMAudio]) {
  addToAudios(.init(array: singleElements))
 }
 
 public func removeFromContainer(singleElements: [NMAudio]) {
  removeFromAudios(.init(array: singleElements))
 }
 
 public func addToContainer(folders: [NMAudioFolder]) {
  addToAudioFolders(.init(array: folders))
  addToContainer(singleElements: folders.flatMap{ $0.folderedElements } )
   //add all folders' children to this snippet container as well!
  
 }
 
 public func removeFromContainer(folders: [NMAudioFolder]) {
  removeFromAudioFolders(.init(array: folders))
 }

 public var folders: [NMAudioFolder] {
  (audioFolders?.allObjects ?? []).compactMap{$0 as? NMAudioFolder }
  
 }
 
 public var singleContentElements: [NMAudio] {
  (audios?.allObjects ?? []).compactMap{$0 as? NMAudio }
 }
 

 
}

