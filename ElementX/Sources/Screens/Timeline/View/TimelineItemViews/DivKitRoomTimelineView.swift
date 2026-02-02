//
// Copyright 2025 Clap Inc.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import DivKit
import Foundation
import SwiftUI

struct DivKitRoomTimelineView: View {
    @Environment(\.timelineContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    let timelineItem: DivKitRoomTimelineItem

    @State private var showFallback = false

    private var alreadyActed: Bool {
        context?.viewState.actedDivKitItemIDs.contains(timelineItem.id) == true
    }

    private var resolvedCardData: Data {
        guard let palette = timelineItem.content.palette else {
            return timelineItem.content.cardData
        }
        let colors = colorScheme == .dark ? palette.dark : palette.light
        guard !colors.isEmpty else { return timelineItem.content.cardData }
        return injectPaletteVariables(colors, into: timelineItem.content.cardData)
    }

    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            divKitContent
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var divKitContent: some View {
        if showFallback {
            Text(timelineItem.content.fallbackText)
                .font(.compound.bodyMD)
                .foregroundColor(.compound.textPrimary)
        } else {
            DivKitViewRepresentable(
                cardData: resolvedCardData,
                cardID: timelineItem.id.uniqueID.value,
                onAction: handleDivKitAction,
                onFailure: { showFallback = true }
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func injectPaletteVariables(_ colors: [DivKitPaletteColor], into cardData: Data) -> Data {
        guard var envelope = try? JSONSerialization.jsonObject(with: cardData) as? [String: Any],
              var card = envelope["card"] as? [String: Any] else {
            return cardData
        }

        var variables = card["variables"] as? [[String: Any]] ?? []
        let existingNames = Set(variables.compactMap { $0["name"] as? String })
        for color in colors where !existingNames.contains(color.name) {
            variables.append(["name": color.name, "type": "color", "value": color.color])
        }
        card["variables"] = variables
        envelope["card"] = card

        return (try? JSONSerialization.data(withJSONObject: envelope)) ?? cardData
    }

    private func handleDivKitAction(url: URL) {
        guard !alreadyActed else { return }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == "clap",
              components.host == "action" else {
            return
        }

        guard let queryItems = components.queryItems else { return }

        let actionType = queryItems.first(where: { $0.name == "type" })?.value
        let requestID = queryItems.first(where: { $0.name == "request_id" })?.value
        let value = queryItems.first(where: { $0.name == "value" })?.value

        let messageToSend: String
        switch actionType {
        case "approve":
            messageToSend = "approve"
        case "reject":
            messageToSend = "reject"
        case "skip":
            messageToSend = "skip"
        case "select":
            guard let value, !value.isEmpty else {
                MXLog.warning("DivKit: select action missing value (requestID: \(requestID ?? "nil"))")
                return
            }
            messageToSend = value
        default:
            MXLog.warning("DivKit: Unknown action type: \(actionType ?? "nil")")
            return
        }

        MXLog.info("DivKit: Sending action '\(messageToSend)' (url: \(url), requestID: \(requestID ?? "nil"))")
        context?.send(viewAction: .handleDivKitAction(message: messageToSend, itemID: timelineItem.id))
    }
}

// MARK: - Previews

struct DivKitRoomTimelineView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = TimelineViewModel.mock

    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
                    json: thinkingJSON, messageType: .thinking, fallbackText: "계획을 세우는 중..."
                ))
                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
                    json: planApprovalJSON, messageType: .planApproval, fallbackText: "실행 계획을 승인해주세요."
                ))
                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
                    json: toolApprovalJSON, messageType: .toolApproval, fallbackText: "도구 실행을 승인해주세요."
                ))
                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
                    json: selectionJSON, messageType: .selection, fallbackText: "어떤 채널을 확인할까요?"
                ))
                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
                    json: finalResultJSON, messageType: .finalResult, fallbackText: "작업 완료"
                ))
                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
                    json: errorJSON, messageType: .error, fallbackText: "오류가 발생했습니다."
                ))
            }
        }
        .environmentObject(viewModel.context)
        .environment(\.timelineContext, viewModel.context)
        .previewDisplayName("DivKit Cards")
        .previewLayout(.sizeThatFits)
    }

    private static func makeDivKitItem(json: String,
                                       messageType: DivKitMessageType,
                                       fallbackText: String) -> DivKitRoomTimelineItem {
        let cardDict = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!) as! [String: Any]
        let envelope: [String: Any] = ["card": cardDict]
        let cardData = try! JSONSerialization.data(withJSONObject: envelope)

        return DivKitRoomTimelineItem(
            id: .randomEvent,
            timestamp: .mock,
            isOutgoing: false,
            isEditable: false,
            canBeRepliedTo: false,
            sender: .init(id: "ClapBot", displayName: "ClapBot"),
            content: DivKitRoomTimelineItemContent(
                cardData: cardData,
                fallbackText: fallbackText,
                messageType: messageType,
                requestID: nil,
                version: "1.0",
                cardLogID: cardDict["log_id"] as? String,
                palette: nil
            )
        )
    }

    // swiftlint:disable line_length
    static let thinkingJSON = """
    {"log_id":"thinking","states":[{"state_id":0,"div":{"type":"container","orientation":"horizontal","paddings":{"left":16,"top":12,"right":16,"bottom":12},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":12},"items":[{"type":"text","text":"🤔","font_size":16,"width":{"type":"fixed","value":28}},{"type":"text","text":"계획을 세우는 중...","font_size":14,"text_color":"#718096"}]}}]}
    """

    static let planApprovalJSON = """
    {"log_id":"plan_approval_req_plan_001","states":[{"state_id":0,"div":{"type":"container","orientation":"vertical","paddings":{"left":16,"top":16,"right":16,"bottom":16},"background":[{"type":"solid","color":"#FFFFFF"}],"border":{"corner_radius":16,"stroke":{"color":"#E2E8F0","width":1}},"items":[{"type":"container","orientation":"horizontal","items":[{"type":"text","text":"📋","font_size":18,"width":{"type":"fixed","value":28}},{"type":"text","text":"실행 계획","font_size":16,"font_weight":"bold","text_color":"#1A202C"}]},{"type":"text","text":"오늘 일정을 확인하고 요약해서 알려드립니다.","font_size":14,"text_color":"#4A5568","margins":{"top":12}},{"type":"separator","delimiter_style":{"color":"#E2E8F0"},"margins":{"top":12,"bottom":12}},{"type":"container","orientation":"vertical","items":[{"type":"container","orientation":"horizontal","margins":{"top":0},"items":[{"type":"text","text":"1.","font_size":13,"text_color":"#A0AEC0","width":{"type":"fixed","value":20}},{"type":"text","text":"📖","font_size":14,"width":{"type":"fixed","value":24}},{"type":"container","orientation":"vertical","items":[{"type":"text","text":"read_messages","font_size":13,"font_weight":"medium","text_color":"#1A202C"},{"type":"text","text":"오늘 메시지 읽기","font_size":12,"text_color":"#718096"}]}]},{"type":"container","orientation":"horizontal","margins":{"top":8},"items":[{"type":"text","text":"2.","font_size":13,"text_color":"#A0AEC0","width":{"type":"fixed","value":20}},{"type":"text","text":"🔍","font_size":14,"width":{"type":"fixed","value":24}},{"type":"container","orientation":"vertical","items":[{"type":"text","text":"web_search","font_size":13,"font_weight":"medium","text_color":"#1A202C"},{"type":"text","text":"관련 정보 검색","font_size":12,"text_color":"#718096"}]}]},{"type":"container","orientation":"horizontal","margins":{"top":8},"items":[{"type":"text","text":"3.","font_size":13,"text_color":"#A0AEC0","width":{"type":"fixed","value":20}},{"type":"text","text":"📤","font_size":14,"width":{"type":"fixed","value":24}},{"type":"container","orientation":"vertical","items":[{"type":"text","text":"send_message","font_size":13,"font_weight":"medium","text_color":"#1A202C"},{"type":"text","text":"요약 결과 전송","font_size":12,"text_color":"#718096"}]}]}]},{"type":"container","orientation":"horizontal","margins":{"top":16},"items":[{"type":"text","text":"거부","text_alignment_horizontal":"center","font_size":13,"font_weight":"bold","text_color":"#4A5568","paddings":{"left":16,"top":10,"right":16,"bottom":10},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":10},"weight":1,"actions":[{"log_id":"action_거부","url":"clap://action?type=reject&request_id=req_plan_001"}]},{"type":"container","width":{"type":"fixed","value":8}},{"type":"text","text":"승인","text_alignment_horizontal":"center","font_size":13,"font_weight":"bold","text_color":"#FFFFFF","paddings":{"left":16,"top":10,"right":16,"bottom":10},"background":[{"type":"solid","color":"#1A202C"}],"border":{"corner_radius":10},"weight":1,"actions":[{"log_id":"action_승인","url":"clap://action?type=approve&request_id=req_plan_001"}]}]}]}}]}
    """

    static let toolApprovalJSON = """
    {"log_id":"tool_approval_req_tool_001","states":[{"state_id":0,"div":{"type":"container","orientation":"vertical","paddings":{"left":16,"top":12,"right":16,"bottom":16},"background":[{"type":"solid","color":"#FFFFFF"}],"border":{"corner_radius":16,"stroke":{"color":"#E2E8F0","width":1}},"items":[{"type":"container","orientation":"horizontal","items":[{"type":"text","text":"1/3","font_size":11,"font_weight":"bold","text_color":"#6B46C1","paddings":{"left":6,"top":2,"right":6,"bottom":2},"background":[{"type":"solid","color":"#EDE9FE"}],"border":{"corner_radius":4}},{"type":"text","text":" ✋ ","font_size":14,"margins":{"left":8}},{"type":"text","text":"도구 실행 확인","font_size":13,"font_weight":"medium","text_color":"#6B46C1"}]},{"type":"container","orientation":"horizontal","margins":{"top":12},"items":[{"type":"text","text":"📖","font_size":16,"width":{"type":"fixed","value":24}},{"type":"container","orientation":"vertical","items":[{"type":"text","text":"read_messages","font_size":14,"font_weight":"bold","text_color":"#1A202C"},{"type":"text","text":"오늘 메시지를 읽어옵니다.","font_size":13,"text_color":"#718096","margins":{"top":2}}]}]},{"type":"text","text":"{ \\"room_id\\": \\"#general\\", \\"since\\": \\"today\\" }","font_size":12,"text_color":"#718096","font_family":"monospace","paddings":{"left":10,"top":8,"right":10,"bottom":8},"margins":{"top":8},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":8}},{"type":"container","orientation":"horizontal","margins":{"top":12},"items":[{"type":"text","text":"거부","text_alignment_horizontal":"center","font_size":13,"font_weight":"bold","text_color":"#4A5568","paddings":{"left":16,"top":10,"right":16,"bottom":10},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":10},"weight":1,"actions":[{"log_id":"action_reject","url":"clap://action?type=reject&request_id=req_tool_001"}]},{"type":"container","width":{"type":"fixed","value":6}},{"type":"text","text":"건너뛰기","text_alignment_horizontal":"center","font_size":13,"font_weight":"bold","text_color":"#6B46C1","paddings":{"left":16,"top":10,"right":16,"bottom":10},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":10},"weight":1,"actions":[{"log_id":"action_skip","url":"clap://action?type=skip&request_id=req_tool_001"}]},{"type":"container","width":{"type":"fixed","value":6}},{"type":"text","text":"실행","text_alignment_horizontal":"center","font_size":13,"font_weight":"bold","text_color":"#FFFFFF","paddings":{"left":16,"top":10,"right":16,"bottom":10},"background":[{"type":"solid","color":"#1A202C"}],"border":{"corner_radius":10},"weight":1,"actions":[{"log_id":"action_approve","url":"clap://action?type=approve&request_id=req_tool_001"}]}]}]}}]}
    """

    static let selectionJSON = """
    {"log_id":"selection_req_sel_001","states":[{"state_id":0,"div":{"type":"container","orientation":"vertical","paddings":{"left":16,"top":16,"right":16,"bottom":16},"background":[{"type":"solid","color":"#FFFFFF"}],"border":{"corner_radius":16,"stroke":{"color":"#E2E8F0","width":1}},"items":[{"type":"container","orientation":"horizontal","items":[{"type":"text","text":"❓","font_size":16,"width":{"type":"fixed","value":24}},{"type":"text","text":"어떤 채널을 확인할까요?","font_size":15,"font_weight":"bold","text_color":"#1A202C"}]},{"type":"container","orientation":"vertical","margins":{"top":12},"items":[{"type":"text","text":"#general — 일반 채팅","font_size":14,"text_color":"#2D3748","paddings":{"left":14,"top":12,"right":14,"bottom":12},"margins":{"top":6},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":10,"stroke":{"color":"#E2E8F0","width":1}},"actions":[{"log_id":"select_general","url":"clap://action?type=select&request_id=req_sel_001&value=general"}]},{"type":"text","text":"#dev — 개발 논의","font_size":14,"text_color":"#2D3748","paddings":{"left":14,"top":12,"right":14,"bottom":12},"margins":{"top":6},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":10,"stroke":{"color":"#E2E8F0","width":1}},"actions":[{"log_id":"select_dev","url":"clap://action?type=select&request_id=req_sel_001&value=dev"}]},{"type":"text","text":"#design — 디자인 리뷰","font_size":14,"text_color":"#2D3748","paddings":{"left":14,"top":12,"right":14,"bottom":12},"margins":{"top":6},"background":[{"type":"solid","color":"#F7FAFC"}],"border":{"corner_radius":10,"stroke":{"color":"#E2E8F0","width":1}},"actions":[{"log_id":"select_design","url":"clap://action?type=select&request_id=req_sel_001&value=design"}]}]}]}}]}
    """
    static let finalResultJSON = """
    {"log_id":"final_result","states":[{"state_id":0,"div":{"type":"container","orientation":"vertical","paddings":{"left":16,"top":16,"right":16,"bottom":16},"background":[{"type":"solid","color":"#F0FFF4"}],"border":{"corner_radius":16,"stroke":{"color":"#68D391","width":1}},"items":[{"type":"container","orientation":"horizontal","items":[{"type":"text","text":"✅","font_size":18,"width":{"type":"fixed","value":28}},{"type":"text","text":"작업 완료","font_size":16,"font_weight":"bold","text_color":"#276749"}]},{"type":"text","text":"#general 채널의 오늘 메시지를 확인하고 요약했습니다. 총 23개의 메시지가 있었고, 주요 논의 내용은 릴리즈 일정 조정과 API 설계 리뷰였습니다.","font_size":14,"text_color":"#2D3748","margins":{"top":12},"line_height":1.5},{"type":"separator","delimiter_style":{"color":"#C6F6D5"},"margins":{"top":12,"bottom":8}},{"type":"text","text":"실행된 단계: 3/3","font_size":12,"text_color":"#48BB78","font_weight":"medium"}]}}]}
    """

    static let errorJSON = """
    {"log_id":"error","states":[{"state_id":0,"div":{"type":"container","orientation":"vertical","paddings":{"left":16,"top":12,"right":16,"bottom":12},"background":[{"type":"solid","color":"#FFF5F5"}],"border":{"corner_radius":12,"stroke":{"color":"#FC8181","width":1}},"items":[{"type":"container","orientation":"horizontal","items":[{"type":"text","text":"❌","font_size":16,"width":{"type":"fixed","value":28}},{"type":"text","text":"오류 [TIMEOUT]","font_size":14,"font_weight":"bold","text_color":"#E53E3E"}]},{"type":"text","text":"도구 승인 시간이 초과되었습니다.","font_size":13,"text_color":"#718096","margins":{"top":6}}]}}]}
    """
    // swiftlint:enable line_length
}

