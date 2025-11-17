import Charts
import SwiftUI

struct FinancialChartView: View {
  let data: [ChartableSalesByHour]

  private func colorFor(index: Int) -> Color {
    if index == 0 {
      return .blue  // Default for first element
    }
    if data[index].amount > data[index - 1].amount {
      return .blue  // Rise
    } else {
      return .red  // Fall
    }
  }

  var body: some View {
    VStack {
      Chart {
        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
          LineMark(
            x: .value("Hour", item.hour),
            y: .value("Sales", item.amount)
          )
          .foregroundStyle(colorFor(index: index))

          if item.amount < 0 {  // Assuming cutoff is 0
            AreaMark(
              x: .value("Hour", item.hour),
              yStart: .value("Zero", 0),
              yEnd: .value("Sales", item.amount)
            )
            .foregroundStyle(Color.red.opacity(0.3))
          }
        }
      }
      .chartYScale(domain: .automatic)
      .chartXAxis {
        AxisMarks(position: .bottom) { value in
          AxisGridLine()
          AxisTick()
          AxisValueLabel().font(.system(size: 10))
        }
      }
      .padding()
      .background(Color.black)
      .cornerRadius(10)
    }
    .padding()
  }
}
