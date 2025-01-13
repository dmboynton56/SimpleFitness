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
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var type: String?
    @NSManaged public var exercises: NSSet?
    @NSManaged public var route: Route?
    
    public var exerciseArray: [Exercise] {
        let set = exercises as? Set<Exercise> ?? []
        return set.sorted { $0.id?.uuidString ?? "" < $1.id?.uuidString ?? "" }
    }
}

// MARK: Generated accessors for exercises
extension Workout {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}
