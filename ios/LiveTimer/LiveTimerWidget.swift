import ActivityKit
import SwiftUI
import WidgetKit

@main
struct LiveTimerBundle: WidgetBundle {
  var body: some Widget {
    RestTimerLiveActivity()
  }
}

private let orange = Color(red: 1, green: 0.353, blue: 0.122)
private let board = Color(red: 0.129, green: 0.118, blue: 0.098)
private let cream = Color(red: 0.973, green: 0.945, blue: 0.894)
private let muted = Color(red: 0.655, green: 0.616, blue: 0.557)

private func clock(_ seconds: Double) -> String {
  let s = Int(seconds.rounded())
  return String(format: "%d:%02d", s / 60, s % 60)
}

/// Counts down to the target, then keeps counting up past it, without the
/// app having to wake up. A paused hold shows its frozen time.
struct TimerText: View {
  let state: RestTimerAttributes.ContentState

  var body: some View {
    if let paused = state.pausedElapsed {
      Text(clock(paused))
    } else {
      Text(state.targetAt, style: .timer)
    }
  }
}

struct Wordmark: View {
  var body: some View {
    (Text("neFa").foregroundColor(cream) + Text("R").foregroundColor(orange) + Text("ec").foregroundColor(cream))
      .font(.system(size: 13, weight: .heavy))
  }
}

struct LockScreenView: View {
  let context: ActivityViewContext<RestTimerAttributes>

  var body: some View {
    let s = context.state
    HStack(alignment: .center, spacing: 14) {
      VStack(alignment: .leading, spacing: 6) {
        HStack(spacing: 6) {
          Wordmark()
          Text(s.kind == "hold" ? "· HOLD" : "· REST")
            .font(.system(size: 11, weight: .bold))
            .tracking(1.2)
            .foregroundColor(muted)
        }
        Text(s.label)
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(cream)
          .lineLimit(1)
        if s.pausedElapsed == nil {
          ProgressView(timerInterval: s.startedAt...s.targetAt, countsDown: false) {
            EmptyView()
          } currentValueLabel: {
            EmptyView()
          }
          .tint(orange)
          HStack(spacing: 4) {
            Text("Target \(clock(s.targetSeconds)) at")
            Text(s.targetAt, style: .time)
          }
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(muted)
        } else {
          Text("Paused")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(muted)
        }
      }
      Spacer(minLength: 8)
      TimerText(state: s)
        .font(.system(size: 44, weight: .black, design: .rounded))
        .monospacedDigit()
        .foregroundColor(orange)
        .multilineTextAlignment(.trailing)
        .frame(minWidth: 100, alignment: .trailing)
    }
    .padding(16)
  }
}

struct RestTimerLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: RestTimerAttributes.self) { context in
      LockScreenView(context: context)
        .activityBackgroundTint(board)
        .activitySystemActionForegroundColor(cream)
    } dynamicIsland: { context in
      let s = context.state
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Label(s.kind == "hold" ? "Hold" : "Rest", systemImage: "timer")
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(orange)
        }
        DynamicIslandExpandedRegion(.trailing) {
          TimerText(state: s)
            .font(.system(size: 26, weight: .black, design: .rounded))
            .monospacedDigit()
            .foregroundColor(orange)
            .frame(maxWidth: 110, alignment: .trailing)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 6) {
            Text(s.label)
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(cream)
              .lineLimit(1)
            if s.pausedElapsed == nil {
              ProgressView(timerInterval: s.startedAt...s.targetAt, countsDown: false) {
                EmptyView()
              } currentValueLabel: {
                EmptyView()
              }
              .tint(orange)
            }
          }
        }
      } compactLeading: {
        Image(systemName: "timer").foregroundColor(orange)
      } compactTrailing: {
        TimerText(state: s)
          .monospacedDigit()
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(orange)
          .frame(maxWidth: 52)
      } minimal: {
        Image(systemName: "timer").foregroundColor(orange)
      }
      .keylineTint(orange)
    }
  }
}
