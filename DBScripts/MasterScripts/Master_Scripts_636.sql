

Insert into GMC_GRID_MENU_CONFIGURATION
   (MENU_ID, GRID_ID, MENU_DISPLAY_NAME, DISPLAY_SEQ_NO, MENU_LEVEL_NO, 
    FEATURE_ID, LINK_CALLED, ICON_CLASS, MENU_PARENT_ID, ACL_ID)
 Values
   ('LOG_DG_SL', 'LOG', 'Sampling Label Document', 15, 2, 
    'APP-PFL-N-182', 'function(){generateDocumentForSelectedGMR();}', NULL, '102', NULL);

-----------------------------------------------------


INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM_SL', 'SL_DOC', 'Sampling Label', 'SL_DOC', 1,
             'insert into asd_assay_sample_d
  (internal_doc_ref_no,
   corporate_id,
   internal_gmr_ref_no,
   gmr_ref_no,
   senders_ref_no,
   contract_refno,
   cp_ref_no,
   cp_name,
   product_name,
   vessel_voyage_name,
   voyage_number,
   shipper_name,
   shippers_ref_no,
   container_nos)
  select ? internal_doc_ref_no,
         gmr.corporate_id,
         gmr.internal_gmr_ref_no,
         gmr.gmr_ref_no,
         gmr.senders_ref_no,
         pcm.contract_ref_no contract_refno,
         pcm.cp_contract_ref_no,
         phd.companyname cp_name,
         (select f_string_aggregate(pdm.product_desc)
            from pdm_productmaster pdm,
                 agrd_action_grd   agrd
           where agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agrd.action_no = agmr.action_no
             and agrd.is_deleted = ''N''
             and pdm.product_id = agrd.product_id) product_name,
         vd.vessel_voyage_name,
         vd.voyage_number,
         phd_ship.companyname shipper_name,
         vd.shippers_ref_no,
         (select f_string_aggregate(agrd.container_no)
            from agrd_action_grd agrd
           where agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agrd.action_no = agmr.action_no
             and agrd.is_deleted = ''N'') container_nos
    from gmr_goods_movement_record  gmr,
         agmr_action_gmr            agmr,
         sd_shipment_detail         sd,
         pcm_physical_contract_main pcm,
         phd_profileheaderdetails   phd,
         phd_profileheaderdetails   phd_ship,
         vd_voyage_detail           vd
   where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and agmr.gmr_latest_action_action_id in
         (''shipmentDetail'', ''airDetail'', ''truckDetail'', ''railDetail'')
     and agmr.is_deleted = ''N''
     and sd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and sd.action_no = agmr.action_no
     and vd.internal_gmr_ref_no = sd.internal_gmr_ref_no
     and vd.action_no = sd.action_no
     and agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
     and pcm.cp_id = phd.profileid
     and gmr.shipping_line_profile_id = phd_ship.profileid(+)
     and GMR.INTERNAL_GMR_REF_NO = ?
         
',
             'N'
            );


-------------------------------------------------------------------------------

INSERT INTO dgm_document_generation_master
            (dgm_id, doc_id, doc_name, activity_id, sequence_order,
             fetch_query,
             is_concentrate
            )
     VALUES ('DGM_SL_CONC', 'SL_DOC', 'Sampling Label', 'SL_DOC', 1,
             'insert into asd_assay_sample_d
  (internal_doc_ref_no,
   corporate_id,
   internal_gmr_ref_no,
   gmr_ref_no,
   senders_ref_no,
   contract_refno,
   cp_ref_no,
   cp_name,
   product_name,
   vessel_voyage_name,
   voyage_number,
   shipper_name,
   shippers_ref_no,
   container_nos)
  select ? internal_doc_ref_no,
         gmr.corporate_id,
         gmr.internal_gmr_ref_no,
         gmr.gmr_ref_no,
         gmr.senders_ref_no,
         pcm.contract_ref_no contract_refno,
         pcm.cp_contract_ref_no,
         phd.companyname cp_name,
         (select f_string_aggregate(pdm.product_desc)
            from pdm_productmaster pdm,
                 agrd_action_grd   agrd
           where agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agrd.action_no = agmr.action_no
             and agrd.is_deleted = ''N''
             and pdm.product_id = agrd.product_id) product_name,
         vd.vessel_voyage_name,
         vd.voyage_number,
         phd_ship.companyname shipper_name,
         vd.shippers_ref_no,
         (select f_string_aggregate(agrd.container_no)
            from agrd_action_grd agrd
           where agrd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
             and agrd.action_no = agmr.action_no
             and agrd.is_deleted = ''N'') container_nos
    from gmr_goods_movement_record  gmr,
         agmr_action_gmr            agmr,
         sd_shipment_detail         sd,
         pcm_physical_contract_main pcm,
         phd_profileheaderdetails   phd,
         phd_profileheaderdetails   phd_ship,
         vd_voyage_detail           vd
   where gmr.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and agmr.gmr_latest_action_action_id in
         (''shipmentDetail'', ''airDetail'', ''truckDetail'', ''railDetail'')
     and agmr.is_deleted = ''N''
     and sd.internal_gmr_ref_no = agmr.internal_gmr_ref_no
     and sd.action_no = agmr.action_no
     and vd.internal_gmr_ref_no = sd.internal_gmr_ref_no
     and vd.action_no = sd.action_no
     and agmr.internal_contract_ref_no = pcm.internal_contract_ref_no
     and pcm.cp_id = phd.profileid
     and gmr.shipping_line_profile_id = phd_ship.profileid(+)
     and GMR.INTERNAL_GMR_REF_NO = ?
         
',
             'Y'
            );

--------------------------------------------------------------------------------

Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID, IS_CONTINUOUS_MIDDLE_NO_REQ)
 Values
   ('SL_DOC', 'Sampling Label', 125, NULL, 'Y', 
    'N', NULL, 'Y');


-------------------------------------------------------------------------------

 Insert into ADM_ACTION_DOCUMENT_MASTER
     (ADM_ID, ACTION_ID, DOC_ID, IS_DELETED)
   Values
   ('ADM_SL', 'CREATE_DOC_REFNO', 'SL_DOC', 'N');
   
------------------------------------------------------------------------------

INSERT INTO dkm_doc_ref_key_master
                  (doc_key_id, doc_key_desc,
                   validation_query
                  )
           VALUES ('DKM-SL', 'Sampling Label',
                   'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id'
            );

  


