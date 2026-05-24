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

            HStack() {
                page.kindImage
                    .font(Font.body.bold())
                    .foregroundStyle(Color.black)
                    .frame(width: 40, height: 40)
                    .background(page.kindColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 15))

                    .padding(.trailing)
                VStack {
                    Text(page.title)
                        .font(Font.theme.display(20).bold())
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                            .minimumScaleFactor(0.6)
                    Text("1BR . Dec 2025")
                        .font(Font.theme.ui(16))
                        .foregroundStyle(Color.black.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
//                    .padding(.horizontal)
                Spacer()
                VStack {
                    Text("$700k")
                        .font(Font.theme.display(20).bold())
                        .foregroundStyle(Color.black)
                    Text("+3.0%")
                        .font(Font.theme.ui(15))
                        .foregroundStyle(Color.theme.highlight)
                }
            }
        
            .padding(.horizontal)
            
        }
        Divider()
            .padding(.horizontal)
    }

}

#Preview {
    PageColumns(page: .property(PropertyPage()))
}
