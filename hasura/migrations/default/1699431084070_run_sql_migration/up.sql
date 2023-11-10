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
-- ALTER TABLE ONLY public.wards
--     ADD CONSTRAINT wards_county_id_fkey FOREIGN KEY (county_id) REFERENCES public.counties(county_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.wish_lists
    ADD CONSTRAINT wish_lists_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE RESTRICT ON DELETE RESTRICT;