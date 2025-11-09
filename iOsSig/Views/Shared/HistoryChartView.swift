import SwiftUI
import Charts

// A data point for the history chart. Must be Identifiable.
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String // e.g., "Ene/23"
    let value: Double
}

// A reusable bar chart view for displaying historical data.
struct HistoryChartView: View {
    let data: [ChartDataPoint]
    let title: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart Header
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2.bold())
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.title2.bold())
            }

            // Chart View
            Chart(data) { point in
                BarMark(
                    x: .value("Mes", point.label),
                    y: .value("Cantidad", point.value)
                )
                .foregroundStyle(accentColor.gradient)
                .cornerRadius(6)
                
                // Add an annotation on top of each bar to show the value
                .annotation(position: .top, alignment: .center) {
                    Text(String(format: "%.0f", point.value))
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
            .chartYAxis {
                // Hide the Y-axis labels as the annotations are sufficient
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                }
            }
            .chartXAxis {
                // Customize X-axis labels for better readability
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel().font(.caption)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding()
    }
}
