-- Student posts: distinguish job-seeking vs internship-seeking
ALTER TABLE public.student_post
  ADD COLUMN IF NOT EXISTS post_type text NOT NULL DEFAULT 'job';

ALTER TABLE public.student_post
  DROP CONSTRAINT IF EXISTS student_post_post_type_check;

ALTER TABLE public.student_post
  ADD CONSTRAINT student_post_post_type_check
  CHECK (post_type IN ('job', 'internship'));
