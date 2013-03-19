
CREATE TABLE wns_assay_d_gmr(internal_doc_ref_no VARCHAR2(30),contract_type VARCHAR2(15),buyer VARCHAR2(30),
		                    seller VARCHAR2(30), gmr_ref_no VARCHAR2(30),shipment_date DATE,arrival_date DATE, 
			       bl_no VARCHAR2(30),bl_date DATE,vessel_name VARCHAR2(30),mode_of_transport VARCHAR2(30), 
			       container_no VARCHAR2(50),senders_ref_no VARCHAR2(30),tare_weight NUMBER(25,10),no_of_pieces NUMBER(9));


---- DGM WnS_GMR  ----

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-WNS-GMR', 'CREATE_WNS_ASSAY', 'Weighing And Sampling', 'CREATE_WNS_ASSAY', 2, 
    'INSERT INTO WNS_ASSAY_D_GMR
            (contract_type, buyer,
             seller, gmr_ref_no, shipment_date, arrival_date, bl_no,
             bl_date, vessel_name, mode_of_transport,
             container_no, senders_ref_no,tare_weight,no_of_pieces, internal_doc_ref_no)
   SELECT gmr.contract_type AS contract_type,
         (CASE
              WHEN gmr.contract_type = ''Sales''
                 THEN vpci.cp_name
              ELSE vpci.corporate_name
           END
          ) buyer,
          (CASE
              WHEN gmr.contract_type = ''Purchase''
                 THEN vpci.cp_name
              ELSE vpci.corporate_name
           END
          ) seller,
          gmr.gmr_ref_no AS gmr_ref_no, gmr.eff_date AS shipment_date,
        
           gmr.arrival_date AS arrival_date, gmr.bl_no AS bl_no,
          gmr.bl_date AS bl_date, gmr.vessel_name AS vessel_name,
          gmr.mode_of_transport AS mode_of_transport,
          grdcontainer.containernostring AS container_no,
          gmr.senders_ref_no,gmr.total_tare_weight,grd.no_of_pieces,
          ?
     FROM ash_assay_header ash,
          axs_action_summary axs,
          v_pci vpci,
          gmr_goods_movement_record gmr,
          grd_goods_record_detail grd,
          
          (SELECT   stragg (distinct agrd.container_no) AS containernostring,
                    agrd.internal_gmr_ref_no AS intgmr
               FROM AGRD_ACTION_GRD agrd
              WHERE agrd.container_no IS NOT NULL
                AND agrd.is_deleted = ''N''
                AND agrd.status = ''Active''
           GROUP BY agrd.internal_gmr_ref_no
           UNION ALL
           SELECT   stragg (dgrd.container_no) AS containernostring,
                    dgrd.internal_gmr_ref_no AS intgmr
               FROM dgrd_delivered_grd dgrd
              WHERE dgrd.container_no IS NOT NULL AND dgrd.status = ''Active''
           GROUP BY dgrd.internal_gmr_ref_no) grdcontainer
    WHERE ash.internal_action_ref_no = axs.internal_action_ref_no
      AND ash.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND gmr.internal_contract_ref_no = vpci.internal_contract_ref_no
      AND ash.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND grdcontainer.intgmr(+) = gmr.internal_gmr_ref_no
      AND grd.internal_contract_item_ref_no = vpci.internal_contract_item_ref_no
      AND ash.internal_grd_ref_no = grd.internal_grd_ref_no
      AND ash.ash_id = ?', 'N');
