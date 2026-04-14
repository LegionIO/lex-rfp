# lex-rfp

Generative AI-powered RFP and proposal automation for [LegionIO](https://github.com/LegionIO/LegionIO). Ingests past proposals and product documentation into Apollo, generates draft RFP responses via the LLM pipeline with RAG retrieval, provides human-in-the-loop review workflows, and tracks win rates with quality analytics.

## Architecture

Monolith-style extension with four sub-modules:

| Sub-Module | Purpose |
|------------|---------|
| **Ingest** | Document parsing (PDF, DOCX, Markdown, Excel, HTML), text chunking, corpus management, Apollo ingestion |
| **Generate** | Draft response generation via LLM + RAG, section-by-section and full-document modes, template system |
| **Review** | Human-in-the-loop workflows, section-level status tracking, comments, approvals |
| **Analytics** | Win rate tracking, proposal metrics, response time stats, quality scoring |

## Installation

```bash
gem install lex-rfp
```

Or add to your Gemfile:

```ruby
gem 'lex-rfp'
```

## Usage

### Standalone Clients

Each sub-module provides a standalone `Client` class:

```ruby
# Ingest documents
ingest = Legion::Extensions::Rfp::Ingest::Client.new
result = ingest.ingest_document(file_path: 'past_proposal.pdf', tags: ['healthcare'])
chunks = result[:result]

# Generate RFP responses
gen = Legion::Extensions::Rfp::Generate::Client.new
draft = gen.generate_response(question: 'Describe your network coverage')

# Review workflow
review = Legion::Extensions::Rfp::Review::Client.new
wf = review.create_workflow(proposal_id: 'prop-123', sections: %w[summary approach pricing])
review.submit_for_review(workflow_id: wf[:result][:id], reviewers: ['reviewer-1'])

# Analytics
analytics = Legion::Extensions::Rfp::Analytics::Client.new
rate = analytics.overall_win_rate(proposals: proposal_data)
```

### Ingest Functions

- `supported?(file_path:)` - Check if a file format is supported
- `extract_text(file_path:)` - Extract text from a document
- `chunk_text(text:, chunk_size:, overlap:)` - Split text into overlapping chunks
- `ingest_document(file_path:, tags:, metadata:)` - Full document ingest pipeline
- `ingest_directory(directory:, tags:, recursive:)` - Batch ingest all supported files
- `ingest_to_apollo(chunks:, scope:)` - Push chunks to Apollo knowledge store
- `parse_rfp_questions(text:)` - Extract numbered questions from RFP text
- `extract_requirements(text:)` - Identify mandatory and preferred requirements
- `extract_sections(text:)` - Split RFP into logical sections

### Generate Functions

- `generate_full_draft(rfp_text:, context:, model:)` - Generate complete RFP response
- `generate_response(question:, context:, model:, scope:)` - Generate single question response with RAG
- `regenerate(question:, previous_answer:, feedback:)` - Revise response based on feedback
- `generate_section_response(question:, section:, context:)` - Section-specific response
- `generate_executive_summary(rfp_text:, company_context:)` - Executive summary generation
- `generate_compliance_matrix(requirements:, capabilities:)` - Compliance matrix
- `list_templates` / `get_template(name:)` / `apply_template(name:, rfp_data:)` - Template management
- `suggest_template(rfp_text:)` - Auto-suggest appropriate template

### Review Functions

- `create_workflow(proposal_id:, sections:, reviewers:)` - Create review workflow
- `update_status(workflow_id:, status:)` / `update_section_status(...)` - Status management
- `submit_for_review(workflow_id:, reviewers:)` - Submit for review
- `finalize(workflow_id:)` - Finalize proposal
- `add_comment(...)` / `resolve_comment(...)` / `request_revision(...)` - Comment system
- `approve_section(...)` / `reject_section(...)` / `approve_proposal(...)` - Approvals
- `check_readiness(sections:)` - Check if all sections are approved

### Analytics Functions

- `record_proposal(proposal_id:, rfp_source:, ...)` - Record proposal metadata
- `record_outcome(proposal_id:, outcome:, revenue:)` - Record win/loss outcome
- `summary(proposals:)` - Aggregate statistics
- `response_time_stats(proposals:)` - Response time analysis
- `overall_win_rate(proposals:)` - Overall win rate
- `win_rate_by_source(proposals:)` / `win_rate_by_template(proposals:)` - Segmented rates
- `trend(proposals:, period:)` - Win rate trends over time
- `score_response(response_text:, question:, requirements:)` - Quality scoring
- `score_proposal(sections:)` - Full proposal quality score
- `quality_report(proposals:)` - Aggregate quality report

## Supported Document Formats

- PDF (via legion-data Extract)
- DOCX (via legion-data Extract)
- Markdown (.md, .markdown)
- Excel (.xlsx, via legion-data Extract)
- HTML (.html, .htm)

## Requirements

- Ruby >= 3.4
- [LegionIO](https://github.com/LegionIO/LegionIO) framework
- `faraday` (>= 2.0)
- Optional: `legion-llm` for LLM-powered generation
- Optional: `legion-apollo` for RAG retrieval
- Optional: `legion-data` for PDF/DOCX/Excel extraction

## License

MIT
