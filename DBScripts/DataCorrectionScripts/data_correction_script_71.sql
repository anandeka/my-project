DECLARE
   TYPE pfd_record IS RECORD(
          pfd_id         VARCHAR2(15 CHAR),
          action_ref_no VARCHAR2(1000 CHAR),
          internal_action_ref_no           VARCHAR2(30 CHAR));
   Type pfd_table is table of pfd_record;
   l_pfd_tab pfd_table;
   vn_count number;
   
BEGIN
    SELECT pfam.pfd_id, axs.action_ref_no, axs.internal_action_ref_no
        bulk collect into l_pfd_tab
         FROM axs_action_summary axs,
              pfam_price_fix_action_mapping pfam
        WHERE axs.internal_action_ref_no = pfam.internal_action_ref_no
         order by pfam.pfd_id, axs.internal_action_ref_no;

   FORall i in l_pfd_tab.first..l_pfd_tab.last
      UPDATE pfd_price_fixation_details pfd
         SET pfd.internal_action_ref_no = l_pfd_tab(i).internal_action_ref_no,
             pfd.price_fixation_ref_no = l_pfd_tab(i).action_ref_no
       WHERE pfd.pfd_id = l_pfd_tab(i).pfd_id;
       
   vn_count:=sql%rowcount;
   dbms_output.put_line(vn_count);
   
  commit;
END;