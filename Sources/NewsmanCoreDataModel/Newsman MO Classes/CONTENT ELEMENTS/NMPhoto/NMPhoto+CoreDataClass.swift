//
//  NMPhoto+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData
import Combine

@objc(NMPhoto) public class NMPhoto: NMBaseContent{}

@available(iOS 15.0, macOS 12.0, *)
extension NMPhoto: NMUndoManageable{
 public var undoTargetOwner: NMUndoManageable? {
  get async {
   await managedObjectContext?.perform { [ unowned self ] in
    photoFolder ?? mixedFolder ?? photoSnippet ?? mixedSnippet
   }
  }
 }
 
 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> {
  
  let p1 = publisher(for: \.photoSnippet, options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p2 = publisher(for: \.photoFolder,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p3 = publisher(for: \.mixedFolder,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p4 = publisher(for: \.mixedSnippet, options: [.new]).compactMap{ $0 as NMUndoManageable? }
  
  return Publishers.Merge4(p1, p2, p3, p4).eraseToAnyPublisher()
 }
 
}


@available(iOS 15.0, macOS 12.0, *)
extension NMPhoto: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMPhoto: NMContentElement{
 
 public typealias Snippet = NMPhotoSnippet
 public typealias Folder = NMPhotoFolder
 
 @objc(container) public var snippet: NMPhotoSnippet? { photoSnippet }
 @objc public var folder: NMPhotoFolder?   { photoFolder  }
 

}





