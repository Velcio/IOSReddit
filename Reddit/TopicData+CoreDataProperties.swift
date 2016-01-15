//
//  TopicData+CoreDataProperties.swift
//  Reddit
//
//  Created by Rutger Benoot on 15/01/16.
//  Copyright © 2016 Rutger Benoot. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TopicData {

    @NSManaged var title: String?
    @NSManaged var author: String?
    @NSManaged var created: NSDate?
    @NSManaged var content: String?
    @NSManaged var url: String?
    @NSManaged var thumbnail: String?

}
