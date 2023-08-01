--
-- PostgreSQL database dump
--

-- Dumped from database version 14.8 (Ubuntu 14.8-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.8 (Ubuntu 14.8-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: sister
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO sister;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: sister
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO sister;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: public; Owner: sister
--

CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;


ALTER FUNCTION public.set_current_timestamp_updated_at() OWNER TO sister;

--
-- Name: sync_authentications_table(); Type: FUNCTION; Schema: public; Owner: sister
--

CREATE FUNCTION public.sync_authentications_table() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    role_id UUID;
    role_name_txt text;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT roles.role_id INTO role_id FROM roles WHERE role_name = substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1);
        SELECT roles.role_name INTO role_name_txt FROM roles WHERE role_name = substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1);
        IF role_name_txt = 'customer' THEN 
            INSERT INTO "authentications" (user_id, role_id, phone_no)
            VALUES (NEW.customer_id, role_id, NEW.phone_no);
        ELSIF role_name_txt = 'vendor' THEN 
            INSERT INTO "authentications" (user_id, role_id, phone_no)
            VALUES (NEW.vendor_id, role_id, NEW.phone_no);
        ELSIF role_name_txt = 'rider' THEN 
           INSERT INTO "authentications" (user_id, role_id, phone_no)
            VALUES (NEW.rider_id, role_id, NEW.phone_no);
        ELSE
            RAISE EXCEPTION 'Unknown role_name: %', role_name_txt;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'customer' THEN
            UPDATE "authentications" SET
                phone_no = NEW.phone_no
            WHERE user_id = NEW.customer_id;
        ELSIF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'vendor' THEN
            UPDATE "authentications" SET
                phone_no = NEW.phone_no
            WHERE user_id = NEW.vendor_id;
        ELSIF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'rider' THEN
            UPDATE "authentications" SET
                phone_no = NEW.phone_no
            WHERE user_id = NEW.rider_id;
        ELSE
            RAISE EXCEPTION 'Unknown TG_TABLE_NAME: %', TG_TABLE_NAME;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'customer' THEN
            DELETE FROM authentications WHERE user_id = OLD.customer_id;
        ELSIF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'vendor' THEN
            DELETE FROM authentications WHERE user_id = OLD.vendor_id;
        ELSIF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'rider' THEN
            DELETE FROM authentications WHERE user_id = OLD.rider_id;
        ELSE
            RAISE EXCEPTION 'Unknown TG_TABLE_NAME: %', TG_TABLE_NAME;
        END IF;
    ELSE
        RAISE EXCEPTION 'Unknown TG_OP: %', TG_OP;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sync_authentications_table() OWNER TO sister;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO sister;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO sister;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO sister;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO sister;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO sister;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO sister;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO sister;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO sister;

--
-- Name: migration_settings; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.migration_settings (
    setting text NOT NULL,
    value text NOT NULL
);


ALTER TABLE hdb_catalog.migration_settings OWNER TO sister;

--
-- Name: schema_migrations; Type: TABLE; Schema: hdb_catalog; Owner: sister
--

CREATE TABLE hdb_catalog.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE hdb_catalog.schema_migrations OWNER TO sister;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.addresses (
    adress_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    address_line_one text NOT NULL,
    address_line_two text NOT NULL,
    city text NOT NULL,
    country_code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ward_id uuid NOT NULL,
    county_id uuid NOT NULL
);


ALTER TABLE public.addresses OWNER TO sister;

