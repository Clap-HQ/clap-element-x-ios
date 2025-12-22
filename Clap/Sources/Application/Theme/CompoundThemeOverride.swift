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
                return UIColor(hex: "EFEEEA")
            } else {
                return UIColor(hex: "EFEEEA")
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
        
        let newBgSubtleSecondary = Color(UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(CompoundCoreColorTokens.gray300)
            } else {
                return UIColor(hex: "F5F5F4", opacity: 0.9)
            }
        })
        
        let newTextPrimary = Color(UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(CompoundCoreColorTokens.gray1400)
            } else {
                return UIColor(hex: "181818")
            }
        })
        
        let newTextSecondary = Color(UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(CompoundCoreColorTokens.gray900)
            } else {
                return UIColor(hex: "666666")
            }
        })
        
        // 전역 토큰 오버라이드
        Color.compound.override(\.bgCanvasDefault, with: newBgCanvasDefault)
        Color.compound.override(\._bgBubbleOutgoing, with: newBgBubbleOutgoing)
        Color.compound.override(\._bgBubbleIncoming, with: newBgBubbleIncoming)
        Color.compound.override(\.bgSubtleSecondary, with: newBgSubtleSecondary)
        Color.compound.override(\.textPrimary, with: newTextPrimary)
        Color.compound.override(\.textSecondary, with: newTextSecondary)
    }
}
