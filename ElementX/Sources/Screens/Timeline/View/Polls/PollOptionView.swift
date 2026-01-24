//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct PollOptionView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.timelineBubbleIsOutgoing) private var isOutgoing

    let pollOption: Poll.Option
    let showVotes: Bool
    let isFinalResult: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemSymbol: pollOption.isSelected ? .checkmarkCircleFill : .circle)
                .font(.compound.bodyLG)
                .foregroundColor(checkboxColor)
                .accessibilityAddTraits(pollOption.isSelected ? .isSelected : [])

            VStack(spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(pollOption.text)
                        .font(isFinalWinningOption ? .compound.bodyLGSemibold : .compound.bodyLG)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.compound.textBubble(isOutgoing: isOutgoing))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if showVotes {
                        if isFinalWinningOption {
                            HStack(spacing: 4) {
                                CompoundIcon(asset: Asset.Images.pollWinner)
                                    .foregroundColor(.compound.iconAccentTertiary)
                                    .accessibilityLabel(L10n.a11yPollsWinningAnswer)

                                Text(L10n.commonPollVotesCount(pollOption.votes))
                                    .font(.compound.bodySMSemibold)
                                    .foregroundColor(.compound.textBubble(isOutgoing: isOutgoing))
                            }
                        } else {
                            Text(L10n.commonPollVotesCount(pollOption.votes))
                                .font(.compound.bodySM)
                                .foregroundColor(.compound.textBubbleSecondary(isOutgoing: isOutgoing))
                        }
                    }
                }

                PollProgressView(progress: progress, isOutgoing: isOutgoing, isFinalWinningOption: isFinalWinningOption)
            }
        }
    }

    private var checkboxColor: Color {
        if pollOption.isSelected && isEnabled {
            return .compound.iconBubble(isOutgoing: isOutgoing)
        } else {
            return .compound.textBubbleSecondary(isOutgoing: isOutgoing)
        }
    }

    // MARK: - Private

    private var progress: Double {
        switch (showVotes, pollOption.allVotes, pollOption.isSelected) {
        case (true, let allVotes, _) where allVotes > 0:
            return Double(pollOption.votes) / Double(allVotes)
        case (false, _, true):
            return 1
        default:
            return 0
        }
    }

    private var isFinalWinningOption: Bool {
        pollOption.isWinning && isFinalResult
    }
}

private struct PollProgressView: View {
    let progress: Double
    let isOutgoing: Bool
    let isFinalWinningOption: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(.compound._bgPollProgressEmpty(isOutgoing: isOutgoing))

                Capsule()
                    .foregroundColor(filledColor)
                    .frame(maxWidth: progress * geometry.size.width)
            }
        }
        .frame(height: 6)
    }

    private var filledColor: Color {
        isFinalWinningOption ? .compound.iconAccentTertiary : .compound._bgPollProgressFilled(isOutgoing: isOutgoing)
    }
}

struct PollOptionView_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        VStack(spacing: 8) {
            Group {
                PollOptionView(pollOption: .init(id: "1",
                                                 text: "Italian 🇮🇹",
                                                 votes: 1,
                                                 allVotes: 10,
                                                 isSelected: true,
                                                 isWinning: false),
                               showVotes: false,
                               isFinalResult: false)

                PollOptionView(pollOption: .init(id: "2",
                                                 text: "Chinese 🇨🇳",
                                                 votes: 9,
                                                 allVotes: 10,
                                                 isSelected: false,
                                                 isWinning: true),
                               showVotes: true,
                               isFinalResult: false)

                PollOptionView(pollOption: .init(id: "2",
                                                 text: "Chinese 🇨🇳",
                                                 votes: 9,
                                                 allVotes: 10,
                                                 isSelected: false,
                                                 isWinning: true),
                               showVotes: true,
                               isFinalResult: true)
            }
            .padding()
        }
    }
}

