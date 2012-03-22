

/****************************************************************************************
Fetch Qury Needs To be Inserted Manually For DGM_ID = 'DGM-GEPD-1' 
*******************************************************************************************/

INSERT INTO gepd_d
            (internal_doc_ref_no, pledge_cp_name, pledge_person_in_charge,
             pledge_activity_date, product, quality, supplier_name,
             contract_ref_no, supplier_person_in_charge, supplier_ref_no,
             pledge_gmr_ref_no, element_name, corporate_name,
             our_person_in_charge, corporate_id, logo_path)
   select ?, 
 pledgephd.companyname as pledge_cp_name,
 '' as pledge_person_in_charge,
 to_char(gepd.activity_date, 'dd-Mon-yyyy') as pledge_activity_date,
 productquality.pname as product,
 productquality.qname as quality,
 supplierphd.companyname as supplier_name,
 pcm.contract_ref_no as contract_ref_no,
 (gab.firstname || ' ' || gab.lastname) as supplier_person_in_charge,
 (select sd.bl_no
    from sd_shipment_detail sd
   where sd.internal_gmr_ref_no = gepd.pledge_input_gmr
  union
  select wrd.warehouse_receipt_no
    from wrd_warehouse_receipt_detail wrd
   where wrd.internal_gmr_ref_no = gepd.pledge_input_gmr) as supplier_ref_no,
 gmr.gmr_ref_no as pledge_gmr_ref_no,
 aml.attribute_name as element_name,
 akc.corporate_name as corporate_name,
 (akgab.firstname || ' ' || akgab.lastname) as our_person_in_charge,
 pcm.corporate_id as corporate_id,
 akl.corporate_image as logo_path
  from gepd_gmr_element_pledge_detail gepd,
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
       (select stragg(qat.quality_name) as qname,
               pdm.product_desc as pname,
               grd.internal_gmr_ref_no as int_gmr
          from qat_quality_attributes  qat,
               grd_goods_record_detail grd,
               pdm_productmaster       pdm
         where grd.quality_id = qat.quality_id
           and grd.product_id = pdm.product_id
           and grd.is_deleted = 'N'
           and grd.status = 'Active'
         group by grd.internal_gmr_ref_no,
                  pdm.product_desc) productquality
 where gepd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
   and productquality.int_gmr = gepd.pledge_input_gmr
   and gmr.internal_contract_ref_no = pcm.internal_contract_ref_no
   and gepd.element_id = aml.attribute_id
   and pcm.cp_id = supplierphd.profileid
   and gepd.pledge_cp_id = pledgephd.profileid
   and pcm.corporate_id = akc.corporate_id
   and akc.corporate_id = akl.corporate_id
   and pcm.cp_person_in_charge_id = gab.gabid(+)
   and pcm.our_person_in_charge_id = aku.user_id(+)
   and aku.gabid = akgab.gabid(+)
   and gmr.is_deleted = 'N'
   and gepd.is_active = 'Y'
   and gepd.internal_gmr_ref_no = ?