# SimpleFitness

A simple iOS fitness tracking application that allows users to manually log workouts with sets, reps, and weights. The app also includes optional GPS tracking for running and biking activities.

## Features

- Manual workout entry with sets and reps
- Weight tracking for strength exercises
- Duration and distance logging
- Optional GPS tracking for outdoor activities
- Workout history viewing

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
```bash
git clone https://github.com/[your-username]/SimpleFitness.git
```

2. Open the project in Xcode
```bash
cd SimpleFitness
open SimpleFitness.xcodeproj
```

3. Build and run the project in Xcode

## Architecture

The project follows the MVVM (Model-View-ViewModel) architecture pattern and is organized into the following structure:

- **App**: Contains app-level files and entry points
- **Core**: Contains core models and services
- **Features**: Contains feature-specific views and view models
- **Shared**: Contains shared components and utilities

## File Structure

SimpleFitness/
├── App/
│ └── SimpleFitnessApp.swift
├── Core/
│ ├── Models/
│ │ ├── SimpleFitnessModel.xcdatamodeld
│ │ ├── Workout+CoreDataClass.swift
│ │ ├── Exercise+CoreDataClass.swift
│ │ ├── Workout+CoreDataProperties.swift
│ │ └── Exercise+CoreDataProperties.swift
│ └── Services/
│ ├── LocationManager.swift
│ └── PersistenceController.swift
├── Features/
│ ├── Workouts/
│ │ ├── Add/
│ │ │ ├── AddWorkoutView.swift
│ │ │ ├── AddWorkoutViewModel.swift
│ │ │ ├── Components/
│ │ │ │ ├── WorkoutTypeSelectionView.swift
│ │ │ │ ├── StrengthWorkoutForm.swift
│ │ │ │ ├── CardioWorkoutForm.swift
│ │ │ │ └── ActiveWorkoutView.swift
│ │ │ └── Models/
│ │ │ ├── ExerciseFormModel.swift
│ │ │ └── WorkoutFormModel.swift
│ │ ├── List/
│ │ │ ├── WorkoutListView.swift
│ │ │ └── WorkoutListViewModel.swift
│ │ └── Detail/
│ │ WorkoutDetailView.swift
│ │ WorkoutDetailViewModel.swift
│ | Components/
| ExerciseEditForm.swift
├── Views/
| NumberField.Swift

## License

This project is licensed under the MIT License - see the LICENSE file for details 