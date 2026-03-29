import Foundation

/// Represents a configurable launch flag for an AI provider
struct ProviderFlag: Identifiable {
    let id: String          // e.g. "permission-mode"
    let label: String       // e.g. "Permission Mode"
    let type: FlagType
    var value: String?

    enum FlagType {
        case toggle                     // --dangerously-skip-permissions
        case selection([String])        // --model [opus, sonnet, haiku]
        case freeText                   // --system-prompt "..."
    }

    /// Renders this flag as CLI arguments, or nil if not set
    func toArgs() -> [String]? {
        switch type {
        case .toggle:
            return value == "true" ? ["--\(id)"] : nil
        case .selection:
            guard let v = value, !v.isEmpty else { return nil }
            return ["--\(id)", v]
        case .freeText:
            guard let v = value, !v.isEmpty else { return nil }
            return ["--\(id)", v]
        }
    }
}

/// Terminal status detected by parsing terminal output
enum TerminalStatus: Equatable {
    case idle
    case working
    case waitingForInput
    case interrupted
    case taskCompleted
}

/// Protocol that all AI backend providers must conform to
protocol AIProvider {
    /// Display name shown in UI
    var name: String { get }

    /// SF Symbol name for the tab/menu icon
    var iconName: String { get }

    /// The executable command (e.g. "claude", "ollama")
    var command: String { get }

    /// Arguments to pass before any user flags
    var baseArgs: [String] { get }

    /// User-configurable flags
    var configurableFlags: [ProviderFlag] { get set }

    /// Whether this provider supports the -p / pipe style one-shot mode
    var supportsPipeMode: Bool { get }

    /// Whether this provider can accept image input
    var supportsImageInput: Bool { get }

    /// Build the full shell command to send into the terminal
    func buildLaunchCommand(workingDirectory: String) -> String

    /// Parse terminal output and return the detected status
    func detectStatus(visibleText: String, fullText: String) -> TerminalStatus
}

extension AIProvider {
    /// Default implementation: cd to dir && command args
    func buildLaunchCommand(workingDirectory: String) -> String {
        let escaped = "'" + workingDirectory.replacingOccurrences(of: "'", with: "'\\''") + "'"
        var parts = [command] + baseArgs
        for flag in configurableFlags {
            if let args = flag.toArgs() {
                parts.append(contentsOf: args)
            }
        }
        return "cd \(escaped) && clear && \(parts.joined(separator: " "))"
    }
}
