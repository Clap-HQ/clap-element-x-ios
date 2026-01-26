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
    case people
    case spaces
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
            // Spaces can be combined with unreads, but not with other filters
            return [.people, .rooms, .favourites, .invites, .lowPriority]
        case .people:
            return [.spaces, .rooms, .invites]
        case .rooms:
            return [.spaces, .people, .invites]
        case .unreads:
            return [.invites]
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
    private let clapDeveloperModeSettings: ClapDeveloperModeSettings

    init(activeFilters: OrderedSet<RoomListFilter>? = nil,
         appSettings: AppSettings,
         clapDeveloperModeSettings: ClapDeveloperModeSettings = ServiceLocator.shared.clapDeveloperModeSettings) {
        // Default to empty (no filters active)
        self.activeFilters = activeFilters ?? []
        self.appSettings = appSettings
        self.clapDeveloperModeSettings = clapDeveloperModeSettings
    }

    var availableFilters: [RoomListFilter] {
        var availableFilters = OrderedSet(RoomListFilter.allCases)

        // Hide spaces filter when groupSpaceRooms is disabled
        if !clapDeveloperModeSettings.groupSpaceRooms {
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

    /// Whether the unreads filter is active
    var isUnreadsFilterActive: Bool {
        activeFilters.contains(.unreads)
    }

    mutating func activateFilter(_ filter: RoomListFilter) {
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
