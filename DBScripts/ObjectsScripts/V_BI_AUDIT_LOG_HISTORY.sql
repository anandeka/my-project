create or replace view v_bi_audit_log_history as
select axs.corporate_id,
       'DERIVATIVE' log_type,
       axs.internal_action_ref_no,
       to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
       to_char(axs.created_date, 'hh24:mi') as activitytime,
       axm.action_name as actionperformed,
       axm.entity_id as entity,
       dt.derivative_ref_no as entityrefno,
       aku.user_name as username,
       axs.internal_action_ref_no as actionrefno,
       axm.action_id as actionid
  from axs_action_summary             axs,
       axm_action_master              axm,
       dam_derivative_action_amapping dam,
       dt_derivative_trade            dt,
       v_corporate_user               aku
 where axs.action_id = axm.action_id
   and dam.internal_action_ref_no = axs.internal_action_ref_no
   and dam.internal_derivative_ref_no = dt.internal_derivative_ref_no
   and axs.created_by = aku.user_id
--   QUERY_STR_CCT =         
union all
select axs.corporate_id,
       'FX' log_type,
       axs.internal_action_ref_no,
       to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
       to_char(axs.created_date, 'hh24:mi') as activitytime,
       axm.action_name as actionperformed,
       axm.entity_id as entity,
       ct.treasury_ref_no as entityrefno,
       aku.user_name as username,
       axs.internal_action_ref_no as actionrefno,
       axm.action_id as actionid
  from axs_action_summary           axs,
       axm_action_master            axm,
       cam_currency_action_amapping cam,
       ct_currency_trade            ct,
       v_corporate_user             aku
 where axs.action_id = axm.action_id
   and cam.internal_action_ref_no = axs.internal_action_ref_no
   and cam.internal_treasury_ref_no = cam.internal_treasury_ref_no
   and axs.created_by = aku.user_id
-- QUERY_STR_INV =  
union all
select axs.corporate_id,
       'PHYSICAL' log_type,
       axs.internal_action_ref_no,
       to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
       to_char(axs.created_date, 'hh24:mi') as activitytime,
       axm.action_name as actionperformed,
       axm.entity_id as entity,
       invs.invoice_ref_no as entityrefno,
       aku.user_name as username,
       axs.internal_action_ref_no as actionrefno,
       axm.action_id as actionid
  from axs_action_summary axs,
       axm_action_master  axm,
       is_invoice_summary invs,
       --  al_audit_log               al,
       v_corporate_user           aku,
       iam_invoice_action_mapping iam
 where invs.internal_invoice_ref_no = iam.internal_invoice_ref_no
   and iam.invoice_action_ref_no = axs.internal_action_ref_no
      -- and al.internal_action_ref_no(+) = axs.internal_action_ref_no
   and axs.action_id = axm.action_id
   and axs.created_by = aku.user_id
--QUERY_STR_FOR_PC =  
union all
select axs.corporate_id,
       'PHYSICAL' log_type,
       axs.internal_action_ref_no,
       to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
       to_char(axs.created_date, 'hh24:mi') as activitytime,
       axm.action_name as actionperformed,
       axm.entity_id as entity,
       pcm.contract_ref_no as entityrefno,
       aku.user_name as username,
       axs.internal_action_ref_no as actionrefno,
       axm.action_id as actionid
  from axs_action_summary           axs,
       axm_action_master            axm,
       pca_physical_contract_action pca,
       pcm_physical_contract_main   pcm,
       v_corporate_user             aku
 where axs.action_id = axm.action_id
   and pca.internal_action_ref_no = axs.internal_action_ref_no
   and pcm.internal_contract_ref_no = pca.internal_contract_ref_no
   and axs.created_by = aku.user_id
--QUERY_LOGISTICS =  
union all
select axs.corporate_id,
       'PHYSICAL' log_type,
       axs.internal_action_ref_no,
       to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
       to_char(axs.created_date, 'hh24:mi') as activitytime,
       axm.action_name as actionperformed,
       axm.entity_id as entity,
       gmr.gmr_ref_no as entityrefno,
       aku.user_name as username,
       axs.internal_action_ref_no as actionrefno,
       axm.action_id as actionid
  from axs_action_summary        axs,
       axm_action_master         axm,
       gmr_goods_movement_record gmr,
       gam_gmr_action_mapping    gam,
       --   al_audit_log              al,
       v_corporate_user aku
 where axs.action_id = axm.action_id
   and axs.internal_action_ref_no = gam.internal_action_ref_no
   and gmr.internal_gmr_ref_no = gam.internal_gmr_ref_no
      -- and axs.internal_action_ref_no = al.internal_action_ref_no(+)
   and axs.created_by = aku.user_id
