//
//  NMTextSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMTextSnippet) public class NMTextSnippet: NMBaseSnippet {}

@available(iOS 15.0, macOS 12.0, *)
extension NMTextSnippet: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMTextSnippet: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerChildrenTaskGroup()
 }
}


extension NMTextSnippet: NMContentElementsContainer {

 public typealias Element = NMText
 public typealias Folder = NMTextFolder
 
 public func addToContainer(singleElements: [NMText]) {
  addToTexts(.init(array: singleElements))
 }
 
 public func removeFromContainer(singleElements: [NMText]) {
  removeFromTexts(.init(array: singleElements))
 }
 
 public func addToContainer(folders: [NMTextFolder]) {
  addToTextFolders(.init(array: folders))
  addToContainer(singleElements: folders.flatMap{ $0.folderedElements } )
   //add all folders' children to this snippet container as well!
 }
 
 public func removeFromContainer(folders: [NMTextFolder]) {
  removeFromTextFolders(.init(array: folders))
 }
 
 public var folders: [NMTextFolder] {
  (textFolders?.allObjects ?? []).compactMap{$0 as? NMTextFolder}
 }
 
 public var singleContentElements: [NMText] {
  (texts?.allObjects ?? []).compactMap{$0 as? NMText}
 }
 

 
 
 
}
