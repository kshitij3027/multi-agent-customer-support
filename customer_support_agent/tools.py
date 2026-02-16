def escalate_to_human(
    customer_name: str, issue_summary: str, reason: str
) -> dict:
    """Escalate a customer issue to a human support agent.

    Use this tool when the issue requires human intervention, such as
    suspended accounts, urgent matters, or cases that cannot be resolved
    by automated agents.

    Args:
        customer_name: The name of the customer whose issue needs escalation.
        issue_summary: A brief summary of the customer's issue.
        reason: Why this issue needs human intervention.

    Returns:
        A confirmation dict with escalation details.
    """
    return {
        "status": "escalated",
        "message": (
            f"Issue for {customer_name} has been escalated to a human agent."
        ),
        "details": {
            "customer_name": customer_name,
            "issue_summary": issue_summary,
            "reason": reason,
            "escalation_id": "ESC-001",
            "estimated_response_time": "2 hours",
        },
    }
