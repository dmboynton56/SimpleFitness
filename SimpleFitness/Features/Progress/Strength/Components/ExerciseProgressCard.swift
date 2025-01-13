import SwiftUI
import Charts

struct ExerciseProgressCard: View {
    let template: ExerciseTemplate
    let latestProgress: StrengthProgress?
    let progressMetrics: [ProgressMetric]
    
    var body: some View {
        NavigationLink(destination: ExerciseProgressDetail(template: template)) {
            VStack(alignment: .leading, spacing: 12) {
                cardHeader
                latestProgressSection
                progressChartSection
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var cardHeader: some View {
        HStack {
            Text(template.displayName)
                .font(.headline)
            Spacer()
            Text(template.category ?? "Uncategorized")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var latestProgressSection: some View {
        Group {
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
        }
    }
    
    private var progressChartSection: some View {
        Group {
            if !progressMetrics.isEmpty {
                ProgressChart(metrics: progressMetrics)
                    .frame(height: 150)
            } else {
                Text("No progress data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ProgressChart: View {
    let metrics: [ProgressMetric]
    
    var body: some View {
        Chart {
            ForEach(metrics) { metric in
                LineMark(
                    x: .value("Date", metric.date ?? Date()),
                    y: .value("Value", metric.value)
                )
                .foregroundStyle(by: .value("Metric", metric.type ?? ""))
            }
        }
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