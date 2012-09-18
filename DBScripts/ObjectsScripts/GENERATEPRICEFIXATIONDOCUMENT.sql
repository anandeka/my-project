CREATE OR REPLACE PROCEDURE "GENERATEPRICEFIXATIONDOCUMENT"(p_pfd_id         VARCHAR2,
                                                                           p_docrefno       VARCHAR2,
                                                                           p_activity_id    VARCHAR2,
                                                                           p_doc_issue_date VARCHAR2) IS

  corporate_name        VARCHAR2(100);
  cp_address            VARCHAR2(100);
  cp_city               VARCHAR2(100);
  cp_country            VARCHAR2(100);
  cp_zip                VARCHAR2(100);
  cp_state              VARCHAR2(100);
  cp_name               VARCHAR2(100);
  cp_person_in_charge   VARCHAR2(100);
  contract_type         VARCHAR2(30);
  contract_ref_no       VARCHAR2(30);
  delivery_item_ref_no  VARCHAR2(80);
  pay_in_currency       VARCHAR2(15);
  product               VARCHAR2(100);
  quality               VARCHAR2(200);
  element_name          VARCHAR2(30);
  pricing_formula       VARCHAR2(200);
  quota_period          VARCHAR2(50);
  gmr_ref_no            VARCHAR2(30);
  qp                    VARCHAR2(50);
  currency_product      VARCHAR2(30);
  quantity_unit         VARCHAR2(30);
  price_type            VARCHAR2(20);
  p_pofh_id             VARCHAR2(20);
  is_delta_pricing      VARCHAR2(10);
  purchase_sales        VARCHAR2(30);
  is_payin_pricing_same VARCHAR2(10);

