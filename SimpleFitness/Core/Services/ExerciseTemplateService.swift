import Foundation
import CoreData

class ExerciseTemplateService {
    static let shared = ExerciseTemplateService()
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func fetchTemplates() -> [ExerciseTemplate] {
        let request = ExerciseTemplate.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExerciseTemplate.lastUsedDate, ascending: false)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching templates: \(error)")
            return []
        }
    }
    
    func findTemplate(named name: String?) -> ExerciseTemplate? {
        guard let name = name else { return nil }
        
        let request = ExerciseTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error finding template: \(error)")
            return nil
        }
    }
    
    func createTemplate(name: String, category: String? = nil) -> ExerciseTemplate {
        let template = ExerciseTemplate(context: context)
        template.id = UUID()
        template.name = name
        template.category = category
        template.lastUsedDate = Date()
        
        do {
            try context.save()
        } catch {
            print("Error saving template: \(error)")
        }
        
        return template
    }
    
    func updateLastUsed(_ template: ExerciseTemplate) {
        template.lastUsedDate = Date()
        
        do {
            try context.save()
        } catch {
            print("Error updating template: \(error)")
        }
    }
} 