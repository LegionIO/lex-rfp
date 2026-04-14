# lex-rfp: RFP and Proposal Automation for LegionIO

**Repository Level 3 Documentation**
- **Category**: `/Users/miverso2/rubymine/legion/extensions/CLAUDE.md`

## Purpose

Generative AI-powered RFP and proposal automation extension. Ingests past proposals and product documentation into Apollo, generates draft RFP responses via the LLM pipeline with RAG retrieval, provides human-in-the-loop review workflows, and tracks win rates with quality analytics.

**GitHub**: https://github.com/LegionIO/lex-rfp
**License**: MIT

## Architecture

Monolith-style extension with four self-contained sub-modules:

```
Legion::Extensions::Rfp
├── Ingest/
│   ├── Runners/
│   │   ├── Documents       # Format detection, text extraction, chunking
│   │   ├── Corpus          # Document ingest pipeline, directory scanning, Apollo push
│   │   └── Parser          # RFP question extraction, requirement identification, section splitting
│   ├── Helpers/Client      # Faraday connection helper
│   └── Client              # Standalone client including all Ingest runners
├── Generate/
│   ├── Runners/
│   │   ├── Drafts          # Full draft generation, single response, regeneration with feedback
│   │   ├── Sections        # Section-specific responses, executive summary, compliance matrix
│   │   └── Templates       # Template management (standard, government, healthcare), auto-suggest
│   ├── Helpers/Client
│   └── Client
├── Review/
│   ├── Runners/
│   │   ├── Workflows       # Workflow lifecycle (create, submit, finalize), section status tracking
│   │   ├── Comments        # Comment system, revision requests, resolution
│   │   └── Approvals       # Section/proposal approval, rejection, readiness checks
│   ├── Helpers/Client
│   └── Client
└── Analytics/
    ├── Runners/
    │   ├── Metrics          # Proposal recording, outcome tracking, summary stats, response times
    │   ├── WinRates         # Overall/by-source/by-template win rates, trend analysis
    │   └── Quality          # Response quality scoring (4 dimensions), proposal scoring, aggregate reports
    ├── Helpers/Client
    └── Client
```

## Supported Document Formats

PDF, DOCX, Markdown, Excel (xlsx), HTML — PDF/DOCX/Excel extraction requires `legion-data` with Extract handlers.

## Dependencies

| Gem | Purpose |
|-----|---------|
| `faraday` (>= 2.0) | HTTP client for all sub-modules |
| `legion-llm` (optional) | LLM pipeline for response generation |
| `legion-apollo` (optional) | RAG retrieval from knowledge store |
| `legion-data` (optional) | Document extraction (PDF, DOCX, Excel) |

## Key Patterns

- **Monolith style**: Top entry point uses `require_relative` to load sub-modules; sub-module entries use bare `require`
- **Standalone Clients**: Each sub-module has its own `Client` class usable outside the framework
- **`client(**)` passthrough**: Runner methods accept `**` and pass through to `client(**)`
- **LLM integration**: Generate runners use `Legion::LLM.ask(message:)` with graceful fallback when LLM unavailable
- **Apollo integration**: Ingest pushes to Apollo via `Legion::Apollo.ingest`; Generate retrieves via `Legion::Apollo.retrieve`

## Testing

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

---

**Maintained By**: Matthew Iverson (@Esity)
