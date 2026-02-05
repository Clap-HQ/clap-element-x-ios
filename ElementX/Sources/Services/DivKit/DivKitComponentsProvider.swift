//
// Copyright 2025 Clap Inc.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import DivKit
import Foundation
import UIKit

@MainActor
final class DivKitComponentsProvider {
    static let shared = DivKitComponentsProvider()

    let components: DivKitComponents
    private let actionRouter: DivKitActionRouter
    private let errorReporter: DivKitErrorReporter
    private var registeredCardIDs: Set<String> = []
    private var cachedHeights: [String: CGFloat] = [:]

    private init() {
        let router = DivKitActionRouter()
        let reporter = DivKitErrorReporter()
        self.actionRouter = router
        self.errorReporter = reporter
        self.components = DivKitComponents(reporter: reporter, urlHandler: router)
    }

    func setActionHandler(for cardID: String, handler: @escaping (URL, DivActionInfo) -> Void) {
        registeredCardIDs.insert(cardID)
        actionRouter.handlers[cardID] = handler
    }

    func removeActionHandler(for cardID: String) {
        actionRouter.handlers.removeValue(forKey: cardID)
        removeCardIDIfFullyCleanedUp(cardID)
    }

    func setErrorHandler(for cardID: String, handler: @escaping () -> Void) {
        registeredCardIDs.insert(cardID)
        errorReporter.handlers[cardID] = handler
    }

    func removeErrorHandler(for cardID: String) {
        errorReporter.handlers.removeValue(forKey: cardID)
        removeCardIDIfFullyCleanedUp(cardID)
    }

    private func removeCardIDIfFullyCleanedUp(_ cardID: String) {
        if actionRouter.handlers[cardID] == nil, errorReporter.handlers[cardID] == nil {
            registeredCardIDs.remove(cardID)
        }
    }

    func cachedHeight(for cardID: String) -> CGFloat? {
        cachedHeights[cardID]
    }

    func cacheHeight(_ height: CGFloat, for cardID: String) {
        cachedHeights[cardID] = height
    }

    func resolvePaletteExpressions(cardData: Data, palette: DivKitPalette?) -> Data {
        guard let palette else { return cardData }
        
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        let colors = isDarkMode ? palette.dark : palette.light
        
        guard !colors.isEmpty, var jsonString = String(data: cardData, encoding: .utf8) else {
            return cardData
        }
        
        for color in colors {
            jsonString = jsonString.replacingOccurrences(of: "@{\(color.name)}", with: color.color)
        }
        return Data(jsonString.utf8)
    }

    func resetAllCardState(keepHeightCache: Bool = false) {
        for cardID in registeredCardIDs {
            components.reset(cardId: DivCardID(rawValue: cardID))
        }
        actionRouter.handlers.removeAll()
        errorReporter.handlers.removeAll()
        registeredCardIDs.removeAll()
        if !keepHeightCache {
            cachedHeights.removeAll()
        }
    }
}

// MARK: - Action Router

// Note: div-action:// URLs (internal DivKit state changes like expand/collapse)
// are handled by DivKit's DivActionHandler internally and never reach this handler.
// The clap:// scheme check in handleDivKitAction provides additional safety.
private final class DivKitActionRouter: DivUrlHandler {
    private let lock = NSLock()
    private var _handlers: [String: (URL, DivActionInfo) -> Void] = [:]
    
    var handlers: [String: (URL, DivActionInfo) -> Void] {
        get { lock.withLock { _handlers } }
        set { lock.withLock { _handlers = newValue } }
    }

    func handle(_ url: URL, info: DivActionInfo, sender: AnyObject?) {
        let cardID = info.cardId.rawValue
        let handler = lock.withLock { _handlers[cardID] }
        
        if let handler {
            DispatchQueue.main.async {
                handler(url, info)
            }
        } else {
            MXLog.warning("DivKit: No action handler registered for card '\(cardID)', URL: \(url)")
        }
    }
}

// MARK: - Error Reporter

private final class DivKitErrorReporter: DivReporter {
    private let lock = NSLock()
    private var _handlers: [String: () -> Void] = [:]
    
    var handlers: [String: () -> Void] {
        get { lock.withLock { _handlers } }
        set { lock.withLock { _handlers = newValue } }
    }

    func reportError(cardId: DivCardID, error: DivError) {
        let cardIDString = cardId.rawValue
        MXLog.warning("DivKit: Error for card '\(cardIDString)': \(error.message) (kind: \(error.kind), level: \(error.level))")

        // Only trigger fallback for fatal errors (deserialization/block modeling), not warnings or expression errors
        guard error.level == .error,
              error.kind == .deserialization || error.kind == .blockModeling else {
            return
        }

        let handler = lock.withLock {
            let h = _handlers[cardIDString]
            _handlers.removeValue(forKey: cardIDString)
            return h
        }
        
        if let handler {
            DispatchQueue.main.async {
                handler()
            }
        }
    }
}
