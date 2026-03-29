import Foundation

class LMStudioProvider: AIProvider {
    let name = "LM Studio"
    let iconName = "cpu"
    let command = "lms"
    let supportsPipeMode = true
    let supportsImageInput = false

    var baseArgs: [String] = ["chat"]

    var configurableFlags: [ProviderFlag] = [
        ProviderFlag(id: "model", label: "Model", type: .freeText),
        ProviderFlag(id: "context-length", label: "Context Length", type: .freeText),
    ]

    func buildLaunchCommand(workingDirectory: String) -> String {
        let escaped = "'" + workingDirectory.replacingOccurrences(of: "'", with: "'\\''") + "'"
        var parts = ["lms", "chat"]
        if let model = configurableFlags.first(where: { $0.id == "model" })?.value, !model.isEmpty {
            parts.append(contentsOf: ["--model", model])
        }
        if let ctx = configurableFlags.first(where: { $0.id == "context-length" })?.value, !ctx.isEmpty {
            parts.append(contentsOf: ["--context-length", ctx])
        }
        return "cd \(escaped) && clear && \(parts.joined(separator: " "))"
    }

    func detectStatus(visibleText: String, fullText: String) -> TerminalStatus {
        let lines = fullText.split(separator: "\n", omittingEmptySubsequences: false)
        let lastNonBlank = lines.last(where: { !$0.allSatisfy({ $0 == " " }) }) ?? ""
        let trimmed = lastNonBlank.trimmingCharacters(in: .whitespaces)

        // LM Studio chat shows ">" when waiting for input
        if trimmed == ">" || trimmed.hasPrefix("> ") {
            return .waitingForInput
        }

        // Streaming output = working
        if !trimmed.isEmpty && trimmed != ">" {
            return .working
        }

        return .idle
    }
}
