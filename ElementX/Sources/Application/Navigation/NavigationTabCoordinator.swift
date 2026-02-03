//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

/// Class responsible for displaying an arbitrary number of coordinators within the tab bar.
@Observable class NavigationTabCoordinator<Tag: Hashable>: CoordinatorProtocol, CustomStringConvertible {
    struct Tab {
        let coordinator: CoordinatorProtocol
        let details: TabDetails
        var dismissalCallback: (() -> Void)?
    }
    
    @MainActor
    @Observable class TabDetails {
        /// A unique tab that identifies the tab for selection.
        let tag: Tag
        let title: String
        let icon: KeyPath<CompoundIcons, Image>
        let selectedIcon: KeyPath<CompoundIcons, Image>
        var badgeCount = 0
        var barVisibilityOverride: Visibility?
        
        /// Provide the tab's split coordinator in here to have the tab bar automatically hidden
        /// when pushing a child into the split view's details on iPhone/compact iPad.
        weak var navigationSplitCoordinator: NavigationSplitCoordinator?
        
        init(tag: Tag, title: String, icon: KeyPath<CompoundIcons, Image>, selectedIcon: KeyPath<CompoundIcons, Image>) {
            self.tag = tag
            self.title = title
            self.icon = icon
            self.selectedIcon = selectedIcon
        }
        
        func barVisibility(in horizontalSizeClass: UserInterfaceSizeClass?) -> Visibility {
            if let barVisibilityOverride {
                barVisibilityOverride
            } else if horizontalSizeClass == .compact, navigationSplitCoordinator?.detailCoordinator != nil {
                // Whilst we support pushing screens on the stack in the sidebarCoordinator, in practice
                // we never do that, so simply checking that the detailCoordinator exists is enough.
                .hidden
            } else {
                .automatic
            }
        }
    }
    
    // MARK: Tabs
    
    fileprivate struct TabModule: Identifiable {
        let module: NavigationModule
        let details: TabDetails
        
        var id: ObjectIdentifier { module.id }
        @MainActor var coordinator: CoordinatorProtocol? { module.coordinator }
    }
    
    fileprivate var tabModules = [TabModule]() {
        didSet {
            let diffs = tabModules.map(\.module).difference(from: oldValue.map(\.module))
            diffs.forEach { change in
                switch change {
                case .insert(_, let module, _):
                    logPresentationChange("Set tab", module)
                    module.coordinator?.start()
                case .remove(_, let module, _):
                    logPresentationChange("Remove tab", module)
                    module.tearDown()
                }
            }
        }
    }
    
    /// The current set of coordinators displayed by the tabs.
    var tabCoordinators: [any CoordinatorProtocol] {
        tabModules.compactMap(\.module.coordinator)
    }
    
