import SwiftUI
import Charts

struct ExerciseProgressDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    let template: ExerciseTemplate
    @StateObject private var viewModel: ExerciseProgressDetailViewModel
    @State private var selectedMetric = MetricType.oneRepMax
    
    init(template: ExerciseTemplate) {
        self.template = template
        _viewModel = StateObject(wrappedValue: ExerciseProgressDetailViewModel(
            template: template,
            progressService: ProgressCalculationService(viewContext: PersistenceController.shared.container.viewContext)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                metricTypeSelector
                statsGrid
                chartSection
                historySection
            }
            .padding()
        }
        .navigationTitle(template.name ?? "Exercise Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var metricTypeSelector: some View {
        Picker("Metric", selection: $selectedMetric) {
            ForEach(MetricType.allCases) { metric in
                Text(metric.displayName)
                    .tag(metric)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            if let progress = viewModel.latestProgress {
                StatCard(
                    title: "Max Weight",
                    value: String(format: "%.1f", progress.maxWeight),
                    unit: "kg"
                )
                StatCard(
                    title: "Max Reps",
                    value: "\(progress.maxReps)",
                    unit: "reps"
                )
                StatCard(
                    title: "1RM",
                    value: String(format: "%.1f", progress.oneRepMax),
                    unit: "kg"
                )
            }
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.headline)
            
            if let metrics = viewModel.progressMetrics {
                Chart(metrics) { metric in
                    LineMark(
                        x: .value("Date", metric.date ?? Date()),
                        y: .value("Value", metric.value)
                    )
                    .foregroundStyle(Color.accentColor)
                    
                    PointMark(
                        x: .value("Date", metric.date ?? Date()),
                        y: .value("Value", metric.value)
                    )
                    .foregroundStyle(Color.accentColor)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month().day())
                            }
                        }
                    }
                }
            } else {
                Text("No progress data available")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Workouts")
                .font(.headline)
            
            if let history = viewModel.exerciseHistory {
                ForEach(history) { exercise in
                    if let sets = exercise.sets as? Set<ExerciseSet>,
                       let workout = exercise.workout,
                       let date = workout.date {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(date, format: .dateTime.month().day().year())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(Array(sets).sorted(by: { $0.order < $1.order })) { set in
                                Text("\(set.reps) reps × \(String(format: "%.1f", set.weight)) kg")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        if exercise.id != history.last?.id {
                            Divider()
                        }
                    }
                }
            } else {
                Text("No workout history available")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title2.bold())
            
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ExerciseProgressDetail(template: ExerciseTemplate.preview)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 