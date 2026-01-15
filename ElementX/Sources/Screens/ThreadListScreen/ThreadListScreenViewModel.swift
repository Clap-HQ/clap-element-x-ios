//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation
import MatrixRustSDK

typealias ThreadListScreenViewModelType = StateStoreViewModel<ThreadListScreenViewState, ThreadListScreenViewAction>

class ThreadListScreenViewModel: ThreadListScreenViewModelType, ThreadListScreenViewModelProtocol {
    private let roomProxy: JoinedRoomProxyProtocol
    private let threadsAPI: MatrixThreadsAPIProtocol
    private let userID: String

    /// Pagination token for loading more threads
    private var nextBatchToken: String?
    /// Flag to prevent concurrent pagination requests
    private var isLoadingMoreThreads = false

    private let actionsSubject: PassthroughSubject<ThreadListScreenViewModelAction, Never> = .init()

    var actionsPublisher: AnyPublisher<ThreadListScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(roomProxy: JoinedRoomProxyProtocol,
         threadsAPI: MatrixThreadsAPIProtocol,
         mediaProvider: MediaProviderProtocol) {
        self.roomProxy = roomProxy
        self.threadsAPI = threadsAPI
        self.userID = roomProxy.ownUserID

        let roomName = roomProxy.infoPublisher.value.displayName ?? roomProxy.id
        super.init(initialViewState: ThreadListScreenViewState(roomName: roomName),
                   mediaProvider: mediaProvider)

        fetchThreads()
    }

    override func process(viewAction: ThreadListScreenViewAction) {
        switch viewAction {
        case .close:
            actionsSubject.send(.dismiss)
        case .selectThread(let thread):
            actionsSubject.send(.selectThread(rootEventID: thread.rootEventID))
        case .loadMore:
            loadMoreThreads()
        }
    }

    // MARK: - Private

    private func fetchThreads() {
        Task {
            state.isLoading = true

            // Load members first to get display names and avatars
            await roomProxy.updateMembers()
            let members = roomProxy.membersPublisher.value
            let memberInfo = Dictionary(uniqueKeysWithValues: members.map {
                ($0.userID, (displayName: $0.displayName, avatarURL: $0.avatarURL))
            })

            let result = await threadsAPI.fetchThreads(roomID: roomProxy.id, limit: 20)

            switch result {
            case .success(let response):
                // Convert events to thread items, decrypting encrypted events
                var threadItems: [ThreadListItem] = []
                for event in response.chunk {
                    if let item = await convertToThreadListItem(event, memberInfo: memberInfo) {
                        threadItems.append(item)
                    }
                }

                await MainActor.run {
                    state.threads = threadItems
                    state.isLoading = false
                    nextBatchToken = response.nextBatch
                    state.canLoadMore = response.nextBatch != nil
                }

            case .failure(let error):
                MXLog.error("Failed to fetch threads: \(error)")
                // Fallback to timeline-based approach if API fails
                await MainActor.run {
                    fallbackToTimelineThreads()
                }
            }
        }
    }

    private func loadMoreThreads() {
        // Prevent concurrent requests
        guard !isLoadingMoreThreads,
              let nextBatch = nextBatchToken,
              state.canLoadMore else {
            return
        }

        isLoadingMoreThreads = true
        state.isLoadingMore = true

        Task {
            // Use cached members for display names and avatars
            let members = roomProxy.membersPublisher.value
            let memberInfo = Dictionary(uniqueKeysWithValues: members.map {
                ($0.userID, (displayName: $0.displayName, avatarURL: $0.avatarURL))
            })

            let result = await threadsAPI.fetchThreads(roomID: roomProxy.id, from: nextBatch, limit: 20)

            switch result {
            case .success(let response):
                // Convert events to thread items, decrypting encrypted events
                var newThreadItems: [ThreadListItem] = []
                for event in response.chunk {
                    if let item = await convertToThreadListItem(event, memberInfo: memberInfo) {
                        newThreadItems.append(item)
                    }
                }

                await MainActor.run {
                    isLoadingMoreThreads = false
                    state.isLoadingMore = false

                    // Append new threads to existing list
                    state.threads.append(contentsOf: newThreadItems)
                    nextBatchToken = response.nextBatch
                    state.canLoadMore = response.nextBatch != nil

                    MXLog.info("Loaded \(newThreadItems.count) more threads, total: \(state.threads.count)")
                }

            case .failure(let error):
                MXLog.error("Failed to load more threads: \(error)")
                await MainActor.run {
                    isLoadingMoreThreads = false
                    state.isLoadingMore = false
                    // Don't update canLoadMore on failure, allow retry
                }
            }
        }
    }

