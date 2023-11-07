CREATE TABLE public.addresses (
    adress_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    address_line_one text NOT NULL,
    address_line_two text NOT NULL,
    city text NOT NULL,
    country_code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.authentications (
    user_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    role_id uuid NOT NULL,
    phone_no text NOT NULL,
    password text,
    status boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.business_categories (
    business_category_id uuid NOT NULL,
    business_category_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.business_reviews (
    business_review_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    business_id uuid NOT NULL,
    business_review text NOT NULL,
    business_rate real DEFAULT '0'::real NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
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
    status boolean NOT NULL
);
CREATE TABLE public.businesses_favorites (
    business_favorite_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    business_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.chats (
    chat_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bussiness_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.customers (
    customer_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    phone_no text NOT NULL,
    status boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.delivery_requests (
    delivery_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_id uuid,
    order_id uuid,
    pickup_point uuid,
    drop_off_point uuid
);
CREATE TABLE public.jnjn (
    kmaskl integer NOT NULL
);
CREATE SEQUENCE public.jnjn_kmaskl_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.jnjn_kmaskl_seq OWNED BY public.jnjn.kmaskl;
CREATE TABLE public.messages (
    message_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    chat_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    reciever_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.new (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nme text
);
CREATE TABLE public.order_items (
    order_item_id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.orders (
    order_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    business_id uuid NOT NULL
);
CREATE TABLE public.product_categories (
    product_category_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    businesses_category_id uuid NOT NULL,
    product_category_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.product_reviews (
    product_review_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    product_id uuid NOT NULL,
    product_review text NOT NULL,
    product_rate real NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
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
CREATE TABLE public.riders (
    rider_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    phone_no text NOT NULL,
    is_verified boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.roles (
    role_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    role_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.statuses (
    status_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    business_id uuid NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    status_caption text,
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.tested (
    id uuid DEFAULT gen_random_uuid() NOT NULL
);
CREATE TABLE public.variant_categories (
    variant_category_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    variant_category_name text NOT NULL
);
CREATE TABLE public.variants (
    variant_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    variant_category_id uuid NOT NULL,
    variant_name text NOT NULL,
    variant_price real NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.vehicles (
    vehicle_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    rider_id uuid NOT NULL,
    vehicle_type text,
    vehicle_make text,
    vehicle_plate_no text,
    year_of_manufacture text
);
CREATE TABLE public.vendors (
    vendor_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    phone_no text NOT NULL,
    status boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.wish_lists (
    wish_list_id uuid NOT NULL,
    product_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