-- QUERY_PHYSICAL_CALLOFF =  
union all
select axs.corporate_id,
       'PHYSICAL' log_type,
       axs.internal_action_ref_no,
       to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
       to_char(axs.created_date, 'hh24:mi') as activitytime,
       axm.action_name as actionperformed,
       axm.entity_id as entity,
       pcm.contract_ref_no as entityrefno,
       aku.user_name as username,
       axs.internal_action_ref_no as actionrefno,
       axm.action_id as actionid
  from axs_action_summary         axs,
       axm_action_master          axm,
       v_corporate_user           aku,
       pcm_physical_contract_main pcm,
       cod_call_off_details       cod,
       pcdi_pc_delivery_item      pcdi
 where axs.action_id = axm.action_id
   and axs.internal_action_ref_no = cod.internal_action_ref_no
   and cod.pcdi_id = pcdi.pcdi_id
   and pcm.internal_contract_ref_no = pcdi.internal_contract_ref_no
   and axs.created_by = aku.user_id
--QUERY_PRICING_CALLOFF =  
union all
select axs.corporate_id,
       'PHYSICAL' log_type,
       axs.internal_action_ref_no,
       to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
       to_char(axs.created_date, 'hh24:mi') as activitytime,
       axm.action_name as actionperformed,
       axm.entity_id as entity,
       pcm.contract_ref_no as entityrefno,
       aku.user_name as username,
       axs.internal_action_ref_no as actionrefno,
       axm.action_id as actionid
  from axs_action_summary             axs,
       axm_action_master              axm,
       v_corporate_user               aku,
       pcm_physical_contract_main     pcm,
       pcdi_pc_delivery_item          pcdi,
       poch_price_opt_call_off_header poch,
       pcbph_pc_base_price_header     pcbph,
       pci_physical_contract_item     pci
 where axs.action_id = axm.action_id
   and axs.internal_action_ref_no = poch.internal_action_ref_no
   and poch.pcbph_id = pcbph.pcbph_id
   and pcdi.pcdi_id = pci.pcdi_id
   and poch.pcdi_id = pcdi.pcdi_id
   and pcdi.is_price_optionality_present = 'Y'
   and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   and axs.created_by = aku.user_id
--QUERY_PRICING_FIXATION_CREATE =  
union all
select distinct axs.corporate_id,
       'PHYSICAL' log_type,
                axs.internal_action_ref_no,
                to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
                to_char(axs.created_date, 'hh24:mi') as activitytime,
                axm.action_name as actionperformed,
                axm.entity_id as entity,
                axs.action_ref_no as entityrefno,
                aku.user_name as username,
                axs.internal_action_ref_no as actionrefno,
                axm.action_id as actionid
  from pfd_price_fixation_details    pfd,
       pfam_price_fix_action_mapping pfam,
       axs_action_summary            axs,
       axm_action_master             axm,
       v_corporate_user              aku
 where pfam.pfd_id = pfd.pfd_id
   and axs.internal_action_ref_no = pfam.internal_action_ref_no
   and axs.action_id = axm.action_id
   and axs.created_by = aku.user_id
   and pfd.is_active = 'Y'
   and pfam.is_active = 'Y'
   and nvl(pfd.is_cancel, 'N') = 'N'
--QUERY_PRICING_FIXATION_CANCEL =  
union all
select distinct axs.corporate_id,
       'PHYSICAL' log_type,
                axs.internal_action_ref_no,
                to_char(axs.created_date, 'DD-MM-YYYY') as activitydate,
                to_char(axs.created_date, 'hh24:mi') as activitytime,
                axm.action_name as actionperformed,
                axm.entity_id as entity,
                axs.action_ref_no as entityrefno,
                aku.user_name as username,
                axs.internal_action_ref_no as actionrefno,
                axm.action_id as actionid
  from pfd_price_fixation_details pfd,
       axs_action_summary         axs,
       axm_action_master          axm,
       v_corporate_user           aku
 where axs.internal_action_ref_no = pfd.cancel_action_ref_no
   and axs.action_id = axm.action_id
   and axs.created_by = aku.user_id
   and pfd.is_active = 'N'
   and pfd.is_cancel = 'Y'
/
