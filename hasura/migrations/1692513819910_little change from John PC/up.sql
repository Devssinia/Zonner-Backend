SET check_function_bodies = false;
CREATE TYPE public.order_status AS ENUM (
    'dispatched',
    'cancelled',
    'inprogress',
    'delivered'
);
CREATE TABLE public.infos (
    title text NOT NULL,
    description text NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    subtitle text,
    info_address uuid
);
CREATE FUNCTION public.info_dislike_counter(info_row public.infos) RETURNS bigint
    LANGUAGE sql STABLE
    AS $$
  SELECT COUNT(1) FROM likes WHERE info_id = info_row.id AND is_like = false;
$$;
CREATE FUNCTION public.info_like_counter(info_row public.infos) RETURNS bigint
    LANGUAGE sql STABLE
    AS $$
  SELECT COUNT(1) FROM likes WHERE info_id = info_row.id AND is_like = true;
$$;
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
    county_id uuid NOT NULL,
    latitude text,
    longtude text
);
CREATE TABLE public.authentications (
    user_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    role_id uuid NOT NULL,
    phone_no text NOT NULL,
    password text,
    status boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen timestamp with time zone
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
    status boolean NOT NULL,
    bussiness_name text,
    bussiness_profile text DEFAULT 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTygdi26NdE4pjceF7zZsUDZFdBWZtxSUPAYA&usqp=CAU'::text
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
CREATE TABLE public.counties (
    county_id uuid DEFAULT gen_random_uuid() NOT NULL,
    county_name text NOT NULL
);
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
CREATE TABLE public.delivery_requests (
    delivery_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_id uuid,
    order_id uuid,
    pickup_point uuid,
    drop_off_point uuid
);
CREATE TABLE public.info_images (
    info_image_id uuid DEFAULT gen_random_uuid() NOT NULL,
    image_url text NOT NULL,
    info_id uuid NOT NULL
);
CREATE TABLE public.likes (
    like_id uuid DEFAULT gen_random_uuid() NOT NULL,
    info_id uuid NOT NULL,
    user_id uuid NOT NULL,
    is_like boolean DEFAULT true NOT NULL
);
CREATE TABLE public.messages (
    message_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    chat_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    reciever_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE VIEW public.online_users AS
 SELECT authentications.user_id,
    authentications.role_id,
    authentications.last_seen,
    authentications.phone_no
   FROM public.authentications
  WHERE (authentications.last_seen > (now() - '00:30:00'::interval));
CREATE TABLE public.order_items (
    order_item_id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    order_id uuid
);
CREATE TABLE public.orders (
    order_id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    business_id uuid NOT NULL,
    order_status public.order_status DEFAULT 'inprogress'::public.order_status
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
CREATE TABLE public.rider_documents (
    driving_license text DEFAULT 'https://www.shutterstock.com/shutterstock/photos/645891550/display_1500/stock-vector-flat-man-driver-license-plastic-card-template-id-card-vector-illustration-645891550.jpg'::text NOT NULL,
    vehicle_logbook text DEFAULT 'https://www.shutterstock.com/shutterstock/photos/645891550/display_1500/stock-vector-flat-man-driver-license-plastic-card-template-id-card-vector-illustration-645891550.jpg'::text NOT NULL,
    ceritificate_of_good_conduct text DEFAULT 'https://www.shutterstock.com/shutterstock/photos/645891550/display_1500/stock-vector-flat-man-driver-license-plastic-card-template-id-card-vector-illustration-645891550.jpg'::text NOT NULL,
    national_id text DEFAULT 'https://www.shutterstock.com/shutterstock/photos/645891550/display_1500/stock-vector-flat-man-driver-license-plastic-card-template-id-card-vector-illustration-645891550.jpg'::text NOT NULL,
    vehicle_image text DEFAULT 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y2FyfGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60'::text NOT NULL,
    rider_id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_documents_id uuid NOT NULL
);
CREATE TABLE public.riders (
    rider_id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    full_name text NOT NULL,
    email text NOT NULL,
    phone_no text NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    rider_profile text DEFAULT 'https://i.pinimg.com/236x/7a/44/d2/7a44d23d067ac4711ff45ffcec02052b--bollywood-actors-bollywood-fashion.jpg'::text
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
    full_name text NOT NULL,
    email text NOT NULL,
    phone_no text NOT NULL,
    status boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    profile_image text DEFAULT 'https://img.freepik.com/free-photo/focused-asian-marketing-company-office-worker-using-work-computer-analyze-department-management-chart-finance-agency-employee-reviewing-startup-audit-results-while-modern-workspace_482257-40167.jpg?w=740&t=st=1691924462~exp=1691925062~hmac=86dee227d58c63d7bce149327550e8ab27d295564aa47a1d43a762e76ca5bb8d'::text
);
CREATE TABLE public.wards (
    ward_id uuid DEFAULT gen_random_uuid() NOT NULL,
    county_id uuid NOT NULL,
    ward_name text NOT NULL
);
CREATE TABLE public.wish_lists (
    wish_list_id uuid NOT NULL,
    product_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (adress_id);
ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_phone_no_key UNIQUE (phone_no);
ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (user_id);
ALTER TABLE ONLY public.business_reviews
    ADD CONSTRAINT business_reviews_pkey PRIMARY KEY (business_review_id);
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_email_key UNIQUE (business_email);
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_phone_no_key UNIQUE (business_phone_no);
ALTER TABLE ONLY public.business_categories
    ADD CONSTRAINT businesses_categories_pkey PRIMARY KEY (business_category_id);
ALTER TABLE ONLY public.businesses_favorites
    ADD CONSTRAINT businesses_fovorites_pkey PRIMARY KEY (business_favorite_id);
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (business_id);
ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (chat_id);
ALTER TABLE ONLY public.counties
    ADD CONSTRAINT counties_pkey PRIMARY KEY (county_id);
ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);
ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_no_key UNIQUE (phone_no);
ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);
ALTER TABLE ONLY public.delivery_requests
    ADD CONSTRAINT delivery_requests_pkey PRIMARY KEY (delivery_request_id);
ALTER TABLE ONLY public.info_images
    ADD CONSTRAINT info_images_pkey PRIMARY KEY (info_image_id);
ALTER TABLE ONLY public.infos
    ADD CONSTRAINT infos_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (like_id);
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);
ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);
ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (product_category_id);
ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_pkey PRIMARY KEY (product_review_id);
ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);
ALTER TABLE ONLY public.rider_documents
    ADD CONSTRAINT rider_documents_pkey PRIMARY KEY (rider_id);
ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_email_key UNIQUE (email);
ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_phone_no_key UNIQUE (phone_no);
ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_pkey PRIMARY KEY (rider_id);
ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);
ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (status_id);
ALTER TABLE ONLY public.variant_categories
    ADD CONSTRAINT variant_categories_pkey PRIMARY KEY (variant_category_id);
ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_pkey PRIMARY KEY (variant_id);
ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);
ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_email_key UNIQUE (email);
ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_phone_no_key UNIQUE (phone_no);
ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (vendor_id);
ALTER TABLE ONLY public.wards
    ADD CONSTRAINT wards_pkey PRIMARY KEY (ward_id);
ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_pkey PRIMARY KEY (wish_list_id);
CREATE TRIGGER set_public_addresses_updated_at BEFORE UPDATE ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_addresses_updated_at ON public.addresses IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_authentications_updated_at BEFORE UPDATE ON public.authentications FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_authentications_updated_at ON public.authentications IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_business_reviews_updated_at BEFORE UPDATE ON public.business_reviews FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_business_reviews_updated_at ON public.business_reviews IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_businesses_categories_updated_at BEFORE UPDATE ON public.business_categories FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_businesses_categories_updated_at ON public.business_categories IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_businesses_favorites_updated_at BEFORE UPDATE ON public.businesses_favorites FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_businesses_favorites_updated_at ON public.businesses_favorites IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_chats_updated_at BEFORE UPDATE ON public.chats FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_chats_updated_at ON public.chats IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_customers_updated_at ON public.customers IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_messages_updated_at BEFORE UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_messages_updated_at ON public.messages IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_order_items_updated_at BEFORE UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_order_items_updated_at ON public.order_items IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_orders_updated_at ON public.orders IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_product_categories_updated_at BEFORE UPDATE ON public.product_categories FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_product_categories_updated_at ON public.product_categories IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_product_reviews_updated_at BEFORE UPDATE ON public.product_reviews FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_product_reviews_updated_at ON public.product_reviews IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_products_updated_at ON public.products IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_riders_updated_at BEFORE UPDATE ON public.riders FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_riders_updated_at ON public.riders IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_roles_updated_at ON public.roles IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_variants_updated_at BEFORE UPDATE ON public.variants FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_variants_updated_at ON public.variants IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_vendors_updated_at BEFORE UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_vendors_updated_at ON public.vendors IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_wish_lists_updated_at BEFORE UPDATE ON public.wish_lists FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_wish_lists_updated_at ON public.wish_lists IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER sync_customers AFTER INSERT OR DELETE OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
CREATE TRIGGER sync_riders AFTER INSERT OR DELETE OR UPDATE ON public.riders FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
CREATE TRIGGER sync_vendors AFTER INSERT OR DELETE OR UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.authentications(user_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.business_reviews
    ADD CONSTRAINT business_reviews_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.business_reviews
    ADD CONSTRAINT business_reviews_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.addresses(adress_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_category_id_fkey FOREIGN KEY (business_category_id) REFERENCES public.business_categories(business_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.businesses_favorites
    ADD CONSTRAINT businesses_favorites_businesses_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.businesses_favorites
    ADD CONSTRAINT businesses_favorites_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(vendor_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_bussiness_id_fkey FOREIGN KEY (bussiness_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.info_images
    ADD CONSTRAINT info_images_info_id_fkey FOREIGN KEY (info_id) REFERENCES public.infos(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.infos
    ADD CONSTRAINT infos_info_address_fkey FOREIGN KEY (info_address) REFERENCES public.addresses(adress_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_info_id_fkey FOREIGN KEY (info_id) REFERENCES public.infos(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(chat_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_businesses_category_id_fkey FOREIGN KEY (businesses_category_id) REFERENCES public.business_categories(business_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_businesses_id_fkey FOREIGN KEY (businesses_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_product_category_id_fkey FOREIGN KEY (product_category_id) REFERENCES public.product_categories(product_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.rider_documents
    ADD CONSTRAINT rider_documents_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.riders(rider_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.statuses
    ADD CONSTRAINT statuses_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.variant_categories
    ADD CONSTRAINT variant_categories_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_variant_category_id_fkey FOREIGN KEY (variant_category_id) REFERENCES public.variant_categories(variant_category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.wards
    ADD CONSTRAINT wards_county_id_fkey FOREIGN KEY (county_id) REFERENCES public.counties(county_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
