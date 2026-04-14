# Changelog

## [Unreleased]

## [0.1.0] - 2026-04-14

### Added
- Initial scaffold with monolith architecture (4 sub-modules)
- Ingest sub-module: corpus loading for PDF, DOCX, Markdown, Excel, HTML documents
- Generate sub-module: draft RFP response generation via LLM pipeline with RAG
- Review sub-module: human-in-the-loop workflow with section-level status tracking
- Analytics sub-module: win rate tracking, proposal metrics, and quality scoring
- Standalone Client classes for each sub-module
- Full RSpec test suite
- GitHub Actions CI workflow
