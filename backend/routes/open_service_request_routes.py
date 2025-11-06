# /Users/ssdm/Desktop/ssdm9/backend/routes/open_service_request_routes.py

from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import JSONResponse
from sqlalchemy import create_engine, text
from datetime import date
import json

# ─────────────────────────────────────────────────────────────────────────────
# 1. DB CONNECTION — make this file self-contained
# ─────────────────────────────────────────────────────────────────────────────
# NOTE: this is the SAME DSN you used in main.py
DATABASE_URL = "postgresql://postgres:ssdm123@localhost:54321/postgres"
SCHEMA = "ssdm9"
engine = create_engine(DATABASE_URL)

router = APIRouter(
    prefix="/open_service_requests",
    tags=["Open Service Request"]
)

# ─────────────────────────────────────────────────────────────────────────────
# helper: normalise external requester/payer
# ─────────────────────────────────────────────────────────────────────────────
def _norm(s):
    if s is None:
        return None
    s = str(s).strip()
    return s or None


@router.post("/")
async def create_open_service_request(request: Request):
   """
Save an OPEN SERVICE REQUEST (OSR) into its dedicated table:
ssdm9.open_service_requests

Differences vs subscription:
- request_type = 'OSR'
- period_start / period_end default to TODAY (since OSRs are one-time or same-day)
- requester can be a customer or an external person
- payer can be a customer or an external person
    - period_start / period_end default to TODAY (since OSRs are one-time or same-day)
    - requester can be a customer or an external person
    """
    Save an OPEN SERVICE REQUEST (OSR) into its dedicated table:
    ssdm9.open_service_requests

    Differences vs subscription:
    - request_type = 'OSR'
    - period_start / period_end default to TODAY (since OSRs are one-time or same-day)
    - requester can be a customer or an external person
    - payer can be a customer or an external person
    """
    try:
        body = await request.json()

        # ── required for ALL OSRs ────────────────────────────────────────────
        required_core = ["unit_id", "services"]
        missing_core = [f for f in required_core if f not in body]
        if missing_core:
            raise HTTPException(
                status_code=400,
                detail=f"Missing fields: {', '.join(missing_core)}"
            )

        unit_id = body["unit_id"]

        # requestor (either customer or external)
        req_by_cust = body.get("requested_by_customer_id")
        req_by_ext = _norm(body.get("requested_by_external_name"))

        if not req_by_cust and not req_by_ext:
            raise HTTPException(
                status_code=400,
                detail="Either requested_by_customer_id or requested_by_external_name must be provided."
            )

        # service for — must be a list (we agreed: possibly multiple residents of same unit)
        service_for = body.get("service_for_customer_ids") or []
        if not isinstance(service_for, list):
            raise HTTPException(
                status_code=400,
                detail="service_for_customer_ids must be a list (can be empty if external)."
            )

        # payer — same rule as requester: either customer or external
        payer_cust = body.get("payer_customer_id")
        payer_ext = _norm(body.get("payer_external_name"))
        if not payer_cust and not payer_ext:
            # default: if requester is a customer → requester pays
            if req_by_cust:
                payer_cust = req_by_cust
            else:
                payer_ext = req_by_ext

        # services must be non-empty list
        services = body.get("services") or []
        if not isinstance(services, list) or len(services) == 0:
            raise HTTPException(
                status_code=400,
                detail="At least one service must be supplied in 'services'."
            )

        # period defaults (OSR = usually today)
        period_start = body.get("period_start") or date.today().isoformat()
        period_end = body.get("period_end") or period_start

        # special notes
        special_instructions = body.get("special_instructions") or ""

        # build JSON payload exactly like our earlier attempts
        full_payload = {
            "unit_id": unit_id,
            "services": services,
            "special_instructions": special_instructions,
            "service_for_customer_ids": service_for,
            "requested_by_customer_id": req_by_cust,
            "requested_by_external_name": req_by_ext,
            "payer_customer_id": payer_cust,
            "payer_external_name": payer_ext,
            "period_start": period_start,
            "period_end": period_end,
        }

        # ───────────────────────────────────────────────────────────────────
        # INSERT — IMPORTANT: your table wants NOT NULL for period_start,
        # period_end, created_by, status, unit_id.
        # We will set created_by = 'helpdesk1' for now.
        # ───────────────────────────────────────────────────────────────────
        insert_sql = text(f"""
            INSERT INTO {SCHEMA}.open_service_requests
            (
                unit_id,
                period_start,
                period_end,
                created_by,
                status,
                request_type,
                payload,
                requested_by_customer_id,
                requested_by_external_name,
                service_for_customer_ids,
                payer_customer_id,
                payer_external_name,
                created_on
            )
            VALUES
            (
                :unit_id,
                :period_start,
                :period_end,
                :created_by,
                :status,
                'OSR',
                :payload::jsonb,
                :req_by_cust,
                :req_by_ext,
                :service_for,
                :payer_cust,
                :payer_ext,
                CURRENT_TIMESTAMP
            )
            RETURNING request_id
        """)

        with engine.begin() as conn:
            res = conn.execute(
                insert_sql,
                {
                    "unit_id": unit_id,
                    "period_start": period_start,
                    "period_end": period_end,
                    "created_by": body.get("created_by", "helpdesk1"),
                    "status": "PENDING_APPROVAL",
                    "payload": json.dumps(full_payload),
                    "req_by_cust": req_by_cust,
                    "req_by_ext": req_by_ext,
                    "service_for": service_for,
                    "payer_cust": payer_cust,
                    "payer_ext": payer_ext,
                },
            )
            new_id = res.scalar()

        return JSONResponse(
            status_code=201,
            content={
                "message": "Open Service Request saved",
                "request_id": new_id,
                "period_start": period_start,
                "period_end": period_end,
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        # make it visible on frontend
        raise HTTPException(status_code=500, detail=f"Error saving OSR: {e}")