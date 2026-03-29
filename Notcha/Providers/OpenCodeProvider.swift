import Foundation

class OpenCodeProvider: AIProvider {
    let name = "OpenCode"
    let iconName = "chevron.left.forwardslash.chevron.right"
    let command = "opencode"
    let supportsPipeMode = true
    let supportsImageInput = false

    var baseArgs: [String] = []

    var configurableFlags: [ProviderFlag] = [
        ProviderFlag(id: "project", label: "Project Path", type: .freeText),
    ]

    func buildLaunchCommand(workingDirectory: String) -> String {
        let escaped = "'" + workingDirectory.replacingOccurrences(of: "'", with: "'\\''") + "'"
        // OpenCode auto-detects project from cwd
        return "cd \(escaped) && clear && opencode"
    }

    func detectStatus(visibleText: String, fullText: String) -> TerminalStatus {
        // OpenCode uses a rich TUI — detect based on output patterns
        // When generating: streaming text output without prompt
        // When waiting: shows input prompt area at bottom

        // OpenCode TUI shows tool calls and streaming responses
        // Look for common patterns in the rendered output
        if fullText.contains("Running") || fullText.contains("Editing") ||
           fullText.contains("Reading") || fullText.contains("Searching") ||
           fullText.contains("Writing") {
            return .working
        }

        // OpenCode shows a prompt input area — if we see it, it's waiting
        // The TUI typically has a message input field at the bottom
        let lines = fullText.split(separator: "\n", omittingEmptySubsequences: false)
        let lastNonBlank = lines.last(where: { !$0.allSatisfy({ $0 == " " }) }) ?? ""
        let trimmed = lastNonBlank.trimmingCharacters(in: .whitespaces)

        // OpenCode's TUI input prompt patterns
        if trimmed.contains("Message") || trimmed.contains(">") && trimmed.count < 20 {
            return .waitingForInput
        }

        // If there's substantial recent output, likely working
        let recentLines = lines.suffix(5).filter { !$0.allSatisfy({ $0 == " " }) }
        if recentLines.count >= 3 {
            return .working
        }

        return .idle
    }
}
