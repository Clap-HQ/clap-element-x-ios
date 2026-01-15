//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation
import SwiftState

enum SpaceFlowCoordinatorAction {
    case presentCallScreen(roomProxy: JoinedRoomProxyProtocol)
    case verifyUser(userID: String)
    case finished
}

// TODO: SpaceScreen이 완전히 SpaceDetailScreen으로 대체되면 SpaceDetailFlowCoordinator로 분리 검토.
// 현재는 SpaceFlowCoordinator가 SpaceScreen과 SpaceDetailScreen 두 화면을 모두 관리하고,
// ChatsFlowCoordinator에도 SpaceDetail 관련 코드가 중복되어 있음.
enum SpaceFlowCoordinatorEntryPoint {
    /// Show space screen for an already joined space
    case space(SpaceRoomListProxyProtocol)
    /// Show space detail screen after joining a space (with join all rooms confirmation)
    case spaceDetailAfterJoin(SpaceRoomListProxyProtocol)
    /// Show join space screen for an unjoined space
    case joinSpace(SpaceRoomProxyProtocol)

    var spaceID: String {
        switch self {
        case .space(let spaceRoomListProxy), .spaceDetailAfterJoin(let spaceRoomListProxy):
            spaceRoomListProxy.id
        case .joinSpace(let spaceRoomProxy):
            spaceRoomProxy.id
        }
    }
}

class SpaceFlowCoordinator: FlowCoordinatorProtocol {
    private var entryPoint: SpaceFlowCoordinatorEntryPoint
    private let spaceServiceProxy: SpaceServiceProxyProtocol
    private let isChildFlow: Bool
    
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    private let flowParameters: CommonFlowParameters
    
    private let selectedSpaceRoomSubject: CurrentValueSubject<String?, Never> = .init(nil)
    
    private var childSpaceFlowCoordinator: SpaceFlowCoordinator?
    private var roomFlowCoordinator: RoomFlowCoordinator?
    private var membersFlowCoordinator: RoomMembersFlowCoordinator?
    private var settingsFlowCoordinator: SpaceSettingsFlowCoordinator?
    private var rolesAndPermissionsFlowCoordinator: RoomRolesAndPermissionsFlowCoordinator?
    
    indirect enum State: StateType {
        /// The state machine hasn't started.
        case initial
        /// Shown when the flow is started for an unjoined space.
        case joinSpace
        /// The root screen for this flow.
        case space
        /// Shown as the root screen after joining a space (SpaceDetailScreen instead of SpaceScreen)
        case spaceDetail
        /// A child (space) flow is in progress.
        case presentingChild(childSpaceID: String, previousState: State)
        /// A room flow is in progress
        case roomFlow(previousState: State)
        /// A members flow is in progress
        case membersFlow
        /// A space settings flow is in progress
        case settingsFlow

        case rolesAndPermissionsFlow

        case leftSpace
    }
    
    enum Event: EventType {
        /// The flow is being started.
        case start
        /// The flow is being started for an unjoined space.
        case startUnjoined

        /// The join space screen joined the space.
        case joinedSpace(shouldShowJoinAllRoomsConfirmation: Bool)
        /// The space screen left the space.
        case leftSpace
        
        /// Request the presentation of a child space flow.
        ///
        /// The space's `SpaceRoomListProxyProtocol` must be provided in the `userInfo`.
        case startChildFlow
        /// Tidy-up the child flow after it has dismissed itself.
        case stopChildFlow
        
        case startRoomFlow(roomID: String)
        case stopRoomFlow
        
        case startMembersFlow
        case stopMembersFlow
        
        case startSettingsFlow
        case stopSettingsFlow
        
        case startRolesAndPermissionsFlow
        case stopRolesAndPermissionsFlow
    }
    
    private let stateMachine: StateMachine<State, Event>
    private var cancellables: Set<AnyCancellable> = []

    private let actionsSubject: PassthroughSubject<SpaceFlowCoordinatorAction, Never> = .init()
    var actionsPublisher: AnyPublisher<SpaceFlowCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(entryPoint: SpaceFlowCoordinatorEntryPoint,
         spaceServiceProxy: SpaceServiceProxyProtocol,
         isChildFlow: Bool,
         navigationStackCoordinator: NavigationStackCoordinator,
         flowParameters: CommonFlowParameters) {
        self.entryPoint = entryPoint
        self.spaceServiceProxy = spaceServiceProxy
        self.isChildFlow = isChildFlow
        self.flowParameters = flowParameters

        self.navigationStackCoordinator = navigationStackCoordinator

        stateMachine = .init(state: .initial)
        configureStateMachine()
    }

