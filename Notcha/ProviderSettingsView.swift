import SwiftUI

/// A sheet that lets the user configure provider flags for a session
struct ProviderSettingsView: View {
    let sessionId: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var flags: [ProviderFlag] = []
    @State private var providerName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(providerName) Settings")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button("Done") { applyAndDismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
            }

            Divider()

            if flags.isEmpty {
                Text("No configurable options for this provider.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            } else {
                ForEach($flags) { $flag in
                    FlagRow(flag: $flag)
                }
            }

            Spacer()
        }
        .padding(16)
        .frame(width: 360, height: CGFloat(max(flags.count, 1)) * 44 + 80)
        .background(Color(nsColor: NSColor(white: 0.12, alpha: 1.0)))
        .onAppear { loadFlags() }
    }

    private func loadFlags() {
        guard let session = SessionStore.shared.sessions.first(where: { $0.id == sessionId }) else { return }
        providerName = session.provider.name
        flags = session.provider.configurableFlags
    }

    private func applyAndDismiss() {
        guard let index = SessionStore.shared.sessions.firstIndex(where: { $0.id == sessionId }) else {
            dismiss()
            return
        }
        SessionStore.shared.sessions[index].provider.configurableFlags = flags
        dismiss()
    }
}

struct FlagRow: View {
    @Binding var flag: ProviderFlag

    var body: some View {
        HStack {
            Text(flag.label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 120, alignment: .leading)

            switch flag.type {
            case .toggle:
                Toggle("", isOn: Binding(
                    get: { flag.value == "true" },
                    set: { flag.value = $0 ? "true" : nil }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)

            case .selection(let options):
                Picker("", selection: Binding(
                    get: { flag.value ?? "" },
                    set: { flag.value = $0.isEmpty ? nil : $0 }
                )) {
                    Text("—").tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)

            case .freeText:
                TextField("", text: Binding(
                    get: { flag.value ?? "" },
                    set: { flag.value = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11))
            }
        }
        .frame(height: 28)
    }
}
