import SwiftUI
import Charts

struct CardioProgressView: View {
    @StateObject private var viewModel = CardioProgressViewModel()
    @State private var selectedMetric: CardioMetricType = .distance
    @State private var timeRange: TimeRange = .month
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Metric Selection
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(CardioMetricType.allCases) { metric in
                        Text(metric.displayName)
                            .tag(metric)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Time Range Selection
                Picker("Time Range", selection: $timeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.displayName)
                            .tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Progress Chart
                CardioProgressChart(
                    data: viewModel.progressData(for: selectedMetric, timeRange: timeRange),
                    metric: selectedMetric
                )
                .frame(height: 300)
                .padding()
                
                // Recent Activities
                LazyVStack {
                    ForEach(viewModel.recentActivities) { activity in
                        CardioActivityCard(activity: activity)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Cardio Progress")
    }
}

struct CardioProgressChart: View {
    let data: [(date: Date, value: Double)]
    let metric: CardioMetricType
    
    var body: some View {
        Chart {
            ForEach(data, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value(metric.displayName, item.value)
                )
                .foregroundStyle(.blue)
                
                PointMark(
                    x: .value("Date", item.date),
                    y: .value(metric.displayName, item.value)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                if let doubleValue = value.as(Double.self) {
                    AxisValueLabel {
                        switch metric {
                        case .duration:
                            Text(formatDuration(minutes: doubleValue))
                        case .averagePace, .bestPace:
                            Text(formatPace(doubleValue))
                        default:
                            Text(String(format: "%.1f", doubleValue))
                        }
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: .dateTime.month().day())
                    }
                }
            }
        }
    }
    
    private func formatDuration(minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }
    
    private func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct CardioActivityCard: View {
    let activity: CardioActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activity.date, format: .dateTime.month().day().year())
                    .font(.headline)
                Spacer()
                Image(systemName: "figure.run")
                    .foregroundStyle(.blue)
            }
            
            HStack {
                MetricView(
                    value: String(format: "%.2f", activity.distance),
                    unit: "miles",
                    label: "Distance"
                )
                
                Divider()
                
                MetricView(
                    value: formatDuration(minutes: activity.duration),
                    unit: "",
                    label: "Duration"
                )
                
                Divider()
                
                MetricView(
                    value: formatPace(activity.averagePace),
                    unit: "min/mi",
                    label: "Pace"
                )
            }
            
            if !activity.splits.isEmpty {
                Text("Split Times")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(activity.splits.indices, id: \.self) { index in
                            VStack {
                                Text("Mile \(index + 1)")
                                    .font(.caption2)
                                Text(formatPace(activity.splits[index]))
                                    .font(.caption)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func formatDuration(minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }
    
    private func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MetricView: View {
    let value: String
    let unit: String
    let label: String
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .monospacedDigit()
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

struct CardioActivity: Identifiable {
    let id: UUID
    let date: Date
    let distance: Double
    let duration: Double
    let averagePace: Double
    let splits: [Double]
    let elevationGain: Double
}

#Preview {
    NavigationView {
        CardioProgressView()
    }
} 