// MARK: - UIViewRepresentable

struct DivKitViewRepresentable: UIViewRepresentable {
    let cardData: Data
    let cardID: String
    let onAction: (URL) -> Void
    let onFailure: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(cardID: cardID, onAction: onAction, onFailure: onFailure)
    }

    func makeUIView(context: Context) -> DivView {
        let provider = DivKitComponentsProvider.shared

        provider.setActionHandler(for: cardID) { [weak coordinator = context.coordinator] url in
            coordinator?.onAction(url)
        }

        provider.setErrorHandler(for: cardID) { [weak coordinator = context.coordinator] in
            coordinator?.onFailure()
        }

        let divView = DivView(divKitComponents: provider.components)
        context.coordinator.currentCardData = cardData

        Task { @MainActor in
            let source = DivViewSource(
                kind: .data(cardData),
                cardId: DivCardID(rawValue: cardID)
            )
            await divView.setSource(source)
        }

        return divView
    }

    func updateUIView(_ divView: DivView, context: Context) {
        context.coordinator.onAction = onAction

        if context.coordinator.currentCardData != cardData {
            context.coordinator.currentCardData = cardData
            Task { @MainActor in
                let source = DivViewSource(
                    kind: .data(cardData),
                    cardId: DivCardID(rawValue: cardID)
                )
                await divView.setSource(source)
            }
        }
    }

    final class Coordinator {
        let cardID: String
        var onAction: (URL) -> Void
        let onFailure: () -> Void
        var currentCardData: Data?

        init(cardID: String, onAction: @escaping (URL) -> Void, onFailure: @escaping () -> Void) {
            self.cardID = cardID
            self.onAction = onAction
            self.onFailure = onFailure
        }

        deinit {
            let cardID = self.cardID
            DispatchQueue.main.async {
                DivKitComponentsProvider.shared.removeActionHandler(for: cardID)
                DivKitComponentsProvider.shared.removeErrorHandler(for: cardID)
            }
        }
    }
}
