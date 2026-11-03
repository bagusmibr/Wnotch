//
//  IdleNotchContent.swift
//  Wnotch
//
//  Shown when nothing else is active so the notch never looks empty:
//  clock on the left, battery on the right.
//

import SwiftUI
import Combine

struct IdleNotchContent: NotchContentProtocol, DynamicIslandCustomizable {
    let id = NotchContentRegistry.Idle.clock.id
    let powerService: PowerService

    var priority: Int { NotchContentRegistry.Idle.clock.priority }
    var isRestorable: Bool { false }

    func compactSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        .init(width: baseWidth + 110, height: baseHeight)
    }

    func dynamicIslandSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        .init(width: baseWidth + 100, height: baseHeight)
    }

    @MainActor
    func compactView() -> AnyView {
        AnyView(IdleNotchView(powerService: powerService))
    }
}

struct IdleNotchView: View {
    @Environment(\.isNotchlessScreen) private var isNotchlessScreen
    @Environment(\.notchScale) private var scale
    @ObservedObject var powerService: PowerService

    var body: some View {
        HStack {
            TimelineView(.everyMinute) { context in
                Text(context.date, format: .dateTime.hour().minute())
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            Spacer()

            HStack(spacing: 4) {
                Text("\(powerService.batteryLevel)%")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .monospacedDigit()
                Image(systemName: batterySymbol)
                    .font(.system(size: 14))
            }
            .foregroundStyle(batteryTint)
        }
        .padding(.leading, isNotchlessScreen ? 10.scaled(by: scale) : 16.scaled(by: scale))
        .padding(.trailing, isNotchlessScreen ? 10.scaled(by: scale) : 16.scaled(by: scale))
    }

    private var batterySymbol: String {
        if powerService.isCharging { return "battery.100percent.bolt" }
        switch powerService.batteryLevel {
        case ..<13: return "battery.0percent"
        case ..<38: return "battery.25percent"
        case ..<63: return "battery.50percent"
        case ..<88: return "battery.75percent"
        default: return "battery.100percent"
        }
    }

    private var batteryTint: Color {
        if powerService.isCharging { return .green }
        if powerService.isLowPowerMode { return .yellow }
        return powerService.batteryLevel <= 20 ? .red : .white.opacity(0.85)
    }
}

/// Keeps the idle widget registered while the setting is on. The notch engine shows the
/// highest-priority live activity, so this only appears when nothing else is active.
@MainActor
final class NotchIdleEventsHandler {
    private let notchViewModel: NotchViewModel
    private let powerService: PowerService
    private var cancellables = Set<AnyCancellable>()

    init(notchViewModel: NotchViewModel, powerService: PowerService, settings: ApplicationSettingsStore) {
        self.notchViewModel = notchViewModel
        self.powerService = powerService

        settings.$isIdleNotchWidgetEnabled
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in self?.update(isEnabled: isEnabled) }
            .store(in: &cancellables)
    }

    private func update(isEnabled: Bool) {
        if isEnabled {
            notchViewModel.send(.showLiveActivity(IdleNotchContent(powerService: powerService)))
        } else {
            notchViewModel.send(.hideLiveActivity(id: NotchContentRegistry.Idle.clock.id))
        }
    }
}
