--
-- PostgreSQL database dump
--

\restrict anKJxgTat996XQtzTyzq425Umm7N5zdj4KyG5ygjoxln6TVFYwexnGngGRS1Dii

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ssdm9; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ssdm9;


ALTER SCHEMA ssdm9 OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ssdm9_customers; Type: TABLE; Schema: ssdm9; Owner: postgres
--

CREATE TABLE ssdm9.ssdm9_customers (
    customer_id integer NOT NULL,
    full_name text,
    contact_no text,
    email_id text,
    whatsapp_available boolean,
    gender text,
    dob date,
    age integer,
    blood_group text,
    allergies text,
    relation_to_unit text,
    special_status text,
    resident_since date,
    unit_id text,
    default_payer_id integer,
    active_status boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ssdm9.ssdm9_customers OWNER TO postgres;

--
-- Name: ssdm9_service_enums; Type: TABLE; Schema: ssdm9; Owner: postgres
--

CREATE TABLE ssdm9.ssdm9_service_enums (
    enum_type text,
    enum_value text,
    description text
);


ALTER TABLE ssdm9.ssdm9_service_enums OWNER TO postgres;

--
-- Name: ssdm9_service_master; Type: TABLE; Schema: ssdm9; Owner: postgres
--

CREATE TABLE ssdm9.ssdm9_service_master (
    service_id text NOT NULL,
    service_name text,
    service_category text,
    service_complexity text,
    serv_dely_lead_team text,
    serv_dely_supp_team text,
    serv_dely_ext_vendor text,
    service_availability_mode text,
    open_or_subsription text,
    serv_dely_location double precision,
    serv_special_instr double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ssdm9.ssdm9_service_master OWNER TO postgres;

--
-- Name: ssdm9_subscription_customers; Type: TABLE; Schema: ssdm9; Owner: postgres
--

CREATE TABLE ssdm9.ssdm9_subscription_customers (
    sub_cust_id integer NOT NULL,
    subscription_id text,
    customer_id integer,
    included boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ssdm9.ssdm9_subscription_customers OWNER TO postgres;

--
-- Name: ssdm9_subscription_master; Type: TABLE; Schema: ssdm9; Owner: postgres
--

CREATE TABLE ssdm9.ssdm9_subscription_master (
    subscription_id text NOT NULL,
    unit_id text,
    subscription_month text,
    created_by_customer_id integer,
    accepted_by_customer_id integer,
    created_date timestamp without time zone,
    accepted_date timestamp without time zone,
    total_amount numeric(10,2),
    payment_status text,
    status text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ssdm9.ssdm9_subscription_master OWNER TO postgres;

--
-- Name: ssdm9_subscription_services; Type: TABLE; Schema: ssdm9; Owner: postgres
--

CREATE TABLE ssdm9.ssdm9_subscription_services (
    sub_service_id integer NOT NULL,
    subscription_id text,
    service_id text,
    unit_id text,
    customer_id integer,
    service_scope text,
    period_type text,
    period_start_date date,
    period_end_date date,
    specific_dates text,
    quantity integer,
    unit_cost numeric(10,2),
    total_cost numeric(10,2),
    status text,
    remarks text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ssdm9.ssdm9_subscription_services OWNER TO postgres;

--
-- Name: ssdm9_units_master; Type: TABLE; Schema: ssdm9; Owner: postgres
--

CREATE TABLE ssdm9.ssdm9_units_master (
    unit_id text NOT NULL,
    unit_number text,
    unit_type text,
    ownership_status text,
    active_status boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ssdm9.ssdm9_units_master OWNER TO postgres;

--
-- Data for Name: ssdm9_customers; Type: TABLE DATA; Schema: ssdm9; Owner: postgres
--

COPY ssdm9.ssdm9_customers (customer_id, full_name, contact_no, email_id, whatsapp_available, gender, dob, age, blood_group, allergies, relation_to_unit, special_status, resident_since, unit_id, default_payer_id, active_status, created_at, updated_at) FROM stdin;
41	Ramesh Iyer	9876500011	ramesh.iyer@example.com	t	Male	1962-05-14	63	B+		Owner	Normal	2010-04-01	MMSVA01	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
42	Lakshmi Iyer	9876500012	lakshmi.iyer@example.com	t	Female	1965-08-24	60	O+		Owner Co-resident	Normal	2010-04-01	MMSVA01	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
43	Sundar Krishnan	9876500013	sundar.krishnan@example.com	t	Male	1959-03-10	66	A+		Owner	Promoter	2009-12-01	MMSVA02	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
44	Radha Krishnan	9876500014	radha.krishnan@example.com	t	Female	1962-11-11	63	A+		Owner Co-resident	Director Relative	2009-12-01	MMSVA02	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
45	Ravi Menon	9876500015	ravi.menon@example.com	t	Male	1961-02-05	64	O-		Lessee	Normal	2023-02-01	MMSVA03	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
46	Mala Menon	9876500016	mala.menon@example.com	t	Female	1964-07-08	61	B+		Lessee Co-resident	Normal	2023-02-01	MMSVA03	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
47	Suresh Nair	9876500017	suresh.nair@example.com	t	Male	1957-10-18	68	O+		Lessee	Normal	2022-06-01	MMSVA04	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
48	Meena Nair	9876500018	meena.nair@example.com	t	Female	1960-01-25	65	A-		Lessee Co-resident	Normal	2022-06-01	MMSVA04	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
49	John Mathew	9876500019	john.mathew@example.com	t	Male	1966-04-14	59	B+		Tenant	Normal	2024-01-01	MMSVA05	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
50	Mary Mathew	9876500020	mary.mathew@example.com	t	Female	1968-09-21	57	O+		Tenant Co-resident	Normal	2024-01-01	MMSVA05	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
51	Vijay Patel	9876500021	vijay.patel@example.com	t	Male	1963-12-17	61	A+		Tenant	Normal	2023-12-15	MMSVA06	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
52	Anita Patel	9876500022	anita.patel@example.com	t	Female	1966-06-22	59	B+		Tenant Co-resident	Normal	2023-12-15	MMSVA06	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
53	Rajesh Sharma	9876500023	rajesh.sharma@example.com	t	Male	1959-07-05	66	O+		Non-resident Payer	Normal	\N	MMSVA07	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
54	Geetha Sharma	9876500024	geetha.sharma@example.com	t	Female	1961-03-19	64	A+		Non-resident Payer	Normal	\N	MMSVA08	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
55	Deepak Kumar	9876500025	deepak.kumar@example.com	t	Male	1970-05-15	55	B+		Owner	Normal	2020-05-01	MMSVA09	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
56	Sita Kumar	9876500026	sita.kumar@example.com	t	Female	1973-02-08	52	A-		Owner Co-resident	Normal	2020-05-01	MMSVA09	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
57	Thomas George	9876500027	thomas.george@example.com	t	Male	1960-09-23	65	O+		Lessee	Normal	2022-08-01	MMSVA10	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
58	Elsa George	9876500028	elsa.george@example.com	t	Female	1964-11-14	61	A+		Lessee Co-resident	Normal	2022-08-01	MMSVA10	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
59	Sunil Reddy	9876500029	sunil.reddy@example.com	t	Male	1958-01-07	67	B+		Tenant	Normal	2024-02-01	MMSVA11	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
60	Latha Reddy	9876500030	latha.reddy@example.com	t	Female	1960-06-10	65	O+		Tenant Co-resident	Normal	2024-02-01	MMSVA11	\N	t	2025-10-16 07:37:03.676581	2025-10-16 07:37:03.676581
\.


--
-- Data for Name: ssdm9_service_enums; Type: TABLE DATA; Schema: ssdm9; Owner: postgres
--

COPY ssdm9.ssdm9_service_enums (enum_type, enum_value, description) FROM stdin;
complexity_level	Simple	\N
complexity_level	Compound	\N
complexity_level	Complex	\N
complexity_level	Assess & Decide	\N
complexity_remark	Single Team	\N
complexity_remark	Multi Team	\N
complexity_remark	Multi Org	\N
complexity_remark	Assess & Decide	\N
team_dept	Accommodation Services	\N
team_dept	Sales & Marketing	\N
team_dept	CARE HK & Lau	\N
team_dept	Nursing & Medical	\N
team_dept	Food & Beverages	\N
team_dept	Concierge	\N
team_dept	Accounts & Admin	\N
team_dept	Maintenance	\N
team_dept	Care - H & Wb	\N
vendor_org	Pest Control	\N
vendor_org	Building Assessor	\N
vendor_org	Panchayat Office	\N
vendor_org	TNEB	\N
vendor_org	Building Contractor	\N
vendor_org	External Elect & Plumb Technician	\N
vendor_org	Garbage Collector	\N
vendor_org	External Supplier	\N
vendor_org	Outside Caterer/Cook	\N
vendor_org	Ironman	\N
vendor_org	Dry Cleaning	\N
vendor_org	Hospital	\N
vendor_org	Yoga Teacher	\N
vendor_org	Physio-therapist	\N
vendor_org	Barber	\N
vendor_org	Beautician	\N
vendor_org	Pharmacy	\N
vendor_org	Doctor	\N
vendor_org	Courier	\N
vendor_org	Ext Vendor	\N
service_availability	Available on Request only	\N
service_availability	Available with Restrictions	\N
service_availability	Available on Advance Notice Only	\N
service_availability	Available at Specific Times only	\N
service_availability	Available on Specific Dates only	\N
service_availability	Available	\N
service_availability	Not Available	\N
service_availability_mode	Only Subscription	\N
service_availability_mode	Subscription & Open	\N
service_availability_mode	Only Open	\N
service_location	At Customer Residence	\N
service_location	At Dining Hall	\N
service_location	At Community Hall	\N
service_location	At Event Venue	\N
service_location	At Hospital	\N
service_location	At Medical Room	\N
service_location	At Guest Room	\N
service_location	Take Away	\N
service_location	Picnic Location	\N
service_location	Outside Campus	\N
service_location	Vendor Location	\N
service_location	At Office	\N
service_location	At Director Office	\N
service_location	At Vanam Store	\N
\.


--
-- Data for Name: ssdm9_service_master; Type: TABLE DATA; Schema: ssdm9; Owner: postgres
--

COPY ssdm9.ssdm9_service_master (service_id, service_name, service_category, service_complexity, serv_dely_lead_team, serv_dely_supp_team, serv_dely_ext_vendor, service_availability_mode, open_or_subsription, serv_dely_location, serv_special_instr, created_at, updated_at) FROM stdin;
Accn Serv101	Assessing Unit for Rent ( Condition & Inventorying)	Accommodation Services 	Single Team	Accommodation Services	\N	\N	Available on Request	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv102	Minor Civil / Elect / Plumbing Repair to Unit	Accommodation Services 	Multi Team	Accommodation Services	Maintenance Team	\N	Available on Request	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv103	Major Civil / Elect / Plumbing Repair to Unit	Accommodation Services 	Multi Org	Accommodation Services	Maintenance	Building Contractor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv104	Furnishing Unit for Rent	Accommodation Services 	Multi Team	Accommodation Services	Maintenance Team	External Supplier	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv105	Additional Accessories and Fittings	Accommodation Services 	Muti Org	Accommodation Services	Maintenance Team	External Supplier	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv106	Pre-Occupation - Thorough Cleaning	Accommodation Services 	Multi Team	Accommodation Services	Housekeeping Team	\N	Available on Request	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv107	Welcome, Handover Posession & Familiarization	Accommodation Services 	Multi Team	Accommodation Services	CARE	\N	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv108	Assessing Unit for Sale	Accommodation Services 	Multi Org	Accommodation Services	Sales & Marketing	External Assessor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv109	Staging Unit for Sale	Accommodation Services 	Multi Org	Accommodation Services	Sales & Marketing 	External Supplier	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv110	Generating Sales Enquiries, Followup Closure	Accommodation Services 	Multi Team	Sales & Marketing	\N	External Vendor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv111	Non Housekeeping - Thorough Cleaning	Accommodation Services 	Single Team	Accommodation Services	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv112	Pest Control	Accommodation Services 	Multi Org	Accommodation Services	Maintenance Team	External Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv113	Take Possession while vacating	Accommodation Services 	Multi Team	Accommodation Services	Account & Admin	\N	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv114	Paying Property Tax	Accommodation Services 	Single Team	Accommodation Services	Concierge 	\N	Available on Specific Dates only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv115	Paying Electrical Bill	Accommodation Services 	Single Team	Accommodation Services	Concierge 	\N	Available on Specific Dates only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv116	Accommodation Shifting within Community	Accommodation Services 	Multi Team	Accommodation Services	Maintenance	\N	Available at Specific Times only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv117	Major / Medical  / Biological / Waste Disposal 	Accommodation Services 	Multi Org	Accommodation Services	Maintenance	Garbage Collector	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Accn Serv118	Miscellaneous Work Relating to Accommodation	Accommodation Services 	Assess & Decide	Accommodation Services	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B201	Morning Beverage	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B202	Evening Beverage	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B203	Night Beverage	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B204	Breakfast Standard Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B205	Breakfast Modified Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Request only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B206	Breakfast Custom Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B207	Lunch Standard Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B208	Lunch Modified Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Request only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B209	Lunch Custom Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B210	Dinner Standard Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B211	Dinner Modified Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Request only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B212	Dinner Custom Menu	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B213	Snacks - Mid Morning	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B214	Snacks - Evening	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Request only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B215	Special Food Internal Preparation	Food & Beverages	Single Team	Food & Beverages	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B216	Special Food External Preparation	Food & Beverages	Multi Org	Food & Beverages	\N	Outside Caterer/ Cook	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B217	Festival/Occasion Meal	Food & Beverages	Multi Org	Food & Beverages	\N	Outside Caterer/ Cook	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B218	Picnic Meal	Food & Beverages	Single Team	Food & Beverages	\N	Outside Caterer/ Cook	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
F & B219	Event Catering 	Food & Beverages	Multi Org	Food & Beverages	\N	Outside Caterer/ Cook	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK301	Std HK without Material  (Sweeping+Mopping+Toilet)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK302	Std HK with Material  (Sweeping+Mopping+Toilet)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK303	Fan Cleaning (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK304	Cobweb Removal (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK305	Window & Grill Cleaning (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK306	Kitchen Surface Cleaning (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK307	Bathroom Deep Cleaning (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK308	Full Unit Deep Cleaning (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK309	Long-Absence Reset (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK310	Post-Event Cleaning (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-HK311	Emergency Cleaning After Soiling (With Materials)	CARE (Housekeeping)	Single Team	CARE HK & Lau	\N	\N	Available on Request only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau312	Standard Wash with Material @ Facility Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau313	Standard Wash without Material @ Facility Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau314	Standard Wash with Material @  Home Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau315	Standard Wash without Material @ Home Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau316	Special Wash with Material @ Facility Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau317	Special  Wash without Material @ Facility Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau318	Special Wash with Material @  Home Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau319	Special  Wash without Material @ Home Drying	CARE (Laundry)	Single Team	CARE HK & Lau	\N	\N	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau320	Ironing / Pressing of Clothes	CARE (Laundry)	Multi Org	CARE HK & Lau	Concierge 	Ironman	Available on Specific Dates only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-Lau321	Dry Cleaning of Clothes	CARE (Laundry)	Multi Org	CARE HK & Lau	Concierge 	Dry Cleaning	Available on Specific Dates only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb401	Care needs Assessment	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Request only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb402	Welcome and Mutual Familiarization 	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb403	Wellbeing Checkin - Morning	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb404	Wellbeing Checkin - Afternoon	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb405	Wellbeing Checkin - Evening 	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb406	Wellbeing Checkin - Night Before Sleep	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb407	Periodic Monitor - Checkin Every Two Hours 	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb408	Medication - Appointment Reminder	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb409	Medication - Tablet / Ointment Reminder	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb410	Medication - Tablet / Ointment Administration	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb411	Medication - Removing Expired Medication	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb412	Medication - Loading Pill Boxes	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb413	Companionsip - Conversation / Game Time	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb414	Companionship - Movement within Campus	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb415	Mobility Assistance - Within Accommodation	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb416	Mobility Assistance - Within Campus	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb417	Wheel Chair Assistance - Within Campus	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb418	Accompaniment - Shopping / Temple Visit	CARE (Health & Wellbeing)	Multi Team	CARE HK & Lau	Concierge 	\N	Available with Restrictions	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb419	Accompaniment - Hospital Visit	CARE (Health & Wellbeing)	Multi Org	Care - H & Wb	Nursing & Medical	Hospital	Available with Restrictions	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb420	Accommpaniment - Hospital Admission	CARE (Health & Wellbeing)	Multi Team	CARE HK & Lau	Nursing & Medical	\N	Available with Restrictions	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb421	Accompaniment - Extended Stay in Hospital	CARE (Health & Wellbeing)	Multi Org	Care - H & Wb	Nursing & Medical	Hospital	Available with Restrictions	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb422	Private Yoga Session	CARE (Health & Wellbeing)	Multi Org	CARE HK & Lau	Concierge 	Yoga Teacher	Available on Advance Notice Only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb423	Assisted Stretching/Light Exercise	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb424	Group Yoga / Meditation Session	CARE (Health & Wellbeing)	Multi Team	CARE HK & Lau	Concierge 	\N	Available on Advance Notice Only	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb425	Group Exercises / Physio	CARE (Health & Wellbeing)	Multi Org	CARE HK & Lau	Concierge 	Physio-therapist	Available on Advance Notice Only	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb426	Appearance - Hair oiling & plaiting	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb427	Appearance- Assistance with clothes	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb428	Appearance - Beard Trimming	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb429	Appearance - Hair Dresser (external vendor)	CARE (Health & Wellbeing)	Multi Org	Care - H & Wb	Concierge 	Barber	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb430	Appearance - Shaving Men Barber (external vendor)	CARE (Health & Wellbeing)	Multi Org	Care - H & Wb	Concierge 	Barber	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb431	Appearance - Hair Dyeing (external vendor)	CARE (Health & Wellbeing)	Multi Org	Care - H & Wb	Concierge 	Barber	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb432	Appearance - Nail Cutting & Filing	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb433	Appearance - Nail Polish	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb434	Appearance - Beauty Parlour (external vendor)	CARE (Health & Wellbeing)	Multi Org	Care - H & Wb	Concierge 	Beautician	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb435	Appearance - Saree / Dhoti Draping Assistance	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb436	Hygiene - Bathing Support	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb437	Hygiene - Bathing Support	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb438	Hygiene Oil Bath Traditiona	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb439	Hygiene - Skin Moisture / Powdering	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb440	Hygiene Teeth Brushing	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb441	Hygiene - Bedpan Support	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Care-H&Wb442	Companionship - Night(10PM- 6 AM) Accompaniment 	CARE (Health & Wellbeing)	Single Team	Care - H & Wb	\N	\N	Available with Restrictions	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med501	Vital Signs Monitoring Weekly	Nursing & Medical	Single Team	Nursing & Medical	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med502	Close Monitoring - On return from hospitalization	Nursing & Medical	Single Team	Nursing & Medical	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med503	Supervised Medicine Intake	Nursing & Medical	Single Team	Nursing & Medical	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med504	Medication Procurement & Verification	Nursing & Medical	Multi Org	Nursing & Medical	Concierge 	Pharmacy	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med505	Wound Dressing (Basic)	Nursing & Medical	Single Team	Nursing & Medical	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med506	Injections (Prescribed)	Nursing & Medical	Single Team	Nursing & Medical	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med507	Oxygen / CPAP / BiPAP Setup & Monitoring	Nursing & Medical	Single Team	Nursing & Medical	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med508	Physiotherapy Session - Trained Therapist	Nursing & Medical	Multi Org	Nursing & Medical	Concierge 	Physio-therapist	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med509	Hydrotherapy Session	Nursing & Medical	Multi Org	Nursing & Medical	Concierge 	Physio-therapist	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med510	Post-Surgical Mobility Support	Nursing & Medical	Single Team	Nursing & Medical	\N	\N	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med511	Coordination of Doctor Visit (On Campus)	Nursing & Medical	Multi Org	Nursing & Medical	Concierge 	Physio-therapist	Available on Advance Notice Only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med512	Coordination with External Hospital	Nursing & Medical	Multi Org	Care - H & Wb	Concierge 	Barber	Available on Request only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med513	Ambulance Arrangement	Nursing & Medical	Multi Org	Care - H & Wb	Concierge 	Barber	Available on Request only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med514	Emergency Medical Assistance	Nursing & Medical	Multi Org	Care - H & Wb	Concierge 	Barber	Available	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med515	Handover to Next-of-Kin on admission	Nursing & Medical	Multi Org	Care - H & Wb	Concierge 	Barber	Available with Restrictions	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Nur & Med516	Temporary Nursing Room Stay	Nursing & Medical	Multi Team	Nursing & Medical	Care - H & Wb	\N	Available on Request only	Subscription & Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv601	Local Information & Guidance	Concierge On Request Services	Multi Org	\N	\N	Courier	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv602	Courier/Parcel Handling (Incoming)	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv603	Courier Dispatch (Outgoing)	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv611	Printing/Scanning/Photocopy	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv621	Travel Booking (Bus/Train/Air)	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv622	Taxi / Auto / Ride-Hail Booking	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv623	Event Reservation / Ticket Purchase	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv624	Temple Pooja Booking / Archana	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv631	Local Transport Arrangement	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv632	Outstation Transport Arrangement	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv633	Entertainment Outing Coordination	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv634	Family Outing Assistance	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv641	Org Family Temple Visit	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv642	Religious Donation Handling	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv651	Gift Purchase & Delivery	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv652	Carwash	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv653	Personal Errands (Bank/Post Office)	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv661	Private Celebration Arrangement	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
On Req Serv662	Custom Tour / Day Trip Planning	Concierge On Request Services	Multi Org	\N	\N	Ext Vendor	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil701	Subscription Change Request	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil702	Resident Information Update	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil703	Agreement Copy / Document Retrieval	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil704	Monthly Statement Issuance	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil705	Annual Statement / Tax Document	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil706	Duplicate Receipt Issue	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil707	Billing Clarification / Explanation	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil708	Service Charge Dispute Investigation	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil709	Refund / Credit Processing	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Open and Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil710	Custom Usage Report	Resident Admin & Billing 	Multi Team	\N	\N	\N	Available on Request only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
Adm & Bil711	Third-Party Verification Assistance	Resident Admin & Billing 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR751	Body Preservation (Mortuary Holding)	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR752	Icebox Arrangement	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR753	Death Certificate Procurement	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR754	Cremation/Burial Arrangement	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR755	10th/16th Day Ceremony Coordination	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR756	Annadhanam Sponsorship (Memorial Food)	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available with Restrictions	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR757	Memorial Service Planning	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR758	Will Preparation & Storage	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR759	Power of Attorney Facilitation	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR760	Legal Heirship/Succession Certificate	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR761	Court / Registrar Liaison	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR762	Property Caretaking (Owner Absent)	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Subscription	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR763	Property Rental Facilitation	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR764	Property Sale Coordination	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR765	Insurance Claim Assistance	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR766	Estate Asset Inventory	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR767	Asset Handover to Heirs	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
ELDR768	Estate Closure	Estate, Legal, Death & Rituals 	Multi Org	\N	\N	Ext Vendor	Available on Advance Notice Only	Only Open	\N	\N	2025-10-18 05:40:47.890349	2025-10-18 05:40:47.890349
\.


--
-- Data for Name: ssdm9_subscription_customers; Type: TABLE DATA; Schema: ssdm9; Owner: postgres
--

COPY ssdm9.ssdm9_subscription_customers (sub_cust_id, subscription_id, customer_id, included, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ssdm9_subscription_master; Type: TABLE DATA; Schema: ssdm9; Owner: postgres
--

COPY ssdm9.ssdm9_subscription_master (subscription_id, unit_id, subscription_month, created_by_customer_id, accepted_by_customer_id, created_date, accepted_date, total_amount, payment_status, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ssdm9_subscription_services; Type: TABLE DATA; Schema: ssdm9; Owner: postgres
--

COPY ssdm9.ssdm9_subscription_services (sub_service_id, subscription_id, service_id, unit_id, customer_id, service_scope, period_type, period_start_date, period_end_date, specific_dates, quantity, unit_cost, total_cost, status, remarks, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ssdm9_units_master; Type: TABLE DATA; Schema: ssdm9; Owner: postgres
--

COPY ssdm9.ssdm9_units_master (unit_id, unit_number, unit_type, ownership_status, active_status, created_at, updated_at) FROM stdin;
MMSVA01	A01	Studio	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA02	A02	Studio	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA03	A03	Studio	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA04	A04	Studio	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA05	A05	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA06	A06	Studio	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA07	A07	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA08	A08	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA09	A09	Studio	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA10	A10	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA11	A11	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA12	A12	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA13	A13	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA14	A14	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA15	A15	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA16	A16	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA17	A17	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA18	A18	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA19	A19	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA20	A20	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA21	A21	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA22	A22	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA23	A23	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVA24	A24	Studio	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB01	B01	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB02	B02	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB03	B03	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB04	B04	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB05	B05	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB06	B06	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB07	B07	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB08	B08	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB09	B09	Studio +	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB10	B10	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB11	B11	Studio +	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB12	B12	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB13	B13	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB14	B14	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB15	B15	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB16	B16	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB17	B17	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB18	B18	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB19	B19	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB20	B20	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB21	B21	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB22	B22	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB23	B23	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB24	B24	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB25	B25	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB26	B26	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB27	B27	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB28	B28	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB29	B29	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB30	B30	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB31	B31	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB32	B32	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB33	B33	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB34	B34	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB35	B35	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB36	B36	Studio +	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB37	B37	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB38	B38	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB39	B39	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB40	B40	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB41	B41	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB42	B42	Studio +	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB43	B43	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVB44	B44	Studio +	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC01	C01	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC02	C02	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC03	C03	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC04	C04	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC05	C05	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC06	C06	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC07	C07	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC08	C08	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC09	C09	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC10	C10	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC11	C11	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC12	C12	Semi - Deluxe	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC13	C13	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC14	C14	Semi - Deluxe	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC15	C15	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC16	C16	Semi - Deluxe	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC17	C17	Semi - Deluxe	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC18	C18	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC19	C19	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC20	C20	Semi - Deluxe	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC21	C21	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC22	C22	Semi - Deluxe	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC23	C23	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVC24	C24	Semi - Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD01	D01	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD02	D02	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD03	D03	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD04	D04	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD05	D05	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD06	D06	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD07	D07	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD08	D08	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD09	D09	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD10	D10	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD11	D11	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD12	D12	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD12B	D12B	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD14	D14	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD15	D15	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD16	D16	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD17	D17	Deluxe	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD18	D18	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD19	D19	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD20	D20	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD21	D21	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD22	D22	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD23	D23	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD24	D24	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD25	D25	Deluxe	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD26	D26	Deluxe	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD27	D27	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD28	D28	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD29	D29	Deluxe	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD30	D30	Deluxe	MMALPL	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD31	D31	Deluxe	Private Single	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
MMSVD32	D32	Deluxe	Private Joint	t	2025-10-16 07:14:09.002293	2025-10-16 07:14:09.002293
\.


--
-- Name: ssdm9_customers pk_ssdm9_customers; Type: CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_customers
    ADD CONSTRAINT pk_ssdm9_customers PRIMARY KEY (customer_id);


--
-- Name: ssdm9_service_master pk_ssdm9_service_master; Type: CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_service_master
    ADD CONSTRAINT pk_ssdm9_service_master PRIMARY KEY (service_id);


--
-- Name: ssdm9_subscription_customers pk_ssdm9_subscription_customers; Type: CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_customers
    ADD CONSTRAINT pk_ssdm9_subscription_customers PRIMARY KEY (sub_cust_id);


--
-- Name: ssdm9_subscription_master pk_ssdm9_subscription_master; Type: CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_master
    ADD CONSTRAINT pk_ssdm9_subscription_master PRIMARY KEY (subscription_id);


--
-- Name: ssdm9_subscription_services pk_ssdm9_subscription_services; Type: CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_services
    ADD CONSTRAINT pk_ssdm9_subscription_services PRIMARY KEY (sub_service_id);


--
-- Name: ssdm9_units_master pk_ssdm9_units_master; Type: CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_units_master
    ADD CONSTRAINT pk_ssdm9_units_master PRIMARY KEY (unit_id);


--
-- Name: idx_subscription_customers_customer; Type: INDEX; Schema: ssdm9; Owner: postgres
--

CREATE INDEX idx_subscription_customers_customer ON ssdm9.ssdm9_subscription_customers USING btree (customer_id);


--
-- Name: idx_subscription_customers_subscription; Type: INDEX; Schema: ssdm9; Owner: postgres
--

CREATE INDEX idx_subscription_customers_subscription ON ssdm9.ssdm9_subscription_customers USING btree (subscription_id);


--
-- Name: idx_subscription_master_unit; Type: INDEX; Schema: ssdm9; Owner: postgres
--

CREATE INDEX idx_subscription_master_unit ON ssdm9.ssdm9_subscription_master USING btree (unit_id);


--
-- Name: idx_subscription_services_customer; Type: INDEX; Schema: ssdm9; Owner: postgres
--

CREATE INDEX idx_subscription_services_customer ON ssdm9.ssdm9_subscription_services USING btree (customer_id);


--
-- Name: idx_subscription_services_subscription; Type: INDEX; Schema: ssdm9; Owner: postgres
--

CREATE INDEX idx_subscription_services_subscription ON ssdm9.ssdm9_subscription_services USING btree (subscription_id);


--
-- Name: ssdm9_subscription_customers fk_subscription_customers_customer; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_customers
    ADD CONSTRAINT fk_subscription_customers_customer FOREIGN KEY (customer_id) REFERENCES ssdm9.ssdm9_customers(customer_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ssdm9_subscription_customers fk_subscription_customers_subscription; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_customers
    ADD CONSTRAINT fk_subscription_customers_subscription FOREIGN KEY (subscription_id) REFERENCES ssdm9.ssdm9_subscription_master(subscription_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ssdm9_subscription_master fk_subscription_master_accepted_by; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_master
    ADD CONSTRAINT fk_subscription_master_accepted_by FOREIGN KEY (accepted_by_customer_id) REFERENCES ssdm9.ssdm9_customers(customer_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ssdm9_subscription_master fk_subscription_master_created_by; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_master
    ADD CONSTRAINT fk_subscription_master_created_by FOREIGN KEY (created_by_customer_id) REFERENCES ssdm9.ssdm9_customers(customer_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ssdm9_subscription_master fk_subscription_master_unit; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_master
    ADD CONSTRAINT fk_subscription_master_unit FOREIGN KEY (unit_id) REFERENCES ssdm9.ssdm9_units_master(unit_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ssdm9_subscription_services fk_subscription_services_customer; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_services
    ADD CONSTRAINT fk_subscription_services_customer FOREIGN KEY (customer_id) REFERENCES ssdm9.ssdm9_customers(customer_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ssdm9_subscription_services fk_subscription_services_service; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_services
    ADD CONSTRAINT fk_subscription_services_service FOREIGN KEY (service_id) REFERENCES ssdm9.ssdm9_service_master(service_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ssdm9_subscription_services fk_subscription_services_subscription; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_services
    ADD CONSTRAINT fk_subscription_services_subscription FOREIGN KEY (subscription_id) REFERENCES ssdm9.ssdm9_subscription_master(subscription_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ssdm9_subscription_services fk_subscription_services_unit; Type: FK CONSTRAINT; Schema: ssdm9; Owner: postgres
--

ALTER TABLE ONLY ssdm9.ssdm9_subscription_services
    ADD CONSTRAINT fk_subscription_services_unit FOREIGN KEY (unit_id) REFERENCES ssdm9.ssdm9_units_master(unit_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict anKJxgTat996XQtzTyzq425Umm7N5zdj4KyG5ygjoxln6TVFYwexnGngGRS1Dii

