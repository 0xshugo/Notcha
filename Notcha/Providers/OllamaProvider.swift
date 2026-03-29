import Foundation

class OllamaProvider: AIProvider {
    let name = "Ollama"
    let iconName = "brain"
    let command = "ollama"
    let supportsPipeMode = true
    let supportsImageInput = false  // depends on model (llava etc.)

    var baseArgs: [String] = ["run"]

    var configurableFlags: [ProviderFlag] = [
        ProviderFlag(id: "model", label: "Model", type: .freeText, value: "qwen3-coder-next"),
    ]

    func buildLaunchCommand(workingDirectory: String) -> String {
        let escaped = "'" + workingDirectory.replacingOccurrences(of: "'", with: "'\\''") + "'"
        let model = configurableFlags.first(where: { $0.id == "model" })?.value ?? "qwen3-coder-next"
        return "cd \(escaped) && clear && ollama run \(model)"
    }

    func detectStatus(visibleText: String, fullText: String) -> TerminalStatus {
        let lines = fullText.split(separator: "\n", omittingEmptySubsequences: false)

        // Ollama shows ">>>" when waiting for input
        let lastNonBlank = lines.last(where: { !$0.allSatisfy({ $0 == " " }) }) ?? ""
        let trimmed = lastNonBlank.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix(">>>") {
            return .waitingForInput
        }

        // If there's streaming output (non-empty, no prompt), it's working
        if !trimmed.isEmpty && !trimmed.hasPrefix(">>>") {
            return .working
        }

        return .idle
    }
}
