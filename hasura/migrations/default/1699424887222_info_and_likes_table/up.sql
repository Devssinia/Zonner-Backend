
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
