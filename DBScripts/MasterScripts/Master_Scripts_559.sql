declare

 cursor cr_csul is
   SELECT cs.effective_date, t.internal_cost_ul_id
  FROM (SELECT csul.effective_date,
               pkg_general.f_is_date@eka_appdb(csul.effective_date) is_date,
               csul.internal_cost_ul_id, csul.internal_cost_id cs_id
          FROM csul_cost_store_ul csul) t,
       cs_cost_store cs
 WHERE is_date = 'N' AND cs.internal_cost_id = t.cs_id;
 
 begin

  for rec_csul in cr_csul loop
    update CSUL_COST_STORE_UL set EFFECTIVE_DATE = to_char(rec_csul.effective_date ,'dd-MON-yy') where INTERNAL_COST_UL_ID = rec_csul.internal_cost_ul_id;
  end loop;
end;