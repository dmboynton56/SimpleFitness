# SimpleFitness

A simple fitness tracking application for iOS that allows users to log workouts, track progress, and visualize their fitness journey.

## Recent Updates
- Added comprehensive progress tracking for strength exercises
- Implemented interactive charts with date range filtering
- Enhanced exercise template selection and management
- Added pull-to-refresh and improved loading states
- Improved error handling and user feedback

## In-Progress Features
- Exercise Progress Tracking (Phase 4: Cardio Progress Implementation)
  - Track distance and pace metrics for cardio workouts
  - Visualize route data and performance trends
  - Filter progress by date range
  - View detailed cardio history
  - Analyze pace and distance improvements

## Completed Features
- Strength Progress Implementation (Phase 3)
  - Track weight and rep progress over time
  - Visualize progress with interactive charts
  - Filter progress by date range
  - View detailed exercise history
  - Exercise-specific progress tracking

## Development Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftUI
- CoreData

## Setup Instructions
1. Clone the repository
2. Open SimpleFitness.xcodeproj in Xcode
3. Build and run the project

## File Structure
```
SimpleFitness/
├── App/
│   └── SimpleFitnessApp.swift
├── Core/
│   ├── Models/
│   │   ├── SimpleFitnessModel.xcdatamodeld
│   │   ├── Exercise+CoreDataClass.swift
│   │   ├── ExerciseTemplate+CoreDataClass.swift
│   │   ├── StrengthProgress+CoreDataClass.swift
│   │   └── ProgressMetric+CoreDataClass.swift
│   └── Services/
│       ├── LocationManager.swift
│       ├── Persistence.swift
│       ├── ExerciseTemplateService.swift
│       └── ProgressCalculationService.swift
└── Features/
    ├── Progress/
    │   ├── Main/
    │   │   └── ProgressView.swift
    │   └── Strength/
    │       ├── StrengthProgressView.swift
    │       ├── StrengthProgressViewModel.swift
    │       └── Components/
    │           ├── ExerciseProgressCard.swift
    │           └── ExerciseProgressDetail.swift
    └── Workouts/
        ├── List/
        │   ├── WorkoutListView.swift
        │   └── WorkoutListViewModel.swift
        ├── Add/
        │   ├── AddWorkoutView.swift
        │   └── Components/
        │       ├── WorkoutTypeSelectionView.swift
        │       └── ActiveWorkoutView.swift
        └── Detail/
            ├── WorkoutDetailView.swift
            ├── WorkoutDetailViewModel.swift
            └── Components/
                └── EditExerciseForm.swift
```

## Key Features
- Manual workout entry with sets and reps
- Weight tracking for strength exercises
- Duration and distance logging
- Optional GPS tracking for outdoor activities
- Progress tracking and visualization
- Exercise history and trends
- Template-based exercise management

## Progress Tracking
The app now includes comprehensive progress tracking features:
- Strength Progress
  - Track max weight, reps, and one-rep max
  - View progress charts with date filtering
  - Analyze trends and improvements
  - Access detailed exercise history
- Coming Soon: Cardio Progress
  - Track distance, pace, and duration
  - View route maps and elevation data
  - Analyze performance trends

## Contributing
Feel free to submit issues and enhancement requests. 