BEGIN

  select ak.corporate_name,
         PAD.ADDRESS,
         CIM.CITY_NAME,
         CYM.COUNTRY_NAME,
         PAD.ZIP,
         SM.STATE_NAME,
         phd.companyname,
         gab.firstname || ' ' || gab.lastname,
         pcm.contract_type,
         pcm.contract_ref_no,
         (pcm.contract_ref_no || '-' || pcdi.delivery_item_no),
         cm.cur_code,
         pdm.product_desc,
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
                      WHERE gmr_in.internal_gmr_ref_no =
                            grd.internal_gmr_ref_no
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
                      WHERE gmr_in.internal_gmr_ref_no =
                            grd.internal_gmr_ref_no
                        AND grd.internal_contract_item_ref_no =
                            pci.internal_contract_item_ref_no
                        AND pcpq.quality_template_id = qat.quality_id
                        AND pci.pcpq_id = pcpq.pcpq_id
                        AND pcpq.is_active = 'Y'
                        AND gmr_in.is_deleted = 'N'
                        AND grd.status = 'Active'
                        AND pci.is_active = 'Y') gmrquality
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
         end),
         aml.attribute_name,
         (pcbpd.qty_to_be_priced || '% of ' || (CASE
           WHEN pcbpd.price_basis = 'Formula' THEN
            ppfh.formula_name || ' - ' ||
            (SELECT stragg(dim.instrument_name || ' - ' ||
                           PS.PRICE_SOURCE_NAME || ' ' || PP.PRICE_POINT_NAME || ' ' ||
                           APM.AVAILABLE_PRICE_DISPLAY_NAME)
               FROM dim_der_instrument_master      dim,
                    ppfd_phy_price_formula_details ppfd,
                    PP_PRICE_POINT                 pp,
                    PS_PRICE_SOURCE                ps,
                    APM_AVAILABLE_PRICE_MASTER     apm
              WHERE dim.instrument_id = ppfd.instrument_id
                AND ppfd.is_active = 'Y'
                AND ppfh.ppfh_id = ppfd.ppfh_id
                and PPFD.PRICE_POINT_ID = PP.PRICE_POINT_ID(+)
                and PPFD.PRICE_SOURCE_ID = PS.PRICE_SOURCE_ID
                and PPFD.AVAILABLE_PRICE_TYPE_ID = APM.AVAILABLE_PRICE_ID
              group by ppfh.ppfh_id)
           WHEN pcbpd.price_basis = 'Index' THEN
            (SELECT dim.instrument_name || ' - ' || PS.PRICE_SOURCE_NAME || ' ' ||
                    PP.PRICE_POINT_NAME || ' ' ||
                    APM.AVAILABLE_PRICE_DISPLAY_NAME
               FROM dim_der_instrument_master      dim,
                    ppfd_phy_price_formula_details ppfd,
                    PP_PRICE_POINT                 pp,
                    PS_PRICE_SOURCE                ps,
                    APM_AVAILABLE_PRICE_MASTER     apm
              WHERE dim.instrument_id = ppfd.instrument_id
                AND ppfd.is_active = 'Y'
                AND ppfh.ppfh_id = ppfd.ppfh_id
                and PPFD.PRICE_POINT_ID = PP.PRICE_POINT_ID(+)
                and PPFD.PRICE_SOURCE_ID = PS.PRICE_SOURCE_ID
                and PPFD.AVAILABLE_PRICE_TYPE_ID = APM.AVAILABLE_PRICE_ID)
         END) || (CASE
           WHEN pocd.qp_period_type = 'Event' THEN
            ', ' || pfqpp.no_of_event_months || ' ' || pfqpp.event_name
         END)),
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
          END END),
         gmr.gmr_ref_no,
         (to_char(POFH.QP_START_DATE, 'dd-Mon-YYYY') || ' to ' ||
         to_char(POFH.QP_END_DATE, 'dd-Mon-YYYY')),
         pdm_curr.product_desc,
         qum.qty_unit,
         (CASE
           WHEN pcm.is_tolling_contract = 'Y' THEN
            CASE
           WHEN pcm.purchase_sales = 'P' THEN
            'Sell Tolling'
           ELSE
            'Buy Tolling'
         END ELSE CASE
            WHEN pcm.purchase_sales = 'P' THEN
             'Purchase'
            ELSE
             'Sales'
          END END),
         (CASE
           WHEN pocd.pay_in_cur_id = pocd.pricing_cur_id THEN
            'Y'
           ELSE
            'N'
         END)
    INTO corporate_name,
         cp_address,
         cp_city,
         cp_country,
         cp_zip,
         cp_state,
         cp_name,
         cp_person_in_charge,
         contract_type,
         contract_ref_no,
         delivery_item_ref_no,
         pay_in_currency,
         product,
         quality,
         element_name,
         pricing_formula,
         quota_period,
         gmr_ref_no,
         qp,
         currency_product,
         quantity_unit,
         purchase_sales,
         is_payin_pricing_same
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
     AND PCPD.INPUT_OUTPUT = 'Input'
     AND pcm.corporate_id = ak.corporate_id
     AND pcm.invoice_currency_id = cm.cur_id
     AND pcm.cp_id = phd.profileid
     and PHD.PROFILEID = PAD.PROFILE_ID(+)
     and PAD.COUNTRY_ID = CYM.COUNTRY_ID(+)
     and PAD.CITY_ID = CIM.CITY_ID(+)
     and PAD.STATE_ID = SM.STATE_ID(+)
     and PAD.ADDRESS_TYPE(+) = 'Main'
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
     and pfd.pfd_id = p_pfd_id;

  Insert into PFD_D
    (INTERNAL_DOC_REF_NO,
     CORPORATE_NAME,
     CP_ADDRESS,
     CP_CITY,
     CP_COUNTRY,
     CP_ZIP,
     CP_STATE,
     CP_NAME,
     CP_PERSON_IN_CHARGE,
     CONTRACT_TYPE,
     CONTRACT_REF_NO,
     DELIVERY_ITEM_REF_NO,
     PAY_IN_CURRENCY,
     PRODUCT,
     QUALITY,
     ELEMENT_NAME,
     PRICING_FORMULA,
     QUOTA_PERIOD,
     GMR_REF_NO,
     QP,
     CURRENCY_PRODUCT,
     QUANTITY_UNIT,
     DOC_ISSUE_DATE,
     PURCHASE_SALES)
  VALUES
    (p_docrefno,
     corporate_name,
     cp_address,
     cp_city,
     cp_country,
     cp_zip,
     cp_state,
     cp_name,
     cp_person_in_charge,
     contract_type,
     contract_ref_no,
     delivery_item_ref_no,
     pay_in_currency,
     product,
     quality,
     element_name,
     pricing_formula,
     quota_period,
     gmr_ref_no,
     qp,
     currency_product,
     quantity_unit,
     p_doc_issue_date,
     purchase_sales);

  /** Check if delta pricing exist for that pfd  */
  select nvl(pfd.is_delta_pricing, 'N')
    into is_delta_pricing
    from pfd_price_fixation_details pfd
   where pfd.pfd_id = p_pfd_id;

  /** Get the price type and based on that insert into child  */
  select (case
           when pocd.IS_ANY_DAY_PRICING = 'Y' and
                pfqpp.is_spot_pricing = 'Y' then
            'Spot'
           when pocd.IS_ANY_DAY_PRICING = 'Y' then
            'Price By Request'
           else
            (case
           when pfd.is_delta_pricing = 'Y' then
            'Spot'
           else
            'Average'
         end) end),
         pfd.pofh_id
    into price_type, p_pofh_id
    from pfd_price_fixation_details     pfd,
         pofh_price_opt_fixation_header pofh,
         pocd_price_option_calloff_dtls pocd,
         ppfh_phy_price_formula_header  ppfh,
         pfqpp_phy_formula_qp_pricing   pfqpp
   where pfd.pofh_id = pofh.pofh_id
     AND pofh.pocd_id = pocd.pocd_id
     and pocd.pricing_formula_id = ppfh.ppfh_id
     and ppfh.ppfh_id = pfqpp.ppfh_id
     and pfd.pfd_id = p_pfd_id;

  if (price_type = 'Average' and is_delta_pricing = 'N') then
  
    Insert into PFD_CHILD_D
      (PFD_ID,
       INTERNAL_DOC_REF_NO,
       PRICE_FIXATION_REF_NO,
       PRICE,
       PRICE_UNIT,
       PRICE_FIXATION_DATE,
       PRICED_QUANTITY,
       FX_RATE,
       PRICE_TYPE)
      (select pfd.pfd_id as PFD_ID,
              p_docrefno,
              axs.action_ref_no as PRICE_FIXATION_REF_NO,
              PFD.USER_PRICE as PRICE,
              PUM.PRICE_UNIT_NAME as PRICE_UNIT,
              TO_CHAR(PFD.AS_OF_DATE, 'dd-Mon-YYYY') as PRICE_FIXATION_DATE,
              PFD.QTY_FIXED as PRICED_QUANTITY,
              (case
                when is_payin_pricing_same = 'Y' then
                 '1'
                else
                 PFD.FX_RATE || ''          
              end) as FX_RATE,
              price_type
         from pfd_price_fixation_details     pfd,
              pofh_price_opt_fixation_header pofh,
              PPU_PRODUCT_PRICE_UNITS        ppu,
              PUM_PRICE_UNIT_MASTER          pum,
              pfam_price_fix_action_mapping  pfam,
              axs_action_summary             axs
        where pfd.pofh_id = pofh.pofh_id
          and pfam.internal_action_ref_no = axs.internal_action_ref_no
          AND pfd.pfd_id = pfam.pfd_id
          and PFD.PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID
          and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
          AND pfd.is_active = 'Y'
          and pfam.is_active = 'Y'
          and (pfd.is_delta_pricing is null or pfd.is_delta_pricing != 'Y')
          AND pofh.pofh_id = p_pofh_id);
  
  else
    Insert into PFD_CHILD_D
      (PFD_ID,
       INTERNAL_DOC_REF_NO,
       PRICE_FIXATION_REF_NO,
       PRICE,
       PRICE_UNIT,
       PRICE_FIXATION_DATE,
       PRICED_QUANTITY,
       FX_RATE,
       PRICE_TYPE)
      (select pfd.pfd_id as PFD_ID,
              p_docrefno,
              axs.action_ref_no as PRICE_FIXATION_REF_NO,
              PFD.USER_PRICE as PRICE,
              PUM.PRICE_UNIT_NAME as PRICE_UNIT,
              TO_CHAR(PFD.AS_OF_DATE, 'dd-Mon-YYYY') as PRICE_FIXATION_DATE,
              PFD.QTY_FIXED as PRICED_QUANTITY,
              (case
                when is_payin_pricing_same = 'Y' then
                 '1'
                else
                 PFD.FX_RATE || ''
              end) as FX_RATE,
              price_type
         from pfd_price_fixation_details    pfd,
              PPU_PRODUCT_PRICE_UNITS       ppu,
              PUM_PRICE_UNIT_MASTER         pum,
              pfam_price_fix_action_mapping pfam,
              axs_action_summary            axs
        where pfd.pfd_id = pfam.pfd_id
          and pfam.internal_action_ref_no = axs.internal_action_ref_no
          and PFD.PRICE_UNIT_ID = PPU.INTERNAL_PRICE_UNIT_ID
          and PPU.PRICE_UNIT_ID = PUM.PRICE_UNIT_ID
          AND pfd.is_active = 'Y'
          and pfam.is_active = 'Y'
          AND pfd.pfd_id = p_pfd_id);
  
  end if;

END;
/
