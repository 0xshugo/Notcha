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

    func detectStatus(visibleText: String, fullText: String) -> TerminalStatus {
        // OpenCode is a full-screen TUI app that continuously redraws
        // (cursor blink, clock, etc.), making terminal buffer analysis
        // unreliable for status detection.
        //
        // OpenCode has its own built-in status UI, so we stay idle
        // and let OpenCode handle status display internally.
        return .idle
    }
}
