import SwiftUI
import Charts

struct ExerciseProgressDetail: View {
    let template: ExerciseTemplate
    @StateObject private var viewModel: ExerciseProgressDetailViewModel
    @State private var selectedMetricType = MetricType.oneRepMax
    
    init(template: ExerciseTemplate) {
        self.template = template
        self._viewModel = StateObject(wrappedValue: ExerciseProgressDetailViewModel(template: template))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Metric Type Selector
                Picker("Metric Type", selection: $selectedMetricType) {
                    ForEach(MetricType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Latest Stats
                if let latestProgress = viewModel.latestProgress {
                    StatsGrid(progress: latestProgress)
                        .padding(.horizontal)
                }
                
                // Progress Chart
                if !viewModel.progressMetrics.isEmpty {
                    ChartSection(
                        metrics: viewModel.progressMetrics,
                        selectedType: selectedMetricType
                    )
                } else {
                    Text("No progress data available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                }
                
                // History List
                if !viewModel.exerciseHistory.isEmpty {
                    HistorySection(history: viewModel.exerciseHistory)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(template.name ?? "Exercise Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views
private struct StatsGrid: View {
    let progress: StrengthProgress
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(title: "Max Weight", value: "\(Int(progress.maxWeight))lbs")
            StatCard(title: "Max Reps", value: "\(Int(progress.maxReps))")
            StatCard(title: "1RM", value: "\(Int(progress.oneRepMax))lbs")
            StatCard(title: "Total Volume", value: "\(Int(progress.totalVolume))lbs")
            StatCard(title: "Total Sets", value: "\(progress.totalSets)")
            StatCard(title: "Avg Weight", value: "\(Int(progress.averageWeight))lbs")
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct ChartSection: View {
    let metrics: [ProgressMetric]
    let selectedType: MetricType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress Over Time")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(metrics.filter { $0.type == selectedType.rawValue }) { metric in
                    LineMark(
                        x: .value("Date", metric.date ?? Date()),
                        y: .value("Value", metric.value)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", metric.date ?? Date()),
                        y: .value("Value", metric.value)
                    )
                }
            }
            .frame(height: 250)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
        }
    }
}

private struct HistorySection: View {
    let history: [(date: Date, sets: [ExerciseSet])]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("History")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(history, id: \.date) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ForEach(entry.sets.sorted(by: { $0.order < $1.order })) { set in
                        HStack {
                            Text("Set \(set.order + 1)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(set.weight))lbs × \(set.reps)")
                                .font(.subheadline.bold())
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ExerciseProgressDetail(template: ExerciseTemplate.preview)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 