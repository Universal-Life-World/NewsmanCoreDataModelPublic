//
//  NMMixedFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMMixedFolder)
public class NMMixedFolder: NMBaseContent, NMSnippetContained {
 public var snippetID: UUID? { mixedSnippet?.id }

}
