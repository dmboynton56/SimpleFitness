# SimpleFitness

A simple fitness tracking application that allows users to manually log workouts with sets, reps, and weights. Includes optional GPS tracking for running and biking activities.

## Recent Updates

- Enhanced input field management with improved keyboard handling
- Streamlined exercise and set management with immediate data persistence
- Improved UI layout and spacing for better readability
- Fixed exercise set editing and validation
- Added map visualization for cardio workouts
- Added progress tracking for strength and cardio workouts
- Implemented tab-based navigation structure

## In Progress

🚧 **Exercise Progress Tracking**: Implementing progress visualization and tracking across workouts, including:
- Weight progression tracking
- Rep tracking and performance metrics
- Cardio performance metrics
- Progress visualization
- Historical data analysis

Current Phase: Phase 3 - Strength Progress Implementation
✓ Completed: Navigation structure and data model
⏳ In Progress: Strength progress UI implementation

## Features

- Manual workout entry with sets and reps
- Weight tracking for strength exercises
- Duration and distance logging
- Optional GPS tracking for outdoor activities
- Workout history viewing
- Route visualization for cardio workouts
- Progress tracking for exercises
- Immediate data persistence
- Intuitive keyboard management
- Clean, consistent UI layout

## Development

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Setup
1. Clone the repository
2. Open SimpleFitness.xcodeproj in Xcode
3. Build and run

### Architecture
- SwiftUI for UI
- CoreData for persistence
- MVVM architecture
- Modular components for reusability
- Service-based progress tracking
- Tab-based navigation structure

## File Structure

```
SimpleFitness/
├── App/
│   ├── SimpleFitnessApp.swift
│   └── MainTabView.swift
├── Assets.xcassets/
├── Core/
│   ├── Models/
│   │   ├── SimpleFitnessModel.xcdatamodeld/
│   │   ├── Exercise.swift
│   │   ├── ExerciseTemplate+CoreDataClass.swift
│   │   ├── ExerciseTemplate+CoreDataProperties.swift
│   │   ├── ExerciseSet+CoreDataClass.swift
│   │   ├── ExerciseSet+CoreDataProperties.swift
│   │   ├── Workout+CoreDataClass.swift
│   │   ├── Workout+CoreDataProperties.swift
│   │   ├── StrengthProgress+CoreDataClass.swift
│   │   ├── StrengthProgress+CoreDataProperties.swift
│   │   ├── CardioProgress+CoreDataClass.swift
│   │   ├── CardioProgress+CoreDataProperties.swift
│   │   ├── ProgressMetric+CoreDataClass.swift
│   │   └── ProgressMetric+CoreDataProperties.swift
│   └── Services/
│       ├── LocationManager.swift
│       ├── Persistence.swift
│       ├── ExerciseTemplateService.swift
│       └── ProgressCalculationService.swift
├── Features/
│   ├── Progress/
│   │   ├── Main/
│   │   │   └── ProgressView.swift
│   │   ├── Strength/
│   │   ├── Cardio/
│   │   ├── Charts/
│   │   └── Detail/
│   └── Workouts/
│       ├── Add/
│       │   ├── AddWorkoutView.swift
│       │   ├── AddWorkoutViewModel.swift
│       │   ├── Components/
│       │   │   ├── WorkoutTypeSelectionView.swift
│       │   │   ├── StrengthWorkoutForm.swift
│       │   │   ├── CardioWorkoutForm.swift
│       │   │   └── ActiveWorkoutView.swift
│       │   └── Models/
│       │       └── WorkoutFormModel.swift
│       ├── Detail/
│       │   ├── WorkoutDetailView.swift
│       │   ├── WorkoutDetailViewModel.swift
│       │   └── Components/
│       │       ├── ExerciseEditForm.swift
│       │       └── ExerciseSetList.swift
│       └── List/
│           ├── WorkoutListView.swift
│           └── WorkoutListViewModel.swift
├── Info.plist
├── Resources/
├── Shared/
├── Utils/
└── Views/
    └── NumberField.swift

Tests:
├── SimpleFitnessTests/
└── SimpleFitnessUITests/
```

### Key Components
- `NumberField`: Reusable numeric input with validation
- `ExerciseEditForm`: Centralized exercise management
- `ExerciseSetList`: Exercise set management with proper layout
- `ProgressCalculationService`: Centralized progress tracking and calculations
- `MainTabView`: Tab-based navigation controller
- Focus state management for improved input handling

## Contributing
Feel free to submit issues and pull requests.

## License
MIT License - see LICENSE file for details 