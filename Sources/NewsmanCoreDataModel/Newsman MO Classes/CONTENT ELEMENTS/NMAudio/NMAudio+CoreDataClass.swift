//
//  NMAudio+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData
import Combine

@objc(NMAudio) public class NMAudio: NMBaseContent{}

@available(iOS 15.0, macOS 12.0, *)
extension NMAudio: NMUndoManageable{
 public var undoTargetOwner: NMUndoManageable? {
  get async {
   await managedObjectContext?.perform { [ unowned self ] in 
    audioFolder ?? mixedFolder ?? audioSnippet ?? mixedSnippet
   }
  }
 }
 
 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> {
  
  let p1 = publisher(for: \.audioSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p2 = publisher(for: \.audioFolder,   options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p3 = publisher(for: \.mixedFolder,   options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p4 = publisher(for: \.mixedSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  
  return Publishers.Merge4(p1, p2, p3, p4).eraseToAnyPublisher()
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
extension NMAudio: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMAudio: NMContentElement{
 
 public typealias Snippet = NMAudioSnippet
 public typealias Folder = NMAudioFolder
 
 @objc(container) public var snippet: NMAudioSnippet? { audioSnippet }
 @objc(subcontainer) public var folder:  NMAudioFolder?  { audioFolder  }


 
}

