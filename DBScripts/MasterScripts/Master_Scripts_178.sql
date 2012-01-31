
Insert into DM_DOCUMENT_MASTER
   (DOC_ID, DOC_NAME, DISPLAY_ORDER, VERSION, IS_ACTIVE, 
    IS_DELETED, ACTIVITY_ID)
 Values
   ('CREATE_PFD', 'Price Fixation', 1, NULL, 'Y', 
    'N', NULL);

Insert into ADM_ACTION_DOCUMENT_MASTER
   (ADM_ID, ACTION_ID, DOC_ID, IS_DELETED)
 Values
   ('ADM-PFD-1', 'CREATE_PRICE_FIXATION', 'CREATE_PFD', 'N');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('PFD_KEY_1', 'Price Fixation', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DKM_DOC_REF_KEY_MASTER
   (DOC_KEY_ID, DOC_KEY_DESC, VALIDATION_QUERY)
 Values
   ('PFD_KEY_2', 'Price Fixation', 'SELECT COUNT (*) FROM DS_DOCUMENT_SUMMARY ds WHERE DS.DOC_REF_NO = :pc_document_ref_no AND DS.CORPORATE_ID = :pc_corporate_id');

Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-PFD-1', 'CREATE_PFD', 'Price Fixation', 'CREATE_PRICE_FIXATION', 1, 
    'Insert into PFD_D
   (INTERNAL_DOC_REF_NO, CORPORATE_NAME, CP_ADDRESS, CP_CITY, CP_COUNTRY, 
    CP_ZIP, CP_STATE, CP_NAME, CP_PERSON_IN_CHARGE, CONTRACT_TYPE, 
    CONTRACT_REF_NO, DELIVERY_ITEM_REF_NO, PAY_IN_CURRENCY, PRODUCT, QUALITY, 
    ELEMENT_NAME, PRICING_FORMULA, QUOTA_PERIOD, GMR_REF_NO, QP, 
    CURRENCY_PRODUCT, QUANTITY_UNIT)
 Values
   select ?,ak.corporate_name AS CORPORATE_NAME,
       PAD.ADDRESS as CP_ADDRESS,
       CIM.CITY_NAME as CP_CITY,
       CYM.COUNTRY_NAME as CP_COUNTRY,
       PAD.ZIP as CP_ZIP,
       SM.STATE_NAME as CP_STATE,
       phd.companyname AS CP_NAME,
       gab.firstname || ' ' || gab.lastname AS CP_PERSON_IN_CHARGE,
       pcm.contract_type as CONTRACT_TYPE,
       pcm.contract_ref_no AS CONTRACT_REF_NO,
       (pcm.contract_ref_no || '-' || pcdi.delivery_item_no) AS DELIVERY_ITEM_REF_NO,
       cm.cur_code as PAY_IN_CURRENCY,
       pdm.product_desc as PRODUCT,
       (case
         when pocd.qp_period_type = 'Event' then
          (SELECT stragg(gmrquality.quality_name) AS quality_name
             FROM (SELECT DISTINCT qat.quality_name,
                                   pci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
                                   gmr_in.internal_gmr_ref_no as internal_gmr_ref_no
                     FROM gmr_goods_movement_record  gmr_in,
                          grd_goods_record_detail    grd,
                          pci_physical_contract_item pci,
                          pcpq_pc_product_quality    pcpq,
                          qat_quality_attributes     qat
                    WHERE gmr_in.internal_gmr_ref_no = grd.internal_gmr_ref_no
                      AND grd.internal_contract_item_ref_no =
                          pci.internal_contract_item_ref_no
                      AND pcpq.quality_template_id = qat.quality_id
                      AND pci.pcpq_id = pcpq.pcpq_id
                      AND pcpq.is_active = 'Y'
                      AND gmr_in.is_deleted = 'N'
                      AND grd.is_deleted = 'N'
                      AND grd.status = 'Active'
                      AND pci.is_active = 'Y'
                   UNION ALL
                   SELECT DISTINCT qat.quality_name,
                                   pci.internal_contract_item_ref_no AS internal_contract_item_ref_no,
                                   gmr_in.internal_gmr_ref_no as internal_gmr_ref_no
                     FROM gmr_goods_movement_record  gmr_in,
                          dgrd_delivered_grd         grd,
                          pci_physical_contract_item pci,
                          pcpq_pc_product_quality    pcpq,
                          qat_quality_attributes     qat
                    WHERE gmr_in.internal_gmr_ref_no = grd.internal_gmr_ref_no
                      AND grd.internal_contract_item_ref_no =
                          pci.internal_contract_item_ref_no
                      AND pcpq.quality_template_id = qat.quality_id
                      AND pci.pcpq_id = pcpq.pcpq_id
                      AND pcpq.is_active = 'Y'
                      AND gmr_in.is_deleted = 'N'
                      AND grd.status = 'Active'
                      AND pci.is_active = 'Y'                   
                   ) gmrquality
            where gmrquality.internal_gmr_ref_no = gmr.internal_gmr_ref_no
            GROUP BY gmrquality.internal_contract_item_ref_no,
                     gmrquality.internal_gmr_ref_no)
         else
          (SELECT stragg(qat.quality_name) AS quality_name
             FROM qat_quality_attributes    qat,
                  pcdiqd_di_quality_details pcdiqd,
                  pcdi_pc_delivery_item     pcdi_in,
                  pcpq_pc_product_quality   pcpq
            WHERE pcdiqd.pcpq_id = pcpq.pcpq_id
              AND pcdiqd.pcdi_id = pcdi_in.pcdi_id
              AND pcdiqd.is_active = 'Y'
              AND pcpq.is_active = 'Y'
              AND pcpq.quality_template_id = qat.quality_id
              AND pcdi_in.pcdi_id = pcdi.pcdi_id
            GROUP BY pcdi_in.pcdi_id)
       end) as QUALITY,
       aml.attribute_name as ELEMENT_NAME,
       (pcbpd.qty_to_be_priced || '% of ' || (CASE
         WHEN pcbpd.price_basis = 'Formula' THEN
          ppfh.formula_name
         WHEN pcbpd.price_basis = 'Index' THEN
         
          (select dim.instrument_name
             from dim_der_instrument_master      dim,
                  ppfd_phy_price_formula_details ppfd
            where dim.instrument_id = ppfd.instrument_id
              and ppfd.is_active = 'Y'
              AND ppfh.ppfh_id = ppfd.ppfh_id)
       
       END) || (case
         when pocd.qp_period_type = 'Event' then
          ', ' || pfqpp.no_of_event_months || ' ' || pfqpp.event_name
       end)) AS PRICING_FORMULA,
       (CASE
         WHEN pcdi.delivery_period_type = 'Month' THEN
          CASE
         WHEN pcdi.delivery_from_month = pcdi.delivery_to_month AND
              pcdi.delivery_from_year = pcdi.delivery_to_year THEN
          pcdi.delivery_from_month || ' ' || pcdi.delivery_from_year
         ELSE
          pcdi.delivery_from_month || ' ' || pcdi.delivery_from_year ||
          ' To ' || pcdi.delivery_to_month || ' ' || pcdi.delivery_to_year
       END ELSE CASE
          WHEN TO_CHAR(pcdi.delivery_from_date, 'dd-Mon-YYYY') =
               TO_CHAR(pcdi.delivery_to_date, 'dd-Mon-YYYY') THEN
           TO_CHAR(pcdi.delivery_from_date, 'dd-Mon-YYYY')
          ELSE
           TO_CHAR(pcdi.delivery_from_date, 'dd-Mon-YYYY') || ' To ' ||
           TO_CHAR(pcdi.delivery_to_date, 'dd-Mon-YYYY')
        END END) AS QUOTA_PERIOD,
       gmr.gmr_ref_no as GMR_REF_NO,
       (to_char(POFH.QP_START_DATE, 'dd-Mon-YYYY') || ' to ' ||
       to_char(POFH.QP_END_DATE, 'dd-Mon-YYYY')) as QP,
       pdm_curr.product_desc as CURRENCY_PRODUCT,
       qum.qty_unit as QUANTITY_UNIT
  FROM pfd_price_fixation_details     pfd,
       pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       poch_price_opt_call_off_header poch,
       pcdi_pc_delivery_item          pcdi,
       pcm_physical_contract_main     pcm,
       pcpd_pc_product_definition     pcpd,
       pdm_productmaster              pdm,
       ak_corporate                   ak,
       cm_currency_master             cm,
       phd_profileheaderdetails       phd,
       pad_profile_addresses          pad,
       CYM_COUNTRYMASTER              cym,
       CIM_CITYMASTER                 cim,
       SM_STATE_MASTER                sm,
       qum_quantity_unit_master       qum,
       gab_globaladdressbook          gab,
       GMR_GOODS_MOVEMENT_RECORD      gmr,
       pcbpd_pc_base_price_detail     pcbpd,
       pffxd_phy_formula_fx_details   pffxd,
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       pdm_productmaster              pdm_curr,
       aml_attribute_master_list      aml
 WHERE pfd.pofh_id = pofh.pofh_id
   AND pofh.pocd_id = pocd.pocd_id
   AND pocd.poch_id = poch.poch_id
   AND poch.pcdi_id = pcdi.pcdi_id
   AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
   AND pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
   AND pcpd.product_id = pdm.product_id
   AND pcm.corporate_id = ak.corporate_id
   AND pcm.invoice_currency_id = cm.cur_id
   AND pcm.cp_id = phd.profileid
   and PHD.PROFILEID = PAD.PROFILE_ID
   and PAD.COUNTRY_ID = CYM.COUNTRY_ID
   and PAD.CITY_ID = CIM.CITY_ID(+)
   and PAD.STATE_ID = SM.STATE_ID(+)
   AND pcm.cp_person_in_charge_id = gab.gabid(+)
   and POFH.INTERNAL_GMR_REF_NO = GMR.INTERNAL_GMR_REF_NO(+)
   and pocd.qty_to_be_fixed_unit_id = qum.qty_unit_id
   AND pocd.pcbpd_id = pcbpd.pcbpd_id
   AND pcbpd.pcbpd_id = ppfh.pcbpd_id
   and pcbpd.pffxd_id = pffxd.pffxd_id
   and pffxd.currency_pair_instrument = pdm_curr.product_id(+)
   and pocd.element_id = aml.attribute_id(+)
   and pfqpp.ppfh_id = ppfh.ppfh_id
   and pcbpd.is_active = 'Y'
   and ppfh.is_active = 'Y'
   AND ppfh.ppfh_id = pfqpp.ppfh_id
   and pfd.pfd_id = ?','N');
    
 Insert into DGM_DOCUMENT_GENERATION_MASTER
   (DGM_ID, DOC_ID, DOC_NAME, ACTIVITY_ID, SEQUENCE_ORDER, 
    FETCH_QUERY, IS_CONCENTRATE)
 Values
   ('DGM-PFD-2', 'CREATE_PFD', 'Price Fixation', 'CREATE_PRICE_FIXATION', 2, 
    'Insert into PFD_CHILD_D
   (PFD_ID, INTERNAL_DOC_REF_NO, PRICE_FIXATION_REF_NO, PRICE, PRICE_UNIT, 
    PRICE_FIXATION_DATE, PRICED_QUANTITY, FX_RATE, PRICE_TYPE)
    Values 
    select pfd.pfd_id as PFD_ID, ? ,
       axs.action_ref_no as PRICE_FIXATION_REF_NO,
       PFD.USER_PRICE as PRICE,
       PUM.PRICE_UNIT_NAME as PRICE_UNIT,
       TO_CHAR(PFD.AS_OF_DATE, ''dd-Mon-YYYY'') as PRICE_FIXATION_DATE,
       PFD.QTY_FIXED as PRICED_QUANTITY,
       PFD.FX_RATE as FX_RATE,
       (case
         when pocd.IS_ANY_DAY_PRICING = ''Y'' and pfqpp.is_spot_pricing = ''Y'' then
          ''Spot''
         when pocd.IS_ANY_DAY_PRICING = ''Y'' then
          ''Price By Request''
         else
          (case
         when pfd.is_delta_pricing = ''Y'' then
          ''Spot''
         else
          ''Average''
       end) end) as PRICE_TYPE
  from pfd_price_fixation_details     pfd,
       pofh_price_opt_fixation_header pofh,
       pocd_price_option_calloff_dtls pocd,
       ppfh_phy_price_formula_header  ppfh,
       pfqpp_phy_formula_qp_pricing   pfqpp,
       PPU_PRODUCT_PRICE_UNITS        ppu,
       PUM_PRICE_UNIT_MASTER          pum,
       pfam_price_fix_action_mapping  pfam,
       axs_action_summary             axs
 where pfd.pofh_id = pofh.pofh_id
   AND pofh.pocd_id = pocd.pocd_id
   and pocd.pricing_formula_id = ppfh.ppfh_id
   and ppfh.ppfh_id = pfqpp.ppfh_id
   and pfam.internal_action_ref_no = axs.internal_action_ref_no
   AND pfd.pfd_id = pfam.pfd_id
   and PFD.PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID
   and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
   AND pfd.is_active = ''Y''
   and pfam.is_active = ''Y''
   AND pfd.pfd_id = ? ','N');    