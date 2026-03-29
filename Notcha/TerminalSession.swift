import Foundation

struct TerminalSession: Identifiable {
    let id: UUID
    var projectName: String
    var projectPath: String?
    var workingDirectory: String
    var hasStarted: Bool
    var terminalStatus: TerminalStatus
    var generation: Int
    /// Whether the user has ever manually selected this tab
    var hasBeenSelected: Bool
    let createdAt: Date
    /// When the session most recently entered the .working state
    var workingStartedAt: Date?
    /// The AI provider for this session
    var provider: AIProvider
    /// Provider name for persistence
    var providerName: String

    init(projectName: String, projectPath: String? = nil, workingDirectory: String? = nil, started: Bool = false, provider: AIProvider? = nil) {
        self.id = UUID()
        self.projectName = projectName
        self.projectPath = projectPath
        self.workingDirectory = workingDirectory ?? projectPath ?? NSHomeDirectory()
        self.hasStarted = started
        self.terminalStatus = .idle
        self.generation = 0
        self.hasBeenSelected = started
        self.createdAt = Date()
        self.provider = provider ?? ProviderRegistry.shared.createDefault()
        self.providerName = self.provider.name
    }

    /// Restore a session from persisted data
    init(persisted: PersistedSession) {
        self.id = persisted.id
        self.projectName = persisted.projectName
        self.projectPath = persisted.projectPath
        self.workingDirectory = persisted.workingDirectory
        self.hasStarted = false
        self.terminalStatus = .idle
        self.generation = 0
        self.hasBeenSelected = false
        self.createdAt = Date()
        self.provider = ProviderRegistry.shared.createProvider(named: persisted.providerName ?? "Claude Code") ?? ProviderRegistry.shared.createDefault()
        self.providerName = self.provider.name
    }
}

/// Lightweight Codable representation for UserDefaults persistence
struct PersistedSession: Codable {
    let id: UUID
    let projectName: String
    let projectPath: String?
    let workingDirectory: String
    let providerName: String?
}
