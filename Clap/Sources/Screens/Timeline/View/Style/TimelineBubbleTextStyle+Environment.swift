import SwiftUI
import UIKit
import Compound

private struct TimelineBubbleIsOutgoingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct TimelineBubbleTextUIColorKey: EnvironmentKey {
    static let defaultValue: UIColor = UIColor.compound.textPrimary
}

extension EnvironmentValues {
    var timelineBubbleIsOutgoing: Bool {
        get { self[TimelineBubbleIsOutgoingKey.self] }
        set { self[TimelineBubbleIsOutgoingKey.self] = newValue }
    }

    var timelineBubbleTextUIColor: UIColor {
        get { self[TimelineBubbleTextUIColorKey.self] }
        set { self[TimelineBubbleTextUIColorKey.self] = newValue }
    }
}

extension View {
    /// 버블 최상단에서 1번만 호출하면, 하위(FormattedBodyText/MessageText 포함) 전체가 따라가게 만들기
    func timelineBubbleTextColor(isOutgoing: Bool) -> some View {
        let uiColor: UIColor = isOutgoing ? .white : UIColor(hex: "1C1917")
        return self
            .environment(\.timelineBubbleIsOutgoing, isOutgoing)
            .environment(\.timelineBubbleTextUIColor, uiColor)
            // SwiftUI Text 계열이 먹을 수 있는 경우 대비
            .foregroundStyle(Color(uiColor: uiColor))
    }
}
