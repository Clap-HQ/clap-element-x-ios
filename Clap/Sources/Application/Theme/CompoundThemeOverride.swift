//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//


import SwiftUI
import UIKit
import Compound

enum CompoundThemeOverride {
    /// 앱 시작 시 1회만 호출하세요.
    static func apply() {
        let newBgCanvasDefault = Color(UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(hex: "EBEAE3", opacity: 0.6)
            } else {
                return UIColor(hex: "EBEAE3", opacity: 0.6)
            }
        })
        
        let newBgBubbleOutgoing = Color(UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(CompoundCoreColorTokens.gray500)
            } else {
                return UIColor(hex: "292524")
            }
        })

        
        let newBgBubbleIncoming = Color(UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(CompoundCoreColorTokens.gray400)
            } else {
                return UIColor.white
            }
        })
        
        // 전역 토큰 오버라이드
        Color.compound.override(\.bgCanvasDefault, with: newBgCanvasDefault)
        Color.compound.override(\._bgBubbleOutgoing, with: newBgBubbleOutgoing)
        Color.compound.override(\._bgBubbleIncoming, with: newBgBubbleIncoming)
    }
}
