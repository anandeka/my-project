create or replace view v_bi_audit_log_details as
select vbi.corporate_id,
       vbi.log_type,
       akc.corporate_name,
       vbi.internal_action_ref_no,
       vbi.activitydate,
       vbi.activitytime,
       vbi.actionperformed,
       vbi.entity,
       vbi.entityrefno,
       vbi.username,
       vbi.actionrefno,
       vbi.actionid,
       al.audit_log_id,
       al.entity_ref_no,
       ald.audit_log_details_id,
       ald.sub_entity_name,
       ald.field_name as fieldname,
       ald.new_value as newvalue,
       ald.old_value as oldvalue
  from v_bi_audit_log_history vbi,
       ak_corporate           akc,
       al_audit_log           al,
       ald_audit_log_details  ald
 where vbi.internal_action_ref_no = al.internal_action_ref_no(+)
   and al.audit_log_id = ald.audit_log_id(+)
   and vbi.corporate_id = akc.corporate_id
/
