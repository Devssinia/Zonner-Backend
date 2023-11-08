ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_phone_no_key UNIQUE (phone_no);
ALTER TABLE ONLY public.authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (user_id);
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_email_key UNIQUE (business_email);
ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_businesses_phone_no_key UNIQUE (business_phone_no);
ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_no_key UNIQUE (phone_no);
ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_email_key UNIQUE (email);
ALTER TABLE ONLY public.riders
    ADD CONSTRAINT riders_phone_no_key UNIQUE (phone_no);
ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_email_key UNIQUE (email);
ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_phone_no_key UNIQUE (phone_no);
