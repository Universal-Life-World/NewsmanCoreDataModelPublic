//
//  NMVideoSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@available(iOS 13.0, *)
@objc(NMVideoSnippet)
public class NMVideoSnippet: NMBaseSnippet {}

extension NMVideoSnippet: NMUndoManageable {}

@available(iOS 15.0, macOS 12.0, *)
extension NMVideoSnippet: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerChildrenTaskGroup()
 }
}


extension NMVideoSnippet: NMContentElementsContainer {
 
 
 public typealias Element = NMVideo
 public typealias Folder = NMVideoFolder
 
 public func addToContainer(singleElements: [NMVideo]) {
  addToVideos(.init(array: singleElements))
 }
 
 public func removeFromContainer(singleElements: [NMVideo]) {
  removeFromVideos(.init(array: singleElements))
 }
 
 public func addToContainer(folders: [NMVideoFolder]) {
  addToVideoFolders(.init(array: folders))
  addToContainer(singleElements: folders.flatMap{ $0.folderedElements } )
   //add all folders' children to this snippet container as well!
 }
 
 public func removeFromContainer(folders: [NMVideoFolder]) {
  removeFromVideoFolders(.init(array: folders))
 }
 
 public var folders: [NMVideoFolder] {
  (videoFolders?.allObjects ?? []).compactMap{ $0 as? NMVideoFolder }
 }
 
 public var singleContentElements: [NMVideo] {
  (videos?.allObjects ?? []).compactMap{ $0 as? NMVideo }
 }
 
 
 
}
 
 
