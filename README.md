# SimpleFitness

A simple fitness tracking application for iOS that allows users to log workouts, track progress, and visualize their fitness journey.

## Recent Updates
- Completed Phase 4: Cardio Progress Implementation
- Added cardio progress tracking with distance, pace, and route metrics
- Implemented route visualization for recent cardio workouts
- Enhanced sample data generation for strength and cardio workouts
- Added workout type filtering for running and biking activities
- Improved progress visualization with dropdown metric selection
- Implemented consistent padding and styling across progress views

## In-Progress Features
- Route Visualization Enhancement (Phase 4.4)
  - MapKit integration for displaying workout routes
  - Mile markers and split time visualization
  - Elevation profile display
  - Detailed route analysis tools
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
    - View detailed cardio history

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
│   │   ├── CardioProgress+CoreDataClass.swift
│   │   ├── Route+CoreDataClass.swift
│   │   ├── RoutePoint+CoreDataClass.swift
│   │   ├── ProgressMetric+CoreDataClass.swift
│   │   └── MetricType.swift
│   └── Services/
│       ├── LocationManager.swift
│       ├── Persistence.swift
│       ├── ExerciseTemplateService.swift
│       └── ProgressCalculationService.swift
└── Features/
    ├── Progress/
    │   ├── ProgressView.swift
    │   ├── Strength/
    │   │   ├── StrengthProgressView.swift
    │   │   ├── StrengthProgressViewModel.swift
    │   │   └── Components/
    │   │       ├── ExerciseProgressCard.swift
    │   │       └── ExerciseProgressDetail.swift
    │   └── Cardio/
    │       ├── CardioProgressView.swift
    │       ├── CardioProgressViewModel.swift
    │       └── Components/
    │           ├── CardioProgressChart.swift
    │           └── CardioActivityCard.swift
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