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
                return UIColor(hex: "0B0B0B")   // 다크 모드 배경
            } else {
                return UIColor(hex: "EBEAE3", opacity: 0.6)   // 라이트 모드 배경
            }
        })

        // 전역 토큰 오버라이드 (bgCanvasDefault를 쓰는 모든 곳에 반영)
        Color.compound.override(\.bgCanvasDefault, with: newBgCanvasDefault)

        // 필요하면 같이 맞추세요 (앱에 따라 톤이 더 자연스러워집니다)
        // Color.compound.override(\.bgCanvasDefaultLevel1, with: newBgCanvasDefault)
        // Color.compound.override(\.bgCanvasDefaultLevel2, with: newBgCanvasDefault)
    }
}
