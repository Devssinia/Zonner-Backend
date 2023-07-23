-- Could not auto-generate a down migration.
-- Please write an appropriate down migration for the SQL below:
-- -- INSERT INTO public.riders (rider_id, first_name, last_name, email, phone_no, is_verified)
-- -- VALUES ('d88824ae-135f-11ee-be56-0242ac120002', 'Jane', 'Doe', 'jdoe@example.com', '123-456-7890', true);
-- -- INSERT INTO public.vendors (vendor_id, first_name, last_name, email, phone_no, status)
-- -- VALUES ('0e623e1b-5a94-4b44-b2e7-89d122ae85c3', 'John', 'Smith', 'jsmith@example.com', '123-456-7890', true);
-- CREATE OR REPLACE FUNCTION public.sync_authentications_table() RETURNS TRIGGER
--     LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     role_id UUID;
--     role_name_txt text; -- Change variable name to role_name_txt
-- BEGIN
--     IF TG_OP = 'INSERT' THEN
--         SELECT roles.role_id INTO role_id FROM roles WHERE role_name = TG_TABLE_NAME;
--         SELECT roles.role_name INTO role_name_txt FROM roles WHERE role_name = TG_TABLE_NAME;
--         IF role_name_txt = 'customers' THEN -- Update variable name here as well
--             INSERT INTO "authentications" (user_id, role_id, phone_no)
--             VALUES (NEW.customer_id, role_id, NEW.phone_no);
--         ELSIF role_name_txt = 'vendors' THEN -- Update variable name here as well
--             INSERT INTO "authentications" (user_id, role_id, phone_no)
--             VALUES (NEW.vendor_id, role_id, NEW.phone_no);
--         ELSIF role_name_txt = 'riders' THEN -- Update variable name here as well
--             INSERT INTO user_roles (user_id, role_id)
--             VALUES (NEW.rider_id, role_id);
--         ELSE
--             -- Handle unexpected role_name_txt
--             RAISE EXCEPTION 'Unknown role_name: %', role_name_txt;
--         END IF;
--     ELSIF TG_OP = 'UPDATE' THEN
--         IF TG_TABLE_NAME = 'customers' THEN
--             UPDATE "authentications" SET
--                 phone_no = NEW.phone_no
--             WHERE customer_id = NEW.customer_id;
--         ELSIF TG_TABLE_NAME = 'vendors' THEN
--             UPDATE "authentications" SET
--                 phone_no = NEW.phone_no
--             WHERE vendor_id = NEW.vendor_id;
--         ELSIF TG_TABLE_NAME = 'riders' THEN
--             UPDATE "authentications" SET
--                 phone_no = NEW.phone_no
--             WHERE rider_id = NEW.rider_id;
--         ELSE
--             -- Handle unexpected TG_TABLE_NAME
--             RAISE EXCEPTION 'Unknown TG_TABLE_NAME: %', TG_TABLE_NAME;
--         END IF;
--     ELSIF TG_OP = 'DELETE' THEN
--         IF TG_TABLE_NAME = 'customers' THEN
--             DELETE FROM authentications WHERE customer_id = OLD.customer_id;
--         ELSIF TG_TABLE_NAME = 'vendors' THEN
--             DELETE FROM authentications WHERE vendor_id = OLD.vendor_id;
--         ELSIF TG_TABLE_NAME = 'riders' THEN
--             DELETE FROM authentications WHERE rider_id = OLD.rider_id;
--         ELSE
--             -- Handle unexpected TG_TABLE_NAME
--             RAISE EXCEPTION 'Unknown TG_TABLE_NAME: %', TG_TABLE_NAME;
--         END IF;
--     ELSE
--         -- Handle unexpected TG_OP
--         RAISE EXCEPTION 'Unknown TG_OP: %', TG_OP;
--     END IF;
--     RETURN NEW;
-- END;
-- $$;
