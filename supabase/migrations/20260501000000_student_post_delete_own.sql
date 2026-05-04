-- Allow students to delete their own rows in student_post (active when RLS is enabled on this table).
DROP POLICY IF EXISTS "student_post_delete_own" ON public.student_post;
CREATE POLICY "student_post_delete_own" ON public.student_post
  FOR DELETE
  TO authenticated
  USING (student_id = auth.uid());
