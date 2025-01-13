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
        let today = Date()
        // Start from 1.5 years ago and progress towards today
        guard let startDate = calendar.date(byAdding: .day, value: -548, to: today) else { return }
        
        // Generate 1.5 years (548 days) of cardio workouts
        for dayOffset in 0..<548 {
            // Skip more days to achieve 2-3 workouts per week (70% chance to skip)
            if Double.random(in: 0...1) < 0.7 {
                continue
            }
            
            // Calculate date progressing forward from start date
            guard let workoutDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            
            // Alternate between running and biking
            let isRunning = dayOffset % 2 == 0
            
            let workout = Workout(context: context)
            workout.id = UUID()
            workout.date = workoutDate
            workout.type = isRunning ? "Running" : "Biking"
            workout.name = isRunning ? "Morning Run" : "Evening Ride"
            
            // Calculate progress factors - More gradual and consistent progression
            let monthProgress = Double(dayOffset) / 548.0  // Progress from 0 to 1 over the period
            
            // Add some wave periodization
            let waveFactor = sin(Double(dayOffset) / 30.0) * 0.05 // 5% variation
            let progressFactor = min(1.0, monthProgress + waveFactor)
            
            // Running: Progress from shorter, slower runs to longer, faster runs
            // Biking: Progress from shorter rides to longer rides with better pace
            let baseDistance = isRunning ? 2.0 : 6.0  // Starting: 2mi run or 6mi ride
            let maxDistance = isRunning ? 8.0 : 20.0  // Peak: 8mi run or 20mi ride
            let distanceProgress = baseDistance + (maxDistance - baseDistance) * progressFactor
            
            // Pace improvements (minutes per mile)
            let basePace = isRunning ? 12.0 : 6.0     // Starting: 12min/mi run or 6min/mi ride
            let targetPace = isRunning ? 8.0 : 4.0    // Peak: 8min/mi run or 4min/mi ride
            let paceImprovement = (basePace - targetPace) * progressFactor
            let currentPace = basePace - paceImprovement
            
            // Add some daily variation
            let distance = distanceProgress * Double.random(in: 0.9...1.1)
            let pace = currentPace * Double.random(in: 0.95...1.05)
            
            let duration = distance * pace * 60 // Convert to seconds
            
            workout.distance = distance
            workout.duration = duration
            
            // Create cardio progress
            let progress = CardioProgress(context: context)
            progress.id = UUID()
            progress.date = workoutDate
            progress.distance = distance
            progress.duration = duration
            progress.averagePace = pace
            progress.maxPace = pace * 0.9 // Best pace slightly faster than average
            
            // Link the workout to the progress
            workout.cardioProgress = progress
            progress.workout = workout
            
            // More realistic elevation gains that increase over time
            let baseElevation = isRunning ? 50.0 : 100.0
            let maxElevation = isRunning ? 200.0 : 500.0
            let elevationProgress = baseElevation + (maxElevation - baseElevation) * progressFactor
            progress.elevationGain = elevationProgress * Double.random(in: 0.9...1.1)
            
            // Generate split data with consistent pacing
            let splitCount = Int(ceil(distance))
            var splits: [Double] = []
            for _ in 0..<splitCount {
                let splitVariation = Double.random(in: -0.3...0.3)
                splits.append(pace + splitVariation)
            }
            progress.splitTimes = splits.map { String(format: "%.2f", $0) }.joined(separator: ",")
        }
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