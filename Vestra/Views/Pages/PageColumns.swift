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
        ZStack {
            GroupBox {
                HStack() {
                    page.kindImage
                        .font(Font.title3.bold())
                        .foregroundStyle(Color.white)
                        .frame(width: 45, height: 45)
                        .background(Color.theme.onAsset.opacity(0.15), in: RoundedRectangle(cornerRadius: 20))

                        .padding(.trailing)
                    VStack {
                        Text(page.title)
                            .font(Font.theme.display(20).bold())
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .minimumScaleFactor(0.6)
                        Text("1BR . Dec 2025")
                            .font(Font.theme.ui(15))
                            .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
//                    .padding(.horizontal)
                    Spacer()
                    VStack {
                        Text("$700k")
                            .font(Font.theme.display(20).bold())
                            .foregroundStyle(Color.white)
                        Text("+3.0%")
                            .font(Font.theme.ui(15))
                            .foregroundStyle(Color.theme.highlight)
                    }
                }
            }
            .groupBoxStyle(.custom(for: page))
            .padding(.horizontal)
            
        }
    }

}

#Preview {
    PageColumns(page: .property(PropertyPage()))
}
