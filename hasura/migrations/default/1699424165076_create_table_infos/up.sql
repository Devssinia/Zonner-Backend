CREATE TABLE public.infos (
    title text NOT NULL,
    description text NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    subtitle text,
    info_address uuid
);
