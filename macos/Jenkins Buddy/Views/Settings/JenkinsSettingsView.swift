import SwiftUI

struct JenkinsSettingsView: View {
    let viewModel: JenkinsSettingsViewModel
    let strings: AppStrings

    var body: some View {
        @Bindable var viewModel = viewModel
        Form {
            Section {
                SettingsControlRow(
                    label: strings[.serverURL],
                    hints: [strings[.serverURLHelp]]
                ) {
                    TextField(strings[.serverURL], text: $viewModel.serverURL)
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.URL)
                        .accessibilityLabel(strings[.serverURL])
                        .accessibilityIdentifier("jenkins-url")
                }

                SettingsControlRow(label: strings[.username]) {
                    TextField(strings[.username], text: $viewModel.username)
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.username)
                        .accessibilityLabel(strings[.username])
                        .accessibilityIdentifier("jenkins-user")
                }

                SettingsControlRow(
                    label: strings[.apiToken],
                    hints: [strings[.apiTokenHelp], strings[.permissionsHelp]]
                ) {
                    SecureField(strings[.apiToken], text: $viewModel.token)
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                        .accessibilityLabel(strings[.apiToken])
                        .accessibilityIdentifier("jenkins-token")
                }
            }

            Section {
                SettingsControlRow(label: strings[.refreshInterval]) {
                    HStack(spacing: UIConstants.Settings.hintSpacing) {
                        TextField(
                            strings[.refreshInterval],
                            value: $viewModel.refreshInterval,
                            format: .number
                        )
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(width: UIConstants.Settings.numericFieldWidth)
                        .accessibilityLabel(strings[.refreshInterval])
                        .accessibilityIdentifier("jenkins-refresh-interval")
                        Text(strings[.seconds])
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if viewModel.connectionIdentityChanged {
                Label(strings[.connectionChangeWarning], systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Section {
                HStack {
                    Button(strings[.testConnection]) {
                        Task { await viewModel.testConnection() }
                    }
                    .disabled(!viewModel.canSubmit || viewModel.testState == .testing)
                    .accessibilityIdentifier("test-connection")

                    if viewModel.testState == .testing {
                        ProgressView().controlSize(.small)
                    } else if viewModel.testState == .success {
                        Label(strings[.connectionSuccessful], systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if case .failure = viewModel.testState {
                        Label(strings[.connectionError], systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }

                    Spacer()
                    Button(strings[.save]) { viewModel.save() }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.canSubmit)
                        .accessibilityIdentifier("save-jenkins-settings")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(strings[.jenkins])
    }
}

private struct SettingsControlRow<Control: View>: View {
    let label: String
    let hints: [String]
    let control: Control

    init(
        label: String,
        hints: [String] = [],
        @ViewBuilder control: () -> Control
    ) {
        self.label = label
        self.hints = hints
        self.control = control()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Settings.hintSpacing) {
            HStack(alignment: .firstTextBaseline, spacing: UIConstants.Settings.rowSpacing) {
                Text(label)
                    .frame(width: UIConstants.Settings.labelWidth, alignment: .leading)
                control
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
            ForEach(hints, id: \.self) { hint in
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(
                        .leading,
                        UIConstants.Settings.labelWidth + UIConstants.Settings.rowSpacing
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
