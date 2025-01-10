//
//  Workout+CoreDataProperties.swift
//  SimpleFitness
//
//  Created by Drew Boynton on 1/10/25.
//
//

import Foundation
import CoreData


extension Workout: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var date: Date?
    @NSManaged public var distance: Double
    @NSManaged public var duration: Double
    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var type: String?
    @NSManaged public var weight: Double
    @NSManaged public var id: UUID?

}
