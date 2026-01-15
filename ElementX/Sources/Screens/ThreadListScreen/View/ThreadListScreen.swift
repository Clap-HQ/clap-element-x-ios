//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ThreadListScreen: View {
    @ObservedObject var context: ThreadListScreenViewModelType.Context

    var body: some View {
        content
            .navigationTitle(L10n.screenThreadListTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.actionClose) {
                        context.send(viewAction: .close)
                    }
                }
            }
            .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
    }

    @ViewBuilder
    private var content: some View {
        if context.viewState.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if context.viewState.threads.isEmpty {
            emptyState
        } else {
            threadList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            CompoundIcon(\.threads, size: .custom(64), relativeTo: .title)
                .foregroundColor(.compound.iconSecondary)

            Text(L10n.screenThreadListEmptyTitle)
                .font(.compound.headingMD)
                .foregroundColor(.compound.textPrimary)

            Text(L10n.screenThreadListEmptyDescription)
                .font(.compound.bodyMD)
                .foregroundColor(.compound.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var threadList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(context.viewState.threads) { thread in
                    ThreadListItemView(thread: thread, mediaProvider: context.mediaProvider) {
                        context.send(viewAction: .selectThread(thread))
                    }

                    Divider()
                        .padding(.leading, 72)
                }

                // Load more trigger
                if context.viewState.canLoadMore {
                    loadMoreView
                        .onAppear {
                            context.send(viewAction: .loadMore)
                        }
                }
            }
        }
    }

    @ViewBuilder
    private var loadMoreView: some View {
        if context.viewState.isLoadingMore {
            HStack {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            }
        } else {
            Color.clear
                .frame(height: 1)
        }
    }
}

// MARK: - Previews

struct ThreadListScreen_Previews: PreviewProvider, TestablePreview {
    static let emptyViewModel = makeViewModel(threads: [])
    static let loadedViewModel = makeViewModel(threads: mockThreads)

    static var previews: some View {
        NavigationStack {
            ThreadListScreen(context: emptyViewModel.context)
        }
        .previewDisplayName("Empty")

        NavigationStack {
            ThreadListScreen(context: loadedViewModel.context)
        }
        .previewDisplayName("With Threads")
    }

    static func makeViewModel(threads: [ThreadListItem]) -> ThreadListScreenViewModel {
        let roomProxy = JoinedRoomProxyMock(.init(name: "General"))
        let threadsAPI = MockThreadsAPI()
        let viewModel = ThreadListScreenViewModel(roomProxy: roomProxy,
                                                  threadsAPI: threadsAPI,
                                                  mediaProvider: MediaProviderMock(configuration: .init()))
        viewModel.state.threads = threads
        viewModel.state.isLoading = false
        return viewModel
    }
}

// MARK: - Mock for Preview

private class MockThreadsAPI: MatrixThreadsAPIProtocol {
    func fetchThreads(roomID: String, from: String?, include: ThreadIncludeFilter, limit: Int) async -> Result<ThreadListResponse, RESTAPIError> {
        .success(ThreadListResponse(chunk: [], nextBatch: nil))
    }
}

private let mockThreads: [ThreadListItem] = [
    ThreadListItem(id: "thread1",
                   rootEventID: "event1",
                   rootSenderID: "@alice:example.com",
                   rootSenderDisplayName: "Alice",
                   rootContent: "Has anyone tried the new feature?",
                   replyCount: 5,
                   lastReplyTimestamp: Date(),
                   hasUnread: true,
                   lastReplySenderID: "@bob:example.com",
                   lastReplySenderDisplayName: "Bob",
                   lastReplyContent: "Yes, it works great!"),
    ThreadListItem(id: "thread2",
                   rootEventID: "event2",
                   rootSenderID: "@bob:example.com",
                   rootSenderDisplayName: "Bob",
                   rootContent: "I found a bug in the login flow",
                   replyCount: 12,
                   lastReplyTimestamp: Date().addingTimeInterval(-3600),
                   hasUnread: false,
                   lastReplySenderID: "@charlie:example.com",
                   lastReplySenderDisplayName: "Charlie",
                   lastReplyContent: "Fixed in latest commit"),
    ThreadListItem(id: "thread3",
                   rootEventID: "event3",
                   rootSenderID: "@charlie:example.com",
                   rootSenderDisplayName: "Charlie",
                   rootContent: "Meeting notes from yesterday",
                   replyCount: 3,
                   lastReplyTimestamp: Date().addingTimeInterval(-86400),
                   hasUnread: false,
                   lastReplySenderID: "@alice:example.com",
                   lastReplySenderDisplayName: "Alice",
                   lastReplyContent: "Thanks for sharing!")
]
