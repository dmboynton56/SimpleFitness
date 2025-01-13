import Foundation
import CoreData

extension ExerciseTemplate {
    static var preview: ExerciseTemplate {
        let context = PersistenceController.preview.container.viewContext
        let template = ExerciseTemplate(context: context)
        template.id = UUID()
        template.name = "Bench Press"
        template.category = "Chest"
        return template
    }
    
    static func createPreviewTemplates(in context: NSManagedObjectContext) -> [ExerciseTemplate] {
        let templates = [
            ("Bench Press", "Chest"),
            ("Squat", "Legs"),
            ("Deadlift", "Back"),
            ("Overhead Press", "Shoulders"),
            ("Barbell Row", "Back"),
            ("Pull-ups", "Back"),
            ("Dips", "Chest")
        ]
        
        return templates.map { name, category in
            let template = ExerciseTemplate(context: context)
            template.id = UUID()
            template.name = name
            template.category = category
            return template
        }
    }
} 