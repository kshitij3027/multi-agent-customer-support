# Multi-Agent Customer Support System

A multi-agent customer support system built with Google ADK, MCP (Model Context Protocol), and A2A (Agent-to-Agent) communication.

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Root Router Agent               │
│            (routes customer queries)             │
├────────────────┬────────────────┬────────────────┤
│                │                │                │
▼                ▼                ▼                ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Billing  │ │  Order   │ │ Returns  │ │Escalation│
│  Agent   │ │  Agent   │ │  Agent   │ │  (Tool)  │
│  (MCP)   │ │  (MCP)   │ │  (A2A)   │ │          │
└────┬─────┘ └────┬─────┘ └────┬─────┘ └──────────┘
     │            │            │
     ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────────────┐
│ Supabase │ │ Supabase │ │ Returns A2A Svc  │
│(via MCP) │ │(via MCP) │ │ (port 8001, MCP) │
└──────────┘ └──────────┘ └──────────────────┘
```

- **Root Router Agent** — classifies customer intent and routes to the right specialist
- **Billing Agent** — handles billing inquiries via Supabase MCP (read-only SQL)
- **Order Status Agent** — handles order tracking via Supabase MCP (read-only SQL)
- **Returns Agent** — runs as a separate A2A service on port 8001; has its own Supabase MCP connection plus `check_return_eligibility` and `initiate_return` tools
- **Escalation** — the root agent calls `escalate_to_human` directly for suspended accounts or urgent issues (no sub-agent transfer)

## Tech Stack

- **Agent Framework**: Google ADK (Agent Development Kit)
- **LLM**: Gemini 2.5 Flash
- **Database**: Supabase (PostgreSQL)
- **MCP**: Supabase MCP server for database access
- **A2A**: Agent-to-Agent protocol for the Returns Agent service

## Setup

### Prerequisites

- Python 3.10+
- Node.js / npm (for the Supabase MCP server)
- A Supabase project with the schema and seed data from `supabase/`

### Installation

```bash
# Create and activate a virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -e .
```

### Environment Variables

Create `.env` files in both agent directories:

**`customer_support_agent/.env`**
```
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=<your-gemini-api-key>
SUPABASE_ACCESS_TOKEN=<your-supabase-access-token>
```

**`returns_agent/.env`**
```
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=<your-gemini-api-key>
SUPABASE_ACCESS_TOKEN=<your-supabase-access-token>
```

### Running

```bash
# Start both agents (returns A2A on port 8001, ADK Web UI on port 8000)
./start.sh

# Open the ADK Web UI
open http://localhost:8000

# Stop everything
./stop.sh
```

## Test Scenarios

Select **`customer_support_router`** from the agent dropdown in the ADK Web UI, then run these three scenarios (start a new session between each).

### Scenario 1: Billing Query (MCP path)

| | |
|---|---|
| **What it proves** | Root agent routes to `billing_agent`, which queries Supabase via MCP (`execute_sql` tool) |
| **Query** | `Hi, I'm Alice Johnson. I was overcharged on my USB-C Cable order. Can you look into it?` |
| **Expected flow** | Router → `billing_agent` → MCP `execute_sql` (SELECT from customers + orders + support_tickets) → finds Alice (customer #1), order #1 ($31.98), open ticket about $6 overcharge → presents findings |
| **What to look for** | Tool call to `execute_sql` with a SELECT query visible in the trace; billing_agent responding with order/charge details |

### Scenario 2: Returns Request (A2A path)

| | |
|---|---|
| **What it proves** | Root agent routes to `returns_agent` via A2A (`RemoteA2aAgent` → port 8001), which queries Supabase and calls `check_return_eligibility` |
| **Query** | `I'd like to return my Wireless Earbuds Pro. My name is David Kim.` |
| **Expected flow** | Router → `returns_agent` (A2A call) → MCP `execute_sql` (looks up David, order #4) → `check_return_eligibility` (order_id=4, status=delivered, return_eligible=true) → reports eligible → asks to confirm → on confirm, calls `initiate_return` → returns RMA number |
| **What to look for** | A2A transfer to returns_agent visible in trace; `check_return_eligibility` tool call showing eligible=true; if you confirm, `initiate_return` tool call with RMA-0004 |

**Bonus negative test:** Start a new session and try: `I want to return my USB Hub. My name is Karen Brooks.` — Karen's USB Hub (order #13) has `return_eligible=false`, so the agent should deny the return.

### Scenario 3: Escalation (direct tool call)

| | |
|---|---|
| **What it proves** | Root agent recognizes a suspended-account/urgent issue and calls `escalate_to_human` directly (does NOT route to a sub-agent) |
| **Query** | `My account has been suspended without notice. I'm Jack Thompson and I have urgent pending orders. Please help!` |
| **Expected flow** | Router detects "suspended account" + urgency → calls `escalate_to_human(customer_name="Jack Thompson", ...)` → returns escalation confirmation with ESC-001 and 2-hour response time |
| **What to look for** | `escalate_to_human` tool call visible in the trace (NOT a transfer to a sub-agent); response includes escalation_id and estimated_response_time |
