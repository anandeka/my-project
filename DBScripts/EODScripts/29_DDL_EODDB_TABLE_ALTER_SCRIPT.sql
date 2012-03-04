create  or replace view v_scm_stock_cost_mapping as
select scm.cog_ref_no,
       scm.internal_gmr_ref_no,
       scm.transformation_ratio,
       'N' is_deleted
  from scm_stock_cost_mapping scm
 where scm.internal_dgrd_ref_no is null
 and scm.is_deleted ='N'
 group by scm.cog_ref_no,
       scm.internal_gmr_ref_no,
       scm.transformation_ratio;