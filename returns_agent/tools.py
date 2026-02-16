def check_return_eligibility(
    order_id: int,
    order_status: str,
    return_eligible: bool,
    order_date: str,
    delivery_date: str,
) -> dict:
    """Check whether an order is eligible for return.

    The agent should first query the database for the order details, then
    pass them to this tool for a business-rule evaluation.

    Args:
        order_id: The order ID to check.
        order_status: Current status of the order (e.g. 'delivered', 'shipped').
        return_eligible: The return_eligible flag from the orders table.
        order_date: The order date as a string (ISO format).
        delivery_date: The delivery date as a string, or empty if not delivered.

    Returns:
        A dict with 'eligible' (bool), 'order_id', and 'reason'.
    """
    if order_status != "delivered":
        return {
            "eligible": False,
            "order_id": order_id,
            "reason": (
                f"Order #{order_id} is not eligible for return because it has "
                f"not been delivered yet (current status: {order_status})."
            ),
        }

    if not return_eligible:
        return {
            "eligible": False,
            "order_id": order_id,
            "reason": (
                f"Order #{order_id} is not eligible for return. "
                "This item is outside the return window or is a non-returnable product."
            ),
        }

    if not delivery_date:
        return {
            "eligible": False,
            "order_id": order_id,
            "reason": (
                f"Order #{order_id} is marked as delivered but has no delivery "
                "date on record. Please contact support for assistance."
            ),
        }

    return {
        "eligible": True,
        "order_id": order_id,
        "reason": (
            f"Order #{order_id} is eligible for return. "
            "The item was delivered and is within the return window."
        ),
    }


def initiate_return(
    order_id: int,
    customer_name: str,
    product_name: str,
    reason: str,
) -> dict:
    """Initiate a return for an eligible order.

    Only call this tool after check_return_eligibility has confirmed
    the order is eligible AND the customer has confirmed they want to proceed.

    Args:
        order_id: The order ID to return.
        customer_name: Name of the customer requesting the return.
        product_name: Name of the product being returned.
        reason: The customer's reason for the return.

    Returns:
        A dict with return confirmation details including an RMA number.
    """
    rma_number = f"RMA-{order_id:04d}"
    return {
        "status": "return_initiated",
        "message": (
            f"Return initiated for {customer_name}'s order #{order_id} ({product_name})."
        ),
        "details": {
            "rma_number": rma_number,
            "order_id": order_id,
            "product_name": product_name,
            "customer_name": customer_name,
            "reason": reason,
            "instructions": (
                f"Please ship the item back using the prepaid label sent to your "
                f"email. Reference RMA number {rma_number} on the package. "
                f"Refund will be processed within 5-7 business days after we "
                f"receive the item."
            ),
        },
    }
