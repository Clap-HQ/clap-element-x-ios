//
// CompoundSemanticColors.swift
// Unified semantic color tokens - UIColor as source of truth, Color derived from it
//

import SwiftUI
import UIKit

// MARK: - UIColor Semantic Tokens (Source of Truth)

public class CompoundUIColorTokens {
    public let bgAccentHovered = CompoundCoreUIColorTokens.green1000
    public let bgAccentPressed = CompoundCoreUIColorTokens.green1100
    public let bgAccentRest = CompoundCoreUIColorTokens.green900
    public let bgAccentSelected = CompoundCoreUIColorTokens.alphaGreen300
    public let bgActionPrimaryDisabled = CompoundCoreUIColorTokens.gray700
    public let bgActionPrimaryHovered = CompoundCoreUIColorTokens.gray1200
    public let bgActionPrimaryPressed = CompoundCoreUIColorTokens.gray1100
    public let bgActionPrimaryRest = CompoundCoreUIColorTokens.gray1400
    public let bgActionSecondaryHovered = CompoundCoreUIColorTokens.alphaGray200
    public let bgActionSecondaryPressed = CompoundCoreUIColorTokens.alphaGray300
    public let bgActionSecondaryRest = CompoundCoreUIColorTokens.themeBg
//    public let bgBadgeAccent = UIColor(named: "bgBadgeAccent", in: Bundle.module, compatibleWith: nil)!
    public let bgBadgeAccent = CompoundCoreUIColorTokens.clapBgBadgeAccent
//    public let bgBadgeDefault = UIColor(named: "bgBadgeDefault", in: Bundle.module, compatibleWith: nil)!
    public let bgBadgeDefault = CompoundCoreUIColorTokens.clapBgBadgeDefault
    public let bgBadgeInfo = UIColor(named: "bgBadgeInfo", in: Bundle.module, compatibleWith: nil)!
//    public let bgCanvasDefault = CompoundCoreUIColorTokens.themeBg
    public let bgCanvasDefault = CompoundCoreUIColorTokens.clapThemeBg
    public let bgCanvasDefaultLevel1 = UIColor(named: "bgCanvasDefaultLevel1", in: Bundle.module, compatibleWith: nil)!
    public let bgRoomScreen = CompoundCoreUIColorTokens.clapRoomBg
    public let bgCanvasDisabled = CompoundCoreUIColorTokens.gray200
    public let bgCriticalHovered = CompoundCoreUIColorTokens.red1000
    public let bgCriticalPrimary = CompoundCoreUIColorTokens.red900
    public let bgCriticalSubtle = CompoundCoreUIColorTokens.red200
    public let bgCriticalSubtleHovered = CompoundCoreUIColorTokens.red300
    public let bgDecorative1 = CompoundCoreUIColorTokens.lime300
    public let bgDecorative2 = CompoundCoreUIColorTokens.cyan300
    public let bgDecorative3 = CompoundCoreUIColorTokens.fuchsia300
    public let bgDecorative4 = CompoundCoreUIColorTokens.purple300
    public let bgDecorative5 = CompoundCoreUIColorTokens.pink300
    public let bgDecorative6 = CompoundCoreUIColorTokens.orange300
    public let bgInfoSubtle = CompoundCoreUIColorTokens.blue200
    public let bgSubtlePrimary = CompoundCoreUIColorTokens.gray400
//    public let bgSubtleSecondary = CompoundCoreUIColorTokens.gray300
    public let bgSubtleSecondary = CompoundCoreUIColorTokens.clapBgSubtleSecondary
    public let bgSubtleSecondaryLevel0 = UIColor(named: "bgSubtleSecondaryLevel0", in: Bundle.module, compatibleWith: nil)!
    public let bgSuccessSubtle = CompoundCoreUIColorTokens.green200
    public let borderAccentSubtle = CompoundCoreUIColorTokens.green700
    public let borderCriticalHovered = CompoundCoreUIColorTokens.red1000
    public let borderCriticalPrimary = CompoundCoreUIColorTokens.red900
    public let borderCriticalSubtle = CompoundCoreUIColorTokens.red500
    public let borderDisabled = CompoundCoreUIColorTokens.gray500
    public let borderFocused = CompoundCoreUIColorTokens.blue900
    public let borderInfoSubtle = CompoundCoreUIColorTokens.blue700
    public let borderInteractiveHovered = CompoundCoreUIColorTokens.gray1100
//    public let borderInteractivePrimary = CompoundCoreUIColorTokens.gray800
    public let borderInteractivePrimary = CompoundCoreUIColorTokens.clapIconAccentTertiary
    public let borderInteractiveSecondary = CompoundCoreUIColorTokens.gray600
    public let borderSuccessSubtle = CompoundCoreUIColorTokens.green500
    public let gradientActionStop1 = UIColor(named: "gradientActionStop1", in: Bundle.module, compatibleWith: nil)!
    public let gradientActionStop2 = UIColor(named: "gradientActionStop2", in: Bundle.module, compatibleWith: nil)!
    public let gradientActionStop3 = UIColor(named: "gradientActionStop3", in: Bundle.module, compatibleWith: nil)!
    public let gradientActionStop4 = UIColor(named: "gradientActionStop4", in: Bundle.module, compatibleWith: nil)!
    public let gradientInfoStop1 = CompoundCoreUIColorTokens.alphaBlue500
    public let gradientInfoStop2 = CompoundCoreUIColorTokens.alphaBlue400
    public let gradientInfoStop3 = CompoundCoreUIColorTokens.alphaBlue300
    public let gradientInfoStop4 = CompoundCoreUIColorTokens.alphaBlue200
    public let gradientInfoStop5 = CompoundCoreUIColorTokens.alphaBlue100
    public let gradientInfoStop6 = CompoundCoreUIColorTokens.transparent
    public let gradientSubtleStop1 = CompoundCoreUIColorTokens.alphaGreen500
    public let gradientSubtleStop2 = CompoundCoreUIColorTokens.alphaGreen400
    public let gradientSubtleStop3 = CompoundCoreUIColorTokens.alphaGreen300
    public let gradientSubtleStop4 = CompoundCoreUIColorTokens.alphaGreen200
    public let gradientSubtleStop5 = CompoundCoreUIColorTokens.alphaGreen100
    public let gradientSubtleStop6 = CompoundCoreUIColorTokens.transparent
    public let iconAccentPrimary = CompoundCoreUIColorTokens.green900
    // public let iconAccentTertiary = CompoundCoreUIColorTokens.green800
    public let iconAccentTertiary = CompoundCoreUIColorTokens.clapIconAccentTertiary
//    public let iconCriticalPrimary = CompoundCoreUIColorTokens.red900
    public let iconCriticalPrimary = CompoundCoreUIColorTokens.red800
    public let iconDisabled = CompoundCoreUIColorTokens.gray700
    public let iconInfoPrimary = CompoundCoreUIColorTokens.blue900
//    public let iconOnSolidPrimary = CompoundCoreUIColorTokens.themeBg
    public let iconOnSolidPrimary = CompoundCoreUIColorTokens.clapRoomBg
    public let iconPrimary = CompoundCoreUIColorTokens.gray1400
    public let iconPrimaryAlpha = CompoundCoreUIColorTokens.alphaGray1400
    public let iconQuaternary = CompoundCoreUIColorTokens.gray700
    public let iconQuaternaryAlpha = CompoundCoreUIColorTokens.alphaGray700
    public let iconSecondary = CompoundCoreUIColorTokens.gray900
    public let iconSecondaryAlpha = CompoundCoreUIColorTokens.alphaGray900
    public let iconSuccessPrimary = CompoundCoreUIColorTokens.green900
    public let iconTertiary = CompoundCoreUIColorTokens.gray800
    public let iconTertiaryAlpha = CompoundCoreUIColorTokens.alphaGray800
    public let textActionAccent = CompoundCoreUIColorTokens.green900
    public let textActionPrimary = CompoundCoreUIColorTokens.gray1400
//    public let textBadgeAccent = CompoundCoreUIColorTokens.green1100
    public let textBadgeAccent = CompoundCoreUIColorTokens.clapTextBadgeAccent
    public let textBadgeInfo = CompoundCoreUIColorTokens.blue1100
    public let textCriticalPrimary = CompoundCoreUIColorTokens.red900
    public let textDecorative1 = CompoundCoreUIColorTokens.lime1100
    public let textDecorative2 = CompoundCoreUIColorTokens.cyan1100
    public let textDecorative3 = CompoundCoreUIColorTokens.fuchsia1100
    public let textDecorative4 = CompoundCoreUIColorTokens.purple1100
    public let textDecorative5 = CompoundCoreUIColorTokens.pink1100
    public let textDecorative6 = CompoundCoreUIColorTokens.orange1100
    public let textDisabled = CompoundCoreUIColorTokens.gray800
    public let textInfoPrimary = CompoundCoreUIColorTokens.blue900
    public let textLinkExternal = CompoundCoreUIColorTokens.blue900
    public let textOnSolidPrimary = CompoundCoreUIColorTokens.themeBg
//    public let textPrimary = CompoundCoreUIColorTokens.gray1400
    public let textPrimary = CompoundCoreUIColorTokens.clapTextPrimary
//    public let textSecondary = CompoundCoreUIColorTokens.gray900
    public let textSecondary = CompoundCoreUIColorTokens.clapTextSecondary
    public let textSuccessPrimary = CompoundCoreUIColorTokens.green900
    public init() { }
}

