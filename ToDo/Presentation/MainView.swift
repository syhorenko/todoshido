//
//  MainView.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI

/// Main navigation view with sidebar and detail panes
struct MainView: View {
    @StateObject var coordinator: AppCoordinator
    @State private var selectedTab: Tab = .inbox

    enum Tab: String, CaseIterable, Identifiable {
        case inbox = "Inbox"
        case archive = "Archive"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .inbox: return "tray"
            case .archive: return "archivebox"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationTitle("ToDo")
            .listStyle(.sidebar)
            .frame(minWidth: Constants.sidebarMinWidth, idealWidth: Constants.sidebarIdealWidth)
            .background(AppColors.surface)
        } detail: {
            switch selectedTab {
            case .inbox:
                coordinator.makeInboxView()
            case .archive:
                coordinator.makeArchiveView()
            }
        }
        .background(AppColors.background)
    }
}

#Preview {
    MainView(
        coordinator: AppCoordinator(repository: MockTodoRepository())
    )
}
