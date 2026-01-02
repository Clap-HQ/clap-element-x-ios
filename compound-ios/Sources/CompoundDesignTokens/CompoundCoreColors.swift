//
// CompoundCoreColors.swift
// Unified core color palette - UIColor as source of truth, Color derived from it
//

import SwiftUI
import UIKit

// MARK: - UIColor (Source of Truth)

public class CompoundCoreUIColorTokens {
    public static let themeBg = UIColor(named: "themeBg", in: Bundle.module, compatibleWith: nil)!
    public static let gray100 = UIColor(named: "gray100", in: Bundle.module, compatibleWith: nil)!
    public static let gray200 = UIColor(named: "gray200", in: Bundle.module, compatibleWith: nil)!
    public static let gray300 = UIColor(named: "gray300", in: Bundle.module, compatibleWith: nil)!
    public static let gray400 = UIColor(named: "gray400", in: Bundle.module, compatibleWith: nil)!
    public static let gray500 = UIColor(named: "gray500", in: Bundle.module, compatibleWith: nil)!
    public static let gray600 = UIColor(named: "gray600", in: Bundle.module, compatibleWith: nil)!
    public static let gray700 = UIColor(named: "gray700", in: Bundle.module, compatibleWith: nil)!
    public static let gray800 = UIColor(named: "gray800", in: Bundle.module, compatibleWith: nil)!
    public static let gray900 = UIColor(named: "gray900", in: Bundle.module, compatibleWith: nil)!
    public static let gray1000 = UIColor(named: "gray1000", in: Bundle.module, compatibleWith: nil)!
    public static let gray1100 = UIColor(named: "gray1100", in: Bundle.module, compatibleWith: nil)!
    public static let gray1200 = UIColor(named: "gray1200", in: Bundle.module, compatibleWith: nil)!
    public static let gray1300 = UIColor(named: "gray1300", in: Bundle.module, compatibleWith: nil)!
    public static let gray1400 = UIColor(named: "gray1400", in: Bundle.module, compatibleWith: nil)!
    public static let red100 = UIColor(named: "red100", in: Bundle.module, compatibleWith: nil)!
    public static let red200 = UIColor(named: "red200", in: Bundle.module, compatibleWith: nil)!
    public static let red300 = UIColor(named: "red300", in: Bundle.module, compatibleWith: nil)!
    public static let red400 = UIColor(named: "red400", in: Bundle.module, compatibleWith: nil)!
    public static let red500 = UIColor(named: "red500", in: Bundle.module, compatibleWith: nil)!
    public static let red600 = UIColor(named: "red600", in: Bundle.module, compatibleWith: nil)!
    public static let red700 = UIColor(named: "red700", in: Bundle.module, compatibleWith: nil)!
    public static let red800 = UIColor(named: "red800", in: Bundle.module, compatibleWith: nil)!
    public static let red900 = UIColor(named: "red900", in: Bundle.module, compatibleWith: nil)!
    public static let red1000 = UIColor(named: "red1000", in: Bundle.module, compatibleWith: nil)!
    public static let red1100 = UIColor(named: "red1100", in: Bundle.module, compatibleWith: nil)!
    public static let red1200 = UIColor(named: "red1200", in: Bundle.module, compatibleWith: nil)!
    public static let red1300 = UIColor(named: "red1300", in: Bundle.module, compatibleWith: nil)!
    public static let red1400 = UIColor(named: "red1400", in: Bundle.module, compatibleWith: nil)!
    public static let orange100 = UIColor(named: "orange100", in: Bundle.module, compatibleWith: nil)!
    public static let orange200 = UIColor(named: "orange200", in: Bundle.module, compatibleWith: nil)!
    public static let orange300 = UIColor(named: "orange300", in: Bundle.module, compatibleWith: nil)!
    public static let orange400 = UIColor(named: "orange400", in: Bundle.module, compatibleWith: nil)!
    public static let orange500 = UIColor(named: "orange500", in: Bundle.module, compatibleWith: nil)!
    public static let orange600 = UIColor(named: "orange600", in: Bundle.module, compatibleWith: nil)!
    public static let orange700 = UIColor(named: "orange700", in: Bundle.module, compatibleWith: nil)!
    public static let orange800 = UIColor(named: "orange800", in: Bundle.module, compatibleWith: nil)!
    public static let orange900 = UIColor(named: "orange900", in: Bundle.module, compatibleWith: nil)!
    public static let orange1000 = UIColor(named: "orange1000", in: Bundle.module, compatibleWith: nil)!
    public static let orange1100 = UIColor(named: "orange1100", in: Bundle.module, compatibleWith: nil)!
    public static let orange1200 = UIColor(named: "orange1200", in: Bundle.module, compatibleWith: nil)!
    public static let orange1300 = UIColor(named: "orange1300", in: Bundle.module, compatibleWith: nil)!
    public static let orange1400 = UIColor(named: "orange1400", in: Bundle.module, compatibleWith: nil)!
    public static let yellow100 = UIColor(named: "yellow100", in: Bundle.module, compatibleWith: nil)!
    public static let yellow200 = UIColor(named: "yellow200", in: Bundle.module, compatibleWith: nil)!
    public static let yellow300 = UIColor(named: "yellow300", in: Bundle.module, compatibleWith: nil)!
    public static let yellow400 = UIColor(named: "yellow400", in: Bundle.module, compatibleWith: nil)!
    public static let yellow500 = UIColor(named: "yellow500", in: Bundle.module, compatibleWith: nil)!
    public static let yellow600 = UIColor(named: "yellow600", in: Bundle.module, compatibleWith: nil)!
    public static let yellow700 = UIColor(named: "yellow700", in: Bundle.module, compatibleWith: nil)!
    public static let yellow800 = UIColor(named: "yellow800", in: Bundle.module, compatibleWith: nil)!
    public static let yellow900 = UIColor(named: "yellow900", in: Bundle.module, compatibleWith: nil)!
    public static let yellow1000 = UIColor(named: "yellow1000", in: Bundle.module, compatibleWith: nil)!
    public static let yellow1100 = UIColor(named: "yellow1100", in: Bundle.module, compatibleWith: nil)!
    public static let yellow1200 = UIColor(named: "yellow1200", in: Bundle.module, compatibleWith: nil)!
    public static let yellow1300 = UIColor(named: "yellow1300", in: Bundle.module, compatibleWith: nil)!
    public static let yellow1400 = UIColor(named: "yellow1400", in: Bundle.module, compatibleWith: nil)!
    public static let lime100 = UIColor(named: "lime100", in: Bundle.module, compatibleWith: nil)!
    public static let lime200 = UIColor(named: "lime200", in: Bundle.module, compatibleWith: nil)!
    public static let lime300 = UIColor(named: "lime300", in: Bundle.module, compatibleWith: nil)!
    public static let lime400 = UIColor(named: "lime400", in: Bundle.module, compatibleWith: nil)!
    public static let lime500 = UIColor(named: "lime500", in: Bundle.module, compatibleWith: nil)!
    public static let lime600 = UIColor(named: "lime600", in: Bundle.module, compatibleWith: nil)!
    public static let lime700 = UIColor(named: "lime700", in: Bundle.module, compatibleWith: nil)!
    public static let lime800 = UIColor(named: "lime800", in: Bundle.module, compatibleWith: nil)!
    public static let lime900 = UIColor(named: "lime900", in: Bundle.module, compatibleWith: nil)!
    public static let lime1000 = UIColor(named: "lime1000", in: Bundle.module, compatibleWith: nil)!
    public static let lime1100 = UIColor(named: "lime1100", in: Bundle.module, compatibleWith: nil)!
    public static let lime1200 = UIColor(named: "lime1200", in: Bundle.module, compatibleWith: nil)!
    public static let lime1300 = UIColor(named: "lime1300", in: Bundle.module, compatibleWith: nil)!
    public static let lime1400 = UIColor(named: "lime1400", in: Bundle.module, compatibleWith: nil)!
    public static let green100 = UIColor(named: "green100", in: Bundle.module, compatibleWith: nil)!
    public static let green200 = UIColor(named: "green200", in: Bundle.module, compatibleWith: nil)!
    public static let green300 = UIColor(named: "green300", in: Bundle.module, compatibleWith: nil)!
    public static let green400 = UIColor(named: "green400", in: Bundle.module, compatibleWith: nil)!
    public static let green500 = UIColor(named: "green500", in: Bundle.module, compatibleWith: nil)!
    public static let green600 = UIColor(named: "green600", in: Bundle.module, compatibleWith: nil)!
    public static let green700 = UIColor(named: "green700", in: Bundle.module, compatibleWith: nil)!
    public static let green800 = UIColor(named: "green800", in: Bundle.module, compatibleWith: nil)!
    public static let green900 = UIColor(named: "green900", in: Bundle.module, compatibleWith: nil)!
    public static let green1000 = UIColor(named: "green1000", in: Bundle.module, compatibleWith: nil)!
    public static let green1100 = UIColor(named: "green1100", in: Bundle.module, compatibleWith: nil)!
    public static let green1200 = UIColor(named: "green1200", in: Bundle.module, compatibleWith: nil)!
    public static let green1300 = UIColor(named: "green1300", in: Bundle.module, compatibleWith: nil)!
    public static let green1400 = UIColor(named: "green1400", in: Bundle.module, compatibleWith: nil)!
    public static let cyan100 = UIColor(named: "cyan100", in: Bundle.module, compatibleWith: nil)!
    public static let cyan200 = UIColor(named: "cyan200", in: Bundle.module, compatibleWith: nil)!
    public static let cyan300 = UIColor(named: "cyan300", in: Bundle.module, compatibleWith: nil)!
    public static let cyan400 = UIColor(named: "cyan400", in: Bundle.module, compatibleWith: nil)!
    public static let cyan500 = UIColor(named: "cyan500", in: Bundle.module, compatibleWith: nil)!
    public static let cyan600 = UIColor(named: "cyan600", in: Bundle.module, compatibleWith: nil)!
    public static let cyan700 = UIColor(named: "cyan700", in: Bundle.module, compatibleWith: nil)!
    public static let cyan800 = UIColor(named: "cyan800", in: Bundle.module, compatibleWith: nil)!
    public static let cyan900 = UIColor(named: "cyan900", in: Bundle.module, compatibleWith: nil)!
    public static let cyan1000 = UIColor(named: "cyan1000", in: Bundle.module, compatibleWith: nil)!
    public static let cyan1100 = UIColor(named: "cyan1100", in: Bundle.module, compatibleWith: nil)!
    public static let cyan1200 = UIColor(named: "cyan1200", in: Bundle.module, compatibleWith: nil)!
    public static let cyan1300 = UIColor(named: "cyan1300", in: Bundle.module, compatibleWith: nil)!
    public static let cyan1400 = UIColor(named: "cyan1400", in: Bundle.module, compatibleWith: nil)!
    public static let blue100 = UIColor(named: "blue100", in: Bundle.module, compatibleWith: nil)!
    public static let blue200 = UIColor(named: "blue200", in: Bundle.module, compatibleWith: nil)!
    public static let blue300 = UIColor(named: "blue300", in: Bundle.module, compatibleWith: nil)!
    public static let blue400 = UIColor(named: "blue400", in: Bundle.module, compatibleWith: nil)!
    public static let blue500 = UIColor(named: "blue500", in: Bundle.module, compatibleWith: nil)!
    public static let blue600 = UIColor(named: "blue600", in: Bundle.module, compatibleWith: nil)!
    public static let blue700 = UIColor(named: "blue700", in: Bundle.module, compatibleWith: nil)!
    public static let blue800 = UIColor(named: "blue800", in: Bundle.module, compatibleWith: nil)!
    public static let blue900 = UIColor(named: "blue900", in: Bundle.module, compatibleWith: nil)!
    public static let blue1000 = UIColor(named: "blue1000", in: Bundle.module, compatibleWith: nil)!
    public static let blue1100 = UIColor(named: "blue1100", in: Bundle.module, compatibleWith: nil)!
    public static let blue1200 = UIColor(named: "blue1200", in: Bundle.module, compatibleWith: nil)!
    public static let blue1300 = UIColor(named: "blue1300", in: Bundle.module, compatibleWith: nil)!
    public static let blue1400 = UIColor(named: "blue1400", in: Bundle.module, compatibleWith: nil)!
    public static let purple100 = UIColor(named: "purple100", in: Bundle.module, compatibleWith: nil)!
    public static let purple200 = UIColor(named: "purple200", in: Bundle.module, compatibleWith: nil)!
    public static let purple300 = UIColor(named: "purple300", in: Bundle.module, compatibleWith: nil)!
    public static let purple400 = UIColor(named: "purple400", in: Bundle.module, compatibleWith: nil)!
    public static let purple500 = UIColor(named: "purple500", in: Bundle.module, compatibleWith: nil)!
    public static let purple600 = UIColor(named: "purple600", in: Bundle.module, compatibleWith: nil)!
    public static let purple700 = UIColor(named: "purple700", in: Bundle.module, compatibleWith: nil)!
    public static let purple800 = UIColor(named: "purple800", in: Bundle.module, compatibleWith: nil)!
    public static let purple900 = UIColor(named: "purple900", in: Bundle.module, compatibleWith: nil)!
    public static let purple1000 = UIColor(named: "purple1000", in: Bundle.module, compatibleWith: nil)!
    public static let purple1100 = UIColor(named: "purple1100", in: Bundle.module, compatibleWith: nil)!
    public static let purple1200 = UIColor(named: "purple1200", in: Bundle.module, compatibleWith: nil)!
    public static let purple1300 = UIColor(named: "purple1300", in: Bundle.module, compatibleWith: nil)!
    public static let purple1400 = UIColor(named: "purple1400", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia100 = UIColor(named: "fuchsia100", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia200 = UIColor(named: "fuchsia200", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia300 = UIColor(named: "fuchsia300", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia400 = UIColor(named: "fuchsia400", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia500 = UIColor(named: "fuchsia500", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia600 = UIColor(named: "fuchsia600", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia700 = UIColor(named: "fuchsia700", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia800 = UIColor(named: "fuchsia800", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia900 = UIColor(named: "fuchsia900", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia1000 = UIColor(named: "fuchsia1000", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia1100 = UIColor(named: "fuchsia1100", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia1200 = UIColor(named: "fuchsia1200", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia1300 = UIColor(named: "fuchsia1300", in: Bundle.module, compatibleWith: nil)!
    public static let fuchsia1400 = UIColor(named: "fuchsia1400", in: Bundle.module, compatibleWith: nil)!
    public static let pink100 = UIColor(named: "pink100", in: Bundle.module, compatibleWith: nil)!
    public static let pink200 = UIColor(named: "pink200", in: Bundle.module, compatibleWith: nil)!
    public static let pink300 = UIColor(named: "pink300", in: Bundle.module, compatibleWith: nil)!
    public static let pink400 = UIColor(named: "pink400", in: Bundle.module, compatibleWith: nil)!
    public static let pink500 = UIColor(named: "pink500", in: Bundle.module, compatibleWith: nil)!
    public static let pink600 = UIColor(named: "pink600", in: Bundle.module, compatibleWith: nil)!
    public static let pink700 = UIColor(named: "pink700", in: Bundle.module, compatibleWith: nil)!
    public static let pink800 = UIColor(named: "pink800", in: Bundle.module, compatibleWith: nil)!
    public static let pink900 = UIColor(named: "pink900", in: Bundle.module, compatibleWith: nil)!
    public static let pink1000 = UIColor(named: "pink1000", in: Bundle.module, compatibleWith: nil)!
    public static let pink1100 = UIColor(named: "pink1100", in: Bundle.module, compatibleWith: nil)!
    public static let pink1200 = UIColor(named: "pink1200", in: Bundle.module, compatibleWith: nil)!
    public static let pink1300 = UIColor(named: "pink1300", in: Bundle.module, compatibleWith: nil)!
    public static let pink1400 = UIColor(named: "pink1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray100 = UIColor(named: "alphaGray100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray200 = UIColor(named: "alphaGray200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray300 = UIColor(named: "alphaGray300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray400 = UIColor(named: "alphaGray400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray500 = UIColor(named: "alphaGray500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray600 = UIColor(named: "alphaGray600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray700 = UIColor(named: "alphaGray700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray800 = UIColor(named: "alphaGray800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray900 = UIColor(named: "alphaGray900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray1000 = UIColor(named: "alphaGray1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray1100 = UIColor(named: "alphaGray1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray1200 = UIColor(named: "alphaGray1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray1300 = UIColor(named: "alphaGray1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGray1400 = UIColor(named: "alphaGray1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed100 = UIColor(named: "alphaRed100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed200 = UIColor(named: "alphaRed200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed300 = UIColor(named: "alphaRed300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed400 = UIColor(named: "alphaRed400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed500 = UIColor(named: "alphaRed500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed600 = UIColor(named: "alphaRed600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed700 = UIColor(named: "alphaRed700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed800 = UIColor(named: "alphaRed800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed900 = UIColor(named: "alphaRed900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed1000 = UIColor(named: "alphaRed1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed1100 = UIColor(named: "alphaRed1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed1200 = UIColor(named: "alphaRed1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed1300 = UIColor(named: "alphaRed1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaRed1400 = UIColor(named: "alphaRed1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange100 = UIColor(named: "alphaOrange100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange200 = UIColor(named: "alphaOrange200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange300 = UIColor(named: "alphaOrange300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange400 = UIColor(named: "alphaOrange400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange500 = UIColor(named: "alphaOrange500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange600 = UIColor(named: "alphaOrange600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange700 = UIColor(named: "alphaOrange700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange800 = UIColor(named: "alphaOrange800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange900 = UIColor(named: "alphaOrange900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange1000 = UIColor(named: "alphaOrange1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange1100 = UIColor(named: "alphaOrange1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange1200 = UIColor(named: "alphaOrange1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange1300 = UIColor(named: "alphaOrange1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaOrange1400 = UIColor(named: "alphaOrange1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow100 = UIColor(named: "alphaYellow100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow200 = UIColor(named: "alphaYellow200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow300 = UIColor(named: "alphaYellow300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow400 = UIColor(named: "alphaYellow400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow500 = UIColor(named: "alphaYellow500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow600 = UIColor(named: "alphaYellow600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow700 = UIColor(named: "alphaYellow700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow800 = UIColor(named: "alphaYellow800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow900 = UIColor(named: "alphaYellow900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow1000 = UIColor(named: "alphaYellow1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow1100 = UIColor(named: "alphaYellow1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow1200 = UIColor(named: "alphaYellow1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow1300 = UIColor(named: "alphaYellow1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaYellow1400 = UIColor(named: "alphaYellow1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime100 = UIColor(named: "alphaLime100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime200 = UIColor(named: "alphaLime200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime300 = UIColor(named: "alphaLime300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime400 = UIColor(named: "alphaLime400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime500 = UIColor(named: "alphaLime500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime600 = UIColor(named: "alphaLime600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime700 = UIColor(named: "alphaLime700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime800 = UIColor(named: "alphaLime800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime900 = UIColor(named: "alphaLime900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime1000 = UIColor(named: "alphaLime1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime1100 = UIColor(named: "alphaLime1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime1200 = UIColor(named: "alphaLime1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime1300 = UIColor(named: "alphaLime1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaLime1400 = UIColor(named: "alphaLime1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen100 = UIColor(named: "alphaGreen100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen200 = UIColor(named: "alphaGreen200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen300 = UIColor(named: "alphaGreen300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen400 = UIColor(named: "alphaGreen400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen500 = UIColor(named: "alphaGreen500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen600 = UIColor(named: "alphaGreen600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen700 = UIColor(named: "alphaGreen700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen800 = UIColor(named: "alphaGreen800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen900 = UIColor(named: "alphaGreen900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen1000 = UIColor(named: "alphaGreen1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen1100 = UIColor(named: "alphaGreen1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen1200 = UIColor(named: "alphaGreen1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen1300 = UIColor(named: "alphaGreen1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaGreen1400 = UIColor(named: "alphaGreen1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan100 = UIColor(named: "alphaCyan100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan200 = UIColor(named: "alphaCyan200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan300 = UIColor(named: "alphaCyan300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan400 = UIColor(named: "alphaCyan400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan500 = UIColor(named: "alphaCyan500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan600 = UIColor(named: "alphaCyan600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan700 = UIColor(named: "alphaCyan700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan800 = UIColor(named: "alphaCyan800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan900 = UIColor(named: "alphaCyan900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan1000 = UIColor(named: "alphaCyan1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan1100 = UIColor(named: "alphaCyan1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan1200 = UIColor(named: "alphaCyan1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan1300 = UIColor(named: "alphaCyan1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaCyan1400 = UIColor(named: "alphaCyan1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue100 = UIColor(named: "alphaBlue100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue200 = UIColor(named: "alphaBlue200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue300 = UIColor(named: "alphaBlue300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue400 = UIColor(named: "alphaBlue400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue500 = UIColor(named: "alphaBlue500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue600 = UIColor(named: "alphaBlue600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue700 = UIColor(named: "alphaBlue700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue800 = UIColor(named: "alphaBlue800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue900 = UIColor(named: "alphaBlue900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue1000 = UIColor(named: "alphaBlue1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue1100 = UIColor(named: "alphaBlue1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue1200 = UIColor(named: "alphaBlue1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue1300 = UIColor(named: "alphaBlue1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaBlue1400 = UIColor(named: "alphaBlue1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple100 = UIColor(named: "alphaPurple100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple200 = UIColor(named: "alphaPurple200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple300 = UIColor(named: "alphaPurple300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple400 = UIColor(named: "alphaPurple400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple500 = UIColor(named: "alphaPurple500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple600 = UIColor(named: "alphaPurple600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple700 = UIColor(named: "alphaPurple700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple800 = UIColor(named: "alphaPurple800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple900 = UIColor(named: "alphaPurple900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple1000 = UIColor(named: "alphaPurple1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple1100 = UIColor(named: "alphaPurple1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple1200 = UIColor(named: "alphaPurple1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple1300 = UIColor(named: "alphaPurple1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPurple1400 = UIColor(named: "alphaPurple1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia100 = UIColor(named: "alphaFuchsia100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia200 = UIColor(named: "alphaFuchsia200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia300 = UIColor(named: "alphaFuchsia300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia400 = UIColor(named: "alphaFuchsia400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia500 = UIColor(named: "alphaFuchsia500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia600 = UIColor(named: "alphaFuchsia600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia700 = UIColor(named: "alphaFuchsia700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia800 = UIColor(named: "alphaFuchsia800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia900 = UIColor(named: "alphaFuchsia900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia1000 = UIColor(named: "alphaFuchsia1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia1100 = UIColor(named: "alphaFuchsia1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia1200 = UIColor(named: "alphaFuchsia1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia1300 = UIColor(named: "alphaFuchsia1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaFuchsia1400 = UIColor(named: "alphaFuchsia1400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink100 = UIColor(named: "alphaPink100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink200 = UIColor(named: "alphaPink200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink300 = UIColor(named: "alphaPink300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink400 = UIColor(named: "alphaPink400", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink500 = UIColor(named: "alphaPink500", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink600 = UIColor(named: "alphaPink600", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink700 = UIColor(named: "alphaPink700", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink800 = UIColor(named: "alphaPink800", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink900 = UIColor(named: "alphaPink900", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink1000 = UIColor(named: "alphaPink1000", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink1100 = UIColor(named: "alphaPink1100", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink1200 = UIColor(named: "alphaPink1200", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink1300 = UIColor(named: "alphaPink1300", in: Bundle.module, compatibleWith: nil)!
    public static let alphaPink1400 = UIColor(named: "alphaPink1400", in: Bundle.module, compatibleWith: nil)!
    public static let transparent = UIColor(named: "transparent", in: Bundle.module, compatibleWith: nil)!
    
    // MARK: - Clap Custom Colors (Dynamic UIColors that respond to trait changes)
    public static var clapThemeBg: UIColor { UIColor(named: "clapThemeBg", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgBubbleIncoming: UIColor { UIColor(named: "clapBgBubbleIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgBubbleOutgoing: UIColor { UIColor(named: "clapBgBubbleOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgSubtleSecondary: UIColor { UIColor(named: "clapBgSubtleSecondary", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextPrimary: UIColor { UIColor(named: "clapTextPrimary", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextSecondary: UIColor { UIColor(named: "clapTextSecondary", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextBubbleOutgoing: UIColor { UIColor(named: "clapTextBubbleOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextBubbleIncoming: UIColor { UIColor(named: "clapTextBubbleIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextBubbleSecondaryOutgoing: UIColor { UIColor(named: "clapTextBubbleSecondaryOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextBubbleSecondaryIncoming: UIColor { UIColor(named: "clapTextBubbleSecondaryIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapIconBubbleOutgoing: UIColor { UIColor(named: "clapIconBubbleOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapIconBubbleIncoming: UIColor { UIColor(named: "clapIconBubbleIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapIconAccentTertiary: UIColor { UIColor(named: "clapIconAccentTertiary", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgPollProgressEmptyOutgoing: UIColor { UIColor(named: "clapBgPollProgressEmptyOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgPollProgressEmptyIncoming: UIColor { UIColor(named: "clapBgPollProgressEmptyIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgPollProgressFilledOutgoing: UIColor { UIColor(named: "clapBgPollProgressFilledOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgPollProgressFilledIncoming: UIColor { UIColor(named: "clapBgPollProgressFilledIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextBadgeAccent: UIColor { UIColor(named: "clapTextBadgeAccent", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgBadgeAccent: UIColor { UIColor(named: "clapBgBadgeAccent", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgCodeBlockOutgoing: UIColor { UIColor(named: "clapBgCodeBlockOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgCodeBlockIncoming: UIColor { UIColor(named: "clapBgCodeBlockIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextCodeBlockOutgoing: UIColor { UIColor(named: "clapTextCodeBlockOutgoing", in: Bundle.module, compatibleWith: nil)! }
    public static var clapTextCodeBlockIncoming: UIColor { UIColor(named: "clapTextCodeBlockIncoming", in: Bundle.module, compatibleWith: nil)! }
    public static var clapBgBadgeDefault: UIColor { UIColor(named: "clapBgBadgeDefault", in: Bundle.module, compatibleWith: nil)! }
    public static var clapRoomBg: UIColor { UIColor(named: "clapRoomBg", in: Bundle.module, compatibleWith: nil)! }
}

// MARK: - SwiftUI Color (Derived from UIColor)

public class CompoundCoreColorTokens {
    public static var themeBg: Color { Color(uiColor: CompoundCoreUIColorTokens.themeBg) }
    public static var gray100: Color { Color(uiColor: CompoundCoreUIColorTokens.gray100) }
    public static var gray200: Color { Color(uiColor: CompoundCoreUIColorTokens.gray200) }
    public static var gray300: Color { Color(uiColor: CompoundCoreUIColorTokens.gray300) }
    public static var gray400: Color { Color(uiColor: CompoundCoreUIColorTokens.gray400) }
    public static var gray500: Color { Color(uiColor: CompoundCoreUIColorTokens.gray500) }
    public static var gray600: Color { Color(uiColor: CompoundCoreUIColorTokens.gray600) }
    public static var gray700: Color { Color(uiColor: CompoundCoreUIColorTokens.gray700) }
    public static var gray800: Color { Color(uiColor: CompoundCoreUIColorTokens.gray800) }
    public static var gray900: Color { Color(uiColor: CompoundCoreUIColorTokens.gray900) }
    public static var gray1000: Color { Color(uiColor: CompoundCoreUIColorTokens.gray1000) }
    public static var gray1100: Color { Color(uiColor: CompoundCoreUIColorTokens.gray1100) }
    public static var gray1200: Color { Color(uiColor: CompoundCoreUIColorTokens.gray1200) }
    public static var gray1300: Color { Color(uiColor: CompoundCoreUIColorTokens.gray1300) }
    public static var gray1400: Color { Color(uiColor: CompoundCoreUIColorTokens.gray1400) }
    public static var red100: Color { Color(uiColor: CompoundCoreUIColorTokens.red100) }
    public static var red200: Color { Color(uiColor: CompoundCoreUIColorTokens.red200) }
    public static var red300: Color { Color(uiColor: CompoundCoreUIColorTokens.red300) }
    public static var red400: Color { Color(uiColor: CompoundCoreUIColorTokens.red400) }
    public static var red500: Color { Color(uiColor: CompoundCoreUIColorTokens.red500) }
    public static var red600: Color { Color(uiColor: CompoundCoreUIColorTokens.red600) }
    public static var red700: Color { Color(uiColor: CompoundCoreUIColorTokens.red700) }
    public static var red800: Color { Color(uiColor: CompoundCoreUIColorTokens.red800) }
    public static var red900: Color { Color(uiColor: CompoundCoreUIColorTokens.red900) }
    public static var red1000: Color { Color(uiColor: CompoundCoreUIColorTokens.red1000) }
    public static var red1100: Color { Color(uiColor: CompoundCoreUIColorTokens.red1100) }
    public static var red1200: Color { Color(uiColor: CompoundCoreUIColorTokens.red1200) }
    public static var red1300: Color { Color(uiColor: CompoundCoreUIColorTokens.red1300) }
    public static var red1400: Color { Color(uiColor: CompoundCoreUIColorTokens.red1400) }
    public static var orange100: Color { Color(uiColor: CompoundCoreUIColorTokens.orange100) }
    public static var orange200: Color { Color(uiColor: CompoundCoreUIColorTokens.orange200) }
    public static var orange300: Color { Color(uiColor: CompoundCoreUIColorTokens.orange300) }
    public static var orange400: Color { Color(uiColor: CompoundCoreUIColorTokens.orange400) }
    public static var orange500: Color { Color(uiColor: CompoundCoreUIColorTokens.orange500) }
    public static var orange600: Color { Color(uiColor: CompoundCoreUIColorTokens.orange600) }
    public static var orange700: Color { Color(uiColor: CompoundCoreUIColorTokens.orange700) }
    public static var orange800: Color { Color(uiColor: CompoundCoreUIColorTokens.orange800) }
    public static var orange900: Color { Color(uiColor: CompoundCoreUIColorTokens.orange900) }
    public static var orange1000: Color { Color(uiColor: CompoundCoreUIColorTokens.orange1000) }
    public static var orange1100: Color { Color(uiColor: CompoundCoreUIColorTokens.orange1100) }
    public static var orange1200: Color { Color(uiColor: CompoundCoreUIColorTokens.orange1200) }
    public static var orange1300: Color { Color(uiColor: CompoundCoreUIColorTokens.orange1300) }
    public static var orange1400: Color { Color(uiColor: CompoundCoreUIColorTokens.orange1400) }
    public static var yellow100: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow100) }
    public static var yellow200: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow200) }
    public static var yellow300: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow300) }
    public static var yellow400: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow400) }
    public static var yellow500: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow500) }
    public static var yellow600: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow600) }
    public static var yellow700: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow700) }
    public static var yellow800: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow800) }
    public static var yellow900: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow900) }
    public static var yellow1000: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow1000) }
    public static var yellow1100: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow1100) }
    public static var yellow1200: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow1200) }
    public static var yellow1300: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow1300) }
    public static var yellow1400: Color { Color(uiColor: CompoundCoreUIColorTokens.yellow1400) }
    public static var lime100: Color { Color(uiColor: CompoundCoreUIColorTokens.lime100) }
    public static var lime200: Color { Color(uiColor: CompoundCoreUIColorTokens.lime200) }
    public static var lime300: Color { Color(uiColor: CompoundCoreUIColorTokens.lime300) }
    public static var lime400: Color { Color(uiColor: CompoundCoreUIColorTokens.lime400) }
    public static var lime500: Color { Color(uiColor: CompoundCoreUIColorTokens.lime500) }
    public static var lime600: Color { Color(uiColor: CompoundCoreUIColorTokens.lime600) }
    public static var lime700: Color { Color(uiColor: CompoundCoreUIColorTokens.lime700) }
    public static var lime800: Color { Color(uiColor: CompoundCoreUIColorTokens.lime800) }
    public static var lime900: Color { Color(uiColor: CompoundCoreUIColorTokens.lime900) }
    public static var lime1000: Color { Color(uiColor: CompoundCoreUIColorTokens.lime1000) }
    public static var lime1100: Color { Color(uiColor: CompoundCoreUIColorTokens.lime1100) }
    public static var lime1200: Color { Color(uiColor: CompoundCoreUIColorTokens.lime1200) }
    public static var lime1300: Color { Color(uiColor: CompoundCoreUIColorTokens.lime1300) }
    public static var lime1400: Color { Color(uiColor: CompoundCoreUIColorTokens.lime1400) }
    public static var green100: Color { Color(uiColor: CompoundCoreUIColorTokens.green100) }
    public static var green200: Color { Color(uiColor: CompoundCoreUIColorTokens.green200) }
    public static var green300: Color { Color(uiColor: CompoundCoreUIColorTokens.green300) }
    public static var green400: Color { Color(uiColor: CompoundCoreUIColorTokens.green400) }
    public static var green500: Color { Color(uiColor: CompoundCoreUIColorTokens.green500) }
    public static var green600: Color { Color(uiColor: CompoundCoreUIColorTokens.green600) }
    public static var green700: Color { Color(uiColor: CompoundCoreUIColorTokens.green700) }
    public static var green800: Color { Color(uiColor: CompoundCoreUIColorTokens.green800) }
    public static var green900: Color { Color(uiColor: CompoundCoreUIColorTokens.green900) }
    public static var green1000: Color { Color(uiColor: CompoundCoreUIColorTokens.green1000) }
    public static var green1100: Color { Color(uiColor: CompoundCoreUIColorTokens.green1100) }
    public static var green1200: Color { Color(uiColor: CompoundCoreUIColorTokens.green1200) }
    public static var green1300: Color { Color(uiColor: CompoundCoreUIColorTokens.green1300) }
    public static var green1400: Color { Color(uiColor: CompoundCoreUIColorTokens.green1400) }
    public static var cyan100: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan100) }
    public static var cyan200: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan200) }
    public static var cyan300: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan300) }
    public static var cyan400: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan400) }
    public static var cyan500: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan500) }
    public static var cyan600: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan600) }
    public static var cyan700: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan700) }
    public static var cyan800: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan800) }
    public static var cyan900: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan900) }
    public static var cyan1000: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan1000) }
    public static var cyan1100: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan1100) }
    public static var cyan1200: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan1200) }
    public static var cyan1300: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan1300) }
    public static var cyan1400: Color { Color(uiColor: CompoundCoreUIColorTokens.cyan1400) }
    public static var blue100: Color { Color(uiColor: CompoundCoreUIColorTokens.blue100) }
    public static var blue200: Color { Color(uiColor: CompoundCoreUIColorTokens.blue200) }
    public static var blue300: Color { Color(uiColor: CompoundCoreUIColorTokens.blue300) }
    public static var blue400: Color { Color(uiColor: CompoundCoreUIColorTokens.blue400) }
    public static var blue500: Color { Color(uiColor: CompoundCoreUIColorTokens.blue500) }
    public static var blue600: Color { Color(uiColor: CompoundCoreUIColorTokens.blue600) }
    public static var blue700: Color { Color(uiColor: CompoundCoreUIColorTokens.blue700) }
    public static var blue800: Color { Color(uiColor: CompoundCoreUIColorTokens.blue800) }
    public static var blue900: Color { Color(uiColor: CompoundCoreUIColorTokens.blue900) }
    public static var blue1000: Color { Color(uiColor: CompoundCoreUIColorTokens.blue1000) }
    public static var blue1100: Color { Color(uiColor: CompoundCoreUIColorTokens.blue1100) }
    public static var blue1200: Color { Color(uiColor: CompoundCoreUIColorTokens.blue1200) }
    public static var blue1300: Color { Color(uiColor: CompoundCoreUIColorTokens.blue1300) }
    public static var blue1400: Color { Color(uiColor: CompoundCoreUIColorTokens.blue1400) }
    public static var purple100: Color { Color(uiColor: CompoundCoreUIColorTokens.purple100) }
    public static var purple200: Color { Color(uiColor: CompoundCoreUIColorTokens.purple200) }
    public static var purple300: Color { Color(uiColor: CompoundCoreUIColorTokens.purple300) }
    public static var purple400: Color { Color(uiColor: CompoundCoreUIColorTokens.purple400) }
    public static var purple500: Color { Color(uiColor: CompoundCoreUIColorTokens.purple500) }
    public static var purple600: Color { Color(uiColor: CompoundCoreUIColorTokens.purple600) }
    public static var purple700: Color { Color(uiColor: CompoundCoreUIColorTokens.purple700) }
    public static var purple800: Color { Color(uiColor: CompoundCoreUIColorTokens.purple800) }
    public static var purple900: Color { Color(uiColor: CompoundCoreUIColorTokens.purple900) }
    public static var purple1000: Color { Color(uiColor: CompoundCoreUIColorTokens.purple1000) }
    public static var purple1100: Color { Color(uiColor: CompoundCoreUIColorTokens.purple1100) }
    public static var purple1200: Color { Color(uiColor: CompoundCoreUIColorTokens.purple1200) }
    public static var purple1300: Color { Color(uiColor: CompoundCoreUIColorTokens.purple1300) }
    public static var purple1400: Color { Color(uiColor: CompoundCoreUIColorTokens.purple1400) }
    public static var fuchsia100: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia100) }
    public static var fuchsia200: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia200) }
    public static var fuchsia300: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia300) }
    public static var fuchsia400: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia400) }
    public static var fuchsia500: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia500) }
    public static var fuchsia600: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia600) }
    public static var fuchsia700: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia700) }
    public static var fuchsia800: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia800) }
    public static var fuchsia900: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia900) }
    public static var fuchsia1000: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia1000) }
    public static var fuchsia1100: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia1100) }
    public static var fuchsia1200: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia1200) }
    public static var fuchsia1300: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia1300) }
    public static var fuchsia1400: Color { Color(uiColor: CompoundCoreUIColorTokens.fuchsia1400) }
    public static var pink100: Color { Color(uiColor: CompoundCoreUIColorTokens.pink100) }
    public static var pink200: Color { Color(uiColor: CompoundCoreUIColorTokens.pink200) }
    public static var pink300: Color { Color(uiColor: CompoundCoreUIColorTokens.pink300) }
    public static var pink400: Color { Color(uiColor: CompoundCoreUIColorTokens.pink400) }
    public static var pink500: Color { Color(uiColor: CompoundCoreUIColorTokens.pink500) }
    public static var pink600: Color { Color(uiColor: CompoundCoreUIColorTokens.pink600) }
    public static var pink700: Color { Color(uiColor: CompoundCoreUIColorTokens.pink700) }
    public static var pink800: Color { Color(uiColor: CompoundCoreUIColorTokens.pink800) }
    public static var pink900: Color { Color(uiColor: CompoundCoreUIColorTokens.pink900) }
    public static var pink1000: Color { Color(uiColor: CompoundCoreUIColorTokens.pink1000) }
    public static var pink1100: Color { Color(uiColor: CompoundCoreUIColorTokens.pink1100) }
    public static var pink1200: Color { Color(uiColor: CompoundCoreUIColorTokens.pink1200) }
    public static var pink1300: Color { Color(uiColor: CompoundCoreUIColorTokens.pink1300) }
    public static var pink1400: Color { Color(uiColor: CompoundCoreUIColorTokens.pink1400) }
    public static var alphaGray100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray100) }
    public static var alphaGray200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray200) }
    public static var alphaGray300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray300) }
    public static var alphaGray400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray400) }
    public static var alphaGray500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray500) }
    public static var alphaGray600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray600) }
    public static var alphaGray700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray700) }
    public static var alphaGray800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray800) }
    public static var alphaGray900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray900) }
    public static var alphaGray1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray1000) }
    public static var alphaGray1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray1100) }
    public static var alphaGray1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray1200) }
    public static var alphaGray1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray1300) }
    public static var alphaGray1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGray1400) }
    public static var alphaRed100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed100) }
    public static var alphaRed200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed200) }
    public static var alphaRed300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed300) }
    public static var alphaRed400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed400) }
    public static var alphaRed500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed500) }
    public static var alphaRed600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed600) }
    public static var alphaRed700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed700) }
    public static var alphaRed800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed800) }
    public static var alphaRed900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed900) }
    public static var alphaRed1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed1000) }
    public static var alphaRed1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed1100) }
    public static var alphaRed1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed1200) }
    public static var alphaRed1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed1300) }
    public static var alphaRed1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaRed1400) }
    public static var alphaOrange100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange100) }
    public static var alphaOrange200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange200) }
    public static var alphaOrange300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange300) }
    public static var alphaOrange400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange400) }
    public static var alphaOrange500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange500) }
    public static var alphaOrange600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange600) }
    public static var alphaOrange700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange700) }
    public static var alphaOrange800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange800) }
    public static var alphaOrange900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange900) }
    public static var alphaOrange1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange1000) }
    public static var alphaOrange1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange1100) }
    public static var alphaOrange1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange1200) }
    public static var alphaOrange1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange1300) }
    public static var alphaOrange1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaOrange1400) }
    public static var alphaYellow100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow100) }
    public static var alphaYellow200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow200) }
    public static var alphaYellow300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow300) }
    public static var alphaYellow400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow400) }
    public static var alphaYellow500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow500) }
    public static var alphaYellow600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow600) }
    public static var alphaYellow700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow700) }
    public static var alphaYellow800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow800) }
    public static var alphaYellow900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow900) }
    public static var alphaYellow1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow1000) }
    public static var alphaYellow1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow1100) }
    public static var alphaYellow1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow1200) }
    public static var alphaYellow1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow1300) }
    public static var alphaYellow1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaYellow1400) }
    public static var alphaLime100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime100) }
    public static var alphaLime200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime200) }
    public static var alphaLime300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime300) }
    public static var alphaLime400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime400) }
    public static var alphaLime500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime500) }
    public static var alphaLime600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime600) }
    public static var alphaLime700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime700) }
    public static var alphaLime800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime800) }
    public static var alphaLime900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime900) }
    public static var alphaLime1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime1000) }
    public static var alphaLime1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime1100) }
    public static var alphaLime1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime1200) }
    public static var alphaLime1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime1300) }
    public static var alphaLime1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaLime1400) }
    public static var alphaGreen100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen100) }
    public static var alphaGreen200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen200) }
    public static var alphaGreen300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen300) }
    public static var alphaGreen400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen400) }
    public static var alphaGreen500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen500) }
    public static var alphaGreen600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen600) }
    public static var alphaGreen700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen700) }
    public static var alphaGreen800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen800) }
    public static var alphaGreen900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen900) }
    public static var alphaGreen1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen1000) }
    public static var alphaGreen1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen1100) }
    public static var alphaGreen1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen1200) }
    public static var alphaGreen1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen1300) }
    public static var alphaGreen1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaGreen1400) }
    public static var alphaCyan100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan100) }
    public static var alphaCyan200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan200) }
    public static var alphaCyan300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan300) }
    public static var alphaCyan400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan400) }
    public static var alphaCyan500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan500) }
    public static var alphaCyan600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan600) }
    public static var alphaCyan700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan700) }
    public static var alphaCyan800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan800) }
    public static var alphaCyan900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan900) }
    public static var alphaCyan1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan1000) }
    public static var alphaCyan1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan1100) }
    public static var alphaCyan1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan1200) }
    public static var alphaCyan1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan1300) }
    public static var alphaCyan1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaCyan1400) }
    public static var alphaBlue100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue100) }
    public static var alphaBlue200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue200) }
    public static var alphaBlue300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue300) }
    public static var alphaBlue400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue400) }
    public static var alphaBlue500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue500) }
    public static var alphaBlue600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue600) }
    public static var alphaBlue700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue700) }
    public static var alphaBlue800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue800) }
    public static var alphaBlue900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue900) }
    public static var alphaBlue1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue1000) }
    public static var alphaBlue1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue1100) }
    public static var alphaBlue1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue1200) }
    public static var alphaBlue1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue1300) }
    public static var alphaBlue1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaBlue1400) }
    public static var alphaPurple100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple100) }
    public static var alphaPurple200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple200) }
    public static var alphaPurple300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple300) }
    public static var alphaPurple400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple400) }
    public static var alphaPurple500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple500) }
    public static var alphaPurple600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple600) }
    public static var alphaPurple700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple700) }
    public static var alphaPurple800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple800) }
    public static var alphaPurple900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple900) }
    public static var alphaPurple1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple1000) }
    public static var alphaPurple1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple1100) }
    public static var alphaPurple1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple1200) }
    public static var alphaPurple1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple1300) }
    public static var alphaPurple1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPurple1400) }
    public static var alphaFuchsia100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia100) }
    public static var alphaFuchsia200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia200) }
    public static var alphaFuchsia300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia300) }
    public static var alphaFuchsia400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia400) }
    public static var alphaFuchsia500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia500) }
    public static var alphaFuchsia600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia600) }
    public static var alphaFuchsia700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia700) }
    public static var alphaFuchsia800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia800) }
    public static var alphaFuchsia900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia900) }
    public static var alphaFuchsia1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia1000) }
    public static var alphaFuchsia1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia1100) }
    public static var alphaFuchsia1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia1200) }
    public static var alphaFuchsia1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia1300) }
    public static var alphaFuchsia1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaFuchsia1400) }
    public static var alphaPink100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink100) }
    public static var alphaPink200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink200) }
    public static var alphaPink300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink300) }
    public static var alphaPink400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink400) }
    public static var alphaPink500: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink500) }
    public static var alphaPink600: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink600) }
    public static var alphaPink700: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink700) }
    public static var alphaPink800: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink800) }
    public static var alphaPink900: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink900) }
    public static var alphaPink1000: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink1000) }
    public static var alphaPink1100: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink1100) }
    public static var alphaPink1200: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink1200) }
    public static var alphaPink1300: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink1300) }
    public static var alphaPink1400: Color { Color(uiColor: CompoundCoreUIColorTokens.alphaPink1400) }
    public static var transparent: Color { Color(uiColor: CompoundCoreUIColorTokens.transparent) }
    
    // MARK: - Clap Custom Colors
    public static var clapThemeBg: Color { Color(uiColor: CompoundCoreUIColorTokens.clapThemeBg) }
    public static var clapBgBubbleIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgBubbleIncoming) }
    public static var clapBgBubbleOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgBubbleOutgoing) }
    public static var clapBgSubtleSecondary: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgSubtleSecondary) }
    public static var clapTextPrimary: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextPrimary) }
    public static var clapTextSecondary: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextSecondary) }
    public static var clapTextBubbleOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextBubbleOutgoing) }
    public static var clapTextBubbleIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextBubbleIncoming) }
    public static var clapTextBubbleSecondaryOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextBubbleSecondaryOutgoing) }
    public static var clapTextBubbleSecondaryIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextBubbleSecondaryIncoming) }
    public static var clapIconBubbleOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapIconBubbleOutgoing) }
    public static var clapIconBubbleIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapIconBubbleIncoming) }
    public static var clapIconAccentTertiary: Color { Color(uiColor: CompoundCoreUIColorTokens.clapIconAccentTertiary) }
    public static var clapBgPollProgressEmptyOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgPollProgressEmptyOutgoing) }
    public static var clapBgPollProgressEmptyIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgPollProgressEmptyIncoming) }
    public static var clapBgPollProgressFilledOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgPollProgressFilledOutgoing) }
    public static var clapBgPollProgressFilledIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgPollProgressFilledIncoming) }
    public static var clapTextBadgeAccent: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextBadgeAccent) }
    public static var clapBgBadgeAccent: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgBadgeAccent) }
    public static var clapBgCodeBlockOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgCodeBlockOutgoing) }
    public static var clapBgCodeBlockIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgCodeBlockIncoming) }
    public static var clapTextCodeBlockOutgoing: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextCodeBlockOutgoing) }
    public static var clapTextCodeBlockIncoming: Color { Color(uiColor: CompoundCoreUIColorTokens.clapTextCodeBlockIncoming) }
    public static var clapBgBadgeDefault: Color { Color(uiColor: CompoundCoreUIColorTokens.clapBgBadgeDefault) }
    public static var clapRoomBg: Color { Color(uiColor: CompoundCoreUIColorTokens.clapRoomBg) }
}

