//
//  Account+CoreDataProperties.swift
//  MoneyPlant App
//
//  Created by admin17 on 25/01/25.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var password: String
    @NSManaged public var image: Data?
    @NSManaged public var tenant: String
    @NSManaged public var transactions: Transaction?

}

extension Account : Identifiable {

}
