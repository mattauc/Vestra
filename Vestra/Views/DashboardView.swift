//
//  DashboardView.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var pageStore: PageStore
    
    @State private var addPageNavigationID: UUID?
    
    var body: some View {
        NavigationStack {
            Group {
                if authManager.currentUser != nil {
                    VStack {
                        profileInformation
                        Button {
                            authManager.signOut()
                        } label: {
                            HStack {
                                Text("SIGN OUT")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.left")
                            }
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                            .background(.red)
                        }
                        Button {
                            let newPage = pageStore.createPage()
                            addPageNavigationID = newPage.id
                        } label: {
                            HStack {
                                Text("ADD PAGE")
                                    .fontWeight(.semibold)
                                Image(systemName: "plus.circle.fill")
                            }
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                            .background(.blue)
                        }
                        .navigationDestination(item: $addPageNavigationID) { pageID in
                            PropertyPageView(pageID: pageID)}
                    }
                } else {
                    loadingProfileView
                }
            }
        }
    }
    
    var profileInformation: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.14))
                    Text(userManager.profile?.initials ?? "—")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 4) {
                    Text(userManager.userName)
                        .font(.title2.weight(.semibold))
                    Text("Portfolio overview")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            VStack(spacing: 0) {
                profileStatRow(
                    title: "Net worth",
                    systemImage: "chart.pie.fill",
                    value: formattedCurrency(integer: userManager.userNetworth)
                )
                Divider()
                    .padding(.vertical, 12)
                profileStatRow(
                    title: "Annual salary",
                    systemImage: "dollarsign.circle.fill",
                    value: formattedCurrency(double: userManager.userSalary)
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .padding(.horizontal)
    }
    
    var loadingProfileView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading profile…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("If this stays blank, Firestore rules may be blocking reads or your user document is missing.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Sign out") {
                authManager.signOut()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .task {
            await authManager.fetchUser()
        }
    }

    private func profileStatRow(title: String, systemImage: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .labelStyle(.titleAndIcon)
            Spacer(minLength: 12)
            Text(value)
                .font(.body.weight(.semibold))
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
    }

    private func formattedCurrency(integer: Int) -> String {
        Decimal(integer).formatted(
            .currency(code: Locale.current.currency?.identifier ?? "AUD")
        )
    }

    private func formattedCurrency(double: Double) -> String {
        double.formatted(
            .currency(code: Locale.current.currency?.identifier ?? "AUD")
        )
    }
}

#Preview {
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER

    return DashboardView()
        .environmentObject(auth)
        .environmentObject(UserManager(authManager: auth))
        .environmentObject(PageStore(authManager: auth))
}
