# SSDM9 --- Comprehensive Vision, Architecture, and Implementation Blueprint

## 1. Overview and Mission

SSDM9 (Service Subscription and Delivery Management) is a **fully
offline, LAN-based, open-source application** built to digitize,
coordinate, and monitor all service requests in a retirement community.\
Its objective is to ensure **transparent, traceable, and efficient
service management** without dependence on any cloud or proprietary
tools.

The platform enables both **subscription-based recurring services** and
**open one-time service requests**, which together feed into a **common
Service Delivery Directory (SDD)** --- the operational nucleus of SSDM9.

------------------------------------------------------------------------

## 2. Technology Stack (All Open Source)

  -----------------------------------------------------------------------
  Layer                Tool              Function
  -------------------- ----------------- --------------------------------
  Frontend             Vue 3 + Vite +    Browser-based UI for residents,
                       TailwindCSS       staff & admins

  Backend              FastAPI (Python)  API logic, form validation, and
                                         orchestration

  Database             PostgreSQL        Primary data store; schema
                       (Supabase Docker) `ssdm9`

  Server               macOS / Linux     Runs DB + API locally, no
                       (Docker Compose)  internet required

  Proxy                NGINX             Local routing and serving

  Reporting            Python (pandas +  Local PDF/Excel generation
                       reportlab)        

  Authentication       (Planned)         Role-based access control
                       Keycloak          
  -----------------------------------------------------------------------

All data is **stored locally** with **daily backups** (`pg_dump`) saved
in `/backups`.\
No third-party connections, APIs, or telemetry are used.

------------------------------------------------------------------------

## 3. Database Architecture (Schema: ssdm9)

  ---------------------------------------------------------------------------------------
  Table                            Purpose                Data Status
  -------------------------------- ---------------------- -------------------------------
  `ssdm9_units_master`             Unit, block, and zone  ✅ Real
                                   mapping                

  `ssdm9_customers`                Resident records       ⚠️ Dummy (replace later)

  `ssdm9_service_master`           Canonical service list ✅ Real

  `ssdm9_subscription_master`      Subscription headers   ✅ Active

  `ssdm9_subscription_services`    Per-service            ✅ Active
                                   subscription details   

  `ssdm9_subscription_customers`   Customer linkage to    ✅ Active
                                   subscriptions          

  `ssdm9_service_delivery_log`     Daily task tracking    🟡 Planned

  `ssdm9_service_enums`            Enumerations for       🟡 Planned
                                   statuses               
  ---------------------------------------------------------------------------------------

Primary keys, indexes, and relations ensure consistency between units,
customers, and subscriptions.

------------------------------------------------------------------------

## 4. Service Master and Categorization

**Source Table:** `ssdm9_service_master`

**Core Fields:** - `service_id` - `service_name` - `service_category` -
`open_or_subscription` - `service_scope` (UNIT / INDIVIDUAL) -
`default_delivery_location` - `proof_required` - `delivery_team`

**Filtering logic:** \| Form \| Includes Services Marked As \|
\|------\|------------------------------\| \| Subscription Form \| "Only
Subscription", "Subscription and Open" \| \| Open Request Form \| "Only
Open", "Subscription and Open" \|

**Scope handling:** - **Unit-level services:** Shared per unit (stored
with `customer_id = NULL`) - **Individual-level services:** Linked to
specific residents

------------------------------------------------------------------------

## 5. Subscription Form --- 7-Step Workflow

**Frontend:** `SubscriptionForm.vue`\
**Backend routes:** `/api/subscriptions`, `/api/services/subscription`

### Step 1: Select Month

-   Choose month (current + next 6).\
-   System computes `period_start` and `period_end`.

### Step 2: Select Unit

-   Dropdown from `ssdm9_units_master`\
-   Required for all steps.

### Step 3: Select Customers

-   Multi-select 1--4 active residents of the unit.\
-   Stored in `ssdm9_subscription_customers`.

### Step 4: Choose Categories

-   Expand categories only if selected.\
-   Allows repeating setup from previous customer.

### Step 5: Configure Services

-   Select services under each category.\
-   Set:
    -   Frequency (daily, weekdays, specific dates)
    -   Timing (one or more per day)
    -   Location
    -   Proof required flag
    -   Special instructions
    -   Default or custom payer
-   Unit-level entries auto-bind to first customer visually but store as
    `customer_id = NULL`.

### Step 6: Preview Instances

-   Displays **expanded daily occurrences** generated either locally or
    from `/api/subscriptions/preview`.
-   Review grid by Customer → Category → Service → Date.