    func start(animated: Bool) {
        switch entryPoint {
        case .space:
            stateMachine.tryEvent(.start)
        case .spaceDetailAfterJoin:
            stateMachine.tryEvent(.joinedSpace(shouldShowJoinAllRoomsConfirmation: true))
        case .joinSpace:
            stateMachine.tryEvent(.startUnjoined)
        }
    }
    
    func handleAppRoute(_ appRoute: AppRoute, animated: Bool) {
        // There aren't any routes to this screen yet, so clear the stacks.
        clearRoute(animated: animated)
    }
    
    func clearRoute(animated: Bool) {
        switch stateMachine.state {
        case .initial:
            break
        case .joinSpace, .space, .spaceDetail, .leftSpace:
            if isChildFlow {
                navigationStackCoordinator.pop(animated: animated)
            } else {
                navigationStackCoordinator.setRootCoordinator(nil, animated: animated)
            }
        case .presentingChild:
            childSpaceFlowCoordinator?.clearRoute(animated: animated)
            clearRoute(animated: animated) // Re-run with the state machine back in the .space state.
        case .roomFlow:
            roomFlowCoordinator?.clearRoute(animated: animated)
            clearRoute(animated: animated) // Re-run with the state machine back in the .space state.
        case .membersFlow:
            membersFlowCoordinator?.clearRoute(animated: animated)
            clearRoute(animated: animated) // Re-run with the state machine back in the .space state.
        case .settingsFlow:
            settingsFlowCoordinator?.clearRoute(animated: animated)
            clearRoute(animated: animated) // Re-run with the state machine back in the .space state.
        case .rolesAndPermissionsFlow:
            rolesAndPermissionsFlowCoordinator?.clearRoute(animated: animated)
            clearRoute(animated: animated) // Re-run with the state machine back in the .space state.
        }
    }
    
    // MARK: - Private
    
