import Foundation
import CoreData

extension ExerciseTemplate {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseTemplate> {
        return NSFetchRequest<ExerciseTemplate>(entityName: "ExerciseTemplate")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var lastUsedDate: Date?
    @NSManaged public var exercises: Set<Exercise>?
    
    public var exercisesArray: [Exercise] {
        let set = exercises ?? []
        return Array(set)
    }
} 