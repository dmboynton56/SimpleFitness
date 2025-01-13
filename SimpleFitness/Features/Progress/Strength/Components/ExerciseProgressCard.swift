import SwiftUI
import Charts

struct ExerciseProgressCard: View {
    let template: ExerciseTemplate
    let latestProgress: StrengthProgress?
    let progressMetrics: [ProgressMetric]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(template.name ?? "Unknown Exercise")
                    .font(.headline)
                Spacer()
                Text(template.category ?? "Uncategorized")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Latest Progress
            if let latestProgress = latestProgress {
                HStack(spacing: 16) {
                    ProgressStat(
                        title: "Max Weight",
                        value: "\(Int(latestProgress.maxWeight))lbs"
                    )
                    ProgressStat(
                        title: "Max Reps",
                        value: "\(Int(latestProgress.maxReps))"
                    )
                    ProgressStat(
                        title: "1RM",
                        value: "\(Int(latestProgress.oneRepMax))lbs"
                    )
                }
            }
            
            // Progress Chart
            if !progressMetrics.isEmpty {
                Chart {
                    ForEach(progressMetrics) { metric in
                        LineMark(
                            x: .value("Date", metric.date ?? Date()),
                            y: .value("Value", metric.value)
                        )
                        .foregroundStyle(by: .value("Metric", metric.type ?? ""))
                    }
                }
                .frame(height: 150)
            } else {
                Text("No progress data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ProgressStat: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
    }
}

#Preview {
    ExerciseProgressCard(
        template: ExerciseTemplate.preview,
        latestProgress: nil,
        progressMetrics: []
    )
    .padding()
} 