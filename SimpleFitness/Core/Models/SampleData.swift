import Foundation
import CoreData

struct SampleData {
    static func generateSampleData(in context: NSManagedObjectContext) {
        // Generate strength workouts (existing code)
        generateStrengthWorkouts(in: context)
        
        // Generate cardio workouts
        generateCardioWorkouts(in: context)
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Error saving sample data: \(error)")
        }
    }
    
    private static func generateStrengthWorkouts(in context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let today = Date()
        // Start from 1.5 years ago and progress towards today
        guard let startDate = calendar.date(byAdding: .day, value: -548, to: today) else { return }
        
        // Initial weights for compound movements (in lbs)
        let exercises: [(name: String, category: String, startWeight: Double, endWeight: Double)] = [
            // Main compound lifts with realistic progression
            ("Bench Press", "Push", 135, 225),  // ~90lb improvement
            ("Squat", "Legs", 185, 315),       // ~130lb improvement
            ("Deadlift", "Pull", 225, 405),    // ~180lb improvement
            ("Overhead Press", "Push", 85, 145), // ~60lb improvement
            ("Barbell Row", "Pull", 135, 225),  // ~90lb improvement
            ("Front Squat", "Legs", 135, 245)   // ~110lb improvement
        ]
        
        // Create exercise templates
        for (name, category, _, _) in exercises {
            let template = ExerciseTemplate(context: context)
            template.id = UUID()
            template.name = name
            template.category = category
        }
        
        // Generate 1.5 years (548 days) of workouts
        for dayOffset in 0..<548 {
            // Skip more days to achieve 2-3 workouts per week (70% chance to skip)
            if Double.random(in: 0...1) < 0.7 {
                continue
            }
            
            // Calculate date progressing forward from start date
            guard let workoutDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            
            // Calculate progress factors - More gradual and consistent progression
            let monthProgress = Double(dayOffset) / 548.0  // Progress from 0 to 1 over the period
            
            // Add some wave periodization - slight variation in progress
            let waveFactor = sin(Double(dayOffset) / 30.0) * 0.05 // 5% variation
            let progressFactor = min(1.0, monthProgress + waveFactor)
            
            // Determine workout type based on day
            let workoutType = dayOffset % 3 // 3-day split: Push/Pull/Legs
            let category = ["Push", "Pull", "Legs"][workoutType]
            
            let workout = Workout(context: context)
            workout.id = UUID()
            workout.date = workoutDate
            workout.type = "Strength"
            workout.name = "\(category) Day"
            
            // Filter exercises for this workout type
            let workoutExercises = exercises.filter { $0.category == category }
            let selectedExercises = Array(workoutExercises.prefix(Int.random(in: 3...4)))
            
            for (name, _, startWeight, endWeight) in selectedExercises {
                // Fetch template
                let fetchRequest: NSFetchRequest<ExerciseTemplate> = ExerciseTemplate.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                
                guard let template = try? context.fetch(fetchRequest).first else { continue }
                
                let exercise = Exercise(context: context)
                exercise.id = UUID()
                exercise.template = template
                exercise.workout = workout
                
                // Calculate weight progression with more consistent improvement
                let baseWeight = startWeight
                let totalGain = endWeight - startWeight
                let currentGain = totalGain * progressFactor
                let targetWeight = baseWeight + currentGain
                
                // Add some daily variation (smaller range for more consistency)
                let variation = Double.random(in: -5...5)
                let workingWeight = targetWeight + variation
                
                // Create 2-3 sets per exercise
                let setCount = Int.random(in: 2...3)
                for setNumber in 1...setCount {
                    let set = ExerciseSet(context: context)
                    set.id = UUID()
                    set.exercise = exercise
                    set.order = Int16(setNumber)
                    
                    // All working sets (no warm-up)
                    set.weight = workingWeight
                    set.reps = Int16.random(in: 6...10)
                }
                
                // Create strength progress
                let progress = StrengthProgress(context: context)
                progress.id = UUID()
                progress.date = workoutDate
                progress.exerciseTemplate = template
                
                // Calculate progress metrics
                let sets = exercise.sets?.allObjects as? [ExerciseSet] ?? []
                progress.totalSets = Int16(sets.count)
                progress.maxWeight = sets.map { $0.weight }.max() ?? 0
                progress.maxReps = sets.map { $0.reps }.max() ?? 0
                progress.averageWeight = sets.map { $0.weight }.reduce(0, +) / Double(sets.count)
                progress.totalVolume = sets.map { $0.weight * Double($0.reps) }.reduce(0, +)
                
                // Calculate one rep max using Brzycki formula
                if let bestSet = sets.max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) }) {
                    progress.oneRepMax = bestSet.weight * (36.0 / (37.0 - Double(bestSet.reps)))
                }
            }
        }
    }
    
    private static func generateCardioWorkouts(in context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -548, to: now)! // 1.5 years ago
        
        var currentDate = startDate
        var runningWorkouts: [Workout] = []
        var bikingWorkouts: [Workout] = []
        
        while currentDate <= now {
            // 70% chance to skip a day to achieve 2-3 workouts per week
            if Double.random(in: 0...1) < 0.7 {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                continue
            }
            
            // Alternate between running and biking
            let isRunning = calendar.component(.day, from: currentDate) % 2 == 0
            
            let workout = Workout(context: context)
            workout.id = UUID()
            workout.date = currentDate
            workout.type = isRunning ? "Running" : "Biking"
            workout.name = isRunning ? "Morning Run" : "Evening Ride"
            
            // Calculate progress based on time (0 to 1)
            let totalDays = calendar.dateComponents([.day], from: startDate, to: now).day!
            let currentDays = calendar.dateComponents([.day], from: startDate, to: currentDate).day!
            let progressFactor = Double(currentDays) / Double(totalDays)
            
            // Generate realistic distances and paces with progression
            let progress = generateCardioProgress(for: workout, progress: progressFactor)
            workout.cardioProgress = progress
            
            // Set the workout's distance and duration from the progress
            workout.distance = progress.distance
            workout.duration = progress.duration
            
            if isRunning {
                runningWorkouts.append(workout)
            } else {
                bikingWorkouts.append(workout)
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Generate detailed routes only for the 3 most recent workouts of each type
        for workouts in [runningWorkouts, bikingWorkouts] {
            let recentWorkouts = Array(workouts.suffix(3))
            for workout in recentWorkouts {
                generateDetailedRoute(for: workout, in: context)
            }
        }
    }
    
    private static func generateCardioProgress(for workout: Workout, progress: Double) -> CardioProgress {
        let context = workout.managedObjectContext!
        let cardioProgress = CardioProgress(context: context)
        cardioProgress.id = UUID()
        cardioProgress.date = workout.date
        cardioProgress.workout = workout
        
        let isRunning = workout.type == "Running"
        
        // Add some random variation (-10% to +10%)
        let variation = Double.random(in: -0.1...0.1)
        let adjustedProgress = min(1.0, max(0.0, progress + variation))
        
        if isRunning {
            // Running progression: 2-3 miles → 4-6 miles
            cardioProgress.distance = lerp(start: Double.random(in: 2...3), end: Double.random(in: 4...6), progress: adjustedProgress)
            // Pace improvement: 11-12 min/mile → 8-9 min/mile
            cardioProgress.averagePace = lerp(start: Double.random(in: 11...12), end: Double.random(in: 8...9), progress: adjustedProgress)
        } else {
            // Biking progression: 6-8 miles → 12-15 miles
            cardioProgress.distance = lerp(start: Double.random(in: 6...8), end: Double.random(in: 12...15), progress: adjustedProgress)
            // Pace improvement: 5-6 min/mile → 4-5 min/mile
            cardioProgress.averagePace = lerp(start: Double.random(in: 5...6), end: Double.random(in: 4...5), progress: adjustedProgress)
        }
        
        // Calculate duration from distance and pace
        cardioProgress.duration = cardioProgress.distance * cardioProgress.averagePace * 60 // Convert to seconds
        
        // Generate elevation gain (30-100ft early on, progressing to 150-300ft)
        cardioProgress.elevationGain = lerp(start: Double.random(in: 30...100), end: Double.random(in: 150...300), progress: adjustedProgress)
        
        // Generate simple split times (roughly even pacing with small variations)
        let basePace = cardioProgress.averagePace
        let splits = (0..<Int(ceil(cardioProgress.distance))).map { _ in
            basePace + Double.random(in: -0.5...0.5)
        }
        cardioProgress.splitTimes = splits.map { String(format: "%.2f", $0) }.joined(separator: ",")
        
        return cardioProgress
    }
    
    private static func generateDetailedRoute(for workout: Workout, in context: NSManagedObjectContext) {
        let route = Route(context: context)
        route.id = UUID()
        route.workout = workout
        workout.route = route  // Set up bidirectional relationship
        
        guard let progress = workout.cardioProgress else { return }
        
        // Calculate number of points based on distance (roughly one point every 0.1 miles)
        let pointCount = Int(progress.distance * 10)
        
        // Generate route points with realistic GPS coordinates
        var lastLat = 40.0150 // Starting in Boulder, CO
        var lastLng = -105.2705
        var totalDistance: Double = 0
        
        for i in 0..<pointCount {
            let point = RoutePoint(context: context)
            point.id = UUID()
            point.order = Int16(i)
            point.route = route
            
            // Add some random variation to create a realistic path
            // Smaller variations for more realistic local routes
            let latDelta = Double.random(in: -0.0005...0.0005)
            let lngDelta = Double.random(in: -0.0005...0.0005)
            
            lastLat += latDelta
            lastLng += lngDelta
            
            point.latitude = lastLat
            point.longitude = lastLng
            point.timestamp = workout.date?.addingTimeInterval(Double(i) * (progress.duration / Double(pointCount)))
            
            if i > 0 {
                let points = route.pointsArray
                if let lastPoint = points[safe: i - 1] {
                    totalDistance += route.calculateDistance(from: lastPoint, to: point)
                }
            }
        }
        
        route.distance = totalDistance
    }
    
    private static func lerp(start: Double, end: Double, progress: Double) -> Double {
        return start + (end - start) * progress
    }
    
    static func clearAllData(in context: NSManagedObjectContext) {
        // Delete in order of dependencies to avoid conflicts
        let entities = [
            "CardioProgress",
            "RoutePoint",
            "Route",
            "StrengthProgress",
            "ProgressMetric",
            "ExerciseSet",
            "Exercise",
            "Workout",
            "ExerciseTemplate"
        ]
        
        for entityName in entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error clearing \(entityName) data: \(error)")
            }
        }
        
        // Save the context after clearing
        do {
            try context.save()
        } catch {
            print("Error saving after clearing data: \(error)")
        }
        
        // Reset the context to ensure clean state
        context.reset()
    }
}

// Add safe array access extension
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 