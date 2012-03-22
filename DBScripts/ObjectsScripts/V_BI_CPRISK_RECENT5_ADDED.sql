CREATE OR REPLACE VIEW V_BI_CPRISK_RECENT5_ADDED AS
select t.corporate_id,
       t.profileid,
       t.companyname,
       t.order_id,
       t.added_date
  from (select akc.corporate_id corporate_id,
               phd.profileid,
               phd.companyname,
               rank() over(partition by gcd.groupid, akc.corporate_id order by axs.created_date desc) order_id,
               to_char(axs.created_date, 'dd-Mon-yyyy') added_date
          from phd_profileheaderdetails  phd,
               gcd_groupcorporatedetails gcd,
               ak_corporate              akc,
               mdm_master_data_mapping   mdm,
               axs_action_summary        axs
         where phd.group_id = gcd.groupid
           and phd.isinternalcompany = 'N'
           and gcd.groupid = akc.groupid
           and mdm.internal_mdm_id = phd.profileid
           and mdm.internal_action_ref_no = axs.internal_action_ref_no) t
 where t.order_id <= 5
