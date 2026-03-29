import Foundation

class ClaudeProvider: AIProvider {
    let name = "Claude Code"
    let iconName = "terminal.fill"
    let command = "claude"
    let supportsPipeMode = true
    let supportsImageInput = true

    var baseArgs: [String] = []

    var configurableFlags: [ProviderFlag] = [
        ProviderFlag(id: "permission-mode", label: "Permission Mode", type: .selection([
            "default", "auto", "bypassPermissions", "plan", "acceptEdits"
        ])),
        ProviderFlag(id: "model", label: "Model", type: .selection([
            "opus", "sonnet", "haiku"
        ])),
        ProviderFlag(id: "effort", label: "Effort", type: .selection([
            "low", "medium", "high", "max"
        ])),
        ProviderFlag(id: "dangerously-skip-permissions", label: "Skip Permissions", type: .toggle),
        ProviderFlag(id: "system-prompt", label: "System Prompt", type: .freeText),
    ]

    func buildLaunchCommand(workingDirectory: String) -> String {
        let escaped = "'" + workingDirectory.replacingOccurrences(of: "'", with: "'\\''") + "'"
        var parts = [command] + baseArgs
        for flag in configurableFlags {
            if let args = flag.toArgs() {
                parts.append(contentsOf: args)
            }
        }
        // Only auto-launch if CLAUDE.md exists in the directory
        let claudeMdPath = (workingDirectory as NSString).appendingPathComponent("CLAUDE.md")
        if FileManager.default.fileExists(atPath: claudeMdPath) {
            return "cd \(escaped) && clear && \(parts.joined(separator: " "))"
        } else {
            return "cd \(escaped) && clear"
        }
    }

    // MARK: - Status Detection

    private static let spinnerCharacters: Set<Character> = ["·", "✢", "✳", "✶", "✻", "✽"]

    func detectStatus(visibleText: String, fullText: String) -> TerminalStatus {
        if Self.hasTokenCounterLine(visibleText) || fullText.contains("esc to interrupt") {
            return .working
        }
        if fullText.contains("Esc to cancel") || Self.hasUserPrompt(fullText) {
            return .waitingForInput
        }
        if visibleText.contains("Interrupted") {
            return .interrupted
        }
        return .idle
    }

    private static func hasUserPrompt(_ text: String) -> Bool {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        return lines.contains { line in
            let trimmed = line.drop(while: { $0 == " " })
            return trimmed.hasPrefix("❯") &&
                trimmed.dropFirst().first == " " &&
                trimmed.dropFirst(2).first?.isNumber == true
        }
    }

    private static func hasTokenCounterLine(_ text: String) -> Bool {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        return lines.contains { line in
            guard let first = line.first, spinnerCharacters.contains(first) else { return false }
            guard line.dropFirst().first == " " else { return false }
            return line.contains("…")
        }
    }
}
