from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, text
from fastapi import HTTPException
from enum import Enum
import json

from routes import subscription_routes


app = FastAPI()

# Allow CORS for Vue frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:5174",
        "http://127.0.0.1:5174",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE_URL = "postgresql://postgres:ssdm123@localhost:54321/postgres"
SCHEMA = "ssdm9"
engine = create_engine(DATABASE_URL)

@app.get("/")
def read_root():
    return {"message": "Welcome to SSDM9 API"}

@app.get("/customers")
def get_customers():
    """Fetch a list of active customers (for testing or dashboard use)."""
    try:
        with engine.connect() as conn:
            result = conn.execute(text(f"""
                SELECT customer_id, full_name, unit_id, active_status
                FROM {SCHEMA}.ssdm9_customers
                WHERE active_status = TRUE
                ORDER BY full_name
                LIMIT 10
            """))
            customers = [dict(row._mapping) for row in result]
        return {"customers": customers}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# Dashboard endpoint providing a structured JSON representation of the main application dashboard
@app.get("/dashboard")
def dashboard():
    return {
        "title": "Welcome to Subscription and Service Delivery System",
        "sections": {
            "Subscription": [
                "View Subscription",
                "Add New Subscription",
                "Approve New Subscription",
                "Modify Subscription",
                "Archive Subscription"
            ],
            "Open Service Request": [
                "Emergency Medical",
                "Emergency Non Medical",
                "Regular Service"
            ],
            "Admin": [
                "Units - Add, Modify, Archive",
                "Customers - Add, Modify, Archive",
                "Services - Add, Modify, Archive",
                "Entities / Staff - Add, Modify, Archive"
            ]
        },
        "focus": "Subscription Module",
        "login_required": True,
        "roles": {
            "User": ["view_subscription", "create_subscription", "modify_subscription"],
            "Supervisor": ["approve_new_subscription", "approve_modification"],
            "Manager": ["approve_subscription", "archive_subscription"],
            "Admin": ["manage_units", "manage_customers", "manage_services", "oversee_managers"],
            "SuperUser": ["appoint_admins", "manage_system_operations"],
            "Owner": ["appoint_superusers", "configure_system", "full_control"]
        }
    }

class RoleEnum(str, Enum):
    user = "User"
    supervisor = "Supervisor"
    manager = "Manager"
    admin = "Admin"
    superuser = "SuperUser"
    owner = "Owner"

from fastapi import HTTPException

@app.post("/login")
def login(username: str, password: str):
    # Hardcoded demo user credentials
    users = {
        "userabc": {"password": "user123", "role": "User"},
        "superabc": {"password": "super123", "role": "Supervisor"},
        "managerabc": {"password": "manager123", "role": "Manager"},
        "adminabc": {"password": "admin123", "role": "Admin"},
        "superuserabc": {"password": "superuser123", "role": "SuperUser"},
        "ownerabc": {"password": "owner123", "role": "Owner"},
    }

    roles = {
        "User": ["view_subscription", "create_subscription", "modify_subscription"],
        "Supervisor": ["approve_new_subscription", "approve_modification"],
        "Manager": ["approve_subscription", "archive_subscription", "add_supervisor", "add_user"],
        "Admin": ["manage_units", "manage_customers", "manage_services", "oversee_managers"],
        "SuperUser": ["appoint_admins", "manage_system_operations"],
        "Owner": ["appoint_superusers", "configure_system", "full_control"]
    }

    # Authentication check
    user = users.get(username)
    if not user or user["password"] != password:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    role = user["role"]
    return {
        "message": f"Login successful as {role}",
        "username": username,
        "role": role,
        "permissions": roles[role]
    }


# --- Subscription Draft Endpoint ---
from datetime import datetime
import random

@app.post("/subscription/start")
def start_subscription(month: str, unit_id: str, created_by: str = "userabc"):
    """Start a new subscription draft."""
    try:
        # Generate a unique subscription ID
        now = datetime.now()
        mmyy = now.strftime("%m%y")
        random_suffix = random.randint(100, 999)
        subscription_id = f"SUB-{unit_id}-{mmyy}-{random_suffix}"

        # Return draft subscription details
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

