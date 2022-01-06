//
//  NMReportAudioContainer+CoreDataProperties.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData


extension NMReportAudioContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NMReportAudioContainer> {
        return NSFetchRequest<NMReportAudioContainer>(entityName: "NMReportAudioContainer")
    }

    @NSManaged public var audio: NMAudio?
    @NSManaged public var parentContainer: NMReportElementsContainer?

}
