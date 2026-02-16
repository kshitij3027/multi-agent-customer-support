import os

from google.adk.agents import LlmAgent
from google.adk.agents.remote_a2a_agent import RemoteA2aAgent
from google.adk.tools.mcp_tool import MCPToolset, StdioConnectionParams
from mcp import StdioServerParameters

from . import prompts, tools

_SUPABASE_ACCESS_TOKEN = os.getenv("SUPABASE_ACCESS_TOKEN", "")
_SUPABASE_PROJECT_REF = "olcrluclpcndmdejrtyy"


def _supabase_mcp_toolset() -> MCPToolset:
    """Create an MCPToolset for the Supabase MCP server."""
    return MCPToolset(
        connection_params=StdioConnectionParams(
            server_params=StdioServerParameters(
                command="npx",
                args=[
                    "-y",
                    "@supabase/mcp-server-supabase@latest",
                    "--access-token",
                    _SUPABASE_ACCESS_TOKEN,
                    "--project-ref",
                    _SUPABASE_PROJECT_REF,
                    "--read-only",
                ],
            ),
        ),
        tool_filter=["list_tables", "execute_sql"],
    )


billing_agent = LlmAgent(
    name="billing_agent",
    model="gemini-2.5-flash",
    description=(
        "Specialist for billing inquiries: overcharges, refund disputes, "
        "invoice requests, plan pricing, and payment issues. "
        "Has access to the customer database."
    ),
    instruction=prompts.BILLING_AGENT_INSTRUCTION,
    tools=[_supabase_mcp_toolset()],
)

order_status_agent = LlmAgent(
    name="order_status_agent",
    model="gemini-2.5-flash",
    description=(
        "Specialist for order status inquiries: order tracking, shipping "
        "updates, delivery dates, and order confirmations. "
        "Has access to the customer database."
    ),
    instruction=prompts.ORDER_STATUS_AGENT_INSTRUCTION,
    tools=[_supabase_mcp_toolset()],
)

returns_agent = RemoteA2aAgent(
    name="returns_agent",
    description=(
        "Specialist for product returns: checking return eligibility "
        "and initiating returns for eligible orders."
    ),
    agent_card="http://localhost:8001/.well-known/agent-card.json",
)

root_agent = LlmAgent(
    name="customer_support_router",
    model="gemini-2.5-flash",
    description="Customer support router that directs queries to specialists.",
    instruction=prompts.ROOT_AGENT_INSTRUCTION,
    tools=[tools.escalate_to_human],
    sub_agents=[billing_agent, order_status_agent, returns_agent],
)
