//
//  CustomTabBar.swift
//  Vestra
//
//  Created by Matthew Auciello on 20/5/2026.
//

import SwiftUI

struct CustomTabBar: View {
    
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            Button {
                selectedTab = 0
            } label: {
                Image(systemName: "house")
                    .foregroundStyle(selectedTab == 0 ? Color.black : Color.white)
                    .frame(width: 80, height: 40)
                    .background(selectedTab == 0 ? Color.white : Color.clear, in: Capsule())
                    .font(.system(size: 30).bold())
                    
            }
//            .padding(.horizontal)
            Button {
                selectedTab = 1
            } label: {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(selectedTab == 1 ? Color.black : Color.white)
                    .frame(width: 80, height: 40)
                    .background(selectedTab == 1 ? Color.white : Color.clear, in: Capsule())
                    .font(.system(size: 30).bold())
            }
//            .padding(.horizontal)
            Button {
                selectedTab = 2
            } label: {
                Image(systemName: "gear")
                    .foregroundStyle(selectedTab == 2 ? Color.black : Color.white)
                    .frame(width: 80, height: 40)
                    .background(selectedTab == 2 ? Color.white : Color.clear, in: Capsule())
                    .font(.system(size: 30).bold())
            }
//            .padding(.horizontal)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.black, in: Capsule())
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    CustomTabBar(selectedTab: $selectedTab)
}
