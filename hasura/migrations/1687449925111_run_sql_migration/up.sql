CREATE FUNCTION public.sync_authentications_table() RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
DECLARE
    role_id UUID;
    role_name text;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT role_id, role_name INTO role_id, role_name FROM roles WHERE role_name = TG_TABLE_NAME;
        
        IF role_name = 'customers' THEN
            INSERT INTO "authentications" (user_id, role_id, phone_no)
            VALUES (NEW.customer_id, role_id, NEW.phone_no);
        ELSIF role_name = 'vendors' THEN
            INSERT INTO "authentications" (user_id, role_id, phone_no)
            VALUES (NEW.vendor_id, role_id, NEW.phone_no);
        ELSIF role_name = 'riders' THEN
            INSERT INTO user_roles (user_id, role_id)
            VALUES (NEW.rider_id, role_id);
        END IF;
        
    ELSIF TG_OP = 'UPDATE' THEN
        IF TG_TABLE_NAME = 'customers' THEN
            UPDATE "authentications" SET
                phone_no = NEW.phone_no
            WHERE customer_id = NEW.customer_id;
        ELSIF TG_TABLE_NAME = 'vendors' THEN
            UPDATE "authentications" SET
                phone_no = NEW.phone_no
            WHERE vendor_id = NEW.vendor_id;
        ELSIF TG_TABLE_NAME = 'riders' THEN
            UPDATE "authentications" SET
                phone_no = NEW.phone_no
            WHERE rider_id = NEW.rider_id;
        END IF;
        
    ELSIF TG_OP = 'DELETE' THEN
        IF TG_TABLE_NAME = 'customers' THEN
            DELETE FROM authentications WHERE customer_id = OLD.customer_id;
        ELSIF TG_TABLE_NAME = 'vendors' THEN
            DELETE FROM authentications WHERE vendor_id = OLD.vendor_id;
        ELSIF TG_TABLE_NAME = 'riders' THEN
            DELETE FROM authentications WHERE rider_id = OLD.rider_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;