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
│  Agent   │ │  Agent   │ │  Agent   │ │  Agent   │
│  (MCP)   │ │  (MCP)   │ │  (A2A)   │ │          │
└────┬─────┘ └────┬─────┘ └────┬─────┘ └──────────┘
     │            │            │
     ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ Supabase │ │ Supabase │ │ Returns  │
│(via MCP) │ │(via MCP) │ │ Service  │
└──────────┘ └──────────┘ └──────────┘
```

## Tech Stack

- **Agent Framework**: Google ADK (Agent Development Kit)
- **Database**: Supabase (PostgreSQL)
- **MCP**: Supabase MCP server for database access
- **A2A**: Agent-to-Agent protocol for Returns Agent

## Setup

_Setup instructions coming soon._

## Test Scenarios

1. **Billing Query (MCP)** - Customer asks about billing/invoice details
2. **Returns Request (A2A)** - Customer requests a product return
3. **Escalation** - Complex issue that requires human handoff
