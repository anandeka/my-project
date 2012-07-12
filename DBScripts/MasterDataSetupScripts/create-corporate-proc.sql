declare

  l_corporate_name varchar2(200) := 'Boliden1';
  l_corporate_id   varchar2(10) := 'BL1';
  l_image_name     varchar2(100) := '';
  l_group_id       varchar2(15) := 'GCD-1';
  l_ref_corp_id    varchar2(15) := 'LDE';

  l_seq_phd  varchar2(15);
  l_seq_pad  varchar2(15);
  l_seq_bpc  varchar2(15);
  l_seq_bpr  varchar2(15);
  l_seq_cfl  varchar2(15);
  l_seq_arf  varchar2(15);
  l_seq_arfm varchar2(15);

  l_seq_drf  varchar2(15);
  l_seq_drfm varchar2(15);

  cursor cur_cfl is
  
    select *
      from cfl_corporatefeaturelist cfl
     where cfl.corporate_id = l_ref_corp_id;

  cursor cur_arf is
  
    select *
      from arf_action_ref_number_format arf
     where arf.corporate_id = l_ref_corp_id;

  cursor cur_arfm is
  
    select *
      from arfm_action_ref_no_mapping arfm
     where arfm.corporate_id = l_ref_corp_id;

  cursor cur_drf is
  
    select *
      from drf_doc_ref_number_format drf
     where drf.corporate_id = l_ref_corp_id;

  cursor cur_drfm is
  
    select *
      from drfm_doc_ref_no_mapping drfm
     where drfm.corporate_id = l_ref_corp_id;

  cursor cur_erc is
  
    select *
      from erc_external_ref_no_config erc
     where erc.corporate_id = l_ref_corp_id;

  cursor cur_bpc is
  
    select *
      from bpc_bp_corporates bpc
     where bpc.corporate_id = l_ref_corp_id;

  cursor cur_DC is  
    select *
      from DC_DOCUMENT_CONFIGURATION dc
     where dc.corporate_id = l_ref_corp_id;

