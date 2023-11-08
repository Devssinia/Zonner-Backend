-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE TRIGGER set_public_addresses_updated_at BEFORE UPDATE ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_addresses_updated_at ON public.addresses IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_authentications_updated_at BEFORE UPDATE ON public.authentications FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_authentications_updated_at ON public.authentications IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_business_reviews_updated_at BEFORE UPDATE ON public.business_reviews FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_business_reviews_updated_at ON public.business_reviews IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_businesses_categories_updated_at BEFORE UPDATE ON public.business_categories FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_businesses_categories_updated_at ON public.business_categories IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_businesses_favorites_updated_at BEFORE UPDATE ON public.businesses_favorites FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_businesses_favorites_updated_at ON public.businesses_favorites IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_chats_updated_at BEFORE UPDATE ON public.chats FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_chats_updated_at ON public.chats IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_customers_updated_at ON public.customers IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_messages_updated_at BEFORE UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_messages_updated_at ON public.messages IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_order_items_updated_at BEFORE UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_order_items_updated_at ON public.order_items IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_orders_updated_at ON public.orders IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_product_categories_updated_at BEFORE UPDATE ON public.product_categories FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_product_categories_updated_at ON public.product_categories IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_product_reviews_updated_at BEFORE UPDATE ON public.product_reviews FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_product_reviews_updated_at ON public.product_reviews IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_products_updated_at ON public.products IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_riders_updated_at BEFORE UPDATE ON public.riders FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_riders_updated_at ON public.riders IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_roles_updated_at ON public.roles IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_variants_updated_at BEFORE UPDATE ON public.variants FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_variants_updated_at ON public.variants IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_vendors_updated_at BEFORE UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_vendors_updated_at ON public.vendors IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER set_public_wish_lists_updated_at BEFORE UPDATE ON public.wish_lists FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
-- COMMENT ON TRIGGER set_public_wish_lists_updated_at ON public.wish_lists IS 'trigger to set value of column "updated_at" to current timestamp on row update';
-- CREATE TRIGGER sync_customers AFTER INSERT OR DELETE OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
-- CREATE TRIGGER sync_riders AFTER INSERT OR DELETE OR UPDATE ON public.riders FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
-- CREATE TRIGGER sync_vendors AFTER INSERT OR DELETE OR UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
