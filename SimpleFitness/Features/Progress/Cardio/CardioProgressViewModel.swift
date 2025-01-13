import Foundation
import CoreData
import Combine

class CardioProgressViewModel: ObservableObject {
    @Published var recentActivities: [CardioActivity] = []
    private var cancellables = Set<AnyCancellable>()
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        setupObservers()
        fetchActivities()
    }
    
    private func setupObservers() {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: viewContext)
            .sink { [weak self] _ in
                self?.fetchActivities()
            }
            .store(in: &cancellables)
    }
    
    func progressData(for metric: CardioMetricType, timeRange: TimeRange) -> [(date: Date, value: Double)] {
        let request = CardioProgress.fetchRequest()
        
        // Add date filter based on time range
        let calendar = Calendar.current
        let now = Date()
        var fromDate: Date?
        
        switch timeRange {
        case .week:
            fromDate = calendar.date(byAdding: .day, value: -7, to: now)
        case .month:
            fromDate = calendar.date(byAdding: .month, value: -1, to: now)
        case .year:
            fromDate = calendar.date(byAdding: .year, value: -1, to: now)
        case .all:
            fromDate = nil
        }
        
        if let fromDate = fromDate {
            request.predicate = NSPredicate(format: "date >= %@", fromDate as NSDate)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardioProgress.date, ascending: true)]
        
        do {
            let results = try viewContext.fetch(request)
            return results.compactMap { progress in
                guard let date = progress.date else { return nil }
                
                let value: Double
                switch metric {
                case .distance:
                    value = progress.distance
                case .duration:
                    value = progress.duration / 60 // Convert to minutes
                case .averagePace:
                    value = progress.averagePace
                case .bestPace:
                    value = progress.maxPace
                case .totalDistance:
                    // Calculate cumulative distance
                    let index = results.firstIndex(of: progress) ?? 0
                    let previousResults = results[0...index]
                    value = previousResults.reduce(0) { $0 + $1.distance }
                case .elevationGain:
                    value = progress.elevationGain
                }
                
                return (date: date, value: value)
            }
        } catch {
            print("Error fetching progress data: \(error)")
            return []
        }
    }
    
    private func fetchActivities() {
        let request = CardioProgress.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardioProgress.date, ascending: false)]
        request.fetchLimit = 10 // Only show recent activities
        
        do {
            let results = try viewContext.fetch(request)
            recentActivities = results.compactMap { progress in
                guard let date = progress.date else { return nil }
                
                // Parse split times
                let splits = progress.splitTimes?
                    .split(separator: ",")
                    .compactMap { Double($0.split(separator: ":")[1]) } ?? []
                
                return CardioActivity(
                    id: progress.id ?? UUID(),
                    date: date,
                    distance: progress.distance,
                    duration: progress.duration / 60, // Convert to minutes
                    averagePace: progress.averagePace,
                    splits: splits,
                    elevationGain: progress.elevationGain
                )
            }
        } catch {
            print("Error fetching activities: \(error)")
        }
    }
} 