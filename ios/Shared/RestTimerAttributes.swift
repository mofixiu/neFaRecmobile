import ActivityKit
import Foundation

/// The running neFaRec timer, shared by the app and its Live Activity.
@available(iOS 16.1, *)
struct RestTimerAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    /// "Rest · next: Lateral raise, set 2"
    var label: String
    /// "rest" or "hold".
    var kind: String
    var startedAt: Date
    /// When the target is reached. Before it the timer counts down, after it
    /// counts up: the overtime.
    var targetAt: Date
    var targetSeconds: Double
    /// Set while a hold is paused: the frozen elapsed seconds.
    var pausedElapsed: Double?
  }

  var workout: String
}
