 update cbr_closing_balance_report cbr
    set cbr.parent_internal_gmr_ref_no = 'GMR-11652'
  where cbr.parent_internal_gmr_ref_no = 'GMR-11725'
  and cbr.gmr_ref_no='GMR-11549-BLD';
commit;