begin

  -- ak_corporate Table

  insert into ak_corporate
    (corporate_id,
     corporate_name,
     lang_code,
     time_zone,
     groupid,
     corp_short_name,
     base_cur_id,
     inv_cur_id,
     corp_display_name1,
     corp_display_name2,
     display_order,
     version,
     is_active,
     is_deleted,
     is_internal_corporate)
    select l_corporate_id,
           l_corporate_name,
           lang_code,
           time_zone,
           l_group_id,
           l_corporate_id,
           base_cur_id,
           inv_cur_id,
           l_corporate_name,
           l_corporate_name,
           display_order,
           version,
           is_active,
           is_deleted,
           is_internal_corporate
      from ak_corporate ak
     where ak.corporate_id = l_ref_corp_id;

  -- PHD Table

  select 'PHD-' || SEQ_PHD.NEXTVAL into l_seq_phd from dual;

  insert into phd_profileheaderdetails
    (profileid,
     companyname,
     company_long_name1,
     company_long_name2,
     sales_tax_no,
     isinternalcompany,
     profile_group_id,
     is_active,
     company_type_code,
     group_id,
     corporate_id,
     internal_remarks,
     default_pay_in_cur_id,
     display_order,
     version,
     is_deleted)
    select l_seq_phd,
           l_corporate_name,
           l_corporate_name,
           l_corporate_name,
           sales_tax_no,
           isinternalcompany,
           profile_group_id,
           is_active,
           company_type_code,
           l_group_id,
           l_corporate_id,
           internal_remarks,
           default_pay_in_cur_id,
           display_order,
           version,
           is_deleted
      from phd_profileheaderdetails phd
     where phd.profileid = 'PHD-1';

  -- PAD Table  

  select 'PAD-' || SEQ_PAD.Nextval into l_seq_pad from dual;

  insert into pad_profile_addresses
    (address_id,
     address_name,
     profile_id,
     address_type,
     address,
     country_id,
     city_id,
     state_id,
     phone,
     fax,
     zip,
     email,
     website,
     is_default,
     version,
     is_deleted)
    select l_seq_pad,
           l_corporate_name,
           l_seq_phd,
           address_type,
           address,
           country_id,
           city_id,
           state_id,
           phone,
           fax,
           zip,
           email,
           website,
           is_default,
           version,
           is_deleted
      from pad_profile_addresses pad
     where pad.profile_id = 'PHD-1';

  -- BPC Table
  select 'BPC-' || SEQ_BPC.Nextval into l_seq_bpc from dual;

  insert into bpc_bp_corporates
    (bp_corporate_id, bp_id, corporate_id, is_deleted)
    select l_seq_bpc, l_seq_phd, l_corporate_id, 'N' from dual;

  for cur_bpc_impl in cur_bpc loop
  
    select 'BPC-' || SEQ_BPC.Nextval into l_seq_bpc from dual;
  
    insert into bpc_bp_corporates
      (bp_corporate_id, bp_id, corporate_id, is_deleted)
      select l_seq_bpc, cur_bpc_impl.bp_id, l_corporate_id, 'N' from dual;
  
  end loop;


  for cur_dc_impl in cur_DC loop
  
     
    insert into DC_DOCUMENT_CONFIGURATION
      (ACTIVITY_ID, CORPORATE_ID, IS_GENERATE_DOC_REQD, IS_UPLOAD_DOC_REQD,DOC_VALIDATION_QUERY,NAVIGATION)
      select cur_dc_impl.ACTIVITY_ID, l_corporate_id, cur_dc_impl.IS_GENERATE_DOC_REQD, cur_dc_impl.IS_UPLOAD_DOC_REQD,cur_dc_impl.DOC_VALIDATION_QUERY,cur_dc_impl.NAVIGATION from dual;
  
  end loop;


  -- CCG Table

  insert into ccg_corporateconfig
    (CORPORATEID,
     IS_USD46KG_UNIT_CONV_REQUIRED,
     IS_CLOSEOUT_WARNING_REQD,
     IS_ACC_CHECKBOX_REQUIRED,
     IS_PI_PERCENT_EDIT,
     IS_PI_PERCENT_ON_FIXED,
     IS_CROP_YEAR_REQUIRED,
     GMR_QTY_TOLERANCE_PCT,
     POSITION_CHECK,
     CDC_PROCESS_APPLICABLE,
     PHY_PROCESS_APPLICABLE,
     TRADE_DAY_UNRPNL_FOR_INVENTORY,
     ACTIVE_LAYOUT_CONFIGURATION_ID)  
    select l_corporate_id,
           IS_USD46KG_UNIT_CONV_REQUIRED,
           IS_CLOSEOUT_WARNING_REQD,
           IS_ACC_CHECKBOX_REQUIRED,
           IS_PI_PERCENT_EDIT,
           IS_PI_PERCENT_ON_FIXED,
           IS_CROP_YEAR_REQUIRED,
           GMR_QTY_TOLERANCE_PCT,
           POSITION_CHECK,
          CDC_PROCESS_APPLICABLE,
	  PHY_PROCESS_APPLICABLE,
	 TRADE_DAY_UNRPNL_FOR_INVENTORY,
	ACTIVE_LAYOUT_CONFIGURATION_ID
      from ccg_corporateconfig ccg
     where ccg.corporateid = l_ref_corp_id;

  -- BPR Table

  select 'BPR-' || SEQ_BPR.Nextval into l_seq_bpr from dual;

  insert into bpr_business_partner_roles
    (bp_role_id, profile_id, role_type_code, is_deleted)
  values
    (l_seq_bpr, l_seq_phd, 'BUYER', 'N');

  select 'BPR-' || SEQ_BPR.Nextval into l_seq_bpr from dual;

  insert into bpr_business_partner_roles
    (bp_role_id, profile_id, role_type_code, is_deleted)
  values
    (l_seq_bpr, l_seq_phd, 'SELLER', 'N');

  -- CFL Table      

  for cur_cfl_impl in cur_cfl loop
  
    select 'CFL-' || SEQ_CFL.Nextval into l_seq_cfl from dual;
  
    insert into cfl_corporatefeaturelist
      (corporate_feature_list_id, corporate_id, feature_id, is_deleted)
    values
      (l_seq_cfl, l_corporate_id, cur_cfl_impl.feature_id, 'N');
  
  end loop;

  -- ARF Table

  for cur_arf_impl in cur_arf loop
  
    select 'ARF-' || SEQ_ARF.Nextval into l_seq_arf from dual;
  
    insert into arf_action_ref_number_format
      (action_ref_number_format_id,
       action_key_id,
       corporate_id,
       prefix,
       middle_no_start_value,
       middle_no_last_used_value,
       suffix,
       version,
       is_deleted)
    values
      (l_seq_arf,
       cur_arf_impl.action_key_id,
       l_corporate_id,
       cur_arf_impl.prefix,
       cur_arf_impl.middle_no_start_value,
       0,
       '-' || l_corporate_id,
       null,
       'N');
  
  end loop;

  -- ARFM Table

  for cur_arfm_impl in cur_arfm loop
  
    select 'ARFM-' || SEQ_ARFM.Nextval into l_seq_arfm from dual;
  
    insert into arfm_action_ref_no_mapping
      (action_ref_no_mapping_id,
       corporate_id,
       action_id,
       action_key_id,
       is_deleted)
    values
      (l_seq_arfm,
       l_corporate_id,
       cur_arfm_impl.action_id,
       cur_arfm_impl.action_key_id,
       'N');
  end loop;

  -- DRF Table

  for cur_drf_impl in cur_drf loop
  
    select 'DRF-' || SEQ_DRF.Nextval into l_seq_drf from dual;
  
    insert into drf_doc_ref_number_format
      (doc_ref_number_format_id,
       doc_key_id,
       corporate_id,
       prefix,
       middle_no_start_value,
       middle_no_last_used_value,
       suffix,
       version,
       is_deleted)
    values
      (l_seq_drf,
       cur_drf_impl.doc_key_id,
       l_corporate_id,
       cur_drf_impl.prefix,
       cur_drf_impl.middle_no_start_value,
       0,
       '-' || l_corporate_id,
       null,
       'N');
  
  end loop;

  -- DRFM Table

  for cur_drfm_impl in cur_drfm loop
  
    select 'DRFM-' || SEQ_DRFM.Nextval into l_seq_drfm from dual;
  
    insert into drfm_doc_ref_no_mapping
      (doc_ref_no_mapping_id, corporate_id, doc_id, doc_key_id, is_deleted)
    values
      (l_seq_drfm,
       l_corporate_id,
       cur_drfm_impl.doc_id,
       cur_drfm_impl.doc_key_id,
       'N');
  end loop;

  -- ERC Table

  for cur_erc_impl in cur_erc loop
  
    insert into erc_external_ref_no_config
      (corporate_id,
       external_ref_no_key,
       prefix,
       middle_no_last_used_value,
       suffix)
    values
      (l_corporate_id,
       cur_erc_impl.external_ref_no_key,
       cur_erc_impl.prefix,
       0,
       '-' || l_corporate_id);
  
  end loop;

  -- CDC Table

  insert into cdc_corporate_doc_config
    (doc_template_id,
     corporate_id,
     doc_id,
     doc_template_name,
     doc_template_name_de,
     doc_template_name_es,
     doc_print_name,
     doc_print_name_de,
     doc_print_name_es,
     doc_rpt_file_name,
     is_active,
     doc_auto_generate)
  
    select doc_template_id,
           l_corporate_id,
           doc_id,
           doc_template_name,
           doc_template_name_de,
           doc_template_name_es,
           doc_print_name,
           doc_print_name_de,
           doc_print_name_es,
           doc_rpt_file_name,
           is_active,
           doc_auto_generate
      from cdc_corporate_doc_config cdc
     where cdc.corporate_id = l_ref_corp_id;

  -- RFC Table

  insert into rfc_report_filter_config
    (corporate_id,
     report_id,
     label_id,
     label_column_number,
     label_row_number,
     label,
     field_id,
     colspan,
     IS_MANDATORY)
    select l_corporate_id,
           report_id,
           label_id,
           label_column_number,
           label_row_number,
           label,
           field_id,
           colspan,
	   IS_MANDATORY
      from rfc_report_filter_config rfc
     where rfc.corporate_id = l_ref_corp_id;


     -- RPC Table

  insert into RPC_RF_PARAMETER_CONFIG
    (CORPORATE_ID,	                     
REPORT_ID		,				
LABEL_ID	,					
PARAMETER_ID		,			
REPORT_PARAMETER_NAME	
)
    select l_corporate_id,	                     
