//
//  PageColumns.swift
//  Vestra
//
//  Created by Matthew Auciello on 19/5/2026.
//

import SwiftUI

struct PageColumns: View {
    
    @EnvironmentObject var pageStore: PageStore
    var page: PortfolioPage
    
    var body: some View {
        HStack {
            page.kindImage
                .font(Font.body.bold())
                .foregroundStyle(Color.black)
                .frame(width: 40, height: 40)
                .background(page.kindColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 15))
                .padding(.trailing)
            columnContent
        }
        .padding(.horizontal)
        Divider()
            .padding(.horizontal)
    }

    @ViewBuilder
    var columnContent: some View {
        VStack {
            Text(page.title)
                .font(Font.theme.display(20).bold())
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(page.kindDetails)
                .font(Font.theme.ui(16))
                .foregroundStyle(Color.black.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        Spacer()
        VStack(alignment: .trailing) {
            Text(page.kindValue)
                .font(Font.theme.display(20).bold())
                .foregroundStyle(Color.black)
            Text(page.kindChange)
                .font(Font.theme.ui(15))
                .foregroundStyle(page.kindChangeIsPositive ? Color.theme.highlight : Color.red)
        }
    }

}

#Preview {
    PageColumns(page: .property(PropertyPage()))
}
