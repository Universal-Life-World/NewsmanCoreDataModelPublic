//
//  NMVideoFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMVideoFolder) public class NMVideoFolder: NMBaseContent{}

@available(iOS 15.0, macOS 12.0, *)
extension NMVideoFolder: NMFileStorageManageable{
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerFolderedGroup()
 }
}

extension NMVideoFolder: NMContentFolder{
 

 public typealias Element = NMVideo
 public typealias Snippet = NMVideoSnippet
 
 @objc(container) public var snippet: NMVideoSnippet? { videoSnippet }
 
 @objc public var folderedElements: [NMVideo] {
  (folderedVideos?.allObjects ?? []).compactMap{ $0 as? NMVideo }
 }
 
 public func addToContainer(singleElements: [NMVideo]) {
  let newElements: NSSet = .init(array: singleElements)
  addToFolderedVideos(newElements)
  videoSnippet?.addToVideos(newElements)
  mixedSnippet?.addToVideos(newElements)
 }
 
 public func removeFromContainer(singleElements: [NMVideo]) {
  removeFromFolderedVideos(.init(array: singleElements))
 }
 
 

}
 

