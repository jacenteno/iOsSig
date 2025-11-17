import Charts
import SwiftUI

// A data point for the sales history chart.
struct SalesDataPoint: Identifiable {
  let id = UUID()
  let label: String  // e.g., "Sep/25"
  let sales: Double
  let returns: Double

  // Helper for creating chart entries
  var chartEntries: [ChartEntry] {
    [
      ChartEntry(type: "Ventas", value: sales),
      ChartEntry(type: "Salidas", value: returns),
    ]
  }
}

// A single entry for the chart, representing either a sale or a return.
struct ChartEntry: Identifiable {
  let id = UUID()
  let type: String
  let value: Double
}

// A reusable grouped bar chart view for displaying sales and returns history.
struct SalesHistoryChartView: View {
  let data: [SalesDataPoint]
  let salesColor: Color
  let returnsColor: Color

  @State private var chartImage: UIImage?
  @State private var showShareSheet = false
  @State private var isRendering = false  // For loading indicator

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Chart Header with Share Button
      HStack {
        Image(systemName: "chart.bar.xaxis")
          .font(.title2.bold())
          .foregroundColor(salesColor)
        Text("Ventas vs. Salidas (Mes)")
          .font(.title2.bold())
        Spacer()
        Button(action: shareChart) {
          if isRendering {
            ProgressView()
          } else {
            Image(systemName: "square.and.arrow.up")
              .font(.title2)
              .foregroundColor(.secondary)
          }
        }
        .disabled(isRendering)
      }

      // Legend
      HStack(spacing: 20) {
        HStack(spacing: 6) {
          Circle().fill(salesColor).frame(width: 10, height: 10)
          Text("Ventas").font(.caption)
        }
        HStack(spacing: 6) {
          Circle().fill(returnsColor).frame(width: 10, height: 10)
          Text("Salidas").font(.caption)
        }
      }

      // Chart View
      chartBody
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .padding()
    .sheet(isPresented: $showShareSheet) {
      if let image = chartImage {
        ShareSheet(activityItems: [image])
      }
    }
  }

  private var chartBody: some View {
    Chart {
      ForEach(data) { point in
        ForEach(point.chartEntries) { entry in
          BarMark(
            x: .value("Mes", point.label),
            y: .value("Cantidad", entry.value)
          )
          .position(by: .value("Tipo", entry.type))
          .foregroundStyle(by: .value("Tipo", entry.type))
        }
      }
    }
    .chartForegroundStyleScale([
      "Ventas": salesColor.gradient,
      "Salidas": returnsColor.gradient,
    ])
    .chartYAxis {
      AxisMarks(values: .automatic) { _ in
        AxisGridLine()
      }
    }
    .chartXAxis {
      AxisMarks(values: .automatic) { _ in
        AxisGridLine()
        AxisTick()
        AxisValueLabel().font(.caption)
      }
    }
    .frame(height: 250)
  }

  private func shareChart() {
    Task {
      isRendering = true

      let viewToCapture =
        chartBody
        .padding()
        .background(Color(.systemBackground))

      // Use the new async render function
      let image = await viewToCapture.renderAsImage()

      self.chartImage = image
      self.isRendering = false

      if self.chartImage != nil {
        self.showShareSheet = true
      }
    }
  }
}
