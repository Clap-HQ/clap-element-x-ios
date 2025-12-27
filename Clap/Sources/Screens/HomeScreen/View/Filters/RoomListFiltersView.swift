//
// Copyright 2025 Element Creations Ltd.
// Copyright 2024-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct RoomListFiltersView: View {
    @Binding var state: RoomListFiltersState

    var body: some View {
        HStack(spacing: 8) {
            filterMenuButton

            if state.isFiltering {
                activeFiltersView
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var filterMenuButton: some View {
        Menu {
            ForEach(RoomListFilter.availableFilters) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2).disabledDuringTests()) {
                        if state.isFilterActive(filter) {
                            state.deactivateFilter(filter)
                        } else {
                            // Deactivate incompatible filters first
                            for incompatible in filter.incompatibleFilters {
                                if state.isFilterActive(incompatible) {
                                    state.deactivateFilter(incompatible)
                                }
                            }
                            state.activateFilter(filter)
                        }
                    }
                } label: {
                    Label {
                        Text(filter.localizedName)
                    } icon: {
                        if state.isFilterActive(filter) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

            if state.isFiltering {
                Divider()

                Button(role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.2).disabledDuringTests()) {
                        state.clearFilters()
                    }
                } label: {
                    Label(L10n.screenRoomlistClearFilters, systemImage: "xmark.circle")
                }
            }
        } label: {
            CompoundIcon(\.filter, size: .small, relativeTo: .compound.bodyMD)
                .foregroundColor(state.isFiltering ? .compound.textOnSolidPrimary : .compound.textSecondary)
                .padding(8)
                .background {
                    Circle()
                        .fill(state.isFiltering ? Color.compound.bgActionPrimaryRest : Color.compound.bgSubtleSecondary)
                }
        }
    }

    @ViewBuilder
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(state.activeFilters) { filter in
                    activeFilterChip(for: filter)
                }
            }
        }
    }

    private func activeFilterChip(for filter: RoomListFilter) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2).disabledDuringTests()) {
                state.deactivateFilter(filter)
            }
        } label: {
            HStack(spacing: 4) {
                Text(filter.localizedName)
                    .font(.compound.bodySM)

                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.compound.textOnSolidPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(Color.compound.bgActionPrimaryRest)
            }
        }
    }
}

// MARK: - Previews

struct RoomListFiltersView_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        VStack(spacing: 20) {
            RoomListFiltersView(state: .constant(.init(appSettings: ServiceLocator.shared.settings)))
                .previewDisplayName("No filters")

            RoomListFiltersView(state: .constant(.init(activeFilters: [.rooms],
                                                       appSettings: ServiceLocator.shared.settings)))
                .previewDisplayName("One filter")

            RoomListFiltersView(state: .constant(.init(activeFilters: [.rooms, .favourites],
                                                       appSettings: ServiceLocator.shared.settings)))
                .previewDisplayName("Two filters")
        }
        .padding()
    }
}
