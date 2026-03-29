import Foundation

/// Central registry of available AI providers
class ProviderRegistry {
    static let shared = ProviderRegistry()

    /// All registered provider factories (creates fresh instance each time)
    private let factories: [() -> AIProvider] = [
        { ClaudeProvider() },
        { OpenCodeProvider() },
        { OllamaProvider() },
        { LMStudioProvider() },
    ]

    /// Available provider names
    var availableNames: [String] {
        factories.map { $0().name }
    }

    /// Create a new provider instance by name
    func createProvider(named name: String) -> AIProvider? {
        for factory in factories {
            let provider = factory()
            if provider.name == name {
                return provider
            }
        }
        return nil
    }

    /// Create a default provider (Claude Code)
    func createDefault() -> AIProvider {
        ClaudeProvider()
    }
}
