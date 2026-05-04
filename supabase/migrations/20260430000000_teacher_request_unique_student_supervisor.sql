-- One recommendation letter request per student per supervisor (multiple teachers allowed).
CREATE UNIQUE INDEX IF NOT EXISTS teacher_request_student_supervisor_unique
  ON public.teacher_request (student_id, supervisor_id);
