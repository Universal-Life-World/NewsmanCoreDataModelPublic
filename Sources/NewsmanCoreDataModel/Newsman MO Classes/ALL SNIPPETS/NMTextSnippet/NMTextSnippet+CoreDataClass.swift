//
//  NMTextSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@available(iOS 13.0, *)
@objc(NMTextSnippet)
public class NMTextSnippet: NMBaseSnippet {}

extension NMTextSnippet: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMTextSnippet: NMFileStorageManageable{}

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
