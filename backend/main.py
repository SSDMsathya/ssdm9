from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, text
import json

# 👉 bring in our routers (BOTH of them)
from backend.routes import subscription_routes


# -----------------------------------------------------------------------------
# APP + CORS
# -----------------------------------------------------------------------------
app = FastAPI(title="SSDM9 API")

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

# -----------------------------------------------------------------------------
# DB
# -----------------------------------------------------------------------------
DATABASE_URL = "postgresql://postgres:ssdm123@localhost:54321/postgres"
SCHEMA = "ssdm9"
engine = create_engine(DATABASE_URL)


# -----------------------------------------------------------------------------
# BASIC ENDPOINTS (common to both subscription + OSR forms)
# -----------------------------------------------------------------------------
@app.get("/")
def read_root():
    return {"message": "Welcome to SSDM9 API"}


@app.get("/units")
def get_units():
    try:
        with engine.connect() as conn:
            rows = conn.execute(text(f"""
                SELECT unit_id
                FROM {SCHEMA}.ssdm9_units_master
                WHERE active_status = TRUE
                ORDER BY unit_id
            """))
            units = [{"unit_id": r.unit_id, "display": r.unit_id}
                     for r in rows]
        return {"units": units}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/customers/{unit_id}")
def get_customers_by_unit(unit_id: str):
    """Used by BOTH: subscription form and open service request form."""
    try:
        with engine.connect() as conn:
            rows = conn.execute(
                text(f"""
                    SELECT customer_id, full_name, unit_id
                    FROM {SCHEMA}.ssdm9_customers
                    WHERE unit_id = :uid AND active_status = TRUE
                    ORDER BY full_name
                """),
                {"uid": unit_id},
            )
            customers = [dict(r._mapping) for r in rows]
        return {"customers": customers}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/services")
def get_services():
    """Service catalog for both SSR and OSR."""
    try:
        with engine.connect() as conn:
            rows = conn.execute(text(f"""
                SELECT service_category, service_id, service_name,
                       COALESCE(service_scope, 'INDIVIDUAL') AS service_scope,
                       COALESCE(default_delivery_location, '') AS default_delivery_location,
                       COALESCE(proof_required, FALSE) AS proof_required
                FROM {SCHEMA}.ssdm9_service_master
                ORDER BY service_category, service_name
            """)).fetchall()

        services = {}
        for r in rows:
            cat = r.service_category or "Uncategorized"
            entry = {
                "id": r.service_id,
                "name": r.service_name,
                "service_scope": r.service_scope,
                "default_delivery_location": r.default_delivery_location,
                "proof_required": r.proof_required,
            }
            services.setdefault(cat, []).append(entry)

        return {"services": services}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -----------------------------------------------------------------------------
# INCLUDE ROUTERS (this is the important part)
# -----------------------------------------------------------------------------
# all subscription-related endpoints live here
app.include_router(subscription_routes.router)

# all open-service-request-related endpoints live here
# -----------------------------------------------------------------------------
# HTML Template Setup (Jinja2)
# -----------------------------------------------------------------------------
from fastapi import Form, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

templates = Jinja2Templates(directory="templates")


@app.get("/subscription/new", response_class=HTMLResponse)
def subscription_form(request: Request):
    """Serve a simple HTML form for creating a subscription"""
    return templates.TemplateResponse("subscription_form.html", {"request": request})


@app.post("/subscription/save_html", response_class=HTMLResponse)
def save_subscription_html(
    request: Request,
    unit_id: str = Form(...),
    month: str = Form(...),
    created_by: str = Form(...),
    status: str = Form(...),
    special_instructions: str = Form("")
):
    """Handle form submission and insert into DB"""
    try:
        # Compute period start and end from month
        from datetime import datetime
        y, m = map(int, month.split('-'))
        from calendar import monthrange
        last_day = monthrange(y, m)[1]
        period_start = f"{y}-{m:02d}-01"
        period_end = f"{y}-{m:02d}-{last_day:02d}"

        with engine.begin() as conn:
            payload = {
                "special_instructions": special_instructions,
                "source": "HTML_FORM"
            }
            stmt = text(f"""
                INSERT INTO {SCHEMA}.subscription_requests
                (unit_id, period_start, period_end, created_by, status, payload, created_on)
                VALUES (:unit_id, :period_start, :period_end, :created_by, :status, :payload, CURRENT_TIMESTAMP)
                RETURNING request_id
            """)
            result = conn.execute(stmt, {
                "unit_id": unit_id,
                "period_start": period_start,
                "period_end": period_end,
                "created_by": created_by,
                "status": status,
                "payload": json.dumps(payload)
            })
            req_id = result.scalar()

        return templates.TemplateResponse("subscription_form.html", {
            "request": request,
            "success": f"✅ Subscription saved successfully! Request ID: {req_id}"
        })
    except Exception as e:
        return templates.TemplateResponse("subscription_form.html", {
            "request": request,
            "error": f"❌ Failed to save subscription: {e}"
        })