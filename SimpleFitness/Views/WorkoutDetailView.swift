//
//  WorkoutDetailView.swift
//  SimpleFitness
//
//  Created by Drew Boynton on 1/10/25.
//

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        if !workout.isDeleted && !workout.isFault { // Safeguard for deleted/faulted objects
            VStack(alignment: .leading) {
                Text("Workout Details")
                    .font(.title)

                Text("Type: \(workout.type ?? "Unknown")")
                    .font(.headline)

                Text("Date: \(workout.date ?? Date(), formatter: dateFormatter)")
                    .font(.subheadline)

                // Add more workout details here as needed.
            }
            .padding()
        } else {
            Text("This workout is no longer available.")
                .foregroundColor(.red)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
