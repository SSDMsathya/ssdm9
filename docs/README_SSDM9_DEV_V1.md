README_SSDM9_DEV.md

\# SSDM9 SYSTEM MAP & WORKING CHARTER

\*(Architectural Reference + AI Development Protocol)\*

\*\*Last updated:\*\* \[Insert today's date\]

\-\--

\## 🧩 1. PURPOSE

This document is the \*\*single source of truth\*\* for the SSDM9
application.

It captures:

\- The current file and folder structure.

\- Database tables and their relationships.

\- API flow (Frontend ↔ Backend ↔ Database).

\- Development workflow and protocols for AI-assisted coding (ChatGPT &
Cursor).

It ensures continuity and avoids confusion when updating or debugging
the system.

\-\--

\## ⚙️ 2. SYSTEM OVERVIEW

SSDM9 (Subscription & Service Delivery Manager) is a \*\*full-stack
modular system\*\* designed for managing both:

\- \*\*Subscription-based recurring services (SSR)\*\*

\- \*\*Open Service Requests (OSR)\*\* --- one-time or special services.

The system architecture supports multi-entity operations (Promoter,
Prime Vendor, Secondary Vendor) with a unified \*\*Service Delivery
Engine (SDE)\*\* and audit-friendly \*\*Service Delivery Log (SDL).\*\*

\-\--

\## 🧭 3. PROJECT DIRECTORY STRUCTURE

\### Backend (\`/Users/ssdm/Desktop/ssdm9/backend\`)

backend/

├── main.py

├── db_connect.py

├── routes/

│   ├── **init**.py

│   ├── subscription_routes.py

│   ├── open_service_routes.py  ← (to be added for OSR handling)

├── backups/

└── ...

\### Frontend (\`/Users/ssdm/Desktop/ssdm9/frontend\`)

frontend/

├── src/

│   ├── assets/

│   ├── components/

│   │   ├── forms/

│   │   │   ├── SubscriptionForm.vue

│   │   │   ├── OpenServiceRequestForm.vue

│   │   └── layouts/

│   ├── pages/

│   │   ├── Home.vue

│   │   ├── ServiceReport.vue

│   │   ├── OpenServiceRequest.vue

│   ├── router/

│   │   └── index.js

│   ├── App.vue

│   └── main.js

├── public/

└── package.json

\-\--

\## 🗂️ 4. DATABASE (PostgreSQL - schema: \`ssdm9\`)

\### ✅ Existing Tables

\| Table Name \| Purpose \|

\|\-\-\-\-\-\-\-\-\-\-\-\--\|\-\-\-\-\-\-\-\-\--\|

\| \*\*ssdm9_customers\*\* \| Stores all residents/customers (name,
unit_id, contact). \|

\| \*\*ssdm9_units_master\*\* \| Unit list with mapping to
residents/customers. \|

\| \*\*ssdm9_service_master\*\* \| Master list of all available services
(category, name, code, scope, proof requirements). \|

\| \*\*ssdm9_service_enums\*\* \| Reference values / classification
enums for service attributes. \|

\| \*\*ssdm9_service_delivery_log\*\* \| Unified log for both
subscription and open service requests. \|

\| \*\*ssdm9_subscription_master\*\* \| Subscription header data
(period, unit_id, created_by). \|

\| \*\*ssdm9_subscription_customers\*\* \| Customer mappings within each
subscription. \|

\| \*\*ssdm9_subscription_services\*\* \| Service configuration per
customer per subscription. \|

\| \*\*subscription_requests\*\* \| Tracks incoming subscription
requests before approval. \|

\-\--

\### 🆕 New Tables to Support Open Service Requests

\#### 1. \*\*ssdm9_open_service_requests\*\*

Stores header info for each manually raised (non-subscription) service
request.

\| Field \| Type \| Description \|

\|\-\-\-\-\-\-\--\|\-\-\-\-\--\|\-\-\-\-\-\-\-\-\-\-\-\--\|

\| osr_id \| BIGSERIAL \| Primary key \|

\| unit_id \| VARCHAR(20) \| Linked to \`ssdm9_units_master\` \|

\| requester_id \| INT \| Linked to \`ssdm9_customers\` (nullable if
external) \|

\| requester_type \| VARCHAR(20) \| 'INTERNAL' / 'EXTERNAL' \|

\| external_requester \| JSONB \| For off-site requesters (name, phone,
email, relation) \|

\| payer_id \| INT \| Customer paying for the service \|

\| service_id \| INT \| FK → \`ssdm9_service_master\` \|

\| service_category \| VARCHAR(120) \| Category (from service master) \|

\| requested_date \| DATE \| When request was made \|

\| requested_for_date \| DATE \| Single-day request \|

\| requested_from / requested_to \| DATE \| Optional date range \|

\| requested_time \| TIME \| Scheduled time \|

\| location \| VARCHAR(80) \| Delivery point ('Unit', 'Dining Hall',
etc.) \|

\| special_instructions \| TEXT \| Notes \|

\| urgency_level \| VARCHAR(15) \| ENUM: EMERGENCY / URGENT / ROUTINE /
INFO \|

\| captured_by \| VARCHAR(80) \| Helpdesk or staff user name \|

\| status \| VARCHAR(20) \| NEW / VALIDATED / REJECTED / CANCELLED /
PUSHED \|

\| created_at \| TIMESTAMPTZ \| Auto timestamp \|

\| updated_at \| TIMESTAMPTZ \| Auto timestamp \|

\-\--

\#### 2. \*\*ssdm9_open_service_request_targets\*\*

Stores one or more residents for each OSR.

\| Field \| Type \| Description \|

\|\-\-\-\-\-\-\--\|\-\-\-\-\--\|\-\-\-\-\-\-\-\-\-\-\-\--\|

\| osr_target_id \| BIGSERIAL \| Primary key \|

\| osr_id \| BIGINT \| FK → \`ssdm9_open_service_requests\` \|

\| customer_id \| INT \| Resident ID (linked to \`ssdm9_customers\`) \|

\| bill_to_id \| INT \| Optional override for payer \|

\| status \| VARCHAR(20) \| PENDING / COMPLETED / CANCELLED \|

\| created_at \| TIMESTAMPTZ \| Audit timestamp \|

\-\--

\#### 3. \*\*Alteration to \`ssdm9_service_delivery_log\`\*\*

Adds traceability to service origin (subscription vs open request).

\| Field \| Type \| Description \|

\|\-\-\-\-\-\-\--\|\-\-\-\-\--\|\-\-\-\-\-\-\-\-\-\-\-\--\|

\| origin \| VARCHAR(20) \| 'SUBSCRIPTION' / 'OPEN' \|

\| origin_ref \| BIGINT \| Reference ID (subscription_id or osr_id) \|

\| metadata \| JSONB \| Service-specific metadata (auto-filled) \|

\-\--

\## 🌐 5. API ROUTES (Backend)

\| Route \| Method \| Description \| Status \|

\|\-\-\-\-\-\-\--\|\-\-\-\-\-\-\--\|\-\-\-\-\-\-\-\-\-\-\-\--\|\-\-\-\-\-\-\--\|

\| \`/units\` \| GET \| Fetch all active units \| ✅ \|

\| \`/customers/{unit_id}\` \| GET \| Fetch customers in a unit \| ✅ \|

\| \`/services\` \| GET \| Fetch all services \| ✅ \|

\| \`/subscription_requests\` \| POST \| Create subscription request \|
✅ \|

\| \`/open-requests\` \| POST \| Create new Open Service Request (OSR)
\| 🔧 \*To finalize once DB patch applied\* \|

\| \`/service-delivery-log\` \| POST \| Record delivered service entry
\| ✅ \|

\-\--

\## 🧩 6. FRONTEND FORMS & FLOWS

\### A. Subscription Form

\`/src/components/forms/SubscriptionForm.vue\`

\- Handles recurring service setup per month.

\- Multi-customer, multi-service flow.

\- Uses stepper wizard (month → unit → customers → services → preview →
save).

\### B. Open Service Request Form

\`/src/components/forms/OpenServiceRequestForm.vue\`

\- Handles one-time service requests.

\- Captures:

\- Unit

\- Requester (internal/external)

\- Whom For (one or many)

\- Payer

\- Category / Service

\- Notes / Urgency

\- On submit → posts to \`/open-requests\` → backend inserts into
\`ssdm9_open_service_requests\` and \`ssdm9_service_delivery_log\`.

\-\--

\## 🔐 7. LOGIN & ACCESS

\### Current State:

\- \*\*Authentication not yet implemented\*\*.

\- Frontend is open-access (for internal prototype testing).

\- Backend (FastAPI) accepts all requests locally via
\`localhost:8000\`.

\### Planned (Phase 2):

\| Role \| Description \|

\|\-\-\-\-\--\|\-\-\-\-\-\-\-\-\-\-\-\-\--\|

\| \*\*Super Admin (Promoter)\*\* \| Full schema access, manages service
master & vendor roles. \|

\| \*\*Prime Vendor Admin\*\* \| Handles daily OSR + subscription
processing. \|

\| \*\*Helpdesk User\*\* \| Creates OSRs on behalf of residents. \|

\| \*\*Resident (Customer)\*\* \| Submits own requests (future mobile
app). \|

\-\--

\## 🧠 8. DEVELOPMENT PROTOCOL (AI + HUMAN)

\### Safe Word: \`SAFE SAFE SAFE\`

Triggers ChatGPT to rebuild and re-output:

\- Full folder & file map.

\- Database schema.

\- Backend & frontend status.

\- Pending tasks.

\### File Editing Rule

\- You announce which file is \*\*active\*\* in Cursor.

\- ChatGPT returns a \*\*complete file replacement\*\* (no snippets).

\- You say: \*"Replace this file with ChatGPT's version."\*

\### Command Rule

Every command will be clearly marked:

**Run this in backend terminal**

uvicorn main:app --reload

or

**Run this in frontend terminal**

npm run dev

\### Chat Rule

\- No multi-step or vague responses.

\- One instruction → one action → verify result.

\-\--

\## 🧱 9. NEXT STEPS (as of current build)

1\. ✅ Confirm DB patch applied (new \`origin\` field + OSR tables).

2\. ✅ Ensure \`/open-requests\` route added in backend
(\`open_service_routes.py\`).

3\. ✅ Update \`OpenServiceRequestForm.vue\` to support "external
requester" toggle.

4\. ✅ Link OSR to SDE (\`ssdm9_service_delivery_log\`).

5\. 🔒 Add login + session layer (later phase).

\-\--

\## 🧭 10. REVISION HISTORY

\| Version \| Date \| Description \|

\|\-\-\-\-\-\-\-\-\--\|\-\-\-\-\--\|\-\-\-\-\-\-\-\-\-\-\-\-\--\|

\| 0.9.0 \| \[today's date\] \| Initial combined map (backend, frontend,
database, workflow). \|

\-\--

\## 📜 AUTHOR & CONTROLLER

\*\*Architect & AI Developer:\*\* ChatGPT (OpenAI GPT-5)

\*\*System Owner:\*\* SSDM9 Project (Promoter / Prime Vendor Team)

\*\*Active Developer:\*\* \[Your Name or initials\]

\*\*AI Working Protocol:\*\* Cursor Integration --- ChatGPT Primary

\-\--
