-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- CREATE OR REPLACE FUNCTION public.sync_authentications_table() RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     role_id UUID;
--     role_name_txt text;
-- BEGIN
--     IF TG_OP = 'INSERT' THEN
--         SELECT roles.role_id INTO role_id FROM roles WHERE role_name = substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1);
--         SELECT roles.role_name INTO role_name_txt FROM roles WHERE role_name = substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1);
--         IF role_name_txt = 'customer' THEN
--             INSERT INTO "authentications" (user_id, role_id, phone_no)
--             VALUES (NEW.customer_id, role_id, NEW.phone_no);
--         ELSIF role_name_txt = 'vendor' THEN
--             INSERT INTO "authentications" (user_id, role_id, phone_no)
--             VALUES (NEW.vendor_id, role_id, NEW.phone_no);
--         ELSIF role_name_txt = 'rider' THEN
--            INSERT INTO "authentications" (user_id, role_id, phone_no)
--             VALUES (NEW.rider_id, role_id, NEW.phone_no);
--         ELSE
--             RAISE EXCEPTION 'Unknown role_name: %', role_name_txt;
--         END IF;
--     ELSIF TG_OP = 'UPDATE' THEN
--         IF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'customer' THEN
--             UPDATE "authentications" SET
--                 phone_no = NEW.phone_no
--             WHERE customer_id = NEW.customer_id;
--         ELSIF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'vendor' THEN
--             UPDATE "authentications" SET
--                 phone_no = NEW.phone_no
--             WHERE vendor_id = NEW.vendor_id;
--         ELSIF substring(TG_TABLE_NAME, 1, length(TG_TABLE_NAME)-1) = 'rider' THEN
--             UPDATE "authentications" SET
--                 phone_no = NEW.phone_no
--             WHERE rider_id = NEW.rider_id;
--         ELSE
--             RAISE EXCEPTION 'Unknown TG_TABLE_NAME: %', TG_TABLE_NAME;
--         END IF;
--     ELSIF TG_OP = 'DELETE' THEN
--             DELETE FROM "authentications" WHERE user_id = OLD.user_id;
--     ELSE
--         RAISE EXCEPTION 'Unknown TG_OP: %', TG_OP;
--     END IF;
--     RETURN NEW;
-- END;
-- $$;
