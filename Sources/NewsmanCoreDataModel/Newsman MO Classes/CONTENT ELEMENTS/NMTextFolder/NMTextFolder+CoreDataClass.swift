//
//  NMTextFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMTextFolder)
public class NMTextFolder: NMBaseContent {}

extension NMTextFolder: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMTextFolder: NMFileStorageManageable{}

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


