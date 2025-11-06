from fastapi import APIRouter, HTTPException
from datetime import datetime, date, timedelta
import random, uuid, json
from typing import Optional, List
from sqlalchemy import text
from backend.db_connect import engine  # use SQLAlchemy engine (no get_db / Depends)

router = APIRouter(prefix="/subscription", tags=["Subscription"])

# ---------------------------------------------------------------------
# Sanity check endpoints
# ---------------------------------------------------------------------
@router.get("/test")
def test_subscription():
    """Check if the subscription router is active"""
    return {"status": "ok", "message": "Subscription routes are active"}

@router.post("/start")
def start_subscription(month: str, unit_id: str, created_by: str = "userabc"):
    """Generate a draft subscription header"""
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

# ---------------------------------------------------------------------
# SSDM9 Subscription routes (Phase 1)
# ---------------------------------------------------------------------
from pydantic import BaseModel

class SubscriptionService(BaseModel):
    service_id: int
    start_date: date
    end_date: date
    recurrence: Optional[str] = "DAILY"
    unit_id: Optional[int] = None
    customer_id: Optional[int] = None

class SubscriptionRequestIn(BaseModel):
    unit_id: int
    customer_id: int
    month_code: str
    services: List[SubscriptionService]
    remarks: Optional[str] = None
    client_request_id: Optional[str] = None

def expand_dates(start: date, end: date, recurrence: str):
    dates = []
    if recurrence and recurrence.upper() == "DAILY":
        cur = start
        while cur <= end:
            dates.append(cur)
            cur += timedelta(days=1)
    return dates

@router.post("/request")
def create_subscription_request(payload: SubscriptionRequestIn):
    """
    TX-1: Insert a draft subscription request (idempotent by client_request_id).
    Uses SQLAlchemy engine; no Depends(get_db) and no .cursor().
    """
    client_request_id = payload.client_request_id or str(uuid.uuid4())

    try:
        with engine.begin() as conn:
            # Idempotency check
            row = conn.execute(
                text("SELECT request_id FROM ssdm9_subscription_requests WHERE client_request_id = :cid"),
                {"cid": client_request_id}
            ).fetchone()
            if row:
                return {"request_id": row[0], "client_request_id": client_request_id, "status": "DRAFT"}

            # Insert draft
            request_id = conn.execute(
                text("""
                    INSERT INTO ssdm9_subscription_requests
                    (client_request_id, unit_id, customer_id, month_code, payload, status)
                    VALUES (:cid, :uid, :cust, :month, :payload, 'DRAFT')
                    RETURNING request_id
                """),
                {
                    "cid": client_request_id,
                    "uid": payload.unit_id,
                    "cust": payload.customer_id,
                    "month": payload.month_code,
                    "payload": json.dumps(payload.dict(), default=str),
                }
            ).scalar()

        return {"request_id": request_id, "client_request_id": client_request_id, "status": "DRAFT"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"create_subscription_request error: {e}")

@router.post("/{request_id}/approve")
def approve_subscription(request_id: int):
    raise HTTPException(status_code=501, detail="Approve endpoint will be enabled after master tables are created.")

@router.post("/{subscription_id}/activate")
def activate_subscription(subscription_id: int):
    raise HTTPException(status_code=501, detail="Activate endpoint will be enabled after delivery expansion is ready.")