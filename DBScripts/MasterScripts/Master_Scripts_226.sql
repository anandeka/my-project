Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('pledgeTransfer', 'Pledge', 1, NULL, 'Y', 
    'N', NULL);

Insert into ADM_ACTION_DOCUMENT_MASTER
   (ADM_ID, ACTION_ID, DOC_ID, IS_DELETED)
 Values
   ('ADM-GEPD-1', 'pledgeTransfer', 'pledgeTransfer', 'N');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('GEPD_KEY_1', 'Pledge', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('GEPD_KEY_2', 'Pledge', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');


declare
fetchqry clob :='INSERT INTO gepd_d
            (internal_doc_ref_no, pledge_cp_name, pledge_person_in_charge,
             pledge_activity_date, product, quality, supplier_name,
             contract_ref_no, supplier_person_in_charge, supplier_ref_no,
             pledge_gmr_ref_no, element_name, corporate_name,
             our_person_in_charge, corporate_id, logo_path)
   SELECT ?, pledgephd.companyname AS pledge_cp_name,
          '' AS pledge_person_in_charge,
          TO_CHAR (gepd.activity_date, ''dd-Mon-yyyy'') AS pledge_activity_date,
          productquality.pname AS product, productquality.qname AS quality,
          supplierphd.companyname AS supplier_name,
          pcm.contract_ref_no AS contract_ref_no,
          (gab.firstname || '' '' || gab.lastname
          ) AS supplier_person_in_charge,
          (SELECT sd.bl_no
             FROM sd_shipment_detail sd
            WHERE sd.internal_gmr_ref_no =
                                     gepd.pledge_input_gmr
           UNION
           SELECT wrd.warehouse_receipt_no
             FROM wrd_warehouse_receipt_detail wrd
            WHERE wrd.internal_gmr_ref_no =
                                     gepd.pledge_input_gmr)
                                                           AS supplier_ref_no,
          gmr.gmr_ref_no AS pledge_gmr_ref_no,
          aml.attribute_name AS element_name,
          akc.corporate_name AS corporate_name,
          (akgab.firstname || '' '' || akgab.lastname
          ) AS our_person_in_charge, pcm.corporate_id AS corporate_id,
          akl.corporate_image AS logo_path
     FROM gepd_gmr_element_pledge_detail gepd,
          gmr_goods_movement_record gmr,
          pcm_physical_contract_main pcm,
          aml_attribute_master_list aml,
          phd_profileheaderdetails supplierphd,
          phd_profileheaderdetails pledgephd,
          gab_globaladdressbook gab,
          gab_globaladdressbook akgab,
          ak_corporate akc,
          ak_corporate_logo akl,
          ak_corporate_user aku,
          (SELECT   stragg (qat.quality_name) AS qname,
                    pdm.product_desc AS pname,
                    grd.internal_gmr_ref_no AS int_gmr
               FROM qat_quality_attributes qat,
                    grd_goods_record_detail grd,
                    pdm_productmaster pdm
              WHERE grd.quality_id = qat.quality_id
                AND grd.product_id = pdm.product_id
                AND grd.is_deleted = ''N''
                AND grd.status = ''Active''
           GROUP BY grd.internal_gmr_ref_no, pdm.product_desc) productquality
    WHERE gepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
      AND productquality.int_gmr = gmr.internal_gmr_ref_no
      AND gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
      AND gepd.element_id = aml.attribute_id
      AND pcm.cp_id = supplierphd.profileid
      AND gepd.pledge_cp_id = pledgephd.profileid
      AND pcm.corporate_id = akc.corporate_id
      AND akc.corporate_id = akl.corporate_id
      AND pcm.cp_person_in_charge_id = gab.gabid(+)
      AND pcm.our_person_in_charge_id = aku.user_id(+)
      AND aku.gabid = akgab.gabid(+)
      AND gmr.is_deleted = ''N''
      AND gepd.is_active = ''Y''
      AND gepd.internal_gmr_ref_no = ? ';

begin

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-GEPD-1', 'pledgeTransfer', 'Pledge', 'pledgeTransfer', 1, 
    fetchqry ,'N');
end;

    
