//
//  SubredditData+CoreDataProperties.swift
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

extension SubredditData {

    @NSManaged var after: String?
    @NSManaged var name: String?
    @NSManaged var title: String?
    @NSManaged var order: NSNumber?
    @NSManaged var topics: NSSet?

}
