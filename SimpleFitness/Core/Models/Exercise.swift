import Foundation
import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var sets: NSSet?
    @NSManaged public var template: ExerciseTemplate?
    @NSManaged public var workout: Workout?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }
}

extension Exercise {
    static func create(in context: NSManagedObjectContext) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        return exercise
    }
}

// MARK: Generated accessors for sets
extension Exercise {
    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: ExerciseSet)
    
    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: ExerciseSet)
    
    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)
    
    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)
}
