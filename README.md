# SimpleFitness

A simple fitness tracking application that allows users to manually log workouts with sets, reps, and weights. Includes optional GPS tracking for running and biking activities.

## Recent Updates

- Enhanced input field management with improved keyboard handling
- Streamlined exercise and set management with immediate data persistence
- Improved UI layout and spacing for better readability
- Fixed exercise set editing and validation

## Features

- Manual workout entry with sets and reps
- Weight tracking for strength exercises
- Duration and distance logging
- Optional GPS tracking for outdoor activities
- Workout history viewing
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

### Key Components
- `NumberField`: Reusable numeric input with validation
- `ExerciseEditForm`: Centralized exercise management
- `SetList` & `SetRow`: Exercise set management with proper layout
- Focus state management for improved input handling

## Contributing
Feel free to submit issues and pull requests.

## License
MIT License - see LICENSE file for details 