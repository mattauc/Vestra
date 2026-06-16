//
//  ETFProjectionCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 13/6/2026.
//
//  Template card for the ETF projection hero. Driven by placeholder inputs
//  (monthlyContribution / annualReturn / years) so the layout can be designed
//  before the real DCA projection math exists — swap the inputs for live values
//  once the model is wired up.
//

import SwiftUI
import Charts

struct ETFProjectionCard: View {

    // Placeholder inputs — replace with real values from the projection model.
    var monthlyContribution: Double = 850
    var annualReturn: Double = 0.099
    var years: Int = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            headline
            chart
                .frame(height: 150)
            proportionBar
                .frame(height: 8)
            legend
        }
        .foregroundStyle(Color.theme.onAsset)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#D9622E"), Color(hex: "#A23E1A")],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 190, height: 190)
                .offset(x: 70, y: -70)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            Text("PROJECTED · \(years) YEARS")
                .font(Font.theme.mono(12))
                .tracking(1.5)
                .opacity(0.85)
            Spacer()
            Text(String(format: "%.1f%%/yr net", annualReturn * 100))
                .font(Font.theme.mono(12))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.theme.onAsset.opacity(0.18)))
        }
    }

    // MARK: - Headline

    private var headline: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(shortCurrency(finalTotal))
                .font(Font.theme.display(46))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }

    // MARK: - Chart

    private var chart: some View {
        Chart {
            ForEach(series) { point in
                AreaMark(
                    x: .value("Year", point.year),
                    y: .value("Total", point.total)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.onAsset.opacity(0.35), Color.theme.onAsset.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            // Solid projected-total line
            ForEach(series) { point in
                LineMark(
                    x: .value("Year", point.year),
                    y: .value("Total", point.total),
                    series: .value("Series", "total")
                )
                .foregroundStyle(Color.theme.onAsset)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
            }

            // Dashed contributions line ("what you put in")
            ForEach(series) { point in
                LineMark(
                    x: .value("Year", point.year),
                    y: .value("Contributions", point.contributions),
                    series: .value("Series", "contributions")
                )
                .foregroundStyle(Color.theme.onAsset.opacity(0.55))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                .interpolationMethod(.catmullRom)
            }

            // End-of-curve marker ring
            if let last = series.last {
                PointMark(
                    x: .value("Year", last.year),
                    y: .value("Total", last.total)
                )
                .symbol {
                    Circle()
                        .fill(Color(hex: "#C2531F"))
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.theme.onAsset, lineWidth: 2.5))
                }
            }
        }
        .chartYScale(domain: 0...(finalTotal * 1.08))
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
    }

    // MARK: - Proportion bar

    private var proportionBar: some View {
        GeometryReader { geo in
            let contribWidth = geo.size.width * (finalContributions / finalTotal)
            HStack(spacing: 3) {
                Capsule()
                    .fill(Color.theme.onAsset.opacity(0.9))
                    .frame(width: max(0, contribWidth - 1.5))
                Capsule()
                    .fill(Color.theme.onAsset.opacity(0.35))
            }
        }
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.theme.onAsset.opacity(0.9))
                        .frame(width: 9, height: 9)
                    Text("YOU PUT IN")
                        .font(Font.theme.mono(11))
                        .tracking(0.5)
                        .opacity(0.8)
                }
                Text(shortCurrency(finalContributions))
                    .font(Font.theme.display(22))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.theme.onAsset.opacity(0.35))
                        .frame(width: 9, height: 9)
                    Text("COMPOUND GROWTH")
                        .font(Font.theme.mono(11))
                        .tracking(0.5)
                        .opacity(0.8)
                }
                Text(shortCurrency(finalGrowth))
                    .font(Font.theme.display(22))
                    .opacity(0.85)
            }
        }
    }

    // MARK: - Projection (placeholder math)

    private struct ProjectionPoint: Identifiable {
        let id: Int
        let year: Int
        let contributions: Double
        let total: Double
    }

    /// Month-by-month compounding, sampled yearly. Deterministic — this is the
    /// same shape the real projection will produce once inputs are real.
    private var series: [ProjectionPoint] {
        let monthlyRate = pow(1 + annualReturn, 1.0 / 12) - 1
        var balance = 0.0
        var contributed = 0.0
        var points = [ProjectionPoint(id: 0, year: 0, contributions: 0, total: 0)]
        for month in 1...(years * 12) {
            balance = balance * (1 + monthlyRate) + monthlyContribution
            contributed += monthlyContribution
            if month % 12 == 0 {
                let year = month / 12
                points.append(ProjectionPoint(id: year, year: year, contributions: contributed, total: balance))
            }
        }
        return points
    }

    private var finalTotal: Double { series.last?.total ?? 0 }
    private var finalContributions: Double { series.last?.contributions ?? 0 }
    private var finalGrowth: Double { finalTotal - finalContributions }
    private var multiple: Double { finalContributions > 0 ? finalTotal / finalContributions : 0 }

    /// "$671.8k" / "$202k" — one decimal, trailing ".0" trimmed.
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
    ETFProjectionCard()
        .padding()
        .background(Color.theme.depth)
}
