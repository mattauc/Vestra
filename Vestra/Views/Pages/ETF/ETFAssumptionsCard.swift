//
//  ETFAssumptionsCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 13/6/2026.
//
//  The "knobs" half of the ETF sketchpad: starting amount, DCA amount +
//  frequency, and time horizon. UI-only for now — state is local @State. When
//  the projection model lands, these move to ETFPage / ETFPageManager and drive
//  ETFProjectionCard live. Expected return is no longer a knob here: it now
//  comes from the basket (each ETF carries its own return, blended across the
//  holdings) — see ETFBasketCard.
//

import SwiftUI

/// DCA cadence. Lives here for now; move to Models when persistence is wired.
enum DCAFrequency: String, CaseIterable, Identifiable {
    case weekly, fortnightly, monthly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .weekly:      return "Weekly"
        case .fortnightly: return "Fortnightly"
        case .monthly:     return "Monthly"
        }
    }

    /// Label for the contribution stepper, e.g. "FORTNIGHTLY (DCA)".
    var dcaLabel: String { "\(label.uppercased()) (DCA)" }

    /// Useful for the eventual projection math.
    var periodsPerYear: Int {
        switch self {
        case .weekly:      return 52
        case .fortnightly: return 26
        case .monthly:     return 12
        }
    }
}

struct ETFAssumptionsCard: View {

    // Local placeholder state — promote to the model later.
    @State private var startingAmount: Double = 10_000
    @State private var contribution: Double = 800
    @State private var frequency: DCAFrequency = .monthly
    @State private var years: Double = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR ASSUMPTIONS")
                .font(Font.theme.mono(12))
                .tracking(1.5)
                .foregroundStyle(Color.theme.secondaryText)
                .padding(.horizontal, 4)

            HStack(spacing: 10) {
                stepperField(label: "STARTING AMOUNT", value: $startingAmount, step: 500)
                stepperField(label: frequency.dcaLabel, value: $contribution, step: 25)
            }

            frequencyPicker
            projectionSliders
        }
    }

    // MARK: - Stepper field

    private func stepperField(label: String, value: Binding<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Font.theme.mono(11))
                .tracking(0.5)
                .foregroundStyle(Color.theme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            HStack {
                PressAndHoldButton(systemName: "minus") {
                    value.wrappedValue = max(0, value.wrappedValue - step)
                }
                Spacer()
                Text(shortCurrency(value.wrappedValue))
                    .font(Font.theme.display(22))
                    .foregroundStyle(Color.theme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Spacer()
                PressAndHoldButton(systemName: "plus") {
                    value.wrappedValue += step
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card)
    }

    /// Circular +/- button. A quick tap steps once; holding repeats and
    /// accelerates so you can travel a large range without many taps.
    private struct PressAndHoldButton: View {
        let systemName: String
        let action: () -> Void

        @State private var timer: Timer?
        @State private var isPressing = false
        @State private var interval: Double = 0.3

        var body: some View {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.theme.etf)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.theme.etf.opacity(0.12)))
                .scaleEffect(isPressing ? 0.88 : 1)
                .animation(.easeOut(duration: 0.12), value: isPressing)
                .contentShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !isPressing else { return }
                            isPressing = true
                            action()                  // immediate single step
                            interval = 0.3
                            scheduleRepeat(after: 0.45)
                        }
                        .onEnded { _ in stop() }
                )
                .onDisappear { stop() }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(systemName == "plus" ? "Increase" : "Decrease")
        }

        private func scheduleRepeat(after delay: Double) {
            timer?.invalidate()
            let t = Timer(timeInterval: delay, repeats: false) { _ in
                action()
                interval = max(0.04, interval * 0.82)  // accelerate on hold
                scheduleRepeat(after: interval)
            }
            RunLoop.main.add(t, forMode: .common)       // keep firing during scroll tracking
            timer = t
        }

        private func stop() {
            isPressing = false
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: - Frequency picker

    private var frequencyPicker: some View {
        HStack(spacing: 4) {
            ForEach(DCAFrequency.allCases) { freq in
                let selected = freq == frequency
                Text(freq.label)
                    .font(Font.theme.ui(14))
                    .foregroundStyle(selected ? Color.theme.onAsset : Color.theme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(selected ? Color.theme.etf : Color.clear)
                    )
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { frequency = freq }
                    }
            }
        }
        .padding(4)
        .background(card)
    }

    // MARK: - Horizon slider

    private var projectionSliders: some View {
        VStack(alignment: .leading, spacing: 16) {
            sliderRow(
                label: "TIME HORIZON",
                value: "\(Int(years)) yr",
                binding: $years, range: 1...40, step: 1
            )
        }
        .padding(14)
        .background(card)
    }

    private func sliderRow(
        label: String,
        value: String,
        binding: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(Font.theme.mono(11))
                    .tracking(0.5)
                    .foregroundStyle(Color.theme.secondaryText)
                Spacer()
                Text(value)
                    .font(Font.theme.display(18))
                    .foregroundStyle(Color.theme.etf)
            }
            Slider(value: binding, in: range, step: step)
                .tint(Color.theme.etf)
        }
    }

    // MARK: - Shared style

    private var card: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    /// "$10k" / "$10.5k" / "$800" — one decimal, trailing ".0" trimmed.
    private func shortCurrency(_ value: Double) -> String {
        if value >= 1000 {
            var s = String(format: "%.1f", value / 1000)
            if s.hasSuffix(".0") { s = String(s.dropLast(2)) }
            return "$\(s)k"
        }
        return "$\(Int(value))"
    }
}

#Preview {
    ETFAssumptionsCard()
        .padding()
        .background(Color.theme.depth)
}
