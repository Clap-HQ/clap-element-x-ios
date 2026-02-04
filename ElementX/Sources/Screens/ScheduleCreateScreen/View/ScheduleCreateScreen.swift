//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleCreateScreen: View {
    @Bindable var context: ScheduleCreateScreenViewModel.Context
    
    var body: some View {
        Form {
            nameSection
            cronSection
            timezoneSection
            roomSection
            promptSection
        }
        .compoundList()
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(L10n.screenScheduleCreateTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .interactiveDismissDisabled()
        .alert(item: $context.alertInfo)
        .sheet(isPresented: $context.showRoomPicker) {
            ScheduleRoomPickerView(
                rooms: context.viewState.rooms,
                directMessages: context.viewState.directMessages,
                selectedRoom: context.viewState.bindings.selectedRoom,
                onSelect: { room in
                    context.send(viewAction: .selectRoom(room))
                },
                onCancel: {
                    context.send(viewAction: .hideRoomPicker)
                }
            )
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField(L10n.screenScheduleCreateNamePlaceholder, text: $context.name)
                .textInputAutocapitalization(.never)
        } header: {
            Text(L10n.screenScheduleCreateNameHeader)
        }
    }
    
    private var cronSection: some View {
        Section {
            TextField(L10n.screenScheduleCreateCronPlaceholder, text: $context.cronExpression)
                .font(.body.monospaced())
                .keyboardType(.numbersAndPunctuation)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: context.cronExpression) { _, newValue in
                    let filtered = newValue.filter { char in
                        char.isNumber || "*-/, ".contains(char)
                    }
                    if filtered != newValue {
                        context.cronExpression = filtered
                    }
                }
        } header: {
            Text(L10n.screenScheduleCreateCronHeader)
        } footer: {
            Text(L10n.screenScheduleCreateCronFooter)
        }
    }
    
    private var timezoneSection: some View {
        Section {
            Picker(L10n.screenScheduleCreateTimezoneHeader, selection: $context.selectedTimezone) {
                ForEach(ScheduleTimezone.allCases, id: \.self) { timezone in
                    Text(timezone.displayName).tag(timezone)
                }
            }
        }
    }
    
    private var roomSection: some View {
        Section {
            Button {
                context.send(viewAction: .showRoomPicker)
            } label: {
                HStack {
                    Text(L10n.screenScheduleCreateRoomHeader)
                        .foregroundColor(.compound.textPrimary)
                    
                    Spacer()
                    
                    if let room = context.viewState.bindings.selectedRoom {
                        Text(room.name)
                            .foregroundColor(.compound.textSecondary)
                    } else {
                        Text(L10n.screenScheduleCreateRoomPlaceholder)
                            .foregroundColor(.compound.textSecondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.compound.iconTertiary)
                        .font(.compound.bodySM)
                }
            }
        } footer: {
            Text(L10n.screenScheduleCreateRoomFooter)
        }
    }
    
    private var promptSection: some View {
        Section {
            TextField(L10n.screenScheduleCreatePromptPlaceholder, text: $context.prompt, axis: .vertical)
                .lineLimit(4...10)
                .frame(minHeight: 100, alignment: .top)
        } header: {
            Text(L10n.screenScheduleCreatePromptHeader)
        } footer: {
            Text(L10n.screenScheduleCreatePromptFooter)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(L10n.actionCancel) {
                context.send(viewAction: .cancel)
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(L10n.actionCreate) {
                context.send(viewAction: .submit)
            }
            .disabled(!context.viewState.canSubmit)
        }
    }
}
