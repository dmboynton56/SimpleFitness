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
        // Create exercise templates with realistic categories and exercises
        let templates = [
            // Push exercises
            ("Bench Press", "Push", 135.0),
            ("Overhead Press", "Push", 95.0),
            ("Incline Bench Press", "Push", 115.0),
            ("Tricep Extensions", "Push", 50.0),
            
            // Pull exercises
            ("Barbell Row", "Pull", 135.0),
            ("Pull-ups", "Pull", 0.0),  // Bodyweight
            ("Lat Pulldown", "Pull", 120.0),
            ("Dumbbell Curls", "Pull", 30.0),
            
            // Leg exercises
            ("Squat", "Legs", 185.0),
            ("Deadlift", "Legs", 225.0),
            ("Leg Press", "Legs", 225.0),
            ("Calf Raises", "Legs", 135.0)
        ].map { name, category, baseWeight in
            let template = ExerciseTemplate(context: context)
            template.id = UUID()
            template.name = name
            template.category = category
            return (template, baseWeight)
        }
        
        // Generate workouts over the past 30 days
        let calendar = Calendar.current
        let today = Date()
        
        // Create a Push/Pull/Legs split
        let workoutSplit = [
            ("Push", [0, 1, 2, 3]),  // Push day exercises
            ("Pull", [4, 5, 6, 7]),  // Pull day exercises
            ("Legs", [8, 9, 10, 11]) // Leg day exercises
        ]
        
        var dayOffset = 0
        
        // Generate 30 days of workouts
        while dayOffset < 30 {
            for (splitName, exerciseIndices) in workoutSplit {
                // Skip some workouts randomly (15% chance) to simulate rest days
                if Double.random(in: 0...1) < 0.15 {
                    dayOffset += 1
                    continue
                }
                
                guard let workoutDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
                
                let workout = Workout(context: context)
                workout.id = UUID()
                workout.date = workoutDate
                workout.type = "Strength"
                workout.name = splitName
                
                // Create exercises for this workout
                for exerciseIndex in exerciseIndices {
                    let (template, baseWeight) = templates[exerciseIndex]
                    
                    let exercise = Exercise(context: context)
                    exercise.id = UUID()
                    exercise.name = template.name
                    exercise.template = template
                    exercise.workout = workout
                    
                    // Calculate progressive overload
                    let weekProgress = Double(dayOffset / 7) * 2.5  // 2.5 lbs increase per week
                    
                    // Generate sets
                    let setCount = 4  // Consistent 4 sets for all exercises
                    var exerciseSets = Set<ExerciseSet>()
                    
                    for setIndex in 0..<setCount {
                        let set = ExerciseSet(context: context)
                        set.id = UUID()
                        set.exercise = exercise
                        set.order = Int16(setIndex)
                        
                        // Calculate reps - pyramid down
                        let baseReps: Int16 = 12
                        set.reps = baseReps - Int16(setIndex * 2) + Int16.random(in: -1...1)
                        
                        // Calculate weight - pyramid up
                        var setWeight = baseWeight
                        setWeight += weekProgress // Progressive overload
                        setWeight += Double(setIndex) * 5.0 // Weight increase per set
                        setWeight += Double.random(in: -2.5...2.5) // Small variation
                        setWeight = round(setWeight / 5) * 5 // Round to nearest 5
                        
                        set.weight = setWeight
                        exerciseSets.insert(set)
                    }
                    
                    exercise.sets = exerciseSets as NSSet
                    
                    // Create strength progress entry
                    let progress = StrengthProgress.create(in: context)
                    progress.exercise = exercise
                    progress.exerciseTemplate = template
                    progress.date = workoutDate
                    
                    // Update progress metrics
                    let sets = exerciseSets
                    progress.totalSets = Int16(sets.count)
                    progress.maxWeight = sets.max(by: { $0.weight < $1.weight })?.weight ?? 0
                    progress.maxReps = sets.max(by: { $0.reps < $1.reps })?.reps ?? 0
                    progress.averageWeight = sets.reduce(0) { $0 + $1.weight } / Double(sets.count)
                    progress.totalVolume = sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
                    
                    // Calculate one rep max using the best set
                    if let bestSet = sets.max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) }) {
                        progress.oneRepMax = progress.calculateOneRepMax(weight: bestSet.weight, reps: bestSet.reps)
                    }
                    
                    // Create progress metrics for charts
                    for metricType in MetricType.allCases {
                        let metric = ProgressMetric.create(in: context, type: metricType)
                        metric.template = template
                        metric.date = workoutDate
                        
                        switch metricType {
                        case .oneRepMax:
                            metric.value = progress.oneRepMax
                        case .maxWeight:
                            metric.value = progress.maxWeight
                        case .maxReps:
                            metric.value = Double(progress.maxReps)
                        case .totalVolume:
                            metric.value = progress.totalVolume
                        case .averageWeight:
                            metric.value = progress.averageWeight
                        }
                    }
                }
                
                dayOffset += 1
            }
        }
    }
    
    private static func generateCardioWorkouts(in context: NSManagedObjectContext) {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate 30 days of cardio workouts
        for dayOffset in 0..<30 {
            // Skip some days randomly (30% chance) to simulate rest days
            if Double.random(in: 0...1) < 0.3 {
                continue
            }
            
            guard let workoutDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Alternate between running and biking
            let isRunning = dayOffset % 2 == 0
            
            let workout = Workout(context: context)
            workout.id = UUID()
            workout.date = workoutDate
            workout.type = isRunning ? "Running" : "Biking"
            workout.name = isRunning ? "Morning Run" : "Evening Ride"
            
            // Create route
            let route = Route(context: context)
            route.id = UUID()
            route.startTime = workoutDate
            route.endTime = calendar.date(byAdding: .minute, value: Int.random(in: 30...90), to: workoutDate)
            
            // Generate route points
            var totalDistance = 0.0
            let targetDistance = Double.random(in: isRunning ? 3...8 : 10...20) // miles
            var currentLat = 37.7749 // Sample starting point (San Francisco)
            var currentLon = -122.4194
            
            while totalDistance < targetDistance {
                let point = RoutePoint(context: context)
                point.id = UUID()
                point.timestamp = calendar.date(byAdding: .second, value: Int.random(in: 10...30), to: route.startTime ?? workoutDate)
                point.order = Int16((route.points?.count ?? 0))
                
                // Simulate movement
                currentLat += Double.random(in: -0.001...0.001)
                currentLon += Double.random(in: -0.001...0.001)
                point.latitude = currentLat
                point.longitude = currentLon
                
                point.route = route
                
                // Update total distance
                if let previousPoint = route.pointsArray.last {
                    let segmentDistance = route.calculateDistance(from: previousPoint, to: point)
                    totalDistance += segmentDistance
                }
            }
            
            route.distance = totalDistance
            workout.route = route
            
            // Create cardio progress
            let progress = CardioProgress(context: context)
            progress.id = UUID()
            progress.date = workoutDate
            progress.route = route
            progress.updateFromRoute(route)
            
            // Add some progression over time
            let weekProgress = Double(dayOffset / 7)
            progress.averagePace -= weekProgress * 0.1 // Slight improvement in pace over time
            
            // Save the workout
            workout.distance = totalDistance
            if let start = route.startTime, let end = route.endTime {
                workout.duration = end.timeIntervalSince(start)
            }
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