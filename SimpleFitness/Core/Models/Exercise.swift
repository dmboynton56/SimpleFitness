import Foundation
import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var sets: Int16
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Double
    @NSManaged public var notes: String?
    @NSManaged public var workout: Workout?
}

extension Exercise {
    static func create(in context: NSManagedObjectContext) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        return exercise
    }
} 
