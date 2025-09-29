# Repository Guidelines

## Project Structure & Module Organization
- `imageflow.xcworkspace` aggregates all apps and shared packages; open it in Xcode for end-to-end work.
- `ImageFlowKit/` is the shared Swift package. Production code now lives under `Sources/ImageFlowKit/` (feature folders inside the module), while package tests reside in `Tests/ImageFlowKitTests/`.
- `ImageFlowMac/`, `ImageFlowIPad/`, and `ImageFlowPreviews/` host platform-specific apps, UI tests, and preview scaffolding.
- `ImageFlowCodeGen/` contains helper tooling (`gen-filters.sh`) that regenerates filter definitions; run it when backend node metadata changes.

## Build, Test, and Development Commands
- `xcodebuild -workspace imageflow.xcworkspace -scheme ImageFlowMac -destination 'platform=macOS' build` compiles the macOS target.
- `xcodebuild -workspace imageflow.xcworkspace -scheme ImageFlowIPad -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' build` validates the iPad target.
- `swift test --package-path ImageFlowKit` runs package unit tests.
- `./ImageFlowCodeGen/gen-filters.sh` regenerates codegen outputs; rerun before committing schema tweaks.

## Coding Style & Naming Conventions
- Swift 5 conventions: 4-space indentation, trailing commas in multiline literals, explicit `public`/`internal` modifiers.
- Types use PascalCase; properties, functions, and enum cases use camelCase; test helpers can adopt `given_when_then` for clarity.
- Run `swiftlint lint --strict` in the repo root before pushing; inline `// swiftlint:disable` is reserved for exceptional cyclomatic sections.

## Testing Guidelines
- XCTest powers both package tests and Xcode test targets; prefer behavior-driven names such as `testAddEdgeRejectsMismatchedTypes`.
- Mirror feature folders inside `ImageFlowKit/Tests/ImageFlowKitTests/` and keep fixtures lightweight.
- Capture coverage expectations (≥80 % for touched modules) in PR descriptions when gaps exist; document any skipped UI coverage.

## Commit & Pull Request Guidelines
- Follow the concise, imperative style seen in history (`Add node palette search`, `Fix undo crash`).
- Group logical changes per commit; mention scripts executed (`gen-filters.sh`) in the body when relevant.
- PRs should include: scope summary, validation checklist (`swift test`, relevant `xcodebuild` commands), linked issues (`Fixes #123`), and screenshots/video for UI updates.

## Security & Configuration Tips
- Never commit secrets or API tokens; prefer `.xcconfig` with local overrides and keep them out of version control.
- When adding third-party packages, pin them via `Package.resolved` updates and note security considerations in the PR description.