// MARK: - SwiftUI Color Semantic Tokens (Derived from UIColor)

public class CompoundColorTokens {
    public var bgAccentHovered: Color { Color(uiColor: uiTokens.bgAccentHovered) }
    public var bgAccentPressed: Color { Color(uiColor: uiTokens.bgAccentPressed) }
    public var bgAccentRest: Color { Color(uiColor: uiTokens.bgAccentRest) }
    public var bgAccentSelected: Color { Color(uiColor: uiTokens.bgAccentSelected) }
    public var bgActionPrimaryDisabled: Color { Color(uiColor: uiTokens.bgActionPrimaryDisabled) }
    public var bgActionPrimaryHovered: Color { Color(uiColor: uiTokens.bgActionPrimaryHovered) }
    public var bgActionPrimaryPressed: Color { Color(uiColor: uiTokens.bgActionPrimaryPressed) }
    public var bgActionPrimaryRest: Color { Color(uiColor: uiTokens.bgActionPrimaryRest) }
    public var bgActionSecondaryHovered: Color { Color(uiColor: uiTokens.bgActionSecondaryHovered) }
    public var bgActionSecondaryPressed: Color { Color(uiColor: uiTokens.bgActionSecondaryPressed) }
    public var bgActionSecondaryRest: Color { Color(uiColor: uiTokens.bgActionSecondaryRest) }
    public var bgBadgeAccent: Color { Color(uiColor: uiTokens.bgBadgeAccent) }
    public var bgBadgeDefault: Color { Color(uiColor: uiTokens.bgBadgeDefault) }
    public var bgBadgeInfo: Color { Color(uiColor: uiTokens.bgBadgeInfo) }
    public var bgCanvasDefault: Color { Color(uiColor: uiTokens.bgCanvasDefault) }
    public var bgCanvasDefaultLevel1: Color { Color(uiColor: uiTokens.bgCanvasDefaultLevel1) }
    public var bgRoomScreen: Color { Color(uiColor: uiTokens.bgRoomScreen) }
    public var bgCanvasDisabled: Color { Color(uiColor: uiTokens.bgCanvasDisabled) }
    public var bgCriticalHovered: Color { Color(uiColor: uiTokens.bgCriticalHovered) }
    public var bgCriticalPrimary: Color { Color(uiColor: uiTokens.bgCriticalPrimary) }
    public var bgCriticalSubtle: Color { Color(uiColor: uiTokens.bgCriticalSubtle) }
    public var bgCriticalSubtleHovered: Color { Color(uiColor: uiTokens.bgCriticalSubtleHovered) }
    public var bgDecorative1: Color { Color(uiColor: uiTokens.bgDecorative1) }
    public var bgDecorative2: Color { Color(uiColor: uiTokens.bgDecorative2) }
    public var bgDecorative3: Color { Color(uiColor: uiTokens.bgDecorative3) }
    public var bgDecorative4: Color { Color(uiColor: uiTokens.bgDecorative4) }
    public var bgDecorative5: Color { Color(uiColor: uiTokens.bgDecorative5) }
    public var bgDecorative6: Color { Color(uiColor: uiTokens.bgDecorative6) }
    public var bgInfoSubtle: Color { Color(uiColor: uiTokens.bgInfoSubtle) }
    public var bgSubtlePrimary: Color { Color(uiColor: uiTokens.bgSubtlePrimary) }
    public var bgSubtleSecondary: Color { Color(uiColor: uiTokens.bgSubtleSecondary) }
    public var bgSubtleSecondaryLevel0: Color { Color(uiColor: uiTokens.bgSubtleSecondaryLevel0) }
    public var bgSuccessSubtle: Color { Color(uiColor: uiTokens.bgSuccessSubtle) }
    public var borderAccentSubtle: Color { Color(uiColor: uiTokens.borderAccentSubtle) }
    public var borderCriticalHovered: Color { Color(uiColor: uiTokens.borderCriticalHovered) }
    public var borderCriticalPrimary: Color { Color(uiColor: uiTokens.borderCriticalPrimary) }
    public var borderCriticalSubtle: Color { Color(uiColor: uiTokens.borderCriticalSubtle) }
    public var borderDisabled: Color { Color(uiColor: uiTokens.borderDisabled) }
    public var borderFocused: Color { Color(uiColor: uiTokens.borderFocused) }
    public var borderInfoSubtle: Color { Color(uiColor: uiTokens.borderInfoSubtle) }
    public var borderInteractiveHovered: Color { Color(uiColor: uiTokens.borderInteractiveHovered) }
    public var borderInteractivePrimary: Color { Color(uiColor: uiTokens.borderInteractivePrimary) }
    public var borderInteractiveSecondary: Color { Color(uiColor: uiTokens.borderInteractiveSecondary) }
    public var borderSuccessSubtle: Color { Color(uiColor: uiTokens.borderSuccessSubtle) }
    public var gradientActionStop1: Color { Color(uiColor: uiTokens.gradientActionStop1) }
    public var gradientActionStop2: Color { Color(uiColor: uiTokens.gradientActionStop2) }
    public var gradientActionStop3: Color { Color(uiColor: uiTokens.gradientActionStop3) }
    public var gradientActionStop4: Color { Color(uiColor: uiTokens.gradientActionStop4) }
    public var gradientInfoStop1: Color { Color(uiColor: uiTokens.gradientInfoStop1) }
    public var gradientInfoStop2: Color { Color(uiColor: uiTokens.gradientInfoStop2) }
    public var gradientInfoStop3: Color { Color(uiColor: uiTokens.gradientInfoStop3) }
    public var gradientInfoStop4: Color { Color(uiColor: uiTokens.gradientInfoStop4) }
    public var gradientInfoStop5: Color { Color(uiColor: uiTokens.gradientInfoStop5) }
    public var gradientInfoStop6: Color { Color(uiColor: uiTokens.gradientInfoStop6) }
    public var gradientSubtleStop1: Color { Color(uiColor: uiTokens.gradientSubtleStop1) }
    public var gradientSubtleStop2: Color { Color(uiColor: uiTokens.gradientSubtleStop2) }
    public var gradientSubtleStop3: Color { Color(uiColor: uiTokens.gradientSubtleStop3) }
    public var gradientSubtleStop4: Color { Color(uiColor: uiTokens.gradientSubtleStop4) }
    public var gradientSubtleStop5: Color { Color(uiColor: uiTokens.gradientSubtleStop5) }
    public var gradientSubtleStop6: Color { Color(uiColor: uiTokens.gradientSubtleStop6) }
    public var iconAccentPrimary: Color { Color(uiColor: uiTokens.iconAccentPrimary) }
    public var iconAccentTertiary: Color { Color(uiColor: uiTokens.iconAccentTertiary) }
    public var iconCriticalPrimary: Color { Color(uiColor: uiTokens.iconCriticalPrimary) }
    public var iconDisabled: Color { Color(uiColor: uiTokens.iconDisabled) }
    public var iconInfoPrimary: Color { Color(uiColor: uiTokens.iconInfoPrimary) }
    public var iconOnSolidPrimary: Color { Color(uiColor: uiTokens.iconOnSolidPrimary) }
    public var iconPrimary: Color { Color(uiColor: uiTokens.iconPrimary) }
    public var iconPrimaryAlpha: Color { Color(uiColor: uiTokens.iconPrimaryAlpha) }
    public var iconQuaternary: Color { Color(uiColor: uiTokens.iconQuaternary) }
    public var iconQuaternaryAlpha: Color { Color(uiColor: uiTokens.iconQuaternaryAlpha) }
    public var iconSecondary: Color { Color(uiColor: uiTokens.iconSecondary) }
    public var iconSecondaryAlpha: Color { Color(uiColor: uiTokens.iconSecondaryAlpha) }
    public var iconSuccessPrimary: Color { Color(uiColor: uiTokens.iconSuccessPrimary) }
    public var iconTertiary: Color { Color(uiColor: uiTokens.iconTertiary) }
    public var iconTertiaryAlpha: Color { Color(uiColor: uiTokens.iconTertiaryAlpha) }
    public var textActionAccent: Color { Color(uiColor: uiTokens.textActionAccent) }
    public var textActionPrimary: Color { Color(uiColor: uiTokens.textActionPrimary) }
    public var textBadgeAccent: Color { Color(uiColor: uiTokens.textBadgeAccent) }
    public var textBadgeInfo: Color { Color(uiColor: uiTokens.textBadgeInfo) }
    public var textCriticalPrimary: Color { Color(uiColor: uiTokens.textCriticalPrimary) }
    public var textDecorative1: Color { Color(uiColor: uiTokens.textDecorative1) }
    public var textDecorative2: Color { Color(uiColor: uiTokens.textDecorative2) }
    public var textDecorative3: Color { Color(uiColor: uiTokens.textDecorative3) }
    public var textDecorative4: Color { Color(uiColor: uiTokens.textDecorative4) }
    public var textDecorative5: Color { Color(uiColor: uiTokens.textDecorative5) }
    public var textDecorative6: Color { Color(uiColor: uiTokens.textDecorative6) }
    public var textDisabled: Color { Color(uiColor: uiTokens.textDisabled) }
    public var textInfoPrimary: Color { Color(uiColor: uiTokens.textInfoPrimary) }
    public var textLinkExternal: Color { Color(uiColor: uiTokens.textLinkExternal) }
    public var textOnSolidPrimary: Color { Color(uiColor: uiTokens.textOnSolidPrimary) }
    public var textPrimary: Color { Color(uiColor: uiTokens.textPrimary) }
    public var textSecondary: Color { Color(uiColor: uiTokens.textSecondary) }
    public var textSuccessPrimary: Color { Color(uiColor: uiTokens.textSuccessPrimary) }
    
    private let uiTokens = CompoundUIColorTokens()
    public init() { }
}

