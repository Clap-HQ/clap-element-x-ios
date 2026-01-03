//
// Copyright 2025 Element Creations Ltd.
// Copyright 2024-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

import MatrixRustSDK
import OrderedCollections

enum RoomListFilter: Int, CaseIterable, Identifiable {
    var id: Int {
        rawValue
    }

    case unreads
    case spaces
    case people
    case rooms
    case favourites
    case invites
    case lowPriority

    /// Whether this is the spaces filter (which hides all other filters when active)
    var isSpacesFilter: Bool {
        self == .spaces
    }

    var localizedName: String {
        switch self {
        case .spaces:
            return L10n.screenRoomlistFilterSpaces
        case .people:
            return L10n.screenRoomlistFilterPeople
        case .rooms:
            return L10n.screenRoomlistFilterRooms
        case .unreads:
            return L10n.screenRoomlistFilterUnreads
        case .favourites:
            return L10n.screenRoomlistFilterFavourites
        case .invites:
            return L10n.screenRoomlistFilterInvites
        case .lowPriority:
            return L10n.screenRoomlistFilterLowPriority
        }
    }

    var incompatibleFilters: [RoomListFilter] {
        switch self {
        case .spaces:
            // Spaces hides all other filters when active
            return RoomListFilter.allCases.filter { $0 != .spaces }
        case .people:
            return [.spaces, .rooms, .invites]
        case .rooms:
            return [.spaces, .people, .invites]
        case .unreads:
            return [.spaces, .invites]
        case .favourites:
            return [.spaces, .invites, .lowPriority]
        case .invites:
            return [.spaces, .rooms, .people, .unreads, .favourites, .lowPriority]
        case .lowPriority:
            return [.spaces, .favourites, .invites]
        }
    }

    var rustFilter: RoomListEntriesDynamicFilterKind? {
        switch self {
        case .spaces:
            // Spaces filter will be handled specially in HomeScreenViewModel
            return nil
        case .people:
            return .all(filters: [.category(expect: .people), .joined])
        case .rooms:
            return .all(filters: [.category(expect: .group), .joined])
        case .unreads:
            return .all(filters: [.unread, .joined])
        case .favourites:
            return .all(filters: [.favourite, .joined])
        case .invites:
            return .invite
        case .lowPriority:
            // Note: When not activated, the setFilter method automatically applies the .nonLowPriority filter.
            return .all(filters: [.lowPriority, .joined])
        }
    }
}

struct RoomListFiltersState {
    private(set) var activeFilters: OrderedSet<RoomListFilter>
    private let appSettings: AppSettings
    private let developerModeSettings: DeveloperModeSettings

    init(activeFilters: OrderedSet<RoomListFilter>? = nil,
         appSettings: AppSettings,
         developerModeSettings: DeveloperModeSettings = ServiceLocator.shared.developerModeSettings) {
        // Default to empty (no filters active)
        self.activeFilters = activeFilters ?? []
        self.appSettings = appSettings
        self.developerModeSettings = developerModeSettings
    }

    var availableFilters: [RoomListFilter] {
        var availableFilters = OrderedSet(RoomListFilter.allCases)

        // Hide spaces filter when groupSpaceRooms is disabled
        if !developerModeSettings.groupSpaceRooms {
            availableFilters.remove(.spaces)
        }

        if !appSettings.lowPriorityFilterEnabled {
            availableFilters.remove(.lowPriority)
        }

        for filter in activeFilters {
            availableFilters.remove(filter)
            filter.incompatibleFilters.forEach { availableFilters.remove($0) }
        }

        return availableFilters.elements
    }

    /// Whether any filter is active
    var isFiltering: Bool {
        !activeFilters.isEmpty
    }

    /// Whether the spaces filter is active
    var isSpacesFilterActive: Bool {
        activeFilters.contains(.spaces)
    }

    mutating func activateFilter(_ filter: RoomListFilter) {
        // If activating spaces filter, clear all other filters first
        if filter.isSpacesFilter {
            activeFilters.removeAll()
            activeFilters.append(filter)
            return
        }

        filter.incompatibleFilters.forEach { incompatibleFilter in
            if activeFilters.contains(incompatibleFilter) {
                fatalError("[RoomListFiltersState] adding mutually exclusive filters is not allowed")
            }
        }

        // We always want the most recently enabled filter to be at the bottom of the others.
        activeFilters.append(filter)
    }

    mutating func deactivateFilter(_ filter: RoomListFilter) {
        activeFilters.remove(filter)
    }

    mutating func clearFilters() {
        activeFilters.removeAll()
    }

    func isFilterActive(_ filter: RoomListFilter) -> Bool {
        activeFilters.contains(filter)
    }
}