    // swiftlint:disable:next cyclomatic_complexity
    private func configureStateMachine() {
        stateMachine.addRoutes(event: .start, transitions: [.initial => .space]) { [weak self] _ in
            self?.presentSpace()
        }
        
        stateMachine.addRoutes(event: .startUnjoined, transitions: [.initial => .joinSpace]) { [weak self] _ in
            self?.presentJoinSpaceScreen()
        }

        stateMachine.addRouteMapping { event, fromState, _ in
            guard case .joinedSpace = event else { return nil }
            switch fromState {
            case .joinSpace, .initial:
                return .spaceDetail
            default:
                return nil
            }
        } handler: { [weak self] context in
            guard let self, case let .joinedSpace(shouldShowConfirmation) = context.event else { return }
            presentSpaceDetailAfterJoining(shouldShowJoinAllRoomsConfirmation: shouldShowConfirmation)
        }

        stateMachine.addRoutes(event: .leftSpace, transitions: [.space => .leftSpace, .spaceDetail => .leftSpace]) { [weak self] _ in
            self?.clearRoute(animated: true)
        }
        
        stateMachine.addRouteMapping { event, fromState, userInfo in
            guard event == .startChildFlow else { return nil }
            guard let childEntryPoint = userInfo as? SpaceFlowCoordinatorEntryPoint else { fatalError("An entry point must be provided.") }
            return switch fromState {
            case .space, .spaceDetail: .presentingChild(childSpaceID: childEntryPoint.spaceID, previousState: fromState)
            case .roomFlow(let previousState): .presentingChild(childSpaceID: childEntryPoint.spaceID, previousState: previousState)
            default: nil
            }
        } handler: { [weak self] context in
            guard let self, let entryPoint = context.userInfo as? SpaceFlowCoordinatorEntryPoint else { return }
            startChildFlow(with: entryPoint)
        }
        
        stateMachine.addRouteMapping { event, fromState, _ in
            guard event == .stopChildFlow, case .presentingChild(_, let previousState) = fromState else { return nil }
            return previousState
        } handler: { [weak self] _ in
            guard let self else { return }
            childSpaceFlowCoordinator = nil
            selectedSpaceRoomSubject.send(nil)
        }
        
        stateMachine.addRouteMapping { event, fromState, _ in
            switch (event, fromState) {
            case (.startRoomFlow, .space), (.startRoomFlow, .spaceDetail):
                return .roomFlow(previousState: fromState)
            default:
                return nil
            }
        } handler: { [weak self] context in
            guard let self, case let .startRoomFlow(roomID) = context.event else { return }
            startRoomFlow(roomID: roomID)
        }
        
        stateMachine.addRouteMapping { event, fromState, _ in
            guard event == .stopRoomFlow, case let .roomFlow(previousState) = fromState else { return nil }
            return previousState
        } handler: { [weak self] _ in
            guard let self else { return }
            roomFlowCoordinator = nil
            selectedSpaceRoomSubject.send(nil)
        }
        
        stateMachine.addRouteMapping { event, fromState, _ in
            switch (event, fromState) {
            case (.startMembersFlow, .space), (.startMembersFlow, .spaceDetail):
                return .membersFlow
            default:
                return nil
            }
        } handler: { [weak self] context in
            guard let self, let roomProxy = context.userInfo as? JoinedRoomProxyProtocol else {
                fatalError("The room proxy must always be provided")
            }
            startMembersFlow(roomProxy: roomProxy)
        }

        stateMachine.addRouteMapping { event, fromState, _ in
            guard event == .stopMembersFlow, case .membersFlow = fromState else { return nil }
            return .spaceDetail
        } handler: { [weak self] _ in
            guard let self else { return }
            membersFlowCoordinator = nil
        }

        stateMachine.addRouteMapping { event, fromState, _ in
            switch (event, fromState) {
            case (.startSettingsFlow, .space), (.startSettingsFlow, .spaceDetail):
                return .settingsFlow
            default:
                return nil
            }
        } handler: { [weak self] context in
            guard let self, let roomProxy = context.userInfo as? JoinedRoomProxyProtocol else { return }
            startSettingsFlow(roomProxy: roomProxy)
        }

        stateMachine.addRouteMapping { event, fromState, _ in
            guard event == .stopSettingsFlow, case .settingsFlow = fromState else { return nil }
            return .spaceDetail
        } handler: { [weak self] _ in
            guard let self else { return }
            settingsFlowCoordinator = nil
        }

        stateMachine.addRouteMapping { event, fromState, _ in
            switch (event, fromState) {
            case (.startRolesAndPermissionsFlow, .space), (.startRolesAndPermissionsFlow, .spaceDetail):
                return .rolesAndPermissionsFlow
            default:
                return nil
            }
        } handler: { [weak self] context in
            guard let self, let roomProxy = context.userInfo as? JoinedRoomProxyProtocol else { return }
            startRolesAndPermissionsFlow(roomProxy: roomProxy)
        }

        stateMachine.addRouteMapping { event, fromState, _ in
            guard event == .stopRolesAndPermissionsFlow, case .rolesAndPermissionsFlow = fromState else { return nil }
            return .spaceDetail
        } handler: { [weak self] _ in
            guard let self else { return }
            rolesAndPermissionsFlowCoordinator = nil
        }
        
        stateMachine.addErrorHandler { context in
            fatalError("Unexpected transition: \(context)")
        }
    }
    