    private func convertToThreadListItem(_ event: ThreadRootEvent, memberInfo: [String: (displayName: String?, avatarURL: URL?)]) async -> ThreadListItem? {
        let rootEventID = event.eventId
        let rootSenderID = event.sender

        // Get root content - decrypt if encrypted
        let rootContent: String
        if event.type == "m.room.encrypted" {
            rootContent = await decryptEventContent(eventID: rootEventID) ?? L10n.commonMessage
        } else {
            rootContent = event.content?.displayText ?? L10n.commonMessage
        }

        // Get display name and avatar from members cache
        let rootMemberInfo = memberInfo[rootSenderID]
        let rootSenderDisplayName = rootMemberInfo?.displayName
        let rootSenderAvatarURL = rootMemberInfo?.avatarURL

        // Get thread summary from unsigned relations
        let threadSummary = event.unsigned?.relations?.thread
        let replyCount = threadSummary?.count ?? 0

        // Get latest event info
        let latestEvent = threadSummary?.latestEvent
        let lastReplyTimestamp: Date = latestEvent?.timestamp ?? event.timestamp
        let lastReplySenderID = latestEvent?.sender
        let lastReplyMemberInfo = lastReplySenderID.flatMap { memberInfo[$0] }
        let lastReplySenderDisplayName = lastReplyMemberInfo?.displayName
        let lastReplySenderAvatarURL = lastReplyMemberInfo?.avatarURL

        // Get last reply content - decrypt if encrypted
        let lastReplyContent: String?
        if let latestEvent {
            if latestEvent.type == "m.room.encrypted" {
                lastReplyContent = await decryptEventContent(eventID: latestEvent.eventId) ?? L10n.commonMessage
            } else {
                lastReplyContent = latestEvent.content?.displayText
            }
        } else {
            lastReplyContent = nil
        }

        return ThreadListItem(
            id: rootEventID,
            rootEventID: rootEventID,
            rootSenderID: rootSenderID,
            rootSenderDisplayName: rootSenderDisplayName,
            rootSenderAvatarURL: rootSenderAvatarURL,
            rootContent: rootContent,
            replyCount: replyCount,
            lastReplyTimestamp: lastReplyTimestamp,
            hasUnread: false, // Would need read receipt tracking for accurate value
            lastReplySenderID: lastReplySenderID,
            lastReplySenderDisplayName: lastReplySenderDisplayName,
            lastReplySenderAvatarURL: lastReplySenderAvatarURL,
            lastReplyContent: lastReplyContent
        )
    }

    /// Decrypt an encrypted event using the SDK
    /// - Parameter eventID: The event ID to decrypt
    /// - Returns: The decrypted message body, or nil if decryption failed or event is not a message
    private func decryptEventContent(eventID: String) async -> String? {
        let result = await roomProxy.loadOrFetchEventDetails(for: eventID)

        switch result {
        case .success(let timelineEvent):
            do {
                let eventType = try timelineEvent.eventType()
                switch eventType {
                case .messageLike(let content):
                    switch content {
                    case .roomMessage(let messageType, _):
                        return extractTextFromMessageType(messageType)
                    case .poll(let question):
                        return question
                    default:
                        return nil
                    }
                default:
                    return nil
                }
            } catch {
                MXLog.error("Failed to get event type for \(eventID): \(error)")
                return nil
            }
        case .failure(let error):
            MXLog.error("Failed to decrypt event \(eventID): \(error)")
            return nil
        }
    }

    /// Extract text content from SDK MessageType (unified for both API and timeline sources)
    private func extractTextFromMessageType(_ messageType: MessageType) -> String {
        switch messageType {
        case .text(let content):
            return content.body
        case .emote(let content):
            return content.body
        case .notice(let content):
            return content.body
        case .image(let content):
            return content.filename
        case .video(let content):
            return content.filename
        case .audio(let content):
            return content.filename
        case .file(let content):
            return content.filename
        case .location(let content):
            return content.body
        default:
            return L10n.commonMessage
        }
    }

    // MARK: - Fallback to timeline-based threads

    private func fallbackToTimelineThreads() {
        Task {
            let timeline = roomProxy.timeline

            // Subscribe for updates
            await timeline.subscribeForUpdates()

            // Process initial items
            await MainActor.run {
                updateThreadsFromTimeline(timeline.timelineItemProvider.itemProxies)
            }

            // Subscribe to timeline updates
            timeline.timelineItemProvider.updatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] items, _ in
                    self?.updateThreadsFromTimeline(items)
                }
                .store(in: &cancellables)
        }
    }

    private func updateThreadsFromTimeline(_ items: [TimelineItemProxy]) {
        // Find all items that are thread roots (have a threadSummary)
        let threadItems = items.compactMap { itemProxy -> ThreadListItem? in
            guard case let .event(eventProxy) = itemProxy else {
                return nil
            }

            // Check if this event has a thread summary in its content
            guard case let .msgLike(messageLikeContent) = eventProxy.content,
                  let threadSummary = messageLikeContent.threadSummary else {
                return nil
            }

            // Extract thread information from the thread summary
            let rootEventID = eventProxy.id.eventID ?? eventProxy.id.uniqueID.value
            let rootSenderID = eventProxy.sender.id
            let rootSenderDisplayName = eventProxy.sender.displayName
            let rootContent = extractMessageContent(from: messageLikeContent)
            let timestamp = eventProxy.timestamp

            // Get reply count from thread summary
            let replyCount = Int(threadSummary.numReplies())

            return ThreadListItem(
                id: eventProxy.id.uniqueID.value,
                rootEventID: rootEventID,
                rootSenderID: rootSenderID,
                rootSenderDisplayName: rootSenderDisplayName,
                rootContent: rootContent,
                replyCount: replyCount,
                lastReplyTimestamp: timestamp,
                hasUnread: false
            )
        }

        // Sort by most recent activity (last reply timestamp)
        let sortedThreads = threadItems.sorted { lhs, rhs in
            let lhsDate = lhs.lastReplyTimestamp ?? Date.distantPast
            let rhsDate = rhs.lastReplyTimestamp ?? Date.distantPast
            return lhsDate > rhsDate
        }

        state.threads = sortedThreads
        state.isLoading = false
        state.canLoadMore = false // No pagination for fallback
    }

    private func extractMessageContent(from content: MsgLikeContent) -> String {
        switch content.kind {
        case .message(let messageContent):
            return extractTextFromMessageType(messageContent.msgType)
        case .poll(question: let question, kind: _, maxSelections: _, answers: _, votes: _, endTime: _, _):
            return question
        case .sticker(let body, _, _):
            return body
        default:
            return L10n.commonMessage
        }
    }
}
