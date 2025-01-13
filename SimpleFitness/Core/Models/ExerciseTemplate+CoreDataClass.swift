import Foundation
import CoreData

@objc(ExerciseTemplate)
public class ExerciseTemplate: NSManagedObject, Identifiable {
    public var id: UUID {
        get {
            id_ ?? UUID()
        }
        set {
            id_ = newValue
        }
    }
    
    // Helper computed properties
    public var displayName: String {
        name ?? "Unnamed Exercise"
    }
    
    public var exerciseCount: Int {
        (exercises?.count ?? 0)
    }
    
    public var lastUsed: Date? {
        lastUsedDate
    }
} 