### Step 7: Save and Commit

  Stage        Status        Action
  ------------ ------------- --------------------------------------
  Save Draft   `DRAFT`       Master + services stored
  Submit       `SUBMITTED`   Await approval
  Approve      `APPROVED`    Ready for commit
  Commit       `COMMITTED`   Pushes to Service Delivery Directory

------------------------------------------------------------------------

## 6. Open Service Request Form (OSR)

Handles **one-time** services.\
Creates immediate entries in `ssdm9_service_delivery_log` with
`origin='OPEN'`.

**Captured fields:** - Date, Time, Unit, Customer - Category, Service -
Location, Special instructions, Proof flag

**State flow:** SUBMITTED → APPROVED → SCHEDULED

Both **subscription** and **open** requests share identical structure
once inside the Service Delivery Directory.

------------------------------------------------------------------------

## 7. Service Delivery Directory (SDD)

The **unified table** for all actual service executions.

  Column              Type                          Description
  ------------------- ----------------------------- -----------------------------------
  `delivery_id`       SERIAL PK                     Unique record ID
  `origin`            ENUM('SUBSCRIPTION','OPEN')   Request source
  `subscription_id`   TEXT                          Subscription reference
  `sub_service_id`    INT                           Subscription line
  `unit_id`           TEXT                          Location
  `customer_id`       INT                           Null for unit scope
  `service_id`        TEXT                          From master
  `service_scope`     TEXT                          UNIT/INDIVIDUAL
  `scheduled_date`    DATE                          Planned date
  `scheduled_time`    TIME                          Expected time
  `status`            ENUM                          Scheduled/In Progress/Done/Missed
  `proof_required`    BOOLEAN                       Needs proof
  `team_id`           TEXT                          Assigned team
  `remarks`           TEXT                          Notes
  `verified_by`       TEXT                          Supervisor
  `verified_at`       TIMESTAMP                     Approval time

**Indexes:** by team/date/unit for performance.

------------------------------------------------------------------------

## 8. Backend APIs

  Endpoint                                Purpose
  --------------------------------------- -----------------------------
  `GET /api/services/subscription`        Fetch subscription services
  `GET /api/services/open`                Fetch open services
  `POST /api/subscriptions`               Create draft subscription
  `POST /api/subscriptions/:id/preview`   Expand rules to dates
  `POST /api/subscriptions/:id/commit`    Write to SDD
  `POST /api/open-requests`               Create open SDD entries

All API routes are **LAN-accessible only**.

------------------------------------------------------------------------

## 9. Validation Rules (Authoritative)

-   **Unit:** Must exist in `ssdm9_units_master`
-   **Customer:** 1--4; must belong to selected unit
-   **Frequency:** Must generate ≥1 occurrence
-   **Scope:** `UNIT` services → `customer_id=NULL`
-   **Proof flag:** Default from master; editable
-   **Time:** 24-hour format enforced
-   **Duplicate prevention:** Unique constraint on
    `(subscription_id, sub_service_id, date, time)`

------------------------------------------------------------------------

## 10. Dashboards and Reports

### Daily Operations View

  Team   Date   Scheduled   Done   Missed   Proof Pending
  ------ ------ ----------- ------ -------- ---------------

### Summary Reports

-   **Monthly Service Summary (Unit-wise)**\
-   **Staff Performance / Completion %**
-   **Proof Pending Tracker**
-   **Billing Integration Summary**

------------------------------------------------------------------------

## 11. System Hosting & Security

-   Hosted locally via Docker Compose.\
-   Access via `http://<LAN-IP>:5174`
-   PostgreSQL → Port 54321
-   FastAPI → Port 8000
-   Data backups → `/backups/*.sql`

No cloud sync, no telemetry.

------------------------------------------------------------------------

## 12. Roadmap & Milestones

  Phase                        Description                  Status
  ---------------------------- ---------------------------- ----------------
  DB + Schema Setup            Core structure and indexes   ✅ Done
  Service Master               164 verified records         ✅ Done
  Subscription Form            7-step UI + backend routes   ✅ Active
  Open Service Requests        One-off request form         🟡 Next
  Service Delivery Directory   Auto task generation         🟢 In Progress
  Supervisor Dashboards        Verification UI              🔜 Pending
  Reports & Exports            PDFs, Excel                  🔜 Planned
  Customer Data Update         Replace dummy data           🔜 Pending

------------------------------------------------------------------------

## 13. Vision for Operations

> "Every service --- whether recurring or one-off --- must translate
> into clear, trackable, and verified daily tasks."

The SSDM9 system ensures: - **Residents** can request or subscribe to
services seamlessly.\
- **Teams** receive automatic daily schedules.\
- **Supervisors** verify and report performance.\
- **Management** gets insight and accountability --- all without the
internet.

------------------------------------------------------------------------
