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
