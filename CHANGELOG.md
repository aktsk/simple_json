# Changelog
All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [Unreleased]

## [1.0.0] - 2026-01-28
### Breaking
- Templates are no longer executed by invoking lambdas directly; they are compiled into methods.

### Changed
- Cache template methods by code hash to reduce Ruby method cache invalidation.
- Use a renderer subclass that includes helpers instead of extending instances.

### Fixed
- Rename the config key `cache_enabled` to `template_cache_enabled`.
- Add `/vendor/bundle` to `.gitignore`.

## [0.1.0] - 2025-09-10
### Changed
- Default JSON serializer switched from Oj to ActiveSupport::JSON to better align with Rails defaults.
- Development dependencies refreshed and benchmark script fixed for the latest Ruby/Rails stacks.
- README formatting and examples improved for clarity.

### Fixed
- Resolved `MissingTemplate` errors introduced by the Rails 8 upgrade.
- Added coverage for rendering when template/action names differ to avoid regressions.

## [0.0.0] - 2021-11-02
### Added
- Initial SimpleJson renderer, templates (`.simple_json.rb` lambdas), and `SimpleJson::SimpleJsonRenderable` integration.
- Template caching toggle and configurable template paths.
- Rails generator hooks and dummy app scaffolding for getting started.
- Migration helpers for comparing SimpleJson output against existing Jbuilder views.
