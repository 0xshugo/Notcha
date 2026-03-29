# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Build

```bash
xcodebuild -project Notcha.xcodeproj -scheme Notcha -configuration Debug build
```

Or open `Notcha.xcodeproj` in Xcode and build (Cmd+B).

## Overview

Notcha is a macOS menu bar app that provides a floating terminal panel anchored to the MacBook notch, with support for **multiple AI backends** (Claude Code, Ollama, LM Studio). Forked from [adamlyttleapps/notchy](https://github.com/adamlyttleapps/notchy).

## Architecture

### AI Provider System

The core abstraction is the `AIProvider` protocol (`AIProvider.swift`):
- Each provider defines its launch command, configurable flags, and status detection logic
- `ProviderRegistry` manages available providers and creates instances
- Providers: `ClaudeProvider`, `OllamaProvider`, `LMStudioProvider`

### Key Components

- **NotchWindow** — Invisible NSPanel over the MacBook notch, hover detection, bounce animation
- **TerminalPanel** — Floating NSPanel with embedded terminal sessions
- **SessionStore** — Observable singleton managing sessions, Xcode detection, persistence
- **TerminalManager** — Terminal process lifecycle, delegates status detection to provider
- **SessionTabBar** — Tab UI with provider icons, right-click for provider settings
- **ProviderSettingsView** — SwiftUI sheet for configuring provider flags per session

### Session Flow

1. User clicks "+" menu → selects AI provider
2. `SessionStore.createSessionWithProvider()` creates a `TerminalSession` with the chosen provider
3. `TerminalManager.terminal(for:)` spawns shell, sends `provider.buildLaunchCommand()`
4. `ClickThroughTerminalView.evaluateStatus()` calls `provider.detectStatus()` for status updates

## Dependencies

- **SwiftTerm** (`migueldeicaza/SwiftTerm`) — terminal emulator view

## Adding a New Provider

1. Create `Notcha/Providers/MyProvider.swift` conforming to `AIProvider`
2. Add factory to `ProviderRegistry.factories`
3. Build and test
