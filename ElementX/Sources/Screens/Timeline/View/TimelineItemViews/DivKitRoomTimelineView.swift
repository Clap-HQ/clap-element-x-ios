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
            return injectPaletteVariables([], into: timelineItem.content.cardData)
        }
        let colors = colorScheme == .dark ? palette.dark : palette.light
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
            let cardID = timelineItem.id.uniqueID.value
            DivKitViewRepresentable(
                cardData: resolvedCardData,
                cardID: cardID,
                onAction: handleDivKitAction,
                onFailure: { showFallback = true },
                onHeightChanged: { height in
                    DivKitComponentsProvider.shared.cacheHeight(height, for: cardID)
                }
            )
            .modifier(CachedHeightModifier(cardID: cardID))
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

// MARK: - Cached Height Modifier

private struct CachedHeightModifier: ViewModifier {
    let cardID: String

    func body(content: Content) -> some View {
        if let cachedHeight = DivKitComponentsProvider.shared.cachedHeight(for: cardID) {
            content.frame(height: cachedHeight)
        } else {
            content.fixedSize(horizontal: false, vertical: true)
        }
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
//                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
//                    json: planApprovalJSON, messageType: .planApproval, fallbackText: "실행 계획을 승인해주세요."
//                ))
//                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
//                    json: toolApprovalJSON, messageType: .toolApproval, fallbackText: "도구 실행을 승인해주세요."
//                ))
//                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
//                    json: selectionJSON, messageType: .selection, fallbackText: "어떤 채널을 확인할까요?"
//                ))
//                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
//                    json: finalResultJSON, messageType: .finalResult, fallbackText: "작업 완료"
//                ))
//                DivKitRoomTimelineView(timelineItem: makeDivKitItem(
//                    json: errorJSON, messageType: .error, fallbackText: "오류가 발생했습니다."
//                ))
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
              {
                "log_id": "plan_approval_805f6c4c-fadf-4a3c-8f88-e867365803ab",
                "states": [
                  {
                    "div": {
                      "background": [
                        {
                          "color": "@{clap.bg.primary}",
                          "type": "solid"
                        }
                      ],
                      "items": [
                        {
                          "font_size": 18,
                          "font_weight": "bold",
                          "paddings": {
                            "bottom": 8
                          },
                          "text": "Plan",
                          "text_color": "@{clap.text.primary}",
                          "type": "text"
                        },
                        {
                          "item_builder": {
                            "data": "@{steps}",
                            "data_element_name": "step",
                            "prototypes": [
                              {
                                "div": {
                                  "font_size": 14,
                                  "paddings": {
                                    "bottom": 4,
                                    "top": 4
                                  },
                                  "text": "@{step}",
                                  "text_color": "@{clap.text.primary}",
                                  "type": "text"
                                }
                              }
                            ]
                          },
                          "type": "container"
                        },
                        {
                          "items": [
                            {
                              "actions": [
                                {
                                  "log_id": "approve",
                                  "url": "clap://approve?plan_id=@{plan_id}"
                                }
                              ],
                              "font_size": 14,
                              "font_weight": "bold",
                              "height": {
                                "type": "match_parent"
                              },
                              "paddings": {
                                "right": 24
                              },
                              "text": "Approve",
                              "text_color": "@{clap.accent.primary}",
                              "type": "text"
                            },
                            {
                              "actions": [
                                {
                                  "log_id": "reject",
                                  "url": "clap://reject?plan_id=@{plan_id}"
                                }
                              ],
                              "font_size": 14,
                              "font_weight": "bold",
                              "text": "Reject",
                              "text_color": "@{clap.accent.error}",
                              "type": "text"
                            }
                          ],
                          "orientation": "horizontal",
                          "paddings": {
                            "top": 12
                          },
                          "type": "container"
                        }
                      ],
                      "orientation": "vertical",
                      "paddings": {
                        "bottom": 16,
                        "left": 16,
                        "right": 16,
                        "top": 16
                      },
                      "type": "container"
                    },
                    "state_id": 0
                  }
                ],
                "variables": [
                  {
                    "name": "steps",
                    "type": "array",
                    "value": [
                      "send_message: 사용자의 인사에 응답해 대화를 시작한다"
                    ]
                  },
                  {
                    "name": "plan_id",
                    "type": "string",
                    "value": "805f6c4c-fadf-4a3c-8f88-e867365803ab"
                  }
                ]
              },
              "data": {
                "plan": {
                  "steps": [
                    {
                      "icon": "📤",
                      "purpose": "사용자의 인사에 응답해 대화를 시작한다",
                      "step_number": 1,
                      "tool": "send_message"
                    }
                  ],
                  "summary": "현재 방에서 사용자의 인사에 간단히 응답해 대화를 시작한다"
                },
                "task_summary": "안녕",
                "timeout_seconds": 120
              },
              "message_type": "plan_approval",
              "palette": {
                "dark": [
                  {
                    "color": "#E57373",
                    "name": "clap.accent.error"
                  },
                  {
                    "color": "#64B5F6",
                    "name": "clap.accent.primary"
                  },
                  {
                    "color": "#81C784",
                    "name": "clap.accent.success"
                  },
                  {
                    "color": "#FFB74D",
                    "name": "clap.accent.warning"
                  },
                  {
                    "color": "#1A1A1A",
                    "name": "clap.bg.primary"
                  },
                  {
                    "color": "#2D2D2D",
                    "name": "clap.bg.secondary"
                  },
                  {
                    "color": "#333333",
                    "name": "clap.bg.surface"
                  },
                  {
                    "color": "#444444",
                    "name": "clap.border.default"
                  },
                  {
                    "color": "#64B5F6",
                    "name": "clap.border.focus"
                  },
                  {
                    "color": "#1A1A1A",
                    "name": "clap.text.inverse"
                  },
                  {
                    "color": "#FFFFFF",
                    "name": "clap.text.primary"
                  },
                  {
                    "color": "#B0B0B0",
                    "name": "clap.text.secondary"
                  }
                ],
                "light": [
                  {
                    "color": "#F44336",
                    "name": "clap.accent.error"
                  },
                  {
                    "color": "#4A90D9",
                    "name": "clap.accent.primary"
                  },
                  {
                    "color": "#4CAF50",
                    "name": "clap.accent.success"
                  },
                  {
                    "color": "#FF9800",
                    "name": "clap.accent.warning"
                  },
                  {
                    "color": "#FFFFFF",
                    "name": "clap.bg.primary"
                  },
                  {
                    "color": "#F5F5F5",
                    "name": "clap.bg.secondary"
                  },
                  {
                    "color": "#FAFAFA",
                    "name": "clap.bg.surface"
                  },
                  {
                    "color": "#E0E0E0",
                    "name": "clap.border.default"
                  },
                  {
                    "color": "#4A90D9",
                    "name": "clap.border.focus"
                  },
                  {
                    "color": "#FFFFFF",
                    "name": "clap.text.inverse"
                  },
                  {
                    "color": "#1A1A1A",
                    "name": "clap.text.primary"
                  },
                  {
                    "color": "#666666",
                    "name": "clap.text.secondary"
                  }
                ]
              },
              "request_id": "805f6c4c-fadf-4a3c-8f88-e867365803ab",
              "version": "1.0"
            }
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
    let onHeightChanged: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(cardID: cardID, onAction: onAction, onFailure: onFailure, onHeightChanged: onHeightChanged)
    }

    func makeUIView(context: Context) -> DivViewContainer {
        let provider = DivKitComponentsProvider.shared

        provider.setActionHandler(for: cardID) { [weak coordinator = context.coordinator] url in
            coordinator?.onAction(url)
        }

        provider.setErrorHandler(for: cardID) { [weak coordinator = context.coordinator] in
            coordinator?.onFailure()
        }

        let divView: DivView
        if let cached = provider.cachedDivView(for: cardID) {
            divView = cached
        } else {
            divView = DivView(divKitComponents: provider.components)
            provider.cacheDivView(divView, for: cardID)
        }

        let container = DivViewContainer(divView: divView) { [weak coordinator = context.coordinator] height in
            coordinator?.onHeightChanged(height)
        }
        context.coordinator.currentCardData = cardData

        let divCardID = DivCardID(rawValue: cardID)
        Task { @MainActor in
            provider.components.reset(cardId: divCardID)
            let source = DivViewSource(
                kind: .data(cardData),
                cardId: divCardID
            )
            await divView.setSource(source)
            container.invalidateIntrinsicContentSize()
        }

        return container
    }

    func updateUIView(_ container: DivViewContainer, context: Context) {
        context.coordinator.onAction = onAction

        if context.coordinator.currentCardData != cardData {
            context.coordinator.currentCardData = cardData
            let divCardID = DivCardID(rawValue: cardID)
            Task { @MainActor in
                DivKitComponentsProvider.shared.components.reset(cardId: divCardID)
                let source = DivViewSource(
                    kind: .data(cardData),
                    cardId: divCardID
                )
                await container.divView.setSource(source)
                container.invalidateIntrinsicContentSize()
            }
        }
    }

    final class Coordinator {
        let cardID: String
        var onAction: (URL) -> Void
        let onFailure: () -> Void
        let onHeightChanged: (CGFloat) -> Void
        var currentCardData: Data?

        init(cardID: String, onAction: @escaping (URL) -> Void, onFailure: @escaping () -> Void, onHeightChanged: @escaping (CGFloat) -> Void) {
            self.cardID = cardID
            self.onAction = onAction
            self.onFailure = onFailure
            self.onHeightChanged = onHeightChanged
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

final class DivViewContainer: UIView {
    let divView: DivView
    private let onHeightChanged: (CGFloat) -> Void
    private var lastReportedHeight: CGFloat = 0

    init(divView: DivView, onHeightChanged: @escaping (CGFloat) -> Void) {
        self.divView = divView
        self.onHeightChanged = onHeightChanged
        super.init(frame: .zero)
        addSubview(divView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        divView.frame = bounds
        divView.onVisibleBoundsChanged(to: bounds)

        let height = divView.intrinsicContentSize.height
        if height > 0, height != lastReportedHeight {
            lastReportedHeight = height
            onHeightChanged(height)
        }
    }

    override var intrinsicContentSize: CGSize {
        divView.intrinsicContentSize
    }
}
