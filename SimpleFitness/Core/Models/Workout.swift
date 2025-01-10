import Foundation
import CoreData

@objc(Workout)
public class Workout: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var type: String
    @NSManaged public var duration: Double
    @NSManaged public var exercises: NSSet?
}

extension Workout {
    static func create(in context: NSManagedObjectContext) -> Workout {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.date = Date()
        return workout
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