# --- Units Endpoint for Subscription Form ---
@app.get("/units")
def get_units():
    with engine.connect() as conn:
        result = conn.execute(text("""
            SELECT unit_id
            FROM ssdm9.ssdm9_units_master
            WHERE active_status = TRUE
            ORDER BY unit_id
        """))
        units = [{"unit_id": row.unit_id, "display": row.unit_id} for row in result]
    return {"units": units}

@app.get("/customers/{unit_id}")
def get_customers_by_unit(unit_id: str):
    try:
        with engine.connect() as conn:
            result = conn.execute(
                text("""
                    SELECT customer_id, full_name 
                    FROM ssdm9.ssdm9_customers
                    WHERE unit_id = :unit_id AND active_status = TRUE
                    ORDER BY full_name
                """),
                {"unit_id": unit_id}
            )
            customers = [dict(row._mapping) for row in result]
        print("DEBUG Customers Query Output:", customers)
        return {"customers": customers}
    except Exception as e:
        print("Error fetching customers:", e)
        raise HTTPException(status_code=500, detail=str(e))


# --- Services Endpoint ---
@app.get("/services")
def get_services():
    try:
        with engine.connect() as conn:
            result = conn.execute(text("""
                SELECT service_category, service_id, service_name
                FROM ssdm9.ssdm9_service_master
                ORDER BY service_category, service_name
            """))
            rows = result.fetchall()

        services = {}
        for row in rows:
            category = row.service_category
            service_entry = {
                "id": row.service_id,
                "name": row.service_name
            }
            if category not in services:
                services[category] = []
            services[category].append(service_entry)

        return {"services": services}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

from fastapi import APIRouter

test_router = APIRouter(prefix="/subscription", tags=["Subscription"])

@test_router.get("/test")
def test_subscription():
    return {"message": "Subscription routes are now active"}

app.include_router(test_router)
app.include_router(subscription_routes.router)

from fastapi import APIRouter, Body

subscription_router = APIRouter(prefix="/subscription", tags=["Subscription"])

@subscription_router.post("/configure")
def configure_subscription(subscription_id: str = Body(...), service_dict = Body(...)):
    """Configure a subscription with service-level customizations."""
    return {
        "subscription_id": subscription_id,
        "configured_services": service_dict,
        "status": "Configuration Saved",
        "next_step": "Review Subscription"
    }

@subscription_router.get("/review/{subscription_id}")
def review_subscription(subscription_id: str):
    """Review subscription details before saving."""
    return {
        "subscription_id": subscription_id,
        "summary": "Subscription ready for review and approval",
        "status": "Ready for Review"
    }

@subscription_router.post("/save")
def save_subscription(subscription_id: str = Body(...), reviewed_by: str = Body(...)):
    """Save subscription after review."""
    return {
        "subscription_id": subscription_id,
        "reviewed_by": reviewed_by,
        "status": "Saved - Awaiting Customer Confirmation"
    }

@subscription_router.post("/confirm")
def confirm_subscription(subscription_id: str = Body(...), confirmed_by: str = Body(...)):
    """Confirm subscription with customer acknowledgment."""
    return {
        "subscription_id": subscription_id,
        "confirmed_by": confirmed_by,
        "status": "Confirmed and Published"
    }

app.include_router(subscription_router)

from pydantic import BaseModel
from fastapi import Request

class SubscriptionRequest(BaseModel):
    unit_id: str
    period_start: str  # ISO date string
    period_end: str    # ISO date string
    created_by: str
    status: str
    payload: dict

