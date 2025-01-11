//
//  ContentView.swift
//  SimpleFitness
//
//  Created by Drew Boynton on 1/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.date, ascending: true)],
        animation: .default)
    private var workouts: FetchedResults<Workout>

    var body: some View {
        NavigationView {
            List {
                ForEach(workouts) { workout in
                    if workout.isDeleted == false && workout.isFault == false { // Safeguard for deleted/faulted objects
                        NavigationLink(
                            destination: Text("Workout on \(workout.date ?? Date(), formatter: dateFormatter)"),
                            label: {
                                Text(workout.date ?? Date(), formatter: dateFormatter)
                            }
                        )
                    }
                }
                .onDelete(perform: deleteWorkouts)
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addWorkout) {
                        Label("Add Workout", systemImage: "plus")
                    }
                }
            }
            Text("Select a workout")
        }
    }

    private func addWorkout() {
        viewContext.performAndWait { // Ensure thread safety
            let newWorkout = Workout(context: viewContext)
            newWorkout.id = UUID() // Assign a unique identifier
            newWorkout.date = Date()
            newWorkout.distance = 0.0
            newWorkout.duration = 0.0
            newWorkout.type = "Default"

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteWorkouts(offsets: IndexSet) {
        viewContext.performAndWait { // Ensure thread safety
            offsets.map { workouts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
