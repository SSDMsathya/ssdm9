from fastapi import APIRouter, HTTPException
from datetime import datetime
import random

router = APIRouter(prefix="/subscription", tags=["Subscription"])

@router.get("/test")
def test_subscription():
    """Check if the subscription router is active"""
    return {"status": "ok", "message": "Subscription routes are active"}

@router.post("/start")
def start_subscription(month: str, unit_id: str, created_by: str = "userabc"):
    try:
        now = datetime.now()
        mmyy = now.strftime("%m%y")
        random_suffix = random.randint(100, 999)
        subscription_id = f"SUB-{unit_id}-{mmyy}-{random_suffix}"

        return {
            "message": "New subscription draft created",
            "subscription_id": subscription_id,
            "month": month,
            "unit_id": unit_id,
            "created_by": created_by,
            "status": "Draft",
            "next_step": "Add Customers"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))