@app.post("/subscription_requests")
def create_subscription_request(request_data: SubscriptionRequest):
    try:
        with engine.begin() as conn:  # ensures automatic commit
            insert_stmt = text(f"""
                INSERT INTO {SCHEMA}.subscription_requests
                (unit_id, period_start, period_end, created_by, status, payload, created_on)
                VALUES (:unit_id, :period_start, :period_end, :created_by, :status, :payload, CURRENT_TIMESTAMP)
                RETURNING request_id
            """)
            result = conn.execute(insert_stmt, {
                "unit_id": request_data.unit_id,
                "period_start": request_data.period_start,
                "period_end": request_data.period_end,
                "created_by": request_data.created_by,
                "status": request_data.status,
                "payload": json.dumps(request_data.payload)
            })
            request_id = result.scalar()
        return {"request_id": request_id, "message": "Subscription request saved successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# --- Subscription Request Approval/Listing Endpoints ---
from typing import Optional, List
from datetime import datetime as _dt

from pydantic import BaseModel as _BaseModel
from fastapi import Path, Query

class ApprovalInput(_BaseModel):
    approved_by: str
    approval_notes: Optional[str] = None

class RequestRow(_BaseModel):
    request_id: int
    unit_id: str
    period_start: str
    period_end: str
    created_by: str
    created_on: Optional[str] = None
    status: str
    approval_notes: Optional[str] = None
    payload: dict

@app.get("/subscription_requests", response_model=List[RequestRow])
def list_subscription_requests(status: Optional[str] = Query(None, description="Filter by status e.g. PENDING_APPROVAL, DRAFT, APPROVED")):
    """List subscription requests with optional status filter.
    Returns the payload as JSON (parsed from jsonb/text).
    """
    try:
        where = ""
        params = {}
        if status:
            where = " WHERE status = :status "
            params["status"] = status
        with engine.connect() as conn:
            result = conn.execute(text(f"""
                SELECT request_id, unit_id, period_start, period_end, created_by, created_on, status, approval_notes, payload
                FROM {SCHEMA}.subscription_requests
                {where}
                ORDER BY created_on DESC, request_id DESC
            """), params)
            rows = []
            for r in result:
                # psycopg may return dict already for jsonb, or str; normalize
                pl = r.payload
                try:
                    if isinstance(pl, str):
                        pl = json.loads(pl)
                except Exception:
                    # keep as-is if parsing fails
                    pass
                rows.append({
                    "request_id": r.request_id,
                    "unit_id": r.unit_id,
                    "period_start": str(r.period_start),
                    "period_end": str(r.period_end),
                    "created_by": r.created_by,
                    "created_on": str(r.created_on) if hasattr(r, "created_on") else None,
                    "status": r.status,
                    "approval_notes": r.approval_notes if hasattr(r, "approval_notes") else None,
                    "payload": pl,
                })
        return rows
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/subscription_requests/{request_id}/approve")
def approve_subscription_request(
    request_id: int = Path(..., description="The request_id of the draft to approve"),
    body: ApprovalInput = ...,
):
    """Approve a saved subscription request.
    This ONLY updates the request row to APPROVED and stores approver info.
    A subsequent activation step will migrate rows to live subscription tables.
    """
    try:
        with engine.begin() as conn:
            # Lock the row to avoid races
            sel = text(f"""
                SELECT request_id, status FROM {SCHEMA}.subscription_requests
                WHERE request_id = :rid
                FOR UPDATE
            """)
            row = conn.execute(sel, {"rid": request_id}).fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Request not found")
            if row.status not in ("DRAFT", "PENDING_APPROVAL"):
                raise HTTPException(status_code=409, detail=f"Cannot approve request in status {row.status}")
            upd = text(f"""
                UPDATE {SCHEMA}.subscription_requests
                SET status = 'APPROVED', approved_by = :approved_by, approved_on = CURRENT_TIMESTAMP, approval_notes = :notes
                WHERE request_id = :rid
            """)
            conn.execute(upd, {"approved_by": body.approved_by, "notes": body.approval_notes, "rid": request_id})
        return {"request_id": request_id, "status": "APPROVED", "message": "Subscription request approved. Ready for activation."}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/subscription_requests/{request_id}/reject")
def reject_subscription_request(
    request_id: int = Path(..., description="The request_id of the draft to reject"),
    body: ApprovalInput = ...,
):
    """Reject a saved subscription request with a note."""
    try:
        with engine.begin() as conn:
            sel = text(f"SELECT request_id, status FROM {SCHEMA}.subscription_requests WHERE request_id = :rid FOR UPDATE")
            row = conn.execute(sel, {"rid": request_id}).fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Request not found")
            if row.status in ("APPROVED", "REJECTED"):
                raise HTTPException(status_code=409, detail=f"Cannot reject request in status {row.status}")
            upd = text(f"""
                UPDATE {SCHEMA}.subscription_requests
                SET status = 'REJECTED', approved_by = :approved_by, approved_on = CURRENT_TIMESTAMP, approval_notes = :notes
                WHERE request_id = :rid
            """)
            conn.execute(upd, {"approved_by": body.approved_by, "notes": body.approval_notes, "rid": request_id})
        return {"request_id": request_id, "status": "REJECTED", "message": "Subscription request rejected."}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- Activate Subscription Request Endpoint ---
from fastapi import Path
from datetime import datetime

@app.post("/subscription_requests/{request_id}/activate")
def activate_subscription_request(
    request_id: int = Path(..., description="The request_id of the approved subscription to activate"),
    activated_by: str = "system"
):
    """
    Activate an approved subscription request (aligned with actual schema).
    Writes to subscription_master, subscription_customers, and subscription_services using correct columns.
    """
    try:
        with engine.begin() as conn:
            # Step 1: Fetch and validate
            sel = text(f"""
                SELECT request_id, unit_id, period_start, period_end, created_by, status, payload
                FROM {SCHEMA}.subscription_requests
                WHERE request_id = :rid
                FOR UPDATE
            """)
            row = conn.execute(sel, {"rid": request_id}).fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Subscription request not found.")
            if row.status != "APPROVED":
                raise HTTPException(status_code=409, detail=f"Cannot activate request in status {row.status}.")

            # Step 2: Parse payload
            payload = row.payload
            if isinstance(payload, str):
                payload = json.loads(payload)
            customers = payload.get("customers", [])
            lines = payload.get("lines", [])
            unit_id = row.unit_id
            period_start = str(row.period_start)
            period_end = str(row.period_end)

            # Step 3: Generate subscription ID and month
            now = datetime.now()
            subscription_month = now.strftime("%Y-%m")
            rand_suffix = str(request_id).zfill(3)
            subscription_id = f"SUB-{unit_id}-{subscription_month.replace('-', '')}-{rand_suffix}"

            # Step 4: Insert into master (aligned with real table columns)
            first_customer_id = customers[0]["customer_id"] if customers else None
            ins_master = text(f"""
                INSERT INTO {SCHEMA}.ssdm9_subscription_master
                (subscription_id, unit_id, subscription_month, created_by_customer_id, created_date, status)
                VALUES (:sid, :uid, :smonth, :creator_id, CURRENT_TIMESTAMP, 'ACTIVE')
            """)
            conn.execute(ins_master, {
                "sid": subscription_id,
                "uid": unit_id,
                "smonth": subscription_month,
                "creator_id": first_customer_id
            })

            # Step 5: Insert customers
            for c in customers:
                ins_cust = text(f"""
                    INSERT INTO {SCHEMA}.ssdm9_subscription_customers
                    (subscription_id, customer_id, added_on)
                    VALUES (:sid, :cid, CURRENT_TIMESTAMP)
                """)
                conn.execute(ins_cust, {"sid": subscription_id, "cid": c.get("customer_id")})

            # Step 6: Insert services
            for line in lines:
                ins_serv = text(f"""
                    INSERT INTO {SCHEMA}.ssdm9_subscription_services
                    (subscription_id, customer_id, service_id, category, service_scope, start_date, end_date,
                     specific_dates, time, location, proof_required, special_instructions)
                    VALUES (:sid, :cid, :sid2, :cat, :scope, :sdate, :edate, :spec, :time, :loc, :proof, :notes)
                """)
                conn.execute(ins_serv, {
                    "sid": subscription_id,
                    "cid": line.get("customer_id"),
                    "sid2": line.get("service_id"),
                    "cat": line.get("category"),
                    "scope": line.get("service_scope"),
                    "sdate": line.get("start_date"),
                    "edate": line.get("end_date"),
                    "spec": json.dumps(line.get("specific_dates", [])),
                    "time": line.get("time"),
                    "loc": line.get("location"),
                    "proof": line.get("proof_required"),
                    "notes": line.get("special_instructions")
                })

            # Step 7: Update original request
            upd = text(f"""
                UPDATE {SCHEMA}.subscription_requests
                SET status = 'ACTIVATED',
                    approval_notes = COALESCE(approval_notes, '') || ' | Activated on ' || CURRENT_TIMESTAMP
                WHERE request_id = :rid
            """)
            conn.execute(upd, {"rid": request_id})

        return {
            "message": "Subscription activated successfully.",
            "subscription_id": subscription_id,
            "customers": len(customers),
            "services": len(lines)
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