    /// Updates the displayed tabs with the provided array.
    func setTabs(_ tabs: [Tab], animated: Bool = true) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            tabModules = tabs.map { TabModule(module: .init($0.coordinator, dismissalCallback: $0.dismissalCallback), details: $0.details) }
        }
        
        selectedTab = tabModules.first?.details.tag
    }
    
    /// The currently selected tab's tag.
    var selectedTab: Tag? {
        didSet {
            if selectedTab != oldValue {
                selectedTabDidChange?(selectedTab)
            }
        }
    }

    /// Callback invoked when the selected tab changes.
    var selectedTabDidChange: ((Tag?) -> Void)?

    /// Action invoked when the bottom accessory button is tapped.
    var bottomAccessoryAction: (() -> Void)?

    /// Tag value for the agent tab. Must be set for the agent tab to work properly.
    var agentTag: Tag?
    
    var hasAgentUnread: Bool = false

    /// Internal delegate for intercepting agent tab selection
    fileprivate var agentTabBarDelegate: AgentTabBarDelegate?

    // MARK: Sheets
    
    fileprivate var sheetModule: NavigationModule? {
        didSet {
            if let oldValue {
                logPresentationChange("Remove sheet", oldValue)
                oldValue.tearDown()
            }
            
            if let sheetModule {
                logPresentationChange("Set sheet", sheetModule)
                sheetModule.coordinator?.start()
            }
        }
    }
    
    var presentationDetents: Set<PresentationDetent> = []
    
    /// The currently presented sheet coordinator.
    var sheetCoordinator: (any CoordinatorProtocol)? {
        sheetModule?.coordinator
    }
    
    /// Present a sheet on top of the stack. If this NavigationStackCoordinator is embedded within a NavigationSplitCoordinator
    /// then the presentation will be proxied to the split
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - animated: whether to animate the transition or not. Default is true

    ///   - dismissalCallback: called when the sheet has been dismissed, programatically or otherwise
    func setSheetCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            sheetModule = nil
            return
        }
        
        if sheetModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }

        var transaction = Transaction()
        transaction.disablesAnimations = !animated

        withTransaction(transaction) {
            sheetModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    // MARK: Full Screen Cover
    
    fileprivate var fullScreenCoverModule: NavigationModule? {
        didSet {
            if let oldValue {
                logPresentationChange("Remove fullscreen cover", oldValue)
                oldValue.tearDown()
            }
            
            if let fullScreenCoverModule {
                logPresentationChange("Set fullscreen cover", fullScreenCoverModule)
                fullScreenCoverModule.coordinator?.start()
            }
        }
    }
    
    /// The currently presented fullscreen cover coordinator
    /// Fullscreen covers will be presented through the NavigationSplitCoordinator if provided
    var fullScreenCoverCoordinator: (any CoordinatorProtocol)? {
        fullScreenCoverModule?.coordinator
    }
    
    /// Present a fullscreen cover on top of the stack. If this NavigationStackCoordinator is embedded within a NavigationSplitCoordinator
    /// then the presentation will be proxied to the split
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - animated: whether to animate the transition or not. Default is true
    ///   - dismissalCallback: called when the fullscreen cover has been dismissed, programatically or otherwise
    func setFullScreenCoverCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            fullScreenCoverModule = nil
            return
        }
        
        if fullScreenCoverModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }

        var transaction = Transaction()
        transaction.disablesAnimations = !animated

        withTransaction(transaction) {
            fullScreenCoverModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    // MARK: - Overlay
    
    fileprivate var overlayModule: NavigationModule? {
        didSet {
            if let oldValue {
                logPresentationChange("Remove overlay", oldValue)
                oldValue.tearDown()
            }
            
            if let overlayModule {
                logPresentationChange("Set overlay", overlayModule)
                overlayModule.coordinator?.start()
            }
        }
    }
    
    /// The currently displayed overlay coordinator
    var overlayCoordinator: (any CoordinatorProtocol)? {
        overlayModule?.coordinator
    }
    
    enum OverlayPresentationMode { case fullScreen, minimized }
    fileprivate var overlayPresentationMode: OverlayPresentationMode = .minimized
    
    /// Present an overlay on top of the tab view
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - presentationMode: how the coordinator should be presented
    ///   - animated: whether the transition should be animated
    ///   - dismissalCallback: called when the overlay has been dismissed, programatically or otherwise
    func setOverlayCoordinator(_ coordinator: (any CoordinatorProtocol)?,
                               presentationMode: OverlayPresentationMode = .fullScreen,
                               animated: Bool = true,
                               dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            overlayModule = nil
            return
        }
        
        if overlayModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }

        var transaction = Transaction()
        transaction.disablesAnimations = !animated

        withTransaction(transaction) {
            overlayPresentationMode = presentationMode
            overlayModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    /// Updates the presentation of the overlay coordinator.
    /// - Parameters:
    ///   - mode: The type of presentation to use.
    ///   - animated: whether the transition should be animated
    func setOverlayPresentationMode(_ mode: OverlayPresentationMode, animated: Bool = true) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            overlayPresentationMode = mode
        }
    }
    
    // MARK: - CoordinatorProtocol
    
    /// No idea if this is particuarly needed for the TabView but we do this for the NavigationStackCoordinator and NavigationSplitCoordinator so it
    /// doesn't seem to harm to also do it here.
    func stop() {
        tabModules.forEach { $0.module.tearDown() }
    }
    
    func toPresentable() -> AnyView {
        AnyView(NavigationTabCoordinatorView(navigationTabCoordinator: self))
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        guard !tabModules.isEmpty else { return "NavigationTabCoordinator(Empty)" }
        return "NavigationTabCoordinator(\(tabCoordinators)"
    }
    
    // MARK: - Private
    
    private func logPresentationChange(_ change: String, _ module: NavigationModule) {
        if let coordinator = module.coordinator {
            MXLog.info("\(self) \(change): \(coordinator)")
        }
    }
}

