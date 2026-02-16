import os
from pathlib import Path

from dotenv import load_dotenv

# Load .env before any os.getenv() calls — uvicorn does not auto-load .env
load_dotenv(Path(__file__).parent / ".env")

from google.adk.agents import LlmAgent
from google.adk.tools.mcp_tool import MCPToolset, StdioConnectionParams
from google.adk.a2a.utils.agent_to_a2a import to_a2a
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


returns_agent = LlmAgent(
    name="returns_agent",
    model="gemini-2.5-flash",
    description=(
        "Specialist for product returns: checking return eligibility "
        "and initiating returns for eligible orders. "
        "Has access to the customer database."
    ),
    instruction=prompts.RETURNS_AGENT_INSTRUCTION,
    tools=[
        _supabase_mcp_toolset(),
        tools.check_return_eligibility,
        tools.initiate_return,
    ],
)

a2a_app = to_a2a(returns_agent, host="localhost", port=8001)