REPORT_ID		,				
LABEL_ID	,					
PARAMETER_ID		,			
REPORT_PARAMETER_NAME	

      from RPC_RF_PARAMETER_CONFIG rpc
     where rpc.corporate_id = l_ref_corp_id;


  -- RPD Table

  insert into rpd_report_parameter_data
    (corporate_id, report_id, report_parameter_name, report_param_id)
    select l_corporate_id,
           report_id,
           report_parameter_name,
           report_param_id
      from rpd_report_parameter_data rpd
     where rpd.corporate_id = l_ref_corp_id;

  -- CGAR Table  

  insert into cgar_corporate_gmr_action_rule
    (corporate_id, parent_action_id, action_id)
  
    select l_corporate_id, parent_action_id, action_id
      from cgar_corporate_gmr_action_rule cgar
     where cgar.corporate_id = l_ref_corp_id;

  -- CIT Table

  insert into cit_corporate_invoice_type
    (corporate_id,
     invoice_rule_id,
     menu_display_name,
     output_doc_name,
     warning_reqd,
     warning_message)
    select l_corporate_id,
           invoice_rule_id,
           menu_display_name,
           output_doc_name,
           warning_reqd,
           warning_message
      from cit_corporate_invoice_type cit
     where cit.corporate_id = l_ref_corp_id;

  -- CTFL and CTSL Table
/*
  insert into ctf_contract_text_field
    (field_id,
     corporate_id,
     field_name,
     section_id,
     is_default,
     version,
     is_active,
     is_deleted)
    select field_id,
           l_corporate_id,
           field_name,
           section_id,
           is_default,
           version,
           is_active,
           is_deleted
      from ctf_contract_text_field ctf
     where ctf.corporate_id = l_ref_corp_id;*/

 /* insert into ctsl_cont_text_section_layout
    (section_layout_id,
     corporate_id,
     layout_configuration_id,
     section_id,
     display_order)
    select l_corporate_id||section_layout_id,
           l_corporate_id,
           layout_configuration_id,
           section_id,
           display_order
      from ctsl_cont_text_section_layout ctsl
     where ctsl.corporate_id = l_ref_corp_id;

  insert into ctfl_cont_text_field_layout
    (field_layout_id,
     section_layout_id,
     corporate_id,
     field_id,
     is_pre_content_reqd,
     is_post_content_reqd,
     display_order)
    select field_layout_id,
           section_layout_id,
           l_corporate_id,
           field_id,
           is_pre_content_reqd,
           is_post_content_reqd,
           display_order
      from ctfl_cont_text_field_layout ctfl
     where ctfl.corporate_id = l_ref_corp_id;
*/


end;
