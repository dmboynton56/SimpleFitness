import SwiftUI
import Charts

enum DateRange: String, CaseIterable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "All"
    
    var date: Date? {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: now)
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: now)
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: now)
        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: now)
        case .all:
            return nil
        }
    }
}

struct ExerciseProgressDetail: View {
    @StateObject private var viewModel: ExerciseProgressDetailViewModel
    @State private var selectedDateRange: DateRange = .oneMonth
    @State private var selectedDataPoint: ProgressMetric?
    
    init(template: ExerciseTemplate) {
        _viewModel = StateObject(wrappedValue: ExerciseProgressDetailViewModel(template: template))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Metric Type Selector
                Menu {
                    ForEach(MetricType.allCases) { type in
                        Button {
                            viewModel.selectedMetricType = type
                        } label: {
                            Label(type.displayName, systemImage: metricIcon(for: type))
                        }
                    }
                } label: {
                    HStack {
                        Label(viewModel.selectedMetricType.displayName, systemImage: metricIcon(for: viewModel.selectedMetricType))
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadData()
                            }
                        }
                    }
                    .padding()
                } else {
                    // Stats Grid
                    if let progress = viewModel.latestProgress {
                        StatsGrid(progress: progress)
                            .padding(.horizontal)
                    }
                    
                    // Chart Section
                    if !viewModel.progressMetrics.isEmpty {
                        ChartSection(
                            metrics: viewModel.progressMetrics,
                            selectedMetricType: viewModel.selectedMetricType,
                            selectedDateRange: $selectedDateRange,
                            selectedDataPoint: $selectedDataPoint
                        )
                    }
                    
                    // History Section
                    if !viewModel.exerciseHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("History")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.exerciseHistory, id: \.date) { entry in
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
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.loadData()
        }
        .navigationTitle(viewModel.template.name ?? "Exercise Progress")
    }
    
    private func metricIcon(for type: MetricType) -> String {
        switch type {
        case .oneRepMax:
            return "bolt.fill"
        case .maxWeight:
            return "scalemass.fill"
        case .maxReps:
            return "repeat"
        case .totalVolume:
            return "sum"
        case .averageWeight:
            return "chart.bar.fill"
        }
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
    let selectedMetricType: MetricType
    @Binding var selectedDateRange: DateRange
    @Binding var selectedDataPoint: ProgressMetric?
    
    var filteredMetrics: [ProgressMetric] {
        let filtered = metrics.filter { $0.type == selectedMetricType.rawValue }
        if let startDate = selectedDateRange.date {
            return filtered.filter { ($0.date ?? Date()) >= startDate }
        }
        return filtered
    }
    
    private var yAxisRange: ClosedRange<Double> {
        let values = filteredMetrics.map { $0.value }
        guard let minValue = values.min(),
              let maxValue = values.max() else {
            return 0...100 // Default range if no data
        }
        
        let range = maxValue - minValue
        let padding = range * 0.1 // 10% padding
        
        return max(0, minValue - padding)...maxValue + padding
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress Over Time")
                    .font(.headline)
                
                Picker("Date Range", selection: $selectedDateRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            Chart(filteredMetrics) { metric in
                LineMark(
                    x: .value("Date", metric.date ?? Date()),
                    y: .value("Value", metric.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.accentColor.opacity(0.5))
                
                PointMark(
                    x: .value("Date", metric.date ?? Date()),
                    y: .value("Value", metric.value)
                )
                .foregroundStyle(Color.accentColor)
                .symbolSize(selectedDataPoint?.id == metric.id ? 150 : 50)
            }
            .chartYScale(domain: yAxisRange)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let doubleValue = value.as(Double.self) {
                        AxisValueLabel {
                            switch selectedMetricType {
                            case .maxReps:
                                Text("\(Int(doubleValue))")
                            default:
                                Text("\(Int(doubleValue))lbs")
                            }
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.month(.abbreviated))
                        }
                    }
                }
            }
            .frame(height: 300)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ExerciseProgressDetail(template: ExerciseTemplate.preview)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 