//
//  PropertyPageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 22/3/2026.
//

import SwiftUI
import Kingfisher
import Charts

struct PropertyPageView: View {
    
    @EnvironmentObject private var pageStore: PageStore
    @StateObject private var manager: PropertyPageManager

    let pageId: UUID
    @Binding var pageIndex: Int
    @Binding var path: NavigationPath
    @State var pageTitle: String = ""
    @State var isEditingTitle = false
    @State private var showingLoanEditor = false
    @State private var showingExpensesEditor = false

    private let cardHeight: CGFloat = 320

    init(pageId: UUID, pageStore: PageStore, pageIndex: Binding<Int>, path: Binding<NavigationPath>) {
        self.pageId = pageId
        _pageIndex = pageIndex
        _path = path
        _manager = StateObject(wrappedValue: PropertyPageManager(pageId: pageId, pageStore: pageStore))
    }
    
    var body: some View {
        ZStack {
            Color.theme.depth
                .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 7, pinnedViews: [.sectionHeaders]) {
//
//                    Section {
//
//                    } header: {
//
//                    }
                    GroupBox(label: titleDisplay
                        .fixedSize(horizontal: false, vertical: true)) {
                        VStack() {
                            Text(manager.propertyDetails)
                                .font(Font.theme.ui(15))
                                .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 20)

                            estimateDisplay
                            HStack {
                                StatPill(label: "Purchase", value: manager.lastSoldPrice.formattedAUD(), isCard: true)
                                Spacer()
                                StatPill(label: "Gain", value: manager.propertyGain.formattedAUD(), isCard: true)
                                Spacer()
                                StatPill(label: "Held", value: manager.yearsHeld, isCard: true)
                            }

                        }
                    }
                        .padding([.top, .horizontal])
                        .padding(.bottom, 5)
                    .groupBoxStyle(.custom(for: .property(PropertyPage())))
                    financialData
                        .padding([.horizontal])
                        .padding(.bottom, 5)
                    SalesChartCard(manager: manager)
                        .padding([.horizontal])
                        .padding(.bottom, 5)
                    loanDisplay
                        .padding(.bottom, 5)
                    HStack(alignment: .top) {
                        expenses
                            .padding(.leading)
                            .padding(.trailing, 5)
                        cashFlow
                            .padding(.trailing)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }

//

        }
        .toolbar {
              ToolbarItem(placement: .principal) {
                  HStack(spacing: 6) {
                      Image(systemName: "house.fill")
                      Text("Property")
                          .font(Font.theme.display(15))
                  }
                  .padding(.horizontal, 12)
                  .padding(.vertical, 6)
                  .background(Color.theme.property, in: Capsule())
                  .foregroundStyle(Color.theme.onAsset)

              }
            ToolbarItem(placement: .topBarTrailing) {
                closeButton
                }
          }

    }

    var titleDisplay: some View {
        HStack {
            if isEditingTitle {
                TextField("New Property", text: $pageTitle)
                    .font(.largeTitle.weight(.black))
                    .textFieldStyle(.plain)
                    .onChange(of: pageTitle) { _, newValue in
                        manager.title = newValue
                    }
                    .onSubmit {
                        isEditingTitle = false
                        Task {
                            await manager.sendPropertyAddress(address: manager.title)
                        }
                    }
            } else {
                Text(manager.title == "" ? "New Property" : manager.title)
                    .font(.largeTitle.weight(.bold))
                    .font(.largeTitle.weight(.bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
            }
            Spacer()
            Button {
                isEditingTitle = true
            } label: {
                Image(systemName: "pencil")
                    .font(.title2)
                    .foregroundStyle(Color.theme.onAccent)
            }
        }
        .frame(height: 50)
    }
    
    var closeButton: some View {
        Button {
            if path.count != 0 {
                self.path.removeLast()
            }
            pageStore.deletePage(id: pageId)
            if pageStore.pages.isEmpty {
                    pageIndex = 0
                } else {
                    pageIndex = min(pageIndex, pageStore.pages.count - 1)
                }
        } label: {
            Image(systemName: "xmark")
                .font(.title3)
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
    
    var estimateDisplay: some View {
        let low = manager.estimateLowPirce
        let high = manager.estimateHighPrice
        let mid = manager.estimateMidPrice
        let confidence = manager.estimateConfidence
        let ratio = high > low ? CGFloat((mid - low) / (high - low)) : 0.5

        return VStack(alignment: .leading, spacing: 4) {
            Text("ESTIMATE")
                .font(Font.theme.mono(15, weight: .heavy))
                .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                .tracking(1.2)

            Text(mid.formattedAUD())
                .font(.largeTitle.bold())
                .foregroundStyle(Color.white)
                .padding(.bottom, 8)

            // Horizontal range line with yellow circle at the mid position
            GeometryReader { geo in
                let lineWidth = geo.size.width
                let circleX = max(0, min(ratio * lineWidth - 7, lineWidth - 14))
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(height: 3)
                        .frame(maxWidth: .infinity)
                        .offset(y: 5)
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 14, height: 14)
                        .offset(x: circleX)
                        .shadow(color: .yellow.opacity(0.9), radius: 7, x: 0, y: 0)
                }
            }
            .frame(height: 14)
            HStack {
                VStack {
                    Text("LOW")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                        .tracking(1.2)
                    Text(low.formattedAUD())
                        .font(Font.theme.mono(20))
                        .foregroundStyle(Color.white)
                }
                Spacer()
                VStack {
                    Text("CONFIDENCE")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                        .tracking(1.2)
                    Text(confidence)
                        .font(Font.theme.mono(20))
                        .foregroundStyle(Color.white)
                        .tracking(1.2)
                }
                Spacer()
                VStack {
                    Text("HIGH")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                        .tracking(1.2)
                    Text(high.formattedAUD())
                        .font(Font.theme.mono(20))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    var financialData: some View {
        HStack {
            StatPill(label: "Equity", value: manager.equity.formattedAUD(), isCard: false)
            Spacer()
            StatPill(label: "Loan", value: manager.currentPage.loanBalance.formattedAUD(), isCard: false) { newValue in
                manager.setLoanBalance(newValue)
            }
            Spacer()
            StatPill(label: "Rent", value: manager.rentalEstimate.formattedAUD(), isCard: false) { newValue in
                if let amount = Double(newValue.filter { $0.isNumber || $0 == "." }) {
                    manager.setRent(amount)
                }
            }
            Spacer()
            StatPill(label: "Yield", value: String(format: "%.1f%%", manager.propertyYield), isCard: false) { newValue in
                if let amount = Double(newValue.filter { $0.isNumber || $0 == "." }) {
                    manager.setYield(amount)
                }
            }
        }
    }
    
    var loanDisplay: some View {
        let purchase = manager.lastSoldPrice
        let loan = manager.currentPage.loanBalance
        let equityRatio: CGFloat = purchase > 0
            ? CGFloat(max(0, min(1, 1 - loan / purchase)))
            : 1.0
        let equityPercent = Int(equityRatio * 100)
        let amountPaid = max(0, purchase - loan)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Loan")
                    .font(Font.theme.display(17).bold())
                    .foregroundStyle(Color.black)
                Spacer()
                HStack(spacing: 4) {
                    Text(String(format: "%.2f%%", manager.interestRate))
                        .font(Font.theme.mono(13, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.5))
                    Text("·")
                        .foregroundStyle(Color.black.opacity(0.3))
                    Text("\(manager.monthlyRepayment.formattedAUD())/mo")
                        .font(Font.theme.mono(13, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.5))
                }
                Button {
                    showingLoanEditor = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(Color.black.opacity(0.4))
                        .padding(.leading, 6)
                }
                .popover(isPresented: $showingLoanEditor) {
                    LoanEditorSheet(manager: manager)
                        .presentationDetents([.height(280)])
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.theme.depth)
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(PortfolioPage.property(manager.currentPage).kindColor)
                        .frame(width: geo.size.width * equityRatio, height: 12)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: equityRatio)
                }
            }
            .frame(height: 12)

            HStack {
                Text("\(amountPaid.formattedAUD()) Paid · \(equityPercent)%")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .tracking(1.2)
                Spacer()
                Text("\(loan.formattedAUD()) left")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .tracking(1.2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 1, y: 1)
        )
        .padding([.horizontal])
    }
    
    var expenses: some View {
        let total = manager.totalExpenses

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expenses")
                    .font(Font.theme.display(16).bold())
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    
                    .padding(.leading)
                Spacer()
                Text("\(total.formattedAUD())/mo")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Button {
                    showingExpensesEditor = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(Color.black.opacity(0.4))
                    
                        .padding(.trailing, 6)
                }
                .popover(isPresented: $showingExpensesEditor) {
                    ExpensesEditorSheet(manager: manager)
                        .presentationDetents([.height(420)])
                }
            }
            .padding(.top)

            GeometryReader { geo in
                let widthFor: (Double) -> CGFloat = { price in
                    total > 0 ? geo.size.width * CGFloat(price / total) : 0
                }
                HStack(spacing: 0) {
                    Color.theme.property.frame(width: widthFor(manager.strataPrice))
                    Color.theme.etf.frame(width: widthFor(manager.councilRatesPrice))
                    Color.theme.crypto.frame(width: widthFor(manager.insurancePrice))
                    Color.yellow.frame(width: widthFor(manager.maintenancePrice))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.theme.depth)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .frame(height: 8)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7),
                    value: [manager.strataPrice, manager.councilRatesPrice,
                            manager.insurancePrice, manager.maintenancePrice]
                )
            }
            .frame(height: 8)
            .padding(.horizontal)
            .padding(.bottom, 5)

            expensesList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 1, y: 1)
        )
    }
    
    var expensesList: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .fill(Color.theme.property)
                    .frame(width: 12, height: 12)
                Text("Strata")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(String(manager.strataPrice.formattedAUD()))
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding([.bottom, .horizontal])
            Divider()
                .padding(.horizontal)
          

            HStack {
                Circle()
                    .fill(Color.theme.etf)
                    .frame(width: 12, height: 12)
                Text("Council")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(manager.councilRatesPrice.formattedAUD())
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding()

            Divider()
                .padding(.horizontal)
       

            HStack {
                Circle()
                    .fill(Color.theme.crypto)
                    .frame(width: 12, height: 12)
                Text("Insurance")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(manager.insurancePrice.formattedAUD())
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding()

  
            Divider()
                .padding(.horizontal)
         

            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 12, height: 12)
                Text("Maintain")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(manager.maintenancePrice.formattedAUD())
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var cashFlow: some View {
        let net = manager.monthlyCashFlow
        let isNegative = manager.isNegativelyGeared
        let accent = isNegative ? Color.theme.negative : Color.theme.positive

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Cash flow")
                    .font(Font.theme.display(17).bold())
                    .foregroundStyle(Color.black)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer()
                Text("\(signed(net))/mo")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 7, height: 7)
                Text(isNegative ? "NEGATIVELY GEARED" : "POSITIVELY GEARED")
                    .font(Font.theme.mono(11, weight: .heavy))
                    .foregroundStyle(accent)
                    .tracking(1.2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(signed(net))
                    .font(Font.theme.display(40).bold())
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("/mo")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(accent.opacity(0.6))
            }

            Text("= \(signed(manager.annualCashFlow))/YR")
                .font(Font.theme.mono(12, weight: .heavy))
                .foregroundStyle(Color.black.opacity(0.4))
                .tracking(1.0)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    Color.theme.positive
                        .frame(width: geo.size.width * CGFloat(manager.rentCoverage))
                    Color.theme.graphite
                }
                .clipShape(Capsule())
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: manager.rentCoverage)
            }
            .frame(height: 8)

            VStack(spacing: 8) {
                cashFlowRow(dot: Color.theme.positive, label: "Rent",
                            amount: signed(manager.monthlyRent, showsPlus: true),
                            amountColor: Color.theme.positive)
                cashFlowRow(dot: Color.black, label: "Loan",
                            amount: signed(-manager.monthlyRepayment),
                            amountColor: Color.black)
                cashFlowRow(dot: Color.black, label: "Costs",
                            amount: signed(-manager.totalExpenses),
                            amountColor: Color.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accent.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(accent.opacity(0.55), lineWidth: 1.5)
        )
    }

    private func signed(_ value: Double, showsPlus: Bool = false) -> String {
        let magnitude = abs(value).formattedAUD()
        if value < 0 { return "-\(magnitude)" }
        return showsPlus ? "+\(magnitude)" : magnitude
    }

    @ViewBuilder
    private func cashFlowRow(dot: Color, label: String, amount: String, amountColor: Color) -> some View {
        HStack {
            Circle()
                .fill(dot)
                .frame(width: 8, height: 8)
            Text(label)
                .font(Font.theme.ui(15))
                .foregroundStyle(Color.black.opacity(0.8))
            Spacer()
            Text(amount)
                .font(Font.theme.mono(14, weight: .heavy))
                .foregroundStyle(amountColor)
        }
    }

    var propertyPriceChart: some View {
        Chart {
            
        }
    }
}

#Preview {
    @Previewable @State var pageIndex = 0
    @Previewable @State var path = NavigationPath()
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER

    let store = PageStore(authManager: auth)
    let pageId = UUID()

    return PropertyPageView(
        pageId: pageId,
        pageStore: store,
        pageIndex: $pageIndex,
        path: $path
    )
    .environmentObject(store)
}