    private func presentSpace() {
        guard case let .space(spaceRoomListProxy) = entryPoint else { fatalError("Attempting to show a space with the wrong entry point.") }
        
        let parameters = SpaceScreenCoordinatorParameters(spaceRoomListProxy: spaceRoomListProxy,
                                                          spaceServiceProxy: spaceServiceProxy,
                                                          selectedSpaceRoomPublisher: selectedSpaceRoomSubject.asCurrentValuePublisher(),
                                                          userSession: flowParameters.userSession,
                                                          appSettings: flowParameters.appSettings,
                                                          userIndicatorController: flowParameters.userIndicatorController)
        let coordinator = SpaceScreenCoordinator(parameters: parameters)
        coordinator.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .selectSpace(let spaceRoomListProxy):
                    stateMachine.tryEvent(.startChildFlow, userInfo: SpaceFlowCoordinatorEntryPoint.space(spaceRoomListProxy))
                case .selectUnjoinedSpace(let spaceRoomProxy):
                    stateMachine.tryEvent(.startChildFlow, userInfo: SpaceFlowCoordinatorEntryPoint.joinSpace(spaceRoomProxy))
                case .selectRoom(let roomID):
                    stateMachine.tryEvent(.startRoomFlow(roomID: roomID))
                case .leftSpace:
                    stateMachine.tryEvent(.leftSpace)
                case .displayMembers(let roomProxy):
                    stateMachine.tryEvent(.startMembersFlow, userInfo: roomProxy)
                case .displaySpaceSettings(let roomProxy):
                    stateMachine.tryEvent(.startSettingsFlow, userInfo: roomProxy)
                case .displayRolesAndPermissions(let roomProxy):
                    stateMachine.tryEvent(.startRolesAndPermissionsFlow, userInfo: roomProxy)
                }
            }
            .store(in: &cancellables)
        
        if isChildFlow {
            navigationStackCoordinator.push(coordinator) { [weak self] in
                self?.actionsSubject.send(.finished)
            }
        } else {
            navigationStackCoordinator.setRootCoordinator(coordinator) { [weak self] in
                self?.actionsSubject.send(.finished)
            }
        }
    }
    
    private func presentJoinSpaceScreen() {
        guard case let .joinSpace(spaceRoomProxy) = entryPoint else { fatalError("Attempting to join a space with the wrong entry point.") }

        let parameters = JoinRoomScreenCoordinatorParameters(source: .space(spaceRoomProxy),
                                                             userSession: flowParameters.userSession,
                                                             userIndicatorController: flowParameters.userIndicatorController,
                                                             appSettings: flowParameters.appSettings)
        let coordinator = JoinRoomScreenCoordinator(parameters: parameters)
        coordinator.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .joined(.space(let spaceRoomListProxy)):
                    entryPoint = .spaceDetailAfterJoin(spaceRoomListProxy)
                    stateMachine.tryEvent(.joinedSpace(shouldShowJoinAllRoomsConfirmation: true))
                case .joined(.roomID):
                    MXLog.error("Expected to join a space, but got a room ID instead.")
                    clearRoute(animated: true)
                case .cancelled:
                    clearRoute(animated: true)
                case .presentDeclineAndBlock:
                    MXLog.error("Joining a space from the spaces tab shouldn't involve an inviter.")
                    clearRoute(animated: true)
                }
            }
            .store(in: &cancellables)

        if isChildFlow {
            navigationStackCoordinator.push(coordinator) { [weak self] in
                guard let self, stateMachine.state == .joinSpace else { return }
                actionsSubject.send(.finished)
            }
        } else {
            navigationStackCoordinator.setRootCoordinator(coordinator) { [weak self] in
                guard let self, stateMachine.state == .joinSpace else { return }
                actionsSubject.send(.finished)
            }
        }
    }
    
    private func presentSpaceDetailAfterJoining(shouldShowJoinAllRoomsConfirmation: Bool) {
        let spaceRoomListProxy: SpaceRoomListProxyProtocol
        switch entryPoint {
        case .space(let proxy), .spaceDetailAfterJoin(let proxy):
            spaceRoomListProxy = proxy
        case .joinSpace:
            fatalError("Attempting to show a space detail with the wrong entry point.")
        }

        let parameters = SpaceDetailScreenCoordinatorParameters(spaceRoomListProxy: spaceRoomListProxy,
                                                                 spaceServiceProxy: spaceServiceProxy,
                                                                 userSession: flowParameters.userSession,
                                                                 appSettings: flowParameters.appSettings,
                                                                 userIndicatorController: flowParameters.userIndicatorController)
        let coordinator = SpaceDetailScreenCoordinator(parameters: parameters,
                                                        shouldShowJoinAllRoomsConfirmation: shouldShowJoinAllRoomsConfirmation)
        // 이 플로우는 스페이스 초대 수락 후 사용됨. 초대 수락 직후 컨텍스트에서는 덜 중요한
        // 일부 액션은 의도적으로 미구현 상태.
        // 전체 기능 지원은 ChatsFlowCoordinator.startSpaceDetailFlow 참고.
        coordinator.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .selectRoom(let roomID):
                    stateMachine.tryEvent(.startRoomFlow(roomID: roomID))
                case .showRoomDetails:
                    break // TODO: 필요시 구현
                case .dismiss:
                    stateMachine.tryEvent(.leftSpace)
                case .displayMembers(let roomProxy):
                    stateMachine.tryEvent(.startMembersFlow, userInfo: roomProxy)
                case .inviteUsers:
                    break // TODO: 필요시 구현
                case .displaySpaceSettings(let roomProxy):
                    stateMachine.tryEvent(.startSettingsFlow, userInfo: roomProxy)
                case .presentCreateRoomInSpace:
                    break // TODO: 필요시 구현
                case .removedRoomFromSpace:
                    break // TODO: 필요시 홈화면 새로고침 구현
                case .leftSpace:
                    stateMachine.tryEvent(.leftSpace)
                }
            }
            .store(in: &cancellables)

        if isChildFlow {
            // Replace JoinRoomScreen with SpaceDetailScreen
            navigationStackCoordinator.pop(animated: false)
            navigationStackCoordinator.push(coordinator, animated: true) { [weak self] in
                self?.actionsSubject.send(.finished)
            }
        } else {
            navigationStackCoordinator.setRootCoordinator(coordinator) { [weak self] in
                self?.actionsSubject.send(.finished)
            }
        }
    }

    // MARK: - Other flows
    
    private func startChildFlow(with entryPoint: SpaceFlowCoordinatorEntryPoint) {
        let coordinator = SpaceFlowCoordinator(entryPoint: entryPoint,
                                               spaceServiceProxy: spaceServiceProxy,
                                               isChildFlow: true,
                                               navigationStackCoordinator: navigationStackCoordinator,
                                               flowParameters: flowParameters)
        
        coordinator.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .presentCallScreen(let roomProxy):
                    actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
                case .verifyUser(let userID):
                    actionsSubject.send(.verifyUser(userID: userID))
                case .finished:
                    stateMachine.tryEvent(.stopChildFlow)
                }
            }
            .store(in: &cancellables)
        
        childSpaceFlowCoordinator = coordinator
        coordinator.start()
        selectedSpaceRoomSubject.send(entryPoint.spaceID)
    }
    
    private func startRoomFlow(roomID: String) {
        let coordinator = RoomFlowCoordinator(roomID: roomID,
                                              isChildFlow: true,
                                              navigationStackCoordinator: navigationStackCoordinator,
                                              flowParameters: flowParameters)
        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .presentCallScreen(let roomProxy):
                    actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
                case .verifyUser(let userID):
                    actionsSubject.send(.verifyUser(userID: userID))
                case .continueWithSpaceFlow(let entryPoint):
                    stateMachine.tryEvent(.startChildFlow, userInfo: entryPoint)
                case .finished:
                    stateMachine.tryEvent(.stopRoomFlow)
                }
            }
            .store(in: &cancellables)
        
        roomFlowCoordinator = coordinator
        coordinator.handleAppRoute(.room(roomID: roomID, via: []), animated: true)
        selectedSpaceRoomSubject.send(roomID)
    }
    
    private func startMembersFlow(roomProxy: JoinedRoomProxyProtocol) {
        let flowCoordinator = RoomMembersFlowCoordinator(entryPoint: .roomMembersList,
                                                         roomProxy: roomProxy,
                                                         navigationStackCoordinator: navigationStackCoordinator,
                                                         flowParameters: flowParameters)
        
        flowCoordinator.actions.sink { [weak self] actions in
            guard let self else { return }
            switch actions {
            case .finished:
                stateMachine.tryEvent(.stopMembersFlow)
            case .presentCallScreen(let roomProxy):
                actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
            case .verifyUser(let userID):
                actionsSubject.send(.verifyUser(userID: userID))
            }
        }
        .store(in: &cancellables)
        membersFlowCoordinator = flowCoordinator
        flowCoordinator.start()
    }
    
    private func startSettingsFlow(roomProxy: JoinedRoomProxyProtocol) {
        let flowCoordinator = SpaceSettingsFlowCoordinator(roomProxy: roomProxy,
                                                           navigationStackCoordinator: navigationStackCoordinator,
                                                           flowParameters: flowParameters)
        
        flowCoordinator.actions.sink { [weak self] actions in
            guard let self else { return }
            switch actions {
            case .finished(let leftRoom):
                stateMachine.tryEvent(.stopSettingsFlow)
                if leftRoom {
                    stateMachine.tryEvent(.leftSpace)
                }
            case .presentCallScreen(let roomProxy):
                actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
            case .verifyUser(userID: let userID):
                actionsSubject.send(.verifyUser(userID: userID))
            }
        }
        .store(in: &cancellables)
        
        settingsFlowCoordinator = flowCoordinator
        flowCoordinator.start()
    }
    
    private func startRolesAndPermissionsFlow(roomProxy: JoinedRoomProxyProtocol) {
        let flowCoordinator = RoomRolesAndPermissionsFlowCoordinator(parameters: .init(roomProxy: roomProxy,
                                                                                       mediaProvider: flowParameters.userSession.mediaProvider,
                                                                                       navigationStackCoordinator: navigationStackCoordinator,
                                                                                       userIndicatorController: flowParameters.userIndicatorController,
                                                                                       analytics: flowParameters.analytics))
        flowCoordinator.actionsPublisher.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .complete:
                stateMachine.tryEvent(.stopRolesAndPermissionsFlow)
            }
        }
        .store(in: &cancellables)
        
        rolesAndPermissionsFlowCoordinator = flowCoordinator
        flowCoordinator.start()
    }
}
