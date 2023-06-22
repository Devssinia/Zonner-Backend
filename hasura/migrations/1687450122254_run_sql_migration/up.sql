CREATE TRIGGER sync_riders AFTER INSERT OR DELETE OR UPDATE ON public.riders FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
CREATE TRIGGER sync_customers AFTER INSERT OR DELETE OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
CREATE TRIGGER sync_vendors AFTER INSERT OR DELETE OR UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.sync_authentications_table();