--
-- Name: authentications; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.authentications (
    user_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    role_id uuid NOT NULL,
    phone_no text NOT NULL,
    password text,
    status boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.authentications OWNER TO sister;

--
-- Name: business_categories; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.business_categories (
    business_category_id uuid NOT NULL,
    business_category_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.business_categories OWNER TO sister;

--
-- Name: business_reviews; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.business_reviews (
    business_review_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    business_id uuid NOT NULL,
    business_review text NOT NULL,
    business_rate real DEFAULT '0'::real NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.business_reviews OWNER TO sister;

--
-- Name: businesses; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.businesses (
    business_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    business_category_id uuid NOT NULL,
    vendor_id uuid NOT NULL,
    business_phone_no text NOT NULL,
    business_email text NOT NULL,
    address_id uuid NOT NULL,
    country_code text NOT NULL,
    about text NOT NULL,
    is_verified boolean NOT NULL,
    status boolean NOT NULL,
    bussiness_name text
);


ALTER TABLE public.businesses OWNER TO sister;

--
-- Name: businesses_favorites; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.businesses_favorites (
    business_favorite_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    business_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.businesses_favorites OWNER TO sister;

--
-- Name: chats; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.chats (
    chat_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bussiness_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.chats OWNER TO sister;

--
-- Name: counties; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.counties (
    county_id uuid DEFAULT gen_random_uuid() NOT NULL,
    county_name text NOT NULL
);


ALTER TABLE public.counties OWNER TO sister;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.customers (
    customer_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    email text NOT NULL,
    phone_no text,
    status boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    profile_image text DEFAULT 'https://img.freepik.com/free-icon/user_318-563642.jpg'::text
);


ALTER TABLE public.customers OWNER TO sister;

--
-- Name: delivery_requests; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.delivery_requests (
    delivery_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_id uuid,
    order_id uuid,
    pickup_point uuid,
    drop_off_point uuid
);


ALTER TABLE public.delivery_requests OWNER TO sister;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.messages (
    message_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    chat_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    reciever_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.messages OWNER TO sister;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.order_items (
    order_item_id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.order_items OWNER TO sister;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.orders (
    order_id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    business_id uuid NOT NULL,
    order_status text DEFAULT 'inprogress'::text
);


ALTER TABLE public.orders OWNER TO sister;

--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.product_categories (
    product_category_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    businesses_category_id uuid NOT NULL,
    product_category_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.product_categories OWNER TO sister;

--
-- Name: product_reviews; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.product_reviews (
    product_review_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    product_id uuid NOT NULL,
    product_review text NOT NULL,
    product_rate real NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.product_reviews OWNER TO sister;

--
-- Name: products; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.products (
    product_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    businesses_id uuid NOT NULL,
    product_category_id uuid NOT NULL,
    product_name text NOT NULL,
    product_description text NOT NULL,
    product_price real NOT NULL,
    product_discount_price real NOT NULL,
    quantity_in_stock integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products OWNER TO sister;

--
-- Name: riders; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.riders (
    rider_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    email text NOT NULL,
    phone_no text NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.riders OWNER TO sister;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.roles (
    role_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    role_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.roles OWNER TO sister;

--
-- Name: statuses; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.statuses (
    status_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    business_id uuid NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    status_caption text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.statuses OWNER TO sister;

--
-- Name: variant_categories; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.variant_categories (
    variant_category_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    variant_category_name text NOT NULL
);


ALTER TABLE public.variant_categories OWNER TO sister;

--
-- Name: variants; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.variants (
    variant_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    variant_category_id uuid NOT NULL,
    variant_name text NOT NULL,
    variant_price real NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.variants OWNER TO sister;

--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.vehicles (
    vehicle_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    rider_id uuid NOT NULL,
    vehicle_type text,
    vehicle_make text,
    vehicle_plate_no text,
    year_of_manufacture text
);


ALTER TABLE public.vehicles OWNER TO sister;

--
-- Name: vendors; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.vendors (
    vendor_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    email text NOT NULL,
    phone_no text NOT NULL,
    status boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.vendors OWNER TO sister;

--
-- Name: wards; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.wards (
    ward_id uuid DEFAULT gen_random_uuid() NOT NULL,
    county_id uuid NOT NULL,
    ward_name text NOT NULL
);


ALTER TABLE public.wards OWNER TO sister;

--
-- Name: wish_lists; Type: TABLE; Schema: public; Owner: sister
--

CREATE TABLE public.wish_lists (
    wish_list_id uuid NOT NULL,
    product_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.wish_lists OWNER TO sister;

--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_cron_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_cron_events (id, trigger_name, scheduled_time, status, tries, created_at, next_retry_at) FROM stdin;
\.


--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_metadata (id, metadata, resource_version) FROM stdin;
1	{"actions":[{"definition":{"arguments":[{"name":"full_name","type":"String!"},{"name":"email","type":"String!"},{"name":"phone_no","type":"String!"},{"name":"password","type":"String!"}],"handler":"{{ACTION_BASE_URL}}/customer_signup","kind":"synchronous","output_type":"signup_output!","type":"mutation"},"name":"customer_signup","permissions":[{"role":"rider"},{"role":"vendor"},{"role":"zadmin"},{"role":"anonymous"},{"role":"customer"}]},{"definition":{"arguments":[{"name":"base64str","type":"String!"},{"name":"name","type":"String!"},{"name":"type","type":"String!"}],"handler":"{{ACTION_BASE_URL}}/file_upload","kind":"synchronous","output_type":"file_upload_output!","type":"mutation"},"name":"file_upload"},{"definition":{"arguments":[{"name":"phone_no","type":"String!"},{"name":"password","type":"String!"}],"handler":"{{ACTION_BASE_URL}}/login","kind":"synchronous","output_type":"login_output!","type":"mutation"},"name":"login","permissions":[{"role":"zadmin"},{"role":"vendor"},{"role":"customer"},{"role":"rider"},{"role":"anonymous"}]},{"definition":{"arguments":[{"name":"full_name","type":"String!"},{"name":"email","type":"String!"},{"name":"phone_no","type":"String!"},{"name":"password","type":"String!"}],"handler":"{{ACTION_BASE_URL}}/rider_signup","kind":"synchronous","output_type":"signup_output!","type":"mutation"},"name":"rider_signup","permissions":[{"role":"anonymous"},{"role":"zadmin"},{"role":"vendor"},{"role":"rider"},{"role":"customer"}]},{"definition":{"arguments":[{"name":"full_name","type":"String!"},{"name":"email","type":"String!"},{"name":"phone_no","type":"String!"},{"name":"password","type":"String!"}],"handler":"{{ACTION_BASE_URL}}/vendor_signup","kind":"synchronous","output_type":"signup_output!","type":"mutation"},"name":"vendor_signup","permissions":[{"role":"anonymous"},{"role":"zadmin"},{"role":"vendor"},{"role":"rider"},{"role":"customer"}]}],"custom_types":{"objects":[{"fields":[{"name":"access_token","type":"String!"}],"name":"login_output"},{"fields":[{"name":"success","type":"String!"}],"name":"signup_output"},{"fields":[{"name":"image_url","type":"String!"}],"name":"file_upload_output"}]},"sources":[{"configuration":{"connection_info":{"database_url":{"from_env":"HASURA_GRAPHQL_DATABASE_URL"},"isolation_level":"read-committed","pool_settings":{"connection_lifetime":600,"idle_timeout":180,"max_connections":50,"retries":1},"use_prepared_statements":true}},"kind":"postgres","name":"default","tables":[{"object_relationships":[{"name":"authentication","using":{"foreign_key_constraint_on":"user_id"}}],"select_permissions":[{"permission":{"columns":[],"filter":{}},"role":"customer"},{"permission":{"columns":[],"filter":{}},"role":"rider"},{"permission":{"columns":[],"filter":{}},"role":"vendor"},{"permission":{"columns":[],"filter":{}},"role":"zadmin"}],"table":{"name":"addresses","schema":"public"}},{"array_relationships":[{"name":"addresses","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"addresses","schema":"public"}}}}],"object_relationships":[{"name":"role","using":{"foreign_key_constraint_on":"role_id"}}],"table":{"name":"authentications","schema":"public"}},{"array_relationships":[{"name":"businesses","using":{"foreign_key_constraint_on":{"column":"business_category_id","table":{"name":"businesses","schema":"public"}}}},{"name":"product_categories","using":{"foreign_key_constraint_on":{"column":"businesses_category_id","table":{"name":"product_categories","schema":"public"}}}}],"table":{"name":"business_categories","schema":"public"}},{"object_relationships":[{"name":"business","using":{"foreign_key_constraint_on":"business_id"}},{"name":"customer","using":{"foreign_key_constraint_on":"customer_id"}}],"table":{"name":"business_reviews","schema":"public"}},{"array_relationships":[{"name":"business_reviews","using":{"foreign_key_constraint_on":{"column":"business_id","table":{"name":"business_reviews","schema":"public"}}}},{"name":"businesses_favorites","using":{"foreign_key_constraint_on":{"column":"business_id","table":{"name":"businesses_favorites","schema":"public"}}}},{"name":"chats","using":{"foreign_key_constraint_on":{"column":"bussiness_id","table":{"name":"chats","schema":"public"}}}},{"name":"orders","using":{"foreign_key_constraint_on":{"column":"business_id","table":{"name":"orders","schema":"public"}}}},{"name":"products","using":{"foreign_key_constraint_on":{"column":"businesses_id","table":{"name":"products","schema":"public"}}}},{"name":"statuses","using":{"foreign_key_constraint_on":{"column":"business_id","table":{"name":"statuses","schema":"public"}}}}],"object_relationships":[{"name":"business_category","using":{"foreign_key_constraint_on":"business_category_id"}},{"name":"vendor","using":{"foreign_key_constraint_on":"vendor_id"}}],"table":{"name":"businesses","schema":"public"}},{"object_relationships":[{"name":"business","using":{"foreign_key_constraint_on":"business_id"}},{"name":"customer","using":{"foreign_key_constraint_on":"customer_id"}}],"table":{"name":"businesses_favorites","schema":"public"}},{"array_relationships":[{"name":"messages","using":{"foreign_key_constraint_on":{"column":"chat_id","table":{"name":"messages","schema":"public"}}}}],"object_relationships":[{"name":"business","using":{"foreign_key_constraint_on":"bussiness_id"}},{"name":"customer","using":{"foreign_key_constraint_on":"customer_id"}}],"table":{"name":"chats","schema":"public"}},{"array_relationships":[{"name":"wards","using":{"foreign_key_constraint_on":{"column":"county_id","table":{"name":"wards","schema":"public"}}}}],"table":{"name":"counties","schema":"public"}},{"array_relationships":[{"name":"business_reviews","using":{"foreign_key_constraint_on":{"column":"customer_id","table":{"name":"business_reviews","schema":"public"}}}},{"name":"businesses_favorites","using":{"foreign_key_constraint_on":{"column":"customer_id","table":{"name":"businesses_favorites","schema":"public"}}}},{"name":"chats","using":{"foreign_key_constraint_on":{"column":"customer_id","table":{"name":"chats","schema":"public"}}}},{"name":"orders","using":{"foreign_key_constraint_on":{"column":"customer_id","table":{"name":"orders","schema":"public"}}}},{"name":"product_reviews","using":{"foreign_key_constraint_on":{"column":"customer_id","table":{"name":"product_reviews","schema":"public"}}}},{"name":"wish_lists","using":{"foreign_key_constraint_on":{"column":"customer_id","table":{"name":"wish_lists","schema":"public"}}}}],"table":{"name":"customers","schema":"public"}},{"table":{"name":"delivery_requests","schema":"public"}},{"object_relationships":[{"name":"chat","using":{"foreign_key_constraint_on":"chat_id"}}],"table":{"name":"messages","schema":"public"}},{"object_relationships":[{"name":"product","using":{"foreign_key_constraint_on":"product_id"}}],"table":{"name":"order_items","schema":"public"}},{"object_relationships":[{"name":"business","using":{"foreign_key_constraint_on":"business_id"}},{"name":"customer","using":{"foreign_key_constraint_on":"customer_id"}}],"table":{"name":"orders","schema":"public"}},{"array_relationships":[{"name":"products","using":{"foreign_key_constraint_on":{"column":"product_category_id","table":{"name":"products","schema":"public"}}}}],"object_relationships":[{"name":"business_category","using":{"foreign_key_constraint_on":"businesses_category_id"}}],"table":{"name":"product_categories","schema":"public"}},{"object_relationships":[{"name":"customer","using":{"foreign_key_constraint_on":"customer_id"}},{"name":"product","using":{"foreign_key_constraint_on":"product_id"}}],"table":{"name":"product_reviews","schema":"public"}},{"array_relationships":[{"name":"order_items","using":{"foreign_key_constraint_on":{"column":"product_id","table":{"name":"order_items","schema":"public"}}}},{"name":"product_reviews","using":{"foreign_key_constraint_on":{"column":"product_id","table":{"name":"product_reviews","schema":"public"}}}},{"name":"variant_categories","using":{"foreign_key_constraint_on":{"column":"product_id","table":{"name":"variant_categories","schema":"public"}}}},{"name":"wish_lists","using":{"foreign_key_constraint_on":{"column":"product_id","table":{"name":"wish_lists","schema":"public"}}}}],"object_relationships":[{"name":"business","using":{"foreign_key_constraint_on":"businesses_id"}},{"name":"product_category","using":{"foreign_key_constraint_on":"product_category_id"}}],"select_permissions":[{"permission":{"columns":["quantity_in_stock","product_discount_price","product_price","product_description","product_name","created_at","updated_at","businesses_id","product_category_id","product_id"],"filter":{}},"role":"anonymous"}],"table":{"name":"products","schema":"public"}},{"array_relationships":[{"name":"rider_address","using":{"manual_configuration":{"column_mapping":{"rider_id":"user_id"},"insertion_order":null,"remote_table":{"name":"addresses","schema":"public"}}}}],"table":{"name":"riders","schema":"public"}},{"array_relationships":[{"name":"authentications","using":{"foreign_key_constraint_on":{"column":"role_id","table":{"name":"authentications","schema":"public"}}}}],"table":{"name":"roles","schema":"public"}},{"object_relationships":[{"name":"business","using":{"foreign_key_constraint_on":"business_id"}}],"table":{"name":"statuses","schema":"public"}},{"array_relationships":[{"name":"variants","using":{"foreign_key_constraint_on":{"column":"variant_category_id","table":{"name":"variants","schema":"public"}}}}],"object_relationships":[{"name":"product","using":{"foreign_key_constraint_on":"product_id"}}],"table":{"name":"variant_categories","schema":"public"}},{"object_relationships":[{"name":"variant_category","using":{"foreign_key_constraint_on":"variant_category_id"}}],"table":{"name":"variants","schema":"public"}},{"table":{"name":"vehicles","schema":"public"}},{"array_relationships":[{"name":"businesses","using":{"foreign_key_constraint_on":{"column":"vendor_id","table":{"name":"businesses","schema":"public"}}}}],"table":{"name":"vendors","schema":"public"}},{"object_relationships":[{"name":"county","using":{"foreign_key_constraint_on":"county_id"}}],"table":{"name":"wards","schema":"public"}},{"object_relationships":[{"name":"customer","using":{"foreign_key_constraint_on":"customer_id"}},{"name":"product","using":{"foreign_key_constraint_on":"product_id"}}],"table":{"name":"wish_lists","schema":"public"}}]}],"version":3}	158
\.


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_scheduled_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_scheduled_events (id, webhook_conf, scheduled_time, retry_conf, payload, header_conf, status, tries, created_at, next_retry_at, comment) FROM stdin;
\.


--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_schema_notifications (id, notification, resource_version, instance_id, updated_at) FROM stdin;
1	{"metadata":false,"remote_schemas":[],"sources":["default"],"data_connectors":[]}	158	fb54636c-634b-4efe-bcce-e59e285fd2ca	2023-06-22 15:03:04.774263+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state) FROM stdin;
dab0947f-0079-4270-aef3-cb58fbf91b52	47	2023-06-22 13:55:51.938831+00	{"settings": {"migration_mode": "true"}, "migrations": {"shine": {"1687447525563": false}}, "isStateCopyCompleted": true}	{"console_notifications": {"admin": {"date": "2023-07-19T20:26:23.049Z", "read": [], "showBadge": false}}, "telemetryNotificationShown": true}
\.


--
-- Data for Name: migration_settings; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.migration_settings (setting, value) FROM stdin;
migration_mode	true
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: hdb_catalog; Owner: sister
--

COPY hdb_catalog.schema_migrations (version, dirty) FROM stdin;
1687447525563	f
1687449749623	f
1687449925111	f
1687450122254	f
1687450236477	f
1687376482616	f
1687377640836	f
1687377741481	f
1687377759249	f
1687457208726	f
1687460911189	f
1687460993085	f
1687554465031	f
1687554487704	f
1687638041056	f
1687638351064	f
1687638382759	f
1687638671789	f
1687638699519	f
1687638734972	f
1687639908404	f
1687678905329	f
1687702034786	f
1687702071204	f
1687702188147	f
1687702546695	f
1687702694559	f
1687702765920	f
1687702913958	f
1687705161889	f
1687705175806	f
1687705186511	f
1687705277398	f
1687707219297	f
1687715414942	f
1687726369035	f
1687726578669	f
1687727688982	f
1687727758833	f
1687727942840	f
1687728148685	f
1687801585118	f
1687801659714	f
1687801720201	f
1687801772298	f
1687802048140	f
1688065062514	f
1688065136874	f
1689443529570	f
1689443552528	f
1689443610586	f
1689443633053	f
1689443651340	f
1689799864618	f
1690403062788	f
1690405003330	f
1690407008310	f
1690407375728	f
1690488540109	f
1690488618440	f
1690488761081	f
1690488887814	f
\.


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.addresses (adress_id, user_id, address_line_one, address_line_two, city, country_code, created_at, updated_at, ward_id, county_id) FROM stdin;
\.


--
-- Data for Name: authentications; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.authentications (user_id, role_id, phone_no, password, status, created_at, updated_at) FROM stdin;
00e4dbc6-6061-4ac3-b53b-843016c752b9	34bc49a5-24a5-4d9c-899f-941c6872b53b	0943204801	$2b$10$EoaOZzVMcGaZ7u/nzwFH4uEnkgzNNI7Wy9F.1JaU9wp/W9qcG60Im	t	2023-07-19 21:00:12.599106+00	2023-07-19 21:00:12.617384+00
0e623e1b-5a94-4b44-b2e7-89d122ae95c3	34bc49a5-24a5-4d9c-899f-941c6872b53b	123-456-7890	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 15:25:19.810973+00	2023-06-25 17:23:50.08506+00
c8843d2a-f5c7-49c3-8f53-71ca9b031f7b	f12a37f1-c262-47b9-8873-204a3db263be	0939304930	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 15:51:32.239644+00	2023-06-25 17:23:50.08506+00
3258463a-1a98-4d37-87bf-48de41c4c781	f12a37f1-c262-47b9-8873-204a3db263be	0930295302	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 15:52:26.322694+00	2023-06-25 17:23:50.08506+00
77be860b-a500-45f6-8681-0bde547f217d	f12a37f1-c262-47b9-8873-204a3db263be	0948394239	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 15:54:04.513893+00	2023-06-25 17:23:50.08506+00
a1f6250d-bd25-4557-aef5-69e6b05f7e60	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	0921050699	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 16:02:28.225931+00	2023-06-25 17:23:50.08506+00
277aebc9-12b0-4426-b034-6dd74d63e533	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	0949324392	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 16:03:46.546356+00	2023-06-25 17:23:50.08506+00
395c0548-04ff-4584-adf7-00164d37c51a	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	09123e45678	$2b$10$cspsrGEhuAgb4TM3q3ia3.LksGH8MyiD6915Kli53uZu7NQ0rCfdK	t	2023-06-25 20:58:20.655996+00	2023-06-25 20:58:20.850829+00
20f3832e-c3a8-479b-8f75-1a1af973cb5d	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	0j9123e45678	$2b$10$JYwVXvuQsYvsm65QHCoBQe6NKwWsb4mSt45LmY3gVJ3AKU2LkdHxq	t	2023-06-25 21:11:48.769104+00	2023-06-25 21:11:48.963812+00
a3594264-5c1e-440b-ad3b-cda9859ff66b	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	0j91d23e45678	$2b$10$Tsx6w/Za2BYIeJh5EB.zG.mWhNi2ecW8mg9yVIuX6NeMrBoIgSW1G	t	2023-06-25 21:12:57.285664+00	2023-06-25 21:12:57.477817+00
54268d44-804d-4862-bc63-8af69ea560ab	34bc49a5-24a5-4d9c-899f-941c6872b53b	0937483920	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 16:40:26.224116+00	2023-06-26 17:48:32.29371+00
577eca63-2e83-4ee5-81e8-f7cba0cdee23	34bc49a5-24a5-4d9c-899f-941c6872b53b	0937483926	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 16:41:24.293609+00	2023-06-26 17:49:16.875541+00
5ccc6534-f5b0-43ff-8a88-47d4b69add38	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	0116812019	$2b$10$.kwLe9NBeADP3kQUDhqKh.e0zw8d6.6Oj7U8ETdNwQl5AIJwSjQ1G	t	2023-06-29 17:32:55.515403+00	2023-06-29 17:32:55.5501+00
0c49add2-b51b-4745-8fd6-d448dac137d0	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	0912345678	$2b$10$tWzwWnNTCduVsbMove.5IOUjiNgsVOlBfrScP2ZhHUhgFFfEmJuZK	t	2023-06-29 18:32:15.386736+00	2023-06-29 18:32:15.421115+00
2b02566a-157a-44d2-bc34-ebc4617719fa	34bc49a5-24a5-4d9c-899f-941c6872b53b	22273088	$2b$10$FihrqAzCCqv.W1R8Jm2tUee8z4KuMCzoEVzat67uPncg6rVeoR47q	t	2023-07-21 02:35:22.464186+00	2023-07-21 02:35:22.474711+00
04142094-8182-449e-a564-6a7cf5d4fd11	34bc49a5-24a5-4d9c-899f-941c6872b53b	0962247109	$2b$10$Ft6ng8ikjZ6AqI6WcEfAPeHWr/3de.MB3swoOZI/vOc3uTTDr73Y6	t	2023-07-05 07:43:45.418068+00	2023-07-05 07:43:45.453742+00
c017a9b3-046c-4a36-915a-a5dd165a0acd	34bc49a5-24a5-4d9c-899f-941c6872b53b	0922050699	\N	t	2023-07-15 18:01:28.37462+00	2023-07-15 18:01:28.37462+00
5781fb7a-af04-4988-8f5f-c083d62d3eaf	34bc49a5-24a5-4d9c-899f-941c6872b53b	092224992315	\N	t	2023-07-17 19:33:35.927945+00	2023-07-17 19:33:35.927945+00
e9a5706d-927b-4e57-a3f0-68fcf9e4a041	34bc49a5-24a5-4d9c-899f-941c6872b53b	1234567890	\N	t	2023-07-17 20:01:28.836025+00	2023-07-17 20:01:28.836025+00
c53b4415-5bc5-4755-9e94-52e2c0e001c7	34bc49a5-24a5-4d9c-899f-941c6872b53b	9876543210	\N	t	2023-07-17 20:01:28.836025+00	2023-07-17 20:01:28.836025+00
f218080a-3e0a-421a-b362-876c2f4e83b0	34bc49a5-24a5-4d9c-899f-941c6872b53b	5555555555	\N	t	2023-07-17 20:01:28.836025+00	2023-07-17 20:01:28.836025+00
6909d606-ecce-4184-9ec1-921a28d5d428	34bc49a5-24a5-4d9c-899f-941c6872b53b	097452379	\N	t	2023-07-19 16:16:44.805498+00	2023-07-19 16:16:44.805498+00
8030ae99-c0a8-44ad-84db-b146754a2f22	34bc49a5-24a5-4d9c-899f-941c6872b53b	991232425	\N	t	2023-07-19 16:26:02.318251+00	2023-07-19 16:26:02.318251+00
5aef113a-b61b-4cc0-be0e-71f3ab7c7447	34bc49a5-24a5-4d9c-899f-941c6872b53b	0943204805	$2b$10$PacIrs8/16e4Lk8M9wxpnuOj89DiiuT6XXsrVCNCTqKGcXs3W8RBW	t	2023-07-19 16:32:47.477181+00	2023-07-19 16:32:47.694218+00
29253a31-503d-4bfb-baaf-262fd7c446b4	34bc49a5-24a5-4d9c-899f-941c6872b53b	0974523792	$2b$10$4JFx0IrJFBiOzabBQMSyEOVv5qskE5DA5sOZsC4KxAXvrN4i7outS	t	2023-07-19 16:34:11.571992+00	2023-07-19 16:34:11.779526+00
58048707-0d30-47cc-8eae-031334c4d55a	f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	09876543	$2b$10$mp/Hb8ajlQG/MDO28.vGguwfUesliNOe5ZcGvO.vtM/Z2d6hdA2.W	t	2023-07-19 16:41:16.246476+00	2023-07-19 16:41:16.456918+00
66785577-c019-442e-9acb-bc3ed8399c81	f12a37f1-c262-47b9-8873-204a3db263be	0921212121	$2b$10$ODNDS5hNyr5ELYDap3Jk9.UP1nvc1ZUr/nHyfCBAeERLiTxgbiWgu	t	2023-07-19 16:42:42.377048+00	2023-07-19 16:42:42.592121+00
46cb0755-2f3f-45fb-8cfa-a1ad3a5e25e8	34bc49a5-24a5-4d9c-899f-941c6872b53b	09328473	$2b$10$olRksmyt/WiIoG6oiS48tOgU0Y/s1IDG7ip.yd8s510CeJ3qJ1BaS	t	2023-07-19 20:42:12.6645+00	2023-07-19 20:42:12.697202+00
46206dda-70dd-43a9-accb-54d7bd700f52	34bc49a5-24a5-4d9c-899f-941c6872b53b	+251922273088	$2b$10$cebsMRm.63CxGhEXUMvFleRMJJow7tMNxRWCVWHxVnHJB4bGhV3zm	t	2023-07-21 03:18:11.55782+00	2023-07-21 03:18:11.569372+00
9b1606f6-0af1-4430-9828-e096a29b0deb	34bc49a5-24a5-4d9c-899f-941c6872b53b	0921951u521	$2b$10$.dRnCmrXXbug77f5q8meGOzi12UgF7p7N7uKxJIsFc5W6.WJ/N7yS	t	2023-07-21 03:30:41.923194+00	2023-07-21 03:30:41.934334+00
9fe0df95-e66d-46b6-a7d6-cd30efdee74f	34bc49a5-24a5-4d9c-899f-941c6872b53b	0922222730	\N	t	2023-07-23 12:59:55.037433+00	2023-07-23 12:59:55.037433+00
fdb4ad59-7f58-485d-b273-f7c95cf31ddc	34bc49a5-24a5-4d9c-899f-941c6872b53b	0911223344	\N	t	2023-07-23 18:26:28.98491+00	2023-07-23 18:26:28.98491+00
91991ae1-3364-4389-b2af-f5c5363395c9	34bc49a5-24a5-4d9c-899f-941c6872b53b	0937483927	$2a$10$ZlKUDH7NZf04V57WV93P5elgQus9OYzQFVQohFCJbMfn/sHVjib1W	t	2023-06-25 16:40:53.934817+00	2023-07-23 18:28:15.667741+00
efe62d1b-423b-4def-9051-0f92e5d0f930	34bc49a5-24a5-4d9c-899f-941c6872b53b	0921050611	$2b$10$fznb.lzdjGXNnT5U0l1nv.xyZAcz/0lguBP9DDoT.WYnxcBZAS.vq	t	2023-07-23 18:30:42.299591+00	2023-07-23 18:30:42.308139+00
48031d57-3f90-4086-87f3-ce7c3f1552b2	34bc49a5-24a5-4d9c-899f-941c6872b53b	0921974989	\N	t	2023-07-26 20:36:07.53603+00	2023-07-26 20:36:07.53603+00
2f10d26f-7039-42de-a6df-69fc781d520e	34bc49a5-24a5-4d9c-899f-941c6872b53b	0943843295	$2b$10$nUiHSLs4dznfDOxMJIeoI.NuOEPkaDED0nlOdeSRQ5uBmBuGL.wze	t	2023-07-26 21:40:15.181766+00	2023-07-26 21:40:15.209292+00
2e478847-f05d-4e42-8b81-0f4505374318	34bc49a5-24a5-4d9c-899f-941c6872b53b	0921030539	\N	t	2023-07-27 20:41:56.077427+00	2023-07-27 20:41:56.077427+00
eb215237-ea1f-433e-8e46-a20866234d83	34bc49a5-24a5-4d9c-899f-941c6872b53b	0943948392	\N	t	2023-07-27 20:42:47.495355+00	2023-07-27 20:42:47.495355+00
\.


--
-- Data for Name: business_categories; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.business_categories (business_category_id, business_category_name, created_at, updated_at) FROM stdin;
0e323e1b-5a94-4b44-b2e7-80d122ae95c3	Retail	2023-06-25 14:25:50.763785+00	2023-06-25 14:25:50.763785+00
0e323e1b-5a94-4b44-b2e7-80d122ae95c4	Food	2023-06-25 14:27:08.528263+00	2023-06-25 14:27:08.528263+00
0e323e1b-5a94-4b44-b2e7-80d122ae95c5	Services	2023-06-25 14:27:17.862593+00	2023-06-25 14:27:17.862593+00
0e323e1b-5a94-4b44-b2e7-80d122ae95c6	Entertainment	2023-06-25 14:27:26.749033+00	2023-06-25 14:27:26.749033+00
0e323e1b-5a94-4b44-b2e7-80d122ae95c8	Health	2023-06-25 14:27:37.227114+00	2023-06-25 14:27:37.227114+00
0e323e1b-5a94-4b44-b2e7-80d122ae95c9	Other	2023-06-25 14:27:42.295784+00	2023-06-25 14:27:42.295784+00
0e323e1b-5a94-4b44-b2e7-80d122ae95c7	Online Platform	2023-06-25 14:27:31.935909+00	2023-06-25 16:07:51.519757+00
\.


--
-- Data for Name: business_reviews; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.business_reviews (business_review_id, customer_id, business_id, business_review, business_rate, created_at, updated_at) FROM stdin;
23834179-1ba3-43db-99d5-b48ac9f02370	0e623e1b-5a94-4b44-b2e7-89d122ae95c3	b5f9d84c-5148-4780-b052-ab99be36261c	this buisness is good and I like it 	5	2023-06-25 17:15:02.970951+00	2023-06-25 17:15:02.970951+00
97aba53a-2b64-47c8-a9b2-ddbb07dc05be	0e623e1b-5a94-4b44-b2e7-89d122ae95c3	b5f9d84c-5148-4780-b052-ab99be36261c	I don't like this product at all	4.5	2023-06-25 17:15:23.563153+00	2023-06-25 17:15:23.563153+00
a90ce63a-bc57-4678-82b6-bb0797bc65d7	54268d44-804d-4862-bc63-8af69ea560ab	4fcb60a7-5714-4932-bb04-205609aab822	come on and be loyal to this buisness	5	2023-06-25 17:16:20.282742+00	2023-06-25 17:16:20.282742+00
154a50a3-f2da-4147-84cf-b52d036ac80b	54268d44-804d-4862-bc63-8af69ea560ab	4fcb60a7-5714-4932-bb04-205609aab822	come on and be loyal to this buisness	5	2023-06-25 17:16:20.684916+00	2023-06-25 17:16:20.684916+00
6a76039e-46fb-4a49-9daa-32d31a607c5f	54268d44-804d-4862-bc63-8af69ea560ab	4fcb60a7-5714-4932-bb04-205609aab822	I love this product very much	5	2023-06-25 17:16:35.400322+00	2023-06-25 17:16:35.400322+00
\.


--
-- Data for Name: businesses; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.businesses (business_id, business_category_id, vendor_id, business_phone_no, business_email, address_id, country_code, about, is_verified, status, bussiness_name) FROM stdin;
b5f9d84c-5148-4780-b052-ab99be36261c	0e323e1b-5a94-4b44-b2e7-80d122ae95c7	0e623e1b-5a94-4b44-b2e7-89d122ae85c3	+254-202519601	moderkitchen@gmail.com	9a1637c6-9dcd-4cfb-b3c3-7e489fc21bb8	KE	Hi! Is the Black & Decker Blender available at the moment?	t	t	Modern Kitchen
4fcb60a7-5714-4932-bb04-205609aab822	0e323e1b-5a94-4b44-b2e7-80d122ae95c7	0e623e1b-5a94-4b44-b2e7-89d122ae85c3	+254-202519604	zonner@gmail.com	9a1637c6-9dcd-4cfb-b3c3-7e489fc21bb8	KE	Zonner Platform	t	t	Zonner
\.


--
-- Data for Name: businesses_favorites; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.businesses_favorites (business_favorite_id, business_id, customer_id, updated_at) FROM stdin;
\.


--
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.chats (chat_id, bussiness_id, customer_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: counties; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.counties (county_id, county_name) FROM stdin;
0e623e1b-5a94-4b44-b2e8-80d122ae95c3	Manhattan
b04dba0c-fd9c-4257-8680-18c93ecec36f	kenyan-border
1a9b7706-306a-475c-9318-d10054368f79	centeral kenya
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.customers (customer_id, full_name, email, phone_no, status, created_at, updated_at, profile_image) FROM stdin;
0e623e1b-5a94-4b44-b2e7-89d122ae95c3	Doe	jdoe@example.com	123-456-7890	t	2023-06-25 15:25:19.810973+00	2023-06-25 15:25:19.810973+00	https://img.freepik.com/free-icon/user_318-563642.jpg
54268d44-804d-4862-bc63-8af69ea560ab	Nuge	betty@gmail.com	0937483920	t	2023-06-25 16:40:26.224116+00	2023-06-26 17:48:32.29371+00	https://img.freepik.com/free-icon/user_318-563642.jpg
577eca63-2e83-4ee5-81e8-f7cba0cdee23	Beyene	hiwi@gmail.com	0937483926	t	2023-06-25 16:41:24.293609+00	2023-06-26 17:49:16.875541+00	https://img.freepik.com/free-icon/user_318-563642.jpg
04142094-8182-449e-a564-6a7cf5d4fd11	Molla	mollaaderaw@gmail.com	0962247109	t	2023-07-05 07:43:45.418068+00	2023-07-05 07:43:45.418068+00	https://img.freepik.com/free-icon/user_318-563642.jpg
c017a9b3-046c-4a36-915a-a5dd165a0acd	Aderaw Molla	exmpleemail@gmail.com	0922050699	t	2023-07-15 18:01:28.37462+00	2023-07-15 18:01:28.37462+00	https://img.freepik.com/free-icon/user_318-563642.jpg
5781fb7a-af04-4988-8f5f-c083d62d3eaf	Debebe Debe	doctoremail@gmail.com	092224992315	t	2023-07-17 19:33:35.927945+00	2023-07-17 19:33:35.927945+00	https://img.freepik.com/free-icon/user_318-563642.jpg
e9a5706d-927b-4e57-a3f0-68fcf9e4a041	Customer 1	customer1@example.com	1234567890	t	2023-07-17 00:00:00+00	2023-07-17 20:01:28.836025+00	https://img.freepik.com/free-icon/user_318-563642.jpg
c53b4415-5bc5-4755-9e94-52e2c0e001c7	Customer 2	customer2@example.com	9876543210	t	2023-07-17 00:00:00+00	2023-07-17 20:01:28.836025+00	https://img.freepik.com/free-icon/user_318-563642.jpg
f218080a-3e0a-421a-b362-876c2f4e83b0	Customer 3	customer3@example.com	5555555555	t	2023-07-17 00:00:00+00	2023-07-17 20:01:28.836025+00	https://img.freepik.com/free-icon/user_318-563642.jpg
6909d606-ecce-4184-9ec1-921a28d5d428	Dr Amare	dramare@gmail.com	097452379	t	2023-07-19 16:16:44.805498+00	2023-07-19 16:16:44.805498+00	https://img.freepik.com/free-icon/user_318-563642.jpg
8030ae99-c0a8-44ad-84db-b146754a2f22	John Doe	newEmail@gmail.com	991232425	t	2023-07-19 16:26:02.318251+00	2023-07-19 16:26:02.318251+00	https://img.freepik.com/free-icon/user_318-563642.jpg
5aef113a-b61b-4cc0-be0e-71f3ab7c7447	Selihom Tech	newEmail1@gmail.com	0943204805	t	2023-07-19 16:32:47.477181+00	2023-07-19 16:32:47.477181+00	https://img.freepik.com/free-icon/user_318-563642.jpg
29253a31-503d-4bfb-baaf-262fd7c446b4	Dr Amare	dramarhe@gmail.com	0974523792	t	2023-07-19 16:34:11.571992+00	2023-07-19 16:34:11.571992+00	https://img.freepik.com/free-icon/user_318-563642.jpg
46cb0755-2f3f-45fb-8cfa-a1ad3a5e25e8	Abebe Balcha	molla@gmail.com	09328473	t	2023-07-19 20:42:12.6645+00	2023-07-19 20:42:12.6645+00	https://img.freepik.com/free-icon/user_318-563642.jpg
00e4dbc6-6061-4ac3-b53b-843016c752b9	Selihom Tech	testemail@gmail.com	0943204801	t	2023-07-19 21:00:12.599106+00	2023-07-19 21:00:12.599106+00	https://img.freepik.com/free-icon/user_318-563642.jpg
2b02566a-157a-44d2-bc34-ebc4617719fa	Aderaw Molla	molladderaw@gmail.com	22273088	t	2023-07-21 02:35:22.464186+00	2023-07-21 02:35:22.464186+00	https://img.freepik.com/free-icon/user_318-563642.jpg
46206dda-70dd-43a9-accb-54d7bd700f52	Kasahun Molla	kasahunmolla804@gmail.com	+251922273088	t	2023-07-21 03:18:11.55782+00	2023-07-21 03:18:11.55782+00	https://img.freepik.com/free-icon/user_318-563642.jpg
9b1606f6-0af1-4430-9828-e096a29b0deb	new full name	mollaadera@gmail.com	0921951u521	t	2023-07-21 03:30:41.923194+00	2023-07-21 03:30:41.923194+00	https://img.freepik.com/free-icon/user_318-563642.jpg
9fe0df95-e66d-46b6-a7d6-cd30efdee74f	new Full Name	new@gmail.com	0922222730	t	2023-07-23 12:59:55.037433+00	2023-07-23 12:59:55.037433+00	https://img.freepik.com/free-icon/user_318-563642.jpg
fdb4ad59-7f58-485d-b273-f7c95cf31ddc	selihom Tech	selihom@gmail.com	0911223344	t	2023-07-23 18:26:28.98491+00	2023-07-23 18:26:28.98491+00	https://img.freepik.com/free-icon/user_318-563642.jpg
91991ae1-3364-4389-b2af-f5c5363395c9	Haile Selihom	haile@gnial.com	0937483927	f	2023-06-25 16:40:53.934817+00	2023-07-23 18:28:15.667741+00	https://img.freepik.com/free-icon/user_318-563642.jpg
efe62d1b-423b-4def-9051-0f92e5d0f930	Aderaw Molla	mynewemail@gmail.com	0921050611	t	2023-07-23 18:30:42.299591+00	2023-07-23 18:30:42.299591+00	https://img.freepik.com/free-icon/user_318-563642.jpg
48031d57-3f90-4086-87f3-ce7c3f1552b2	Betty Nuge	bettynuge@gmail.com	0921974989	t	2023-07-26 20:36:07.53603+00	2023-07-26 20:36:07.53603+00	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLVhjfCzHsgKfkm1YjZA-bpCgbz9fX-2ND6wkuZYONvA&s
2f10d26f-7039-42de-a6df-69fc781d520e	my full  Name	newEmails@gmail.com	0943843295	t	2023-07-26 21:40:15.181766+00	2023-07-26 21:40:15.181766+00	https://img.freepik.com/free-icon/user_318-563642.jpg
2e478847-f05d-4e42-8b81-0f4505374318	Samuel Ketema	lijsamuel@gmail.com	0921030539	f	2023-07-27 20:41:56.077427+00	2023-07-27 20:41:56.077427+00	https://img.freepik.com/free-icon/user_318-563642.jpg
eb215237-ea1f-433e-8e46-a20866234d83	Miki Manager	miki@gmail.com	0943948392	f	2023-07-27 20:42:47.495355+00	2023-07-27 20:42:47.495355+00	https://img.freepik.com/free-icon/user_318-563642.jpg
\.


--
-- Data for Name: delivery_requests; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.delivery_requests (delivery_request_id, rider_id, order_id, pickup_point, drop_off_point) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.messages (message_id, chat_id, sender_id, reciever_id, message, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.order_items (order_item_id, product_id, quantity, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.orders (order_id, customer_id, created_at, updated_at, business_id, order_status) FROM stdin;
4e6b8180-e5ef-4de2-a4f5-a65c32ff14b2	efe62d1b-423b-4def-9051-0f92e5d0f930	2023-07-26 21:44:40.981598+00	2023-07-27 20:26:13.758144+00	b5f9d84c-5148-4780-b052-ab99be36261c	dispatched
884300a3-ce4c-49cf-8a71-e05d7fb8dffc	efe62d1b-423b-4def-9051-0f92e5d0f930	2023-07-26 21:44:46.137612+00	2023-07-27 20:26:13.758144+00	b5f9d84c-5148-4780-b052-ab99be36261c	dispatched
450c73f7-0717-4a9d-8e52-cd344ac3fb30	efe62d1b-423b-4def-9051-0f92e5d0f930	2023-07-26 21:45:06.610759+00	2023-07-27 20:26:13.758144+00	4fcb60a7-5714-4932-bb04-205609aab822	dispatched
6a5d5c64-e69d-4f45-83cf-e78d9994d41e	2f10d26f-7039-42de-a6df-69fc781d520e	2023-07-27 20:22:26.145586+00	2023-07-27 20:35:42.913905+00	4fcb60a7-5714-4932-bb04-205609aab822	cancelled
538a46b5-8680-4f76-b9d8-38ad22bcaf77	efe62d1b-423b-4def-9051-0f92e5d0f930	2023-07-26 21:44:35.520588+00	2023-07-27 20:35:55.338702+00	b5f9d84c-5148-4780-b052-ab99be36261c	cancelled
bfb268d8-2d20-4a0f-b1a1-7e8613c94b13	48031d57-3f90-4086-87f3-ce7c3f1552b2	2023-07-26 21:45:31.850376+00	2023-07-27 20:39:11.555102+00	4fcb60a7-5714-4932-bb04-205609aab822	delivered
efe62d1b-423b-4def-9051-0f92e5d0f931	efe62d1b-423b-4def-9051-0f92e5d0f930	2023-07-26 21:38:21.246895+00	2023-07-27 20:39:32.48318+00	b5f9d84c-5148-4780-b052-ab99be36261c	delivered
2ccc9fc8-4fc5-41d7-88cf-2f04cf8af074	eb215237-ea1f-433e-8e46-a20866234d83	2023-07-27 20:47:19.915492+00	2023-07-27 20:47:19.915492+00	b5f9d84c-5148-4780-b052-ab99be36261c	inprogress
3c2bc4b9-0a9e-4fbd-8a4b-17b5f47259c5	2e478847-f05d-4e42-8b81-0f4505374318	2023-07-27 20:47:54.37283+00	2023-07-27 20:47:54.37283+00	b5f9d84c-5148-4780-b052-ab99be36261c	inprogress
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.product_categories (product_category_id, businesses_category_id, product_category_name, created_at, updated_at) FROM stdin;
de46c6af-4e89-44ad-bbbf-bfc15b8b0516	0e323e1b-5a94-4b44-b2e7-80d122ae95c7	Closes and Fashions	2023-06-25 16:02:10.881606+00	2023-06-25 16:02:10.881606+00
\.


--
-- Data for Name: product_reviews; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.product_reviews (product_review_id, customer_id, product_id, product_review, product_rate, created_at, updated_at) FROM stdin;
94128653-59ba-4be7-ab18-242fe5a37252	0e623e1b-5a94-4b44-b2e7-89d122ae95c3	7677f223-0081-4ace-8454-2bda3285ed33	this is good product	4.5	2023-06-25 16:39:42.016836+00	2023-06-25 16:39:42.016836+00
54268d44-804c-4862-bc63-8af69ea560ab	54268d44-804d-4862-bc63-8af69ea560ab	b4cd9006-8609-41d8-9760-0f38e17998e6	I like this product very much	4	2023-06-25 16:46:18.777315+00	2023-06-25 16:46:18.777315+00
54268d44-804c-4862-ba63-8af69ea560ab	54268d44-804d-4862-bc63-8af69ea560ab	b4cd9006-8609-41d8-9760-0f38e17998e6	I like this product very much	4	2023-06-25 16:46:26.0291+00	2023-06-25 16:46:26.0291+00
54268d44-804c-4862-ba63-8ff69ea560ab	54268d44-804d-4862-bc63-8af69ea560ab	b4cd9006-8609-41d8-9760-0f38e17998e6	I don't like this product,it is awful	5	2023-06-25 16:46:57.727085+00	2023-06-25 16:46:57.727085+00
54268d44-804c-4862-ba63-8fd69ea560ab	54268d44-804d-4862-bc63-8af69ea560ab	b3d6f99d-7d27-4f35-b7a1-62efb183abc1	very nice from as I review	5	2023-06-25 16:48:00.073471+00	2023-06-25 16:48:00.073471+00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.products (product_id, businesses_id, product_category_id, product_name, product_description, product_price, product_discount_price, quantity_in_stock, created_at, updated_at) FROM stdin;
94128653-59ba-4be8-ab18-242fe5a37252	4fcb60a7-5714-4932-bb04-205609aab822	de46c6af-4e89-44ad-bbbf-bfc15b8b0516	Sport Closes	Best close	300	250	4	2023-06-25 16:03:41.345336+00	2023-06-25 16:03:41.345336+00
7677f223-0081-4ace-8454-2bda3285ed33	4fcb60a7-5714-4932-bb04-205609aab822	de46c6af-4e89-44ad-bbbf-bfc15b8b0516	Sport Closes	Best close	300	250	4	2023-06-25 16:03:49.295679+00	2023-06-25 16:03:49.295679+00
b4cd9006-8609-41d8-9760-0f38e17998e6	4fcb60a7-5714-4932-bb04-205609aab822	de46c6af-4e89-44ad-bbbf-bfc15b8b0516	Sport Closes	Best close	300	250	4	2023-06-25 16:03:50.803079+00	2023-06-25 16:03:50.803079+00
b3d6f99d-7d27-4f35-b7a1-62efb183abc1	4fcb60a7-5714-4932-bb04-205609aab822	de46c6af-4e89-44ad-bbbf-bfc15b8b0516	Sport Closes	Best close	300	250	4	2023-06-25 16:03:51.00351+00	2023-06-25 16:03:51.00351+00
\.


--
-- Data for Name: riders; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.riders (rider_id, full_name, email, phone_no, is_verified, created_at, updated_at) FROM stdin;
a1f6250d-bd25-4557-aef5-69e6b05f7e60	Ketema	lijsamuel@gmail.com	0921050699	t	2023-06-25 16:02:28.225931+00	2023-06-25 16:02:28.225931+00
277aebc9-12b0-4426-b034-6dd74d63e533	Taye	john@gmail.com	0949324392	t	2023-06-25 16:03:46.546356+00	2023-06-25 16:03:46.546356+00
d2c91f27-d8b2-4cc3-b413-84e5c11ac1ab	Minilik	rider@gmail.com	091234567	f	2023-06-25 20:56:34.171801+00	2023-06-25 20:56:34.171801+00
395c0548-04ff-4584-adf7-00164d37c51a	Minilik	r2eider@gmail.com	09123e45678	f	2023-06-25 20:58:20.655996+00	2023-06-25 20:58:20.655996+00
20f3832e-c3a8-479b-8f75-1a1af973cb5d	Minilik	r2eidier@gmail.com	0j9123e45678	f	2023-06-25 21:11:48.769104+00	2023-06-25 21:11:48.769104+00
a3594264-5c1e-440b-ad3b-cda9859ff66b	Minilik	r2eidier@ddgmail.com	0j91d23e45678	f	2023-06-25 21:12:57.285664+00	2023-06-25 21:12:57.285664+00
5ccc6534-f5b0-43ff-8a88-47d4b69add38	Kibebe	betekibebe@gmail.com	0116812019	f	2023-06-29 17:32:55.515403+00	2023-06-29 17:32:55.515403+00
0c49add2-b51b-4745-8fd6-d448dac137d0	jnwdpi	huuh	0912345678	f	2023-06-29 18:32:15.386736+00	2023-06-29 18:32:15.386736+00
58048707-0d30-47cc-8eae-031334c4d55a	asdfifhisau jasfbufios	ASEFGHJ@RIDER.COM	09876543	f	2023-07-19 16:41:16.246476+00	2023-07-19 16:41:16.246476+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.roles (role_id, role_name, created_at, updated_at) FROM stdin;
34bc49a5-24a5-4d9c-899f-941c6872b53b	customer	2023-06-22 16:03:23.925871+00	2023-06-25 17:50:33.595917+00
3f030a2f-abd6-4910-9c56-ed10b8cf7351	zadmin	2023-06-22 16:04:20.581692+00	2023-06-25 17:50:47.302512+00
f12a37f1-c262-47b9-8873-204a3db263be	vendor	2023-06-22 16:03:35.511428+00	2023-06-25 17:51:30.760856+00
f2cc7a02-72a0-49de-a922-7c54f8bf4aa1	rider	2023-06-24 11:00:02.828718+00	2023-06-25 17:51:53.421285+00
\.


--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.statuses (status_id, business_id, start_time, end_time, status_caption, created_at) FROM stdin;
\.


--
-- Data for Name: variant_categories; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.variant_categories (variant_category_id, product_id, variant_category_name) FROM stdin;
\.


--
-- Data for Name: variants; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.variants (variant_id, variant_category_id, variant_name, variant_price, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.vehicles (vehicle_id, rider_id, vehicle_type, vehicle_make, vehicle_plate_no, year_of_manufacture) FROM stdin;
\.


--
-- Data for Name: vendors; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.vendors (vendor_id, full_name, email, phone_no, status, created_at, updated_at) FROM stdin;
0e623e1b-5a94-4b44-b2e7-89d122ae85c3	Smith	jsmith@example.com	123-456-7890	t	2023-06-25 14:19:36.800475+00	2023-06-25 14:19:36.800475+00
c8843d2a-f5c7-49c3-8f53-71ca9b031f7b	Johnmalik	williumjohn@gmail.com	0939304930	t	2023-06-25 15:51:32.239644+00	2023-06-25 15:51:32.239644+00
3258463a-1a98-4d37-87bf-48de41c4c781	thairu	fredthairu@gmail.com	0930295302	t	2023-06-25 15:52:26.322694+00	2023-06-25 15:52:26.322694+00
77be860b-a500-45f6-8681-0bde547f217d	Kebede	miki@gmail.com	0948394239	f	2023-06-25 15:54:04.513893+00	2023-06-25 15:54:04.513893+00
66785577-c019-442e-9acb-bc3ed8399c81	aDERAW mOLA	kjhFKHUIK@BUSSINESS.COM	0921212121	f	2023-07-19 16:42:42.377048+00	2023-07-19 16:42:42.377048+00
\.


--
-- Data for Name: wards; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.wards (ward_id, county_id, ward_name) FROM stdin;
0e623e1b-5a94-4b44-b2e7-89d122ae95c6	0e623e1b-5a94-4b44-b2e8-80d122ae95c3	Midtown
2d23afcd-1a43-4856-b18f-b083aeba8f0e	0e623e1b-5a94-4b44-b2e8-80d122ae95c3	ward-5
93e2dd23-8835-4439-8790-cc1149807f54	0e623e1b-5a94-4b44-b2e8-80d122ae95c3	ward-5
620d94e8-d7a6-44af-8eef-4d66cec96c9c	0e623e1b-5a94-4b44-b2e8-80d122ae95c3	ward-6
d32e5999-784b-4076-a131-b1f1f742e946	0e623e1b-5a94-4b44-b2e8-80d122ae95c3	ward-8
e55eccd8-1114-4b4f-ab0c-7645241843fa	b04dba0c-fd9c-4257-8680-18c93ecec36f	ward-10
52a01ced-6c91-4905-8aeb-29d4b3bafb04	b04dba0c-fd9c-4257-8680-18c93ecec36f	ward-11
\.


--
-- Data for Name: wish_lists; Type: TABLE DATA; Schema: public; Owner: sister
--

COPY public.wish_lists (wish_list_id, product_id, customer_id, created_at, updated_at) FROM stdin;
\.


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: migration_settings migration_settings_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.migration_settings
    ADD CONSTRAINT migration_settings_pkey PRIMARY KEY (setting);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (adress_id);


--
-- Name: authentications authentications_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_phone_no_key UNIQUE (phone_no);


--
-- Name: authentications authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (user_id);


--
-- Name: business_reviews business_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.business_reviews
    ADD CONSTRAINT business_reviews_pkey PRIMARY KEY (business_review_id);


--
-- Name: businesses businesses_businesses_email_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_email_key UNIQUE (business_email);


--
-- Name: businesses businesses_businesses_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_phone_no_key UNIQUE (business_phone_no);


--
-- Name: business_categories businesses_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.business_categories
    ADD CONSTRAINT businesses_categories_pkey PRIMARY KEY (business_category_id);


--
-- Name: businesses_favorites businesses_fovorites_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses_favorites
    ADD CONSTRAINT businesses_fovorites_pkey PRIMARY KEY (business_favorite_id);


--
-- Name: businesses businesses_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (business_id);


--
-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (chat_id);


--
-- Name: counties counties_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.counties
    ADD CONSTRAINT counties_pkey PRIMARY KEY (county_id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_no_key UNIQUE (phone_no);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: delivery_requests delivery_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.delivery_requests
    ADD CONSTRAINT delivery_requests_pkey PRIMARY KEY (delivery_request_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (product_category_id);


--
-- Name: product_reviews product_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_pkey PRIMARY KEY (product_review_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: riders riders_email_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_email_key UNIQUE (email);


--
-- Name: riders riders_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_phone_no_key UNIQUE (phone_no);


--
-- Name: riders riders_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_pkey PRIMARY KEY (rider_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: statuses statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (status_id);


--
-- Name: variant_categories variant_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.variant_categories
    ADD CONSTRAINT variant_categories_pkey PRIMARY KEY (variant_category_id);


--
-- Name: variants variants_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_pkey PRIMARY KEY (variant_id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vendors vendors_email_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_email_key UNIQUE (email);


--
-- Name: vendors vendors_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_phone_no_key UNIQUE (phone_no);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (vendor_id);


--
-- Name: wards wards_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.wards
    ADD CONSTRAINT wards_pkey PRIMARY KEY (ward_id);


--
-- Name: wish_lists wish_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_pkey PRIMARY KEY (wish_list_id);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: sister
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: sister
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: sister
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: sister
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: sister
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: addresses set_public_addresses_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_addresses_updated_at BEFORE UPDATE ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_addresses_updated_at ON addresses; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_addresses_updated_at ON public.addresses IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: authentications set_public_authentications_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_authentications_updated_at BEFORE UPDATE ON public.authentications FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_authentications_updated_at ON authentications; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_authentications_updated_at ON public.authentications IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: business_reviews set_public_business_reviews_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_business_reviews_updated_at BEFORE UPDATE ON public.business_reviews FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_business_reviews_updated_at ON business_reviews; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_business_reviews_updated_at ON public.business_reviews IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: business_categories set_public_businesses_categories_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_businesses_categories_updated_at BEFORE UPDATE ON public.business_categories FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_businesses_categories_updated_at ON business_categories; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_businesses_categories_updated_at ON public.business_categories IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: businesses_favorites set_public_businesses_favorites_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_businesses_favorites_updated_at BEFORE UPDATE ON public.businesses_favorites FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_businesses_favorites_updated_at ON businesses_favorites; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_businesses_favorites_updated_at ON public.businesses_favorites IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: chats set_public_chats_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_chats_updated_at BEFORE UPDATE ON public.chats FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_chats_updated_at ON chats; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_chats_updated_at ON public.chats IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: customers set_public_customers_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_customers_updated_at ON customers; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_customers_updated_at ON public.customers IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: messages set_public_messages_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_messages_updated_at BEFORE UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_messages_updated_at ON messages; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_messages_updated_at ON public.messages IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: order_items set_public_order_items_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_order_items_updated_at BEFORE UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_order_items_updated_at ON order_items; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_order_items_updated_at ON public.order_items IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: orders set_public_orders_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_orders_updated_at ON orders; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_orders_updated_at ON public.orders IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: product_categories set_public_product_categories_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_product_categories_updated_at BEFORE UPDATE ON public.product_categories FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_product_categories_updated_at ON product_categories; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_product_categories_updated_at ON public.product_categories IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: product_reviews set_public_product_reviews_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_product_reviews_updated_at BEFORE UPDATE ON public.product_reviews FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_product_reviews_updated_at ON product_reviews; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_product_reviews_updated_at ON public.product_reviews IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: products set_public_products_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_products_updated_at ON products; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_products_updated_at ON public.products IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: riders set_public_riders_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_riders_updated_at BEFORE UPDATE ON public.riders FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_riders_updated_at ON riders; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_riders_updated_at ON public.riders IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: roles set_public_roles_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_roles_updated_at ON roles; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_roles_updated_at ON public.roles IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: variants set_public_variants_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_variants_updated_at BEFORE UPDATE ON public.variants FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_variants_updated_at ON variants; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_variants_updated_at ON public.variants IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: vendors set_public_vendors_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_vendors_updated_at BEFORE UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_vendors_updated_at ON vendors; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_vendors_updated_at ON public.vendors IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: wish_lists set_public_wish_lists_updated_at; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER set_public_wish_lists_updated_at BEFORE UPDATE ON public.wish_lists FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_wish_lists_updated_at ON wish_lists; Type: COMMENT; Schema: public; Owner: sister
--

COMMENT ON TRIGGER set_public_wish_lists_updated_at ON public.wish_lists IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: customers sync_customers; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER sync_customers AFTER INSERT OR DELETE OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();


--
-- Name: riders sync_riders; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER sync_riders AFTER INSERT OR DELETE OR UPDATE ON public.riders FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();


--
-- Name: vendors sync_vendors; Type: TRIGGER; Schema: public; Owner: sister
--

CREATE TRIGGER sync_vendors AFTER INSERT OR DELETE OR UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: sister
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: addresses addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.authentications(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: authentications authentications_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: business_reviews business_reviews_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.business_reviews
    ADD CONSTRAINT business_reviews_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_reviews business_reviews_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.business_reviews
    ADD CONSTRAINT business_reviews_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: businesses businesses_businesses_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_category_id_fkey FOREIGN KEY (business_category_id) REFERENCES public.business_categories(business_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: businesses_favorites businesses_favorites_businesses_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses_favorites
    ADD CONSTRAINT businesses_favorites_businesses_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: businesses_favorites businesses_favorites_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses_favorites
    ADD CONSTRAINT businesses_favorites_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: businesses businesses_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(vendor_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: chats chats_bussiness_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_bussiness_id_fkey FOREIGN KEY (bussiness_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: chats chats_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: messages messages_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(chat_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: orders orders_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: product_categories product_categories_businesses_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_businesses_category_id_fkey FOREIGN KEY (businesses_category_id) REFERENCES public.business_categories(business_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: product_reviews product_reviews_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: product_reviews product_reviews_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: products products_businesses_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_businesses_id_fkey FOREIGN KEY (businesses_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: products products_product_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_product_category_id_fkey FOREIGN KEY (product_category_id) REFERENCES public.product_categories(product_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: statuses statuses_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT statuses_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: variant_categories variant_categories_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.variant_categories
    ADD CONSTRAINT variant_categories_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: variants variants_variant_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_variant_category_id_fkey FOREIGN KEY (variant_category_id) REFERENCES public.variant_categories(variant_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wards wards_county_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.wards
    ADD CONSTRAINT wards_county_id_fkey FOREIGN KEY (county_id) REFERENCES public.counties(county_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wish_lists wish_lists_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wish_lists wish_lists_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sister
--

ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

