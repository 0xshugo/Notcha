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
        return "cd \(escaped) && clear && opencode"
    }

    /// Tracks when we last saw data change — used for activity-based detection
    private var lastContentHash: Int = 0
    private var unchangedCount: Int = 0

    func detectStatus(visibleText: String, fullText: String) -> TerminalStatus {
        // OpenCode is a full-screen TUI app. Text-based keyword detection
        // doesn't work reliably because the TUI chrome always contains
        // words like "Reading", "Message", etc.
        //
        // Strategy: detect based on content change frequency.
        // If the buffer is changing rapidly → working
        // If the buffer is stable → waitingForInput (TUI is idle, waiting for user)

        let currentHash = fullText.hashValue

        if currentHash != lastContentHash {
            lastContentHash = currentHash
            unchangedCount = 0
            return .working
        } else {
            unchangedCount += 1
            // After ~3 stable checks (150ms debounce × 3 = ~450ms stable),
            // consider it idle/waiting for input
            if unchangedCount >= 3 {
                return .waitingForInput
            }
            return .working
        }
    }
}
