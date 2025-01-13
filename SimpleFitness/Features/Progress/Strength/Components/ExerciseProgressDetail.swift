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
                metricTypeSelector
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
                } else {
                    statsGrid
                    chartSection
                    historySection
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadData()
        }
        .navigationTitle(viewModel.template.name ?? "Exercise Progress")
    }
    
    private var metricTypeSelector: some View {
        Picker("Metric Type", selection: $viewModel.selectedMetricType) {
            ForEach(MetricType.allCases) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var statsGrid: some View {
        Group {
            if let progress = viewModel.latestProgress {
                StatsGrid(progress: progress)
            } else {
                EmptyView()
            }
        }
    }
    
    private var chartSection: some View {
        Group {
            if !viewModel.progressMetrics.isEmpty {
                ChartSection(
                    metrics: viewModel.progressMetrics,
                    selectedMetricType: viewModel.selectedMetricType,
                    selectedDateRange: $selectedDateRange,
                    selectedDataPoint: $selectedDataPoint
                )
            } else {
                EmptyView()
            }
        }
    }
    
    private var historySection: some View {
        Group {
            if !viewModel.exerciseHistory.isEmpty {
                HistorySection(history: viewModel.exerciseHistory)
            } else {
                EmptyView()
            }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress Over Time")
                    .font(.headline)
                Spacer()
                Picker("Date Range", selection: $selectedDateRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            Chart {
                ForEach(filteredMetrics) { metric in
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
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let currentX = value.location.x - geometry.size.width/2
                                    guard let date = proxy.value(atX: currentX) as Date? else { return }
                                    
                                    // Find the closest data point
                                    selectedDataPoint = filteredMetrics
                                        .min(by: { abs($0.date?.timeIntervalSince(date) ?? 0) < abs($1.date?.timeIntervalSince(date) ?? 0) })
                                }
                                .onEnded { _ in
                                    selectedDataPoint = nil
                                }
                        )
                }
            }
            .chartBackground { proxy in
                if let selectedDataPoint = selectedDataPoint,
                   let date = selectedDataPoint.date {
                    ZStack(alignment: .topLeading) {
                        // Tooltip background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 4)
                            .frame(width: 120, height: 70)
                        
                        // Tooltip content
                        VStack(alignment: .leading, spacing: 4) {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(Int(selectedDataPoint.value))")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(8)
                    }
                    .offset(x: proxy.position(forX: date) ?? 0)
                    .animation(.snappy, value: selectedDataPoint)
                }
            }
            .frame(height: 250)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .animation(.snappy, value: selectedMetricType)
            .animation(.snappy, value: selectedDateRange)
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