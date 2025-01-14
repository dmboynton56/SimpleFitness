# SimpleFitness

A simple fitness tracking application for iOS that allows users to log workouts, track progress, and visualize their fitness journey.

## Recent Updates
- Completed Phase 4: Exercise Progress Implementation
- Added comprehensive strength and cardio progress tracking
- Implemented route visualization for cardio workouts
- Enhanced sample data generation with realistic progression
- Added workout type filtering and improved metric selection
- Implemented consistent UI styling across progress views
- Completed all planned progress tracking features

## In-Progress Features
- Heart Rate Data Support (Future Enhancement)
  - Heart rate data modeling
  - Zone analysis in workouts
  - Heart rate trends and insights

## Completed Features
- Exercise Progress Tracking (Phase 4)
  - Comprehensive strength progress tracking
    - Track weight and rep progress over time
    - Visualize progress with interactive charts
    - Filter progress by date range
    - View detailed exercise history
    - Exercise-specific progress tracking
  - Cardio progress tracking
    - Track distance and pace metrics
    - View route data and performance trends
    - Filter by running and biking activities
    - Analyze pace and distance improvements
    - View detailed cardio history with route visualization

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
│   │   ├── Exercise+CoreDataProperties.swift
│   │   ├── ExerciseTemplate+CoreDataClass.swift
│   │   ├── ExerciseTemplate+CoreDataProperties.swift
│   │   ├── ExerciseTemplate+Preview.swift
│   │   ├── ExerciseSet+CoreDataClass.swift
│   │   ├── ExerciseSet+CoreDataProperties.swift
│   │   ├── Workout+CoreDataClass.swift
│   │   ├── Workout+CoreDataProperties.swift
│   │   ├── CardioProgress+CoreDataClass.swift
│   │   ├── CardioProgress+CoreDataProperties.swift
│   │   ├── Route+CoreDataClass.swift
│   │   ├── Route+CoreDataProperties.swift
│   │   ├── RoutePoint+CoreDataClass.swift
│   │   ├── RoutePoint+CoreDataProperties.swift
│   │   ├── StrengthProgress+CoreDataClass.swift
│   │   ├── StrengthProgress+CoreDataProperties.swift
│   │   ├── ProgressMetric+CoreDataClass.swift
│   │   ├── ProgressMetric+CoreDataProperties.swift
│   │   ├── MetricType.swift
│   │   └── SampleData.swift
│   └── Services/
│       ├── LocationManager.swift
│       ├── Persistence.swift
│       ├── ExerciseTemplateService.swift
│       └── ProgressCalculationService.swift
├── Features/
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   ├── Strength/
│   │   │   ├── StrengthProgressView.swift
│   │   │   ├── StrengthProgressViewModel.swift
│   │   │   └── Components/
│   │   │       ├── ExerciseProgressCard.swift
│   │   │       ├── ExerciseProgressDetail.swift
│   │   │       └── ExerciseProgressDetailViewModel.swift
│   │   └── Cardio/
│   │       ├── CardioProgressView.swift
│   │       ├── CardioProgressViewModel.swift
│   │       └── Components/
│   │           ├── CardioProgressChart.swift
│   │           └── CardioActivityCard.swift
│   └── Workouts/
│       ├── List/
│       │   ├── WorkoutListView.swift
│       │   └── WorkoutListViewModel.swift
│       ├── Add/
│       │   ├── AddWorkoutView.swift
│       │   ├── AddWorkoutViewModel.swift
│       │   ├── Models/
│       │   │   ├── ExerciseFormModel.swift
│       │   │   └── WorkoutFormModel.swift
│       │   └── Components/
│       │       ├── WorkoutTypeSelectionView.swift
│       │       ├── StrengthWorkoutForm.swift
│       │       ├── CardioWorkoutForm.swift
│       │       └── ActiveWorkoutView.swift
│       └── Detail/
│           ├── WorkoutDetailView.swift
│           ├── WorkoutDetailViewModel.swift
│           └── Components/
│               └── ExerciseEditForm.swift
└── Views/
│    ├── NumberField.swift
│    └── RouteMapView.swift
└── Docs/
    └── swiftrules.md
```

## Key Features
- Manual workout entry with sets and reps
- Weight tracking for strength exercises
- Duration and distance logging
- GPS tracking for outdoor activities
- Comprehensive progress tracking and visualization
- Exercise history and trends
- Template-based exercise management
- Route visualization for cardio workouts

## Progress Tracking
The app includes comprehensive progress tracking features:
- Strength Progress
  - Track max weight, reps, and one-rep max
  - View progress charts with date filtering
  - Analyze trends and improvements
  - Access detailed exercise history
- Cardio Progress
  - Track distance, pace, and duration
  - View route maps for recent workouts
  - Filter between running and biking activities
  - Analyze performance trends
  - View detailed cardio history

## Contributing
Feel free to submit issues and enhancement requests. 