private struct NavigationTabCoordinatorView<Tag: Hashable>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Bindable var navigationTabCoordinator: NavigationTabCoordinator<Tag>

    @State private var standardAppearance = UITabBarAppearance()

    var body: some View {
        tabViewContent
            .backportTabBarMinimizeBehaviorOnScrollDown()
            .introspect(.tabView, on: .supportedVersions, customize: configureAppearance)
            .sheet(item: $navigationTabCoordinator.sheetModule) { module in
                module.coordinator?.toPresentable()
                    .id(module.id)
            }
            .fullScreenCover(item: $navigationTabCoordinator.fullScreenCoverModule) { module in
                module.coordinator?.toPresentable()
                    .id(module.id)
            }
            .accessibilityHidden(navigationTabCoordinator.overlayModule?.coordinator != nil && navigationTabCoordinator.overlayPresentationMode == .fullScreen)
            .overlay {
                Group {
                    if let coordinator = navigationTabCoordinator.overlayModule?.coordinator {
                        coordinator.toPresentable()
                            .opacity(navigationTabCoordinator.overlayPresentationMode == .minimized ? 0 : 1)
                            .transition(.opacity)
                    }
                }
                .animation(.elementDefault, value: navigationTabCoordinator.overlayPresentationMode)
                .animation(.elementDefault, value: navigationTabCoordinator.overlayModule)
            }
    }

    @ViewBuilder
    private var tabViewContent: some View {
        if #available(iOS 26.0, *) {
            iOS26TabView()
        } else {
            legacyTabView
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private func iOS26TabView() -> some View {
        TabView(selection: $navigationTabCoordinator.selectedTab) {
            ForEach(navigationTabCoordinator.tabModules) { module in
                Tab(value: module.details.tag) {
                    module.coordinator?.toPresentable()
                        .id(module.id)
                        .toolbar(module.details.barVisibility(in: horizontalSizeClass), for: .tabBar)
                } label: {
                    Label {
                        Text(module.details.title)
                    } icon: {
                        CompoundIcon(module.details.tag == navigationTabCoordinator.selectedTab ? module.details.selectedIcon : module.details.icon)
                    }
                }
                .badge(module.details.badgeCount)
            }

            if let agentTag = navigationTabCoordinator.agentTag {
                Tab(value: agentTag, role: .search) {
                    Color.clear
                } label: {
                    Label {
                        Text("Agent")
                    } icon: {
                        Image(asset: Asset.Images.agentIcon)
                    }
                }
            }
        }
        .introspect(.tabView, on: .supportedVersions) { tabBarController in
            configureAgentTabInterception(tabBarController)
        }
        .id(navigationTabCoordinator.hasAgentUnread)
    }

    private func configureAgentTabInterception(_ tabBarController: UITabBarController) {
        guard #available(iOS 26.0, *) else { return }

        if navigationTabCoordinator.agentTabBarDelegate == nil {
            let delegate = AgentTabBarDelegate()
            delegate.agentTabIndex = navigationTabCoordinator.tabModules.count
            delegate.onAgentTapped = { [weak navigationTabCoordinator] in
                navigationTabCoordinator?.bottomAccessoryAction?()
            }
            delegate.onTabSelected = { [weak navigationTabCoordinator] index in
                guard let navigationTabCoordinator,
                      index < navigationTabCoordinator.tabModules.count else { return }
                navigationTabCoordinator.selectedTab = navigationTabCoordinator.tabModules[index].details.tag
            }
            navigationTabCoordinator.agentTabBarDelegate = delegate
        }

        tabBarController.delegate = navigationTabCoordinator.agentTabBarDelegate
        updateAgentBadge(in: tabBarController.tabBar)
    }

    private var legacyTabView: some View {
        TabView(selection: $navigationTabCoordinator.selectedTab) {
            ForEach(navigationTabCoordinator.tabModules) { module in
                module.coordinator?.toPresentable()
                    .id(module.id)
                    .tabItem {
                        Label {
                            Text(module.details.title)
                        } icon: {
                            CompoundIcon(module.details.tag == navigationTabCoordinator.selectedTab ? module.details.selectedIcon : module.details.icon)
                        }
                    }
                    .tag(module.details.tag)
                    .badge(module.details.badgeCount)
                    .toolbar(module.details.barVisibility(in: horizontalSizeClass), for: .tabBar)
            }

            legacyBotTab
        }
        .introspect(.tabView, on: .supportedVersions) { tabBarController in
            configureLegacyAgentTabInterception(tabBarController)
        }
        .id(navigationTabCoordinator.hasAgentUnread)
    }

    @ViewBuilder
    private var legacyBotTab: some View {
        if let agentTag = navigationTabCoordinator.agentTag {
            Color.clear
                .tabItem {
                    Label {
                        Text("Agent")
                    } icon: {
                        Image(asset: Asset.Images.agentIcon)
                    }
                }
                .tag(agentTag)
        }
    }

    private func configureLegacyAgentTabInterception(_ tabBarController: UITabBarController) {
        guard navigationTabCoordinator.agentTag != nil else { return }

        if navigationTabCoordinator.agentTabBarDelegate == nil {
            let delegate = AgentTabBarDelegate()
            delegate.agentTabIndex = navigationTabCoordinator.tabModules.count
            delegate.onAgentTapped = { [weak navigationTabCoordinator] in
                navigationTabCoordinator?.bottomAccessoryAction?()
            }
            delegate.onTabSelected = { [weak navigationTabCoordinator] index in
                guard let navigationTabCoordinator,
                      index < navigationTabCoordinator.tabModules.count else { return }
                navigationTabCoordinator.selectedTab = navigationTabCoordinator.tabModules[index].details.tag
            }
            navigationTabCoordinator.agentTabBarDelegate = delegate
        }

        tabBarController.delegate = navigationTabCoordinator.agentTabBarDelegate
        updateAgentBadge(in: tabBarController.tabBar)
    }
    
    // WARNING: Uses private UIKit APIs (`_UITabBarAuxiliaryView`, `UITabBarButton`) which may break on iOS updates.
    private func updateAgentBadge(in tabBar: UITabBar) {
        tabBar.layoutIfNeeded()
        tabBar.viewWithTag(AgentBadge.viewTag)?.removeFromSuperview()
        
        guard navigationTabCoordinator.hasAgentUnread else { return }
        
        let dotSize: CGFloat
        let dotX: CGFloat
        let dotY: CGFloat
        
        if #available(iOS 26.0, *) {
            // iOS 26+: Agent tab is rendered as _UITabBarAuxiliaryView (circular button)
            guard let agentButton = tabBar.subviews
                .first(where: { String(describing: type(of: $0)).contains("AuxiliaryView") }) else { return }
            
            dotSize = AgentBadge.iOS26.dotSize
            dotX = agentButton.frame.midX - dotSize / 2 + AgentBadge.iOS26.offset
            dotY = agentButton.frame.midY - dotSize / 2 - AgentBadge.iOS26.offset
        } else {
            // iOS 18 and below: Agent tab is a regular UITabBarButton
            let agentIndex = navigationTabCoordinator.tabModules.count
            let tabBarButtons = tabBar.subviews
                .filter { String(describing: type(of: $0)).contains("UITabBarButton") }
                .sorted { $0.frame.minX < $1.frame.minX }
            
            guard agentIndex < tabBarButtons.count else { return }
            
            let agentButton = tabBarButtons[agentIndex]
            dotSize = AgentBadge.iOS18.dotSize
            dotX = agentButton.frame.midX + AgentBadge.iOS18.offset
            dotY = agentButton.frame.minY + AgentBadge.iOS18.offset / 2
        }
        
        let dotView = UIView(frame: CGRect(x: dotX, y: dotY, width: dotSize, height: dotSize))
        dotView.tag = AgentBadge.viewTag
        dotView.backgroundColor = .compound.iconAccentTertiary
        dotView.layer.cornerRadius = dotSize / 2
        
        tabBar.addSubview(dotView)
    }

    private func configureAppearance(_ tabBarController: UITabBarController) {
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .compound.iconAccentPrimary // iPhone Portrait
        standardAppearance.compactInlineLayoutAppearance.normal.badgeBackgroundColor = .compound.iconAccentPrimary // iPhone Landscape
        standardAppearance.inlineLayoutAppearance.normal.badgeBackgroundColor = .compound.iconAccentPrimary // iPadOS 17 (doesn't work for 18+)
        tabBarController.tabBar.standardAppearance = standardAppearance
    }
}

// MARK: - Agent Badge Constants

private enum AgentBadge {
    static let viewTag = 9999
    
    enum iOS26 {
        static let dotSize: CGFloat = 8
        static let offset: CGFloat = 14
    }
    
    enum iOS18 {
        static let dotSize: CGFloat = 6
        static let offset: CGFloat = 12
    }
}

// MARK: - Agent Tab Bar Delegate

private class AgentTabBarDelegate: NSObject, UITabBarControllerDelegate {
    var agentTabIndex: Int = 0
    var onAgentTapped: (() -> Void)?
    var onTabSelected: ((Int) -> Void)?

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }

        if index == agentTabIndex {
            onAgentTapped?()
            return false
        }

        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return
        }
        onTabSelected?(index)
    }
}

