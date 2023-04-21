//
//  EChat+CoreDataProperties.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//
//

import Foundation
import CoreData


extension EChat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EChat> {
        return NSFetchRequest<EChat>(entityName: "EChat")
    }

    @NSManaged public var name: String?
    @NSManaged public var model: String?
    @NSManaged public var pinned: Bool
    @NSManaged public var chatMsg: EChatMsg?

}

extension EChat : Identifiable {

}
