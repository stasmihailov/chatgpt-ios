//
//  EChatMsg+CoreDataProperties.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//
//

import Foundation
import CoreData


extension EChatMsg {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EChatMsg> {
        return NSFetchRequest<EChatMsg>(entityName: "EChatMsg")
    }

    @NSManaged public var sourceRaw: String?
    @NSManaged public var time: Date?
    @NSManaged public var text: String?
    @NSManaged public var chat: EChat?

}

extension EChatMsg : Identifiable {

}
