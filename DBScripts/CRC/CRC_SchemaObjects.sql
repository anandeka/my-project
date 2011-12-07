define APP_SCHEMA=TRAXYS_AUTOMATION_APP.


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_strategy (strategy_id,
                                             strategy_name,
                                             description,
                                             strategy_def_id,
                                             corporate_id,
                                             display_order,
                                             VERSION,
                                             is_active,
                                             is_deleted
                                            )
AS
   SELECT "STRATEGY_ID", "STRATEGY_NAME", "DESCRIPTION", "STRATEGY_DEF_ID",
          "CORPORATE_ID", "DISPLAY_ORDER", "VERSION", "IS_ACTIVE",
          "IS_DELETED"
     FROM &APP_SCHEMA.css_corporate_strategy_setup
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_quantity (qty_unit_id,
                                             qty_unit,
                                             unit_type,
                                             is_derrived,
                                             decimals,
                                             display_order,
                                             VERSION,
                                             is_active,
                                             is_deleted
                                            )
AS
   SELECT "QTY_UNIT_ID", "QTY_UNIT", "UNIT_TYPE", "IS_DERRIVED", "DECIMALS",
          "DISPLAY_ORDER", "VERSION", "IS_ACTIVE", "IS_DELETED"
     FROM &APP_SCHEMA.qum_quantity_unit_master
    WHERE is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_profit_center (profit_center_id,
                                                  profit_center_name,
                                                  profit_center_short_name,
                                                  corporateid
                                                 )
AS
   SELECT cpc.profit_center_id, cpc.profit_center_name,
          cpc.profit_center_short_name, cpc.corporateid
     FROM &APP_SCHEMA.cpc_corporate_profit_center cpc,
          &APP_SCHEMA.ak_corporate ak
    WHERE cpc.corporateid = ak.corporate_id AND cpc.is_active = 'Y'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_products_qualities (quality_id,
                                                       quality_name,
                                                       product_id,
                                                       product_desc
                                                      )
AS
   SELECT   qat.quality_id,
            (pdm.product_desc || ' / ' || qat.quality_name) quality_name,
            pdm.product_id, pdm.product_desc
       FROM &APP_SCHEMA.qat_quality_attributes qat,
            &APP_SCHEMA.pdm_productmaster pdm
      WHERE qat.product_id = pdm.product_id AND pdm.is_active = 'Y'
   ORDER BY (pdm.product_desc || ' / ' || qat.quality_name)
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_product (product_id,
                                            product_desc,
                                            corporate_id
                                           )
AS
   SELECT DISTINCT pdm.product_id, pdm.product_desc, cpm.corporate_id
              FROM &APP_SCHEMA.cpm_corporateproductmaster cpm,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   &APP_SCHEMA.utp_user_tradable_products utp,
                   &APP_SCHEMA.ak_corporate ak
             WHERE cpm.product_id = pdm.product_id
               AND pdm.product_id = utp.product_id
               AND cpm.corporate_id = ak.corporate_id
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_price_months (price_month_id,
                                                 price_month_name,
                                                 period_year
                                                )
AS
   SELECT   "PRICE_MONTH_ID", "PRICE_MONTH_NAME", "PERIOD_YEAR"
       FROM (SELECT DISTINCT (piip.period_month || ' ' || piip.period_year
                             ) price_month_id,
                             (piip.period_month || ' ' || piip.period_year
                             ) price_month_name,
                             piip.period_year
                        FROM &APP_SCHEMA.piip_phy_item_index_pricing piip
                       WHERE piip.period_month IS NOT NULL
                         AND piip.period_year IS NOT NULL
             UNION
             SELECT DISTINCT (   TO_CHAR (TO_DATE (phy.delivery_date,
                                                   'dd-Mon-yyyy'
                                                  ),
                                          'Mon'
                                         )
                              || ' '
                              || TO_CHAR (TO_DATE (phy.delivery_date,
                                                   'dd-Mon-yyyy'
                                                  ),
                                          'yyyy'
                                         )
                             ) price_month_id,
                             (   TO_CHAR (TO_DATE (phy.delivery_date,
                                                   'dd-Mon-yyyy'
                                                  ),
                                          'Mon'
                                         )
                              || ' '
                              || TO_CHAR (TO_DATE (phy.delivery_date,
                                                   'dd-Mon-yyyy'
                                                  ),
                                          'yyyy'
                                         )
                             ) price_month_name,
                             TO_CHAR
                                    (TO_DATE (phy.delivery_date,
                                              'dd-Mon-yyyy'),
                                     'yyyy'
                                    ) period_year
                        FROM v_list_of_physical_trades phy
                       WHERE phy.delivery_date IS NOT NULL) flds
   ORDER BY flds.period_year
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_price (price_unit_id, price_unit_name)
AS
   SELECT pum.price_unit_id, pum.price_unit_name
     FROM &APP_SCHEMA.pum_price_unit_master pum
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_period_type (period_type_id,
                                                period_type_name,
                                                period_type_display_name,
                                                equivalent_days,
                                                display_order,
                                                VERSION,
                                                is_active,
                                                is_deleted
                                               )
AS
   SELECT   "PERIOD_TYPE_ID", "PERIOD_TYPE_NAME", "PERIOD_TYPE_DISPLAY_NAME",
            "EQUIVALENT_DAYS", "DISPLAY_ORDER", "VERSION", "IS_ACTIVE",
            "IS_DELETED"
       FROM &APP_SCHEMA.pm_period_master pm
      WHERE pm.is_active = 'Y' AND pm.is_deleted = 'N'
   ORDER BY pm.display_order
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_organization_groups (GROUP_ID,
                                                        group_name,
                                                        display_order
                                                       )
AS
   SELECT gcd.groupid GROUP_ID, gcd.groupname group_name, gcd.display_order
     FROM &APP_SCHEMA.gcd_groupcorporatedetails gcd
    WHERE gcd.is_active = 'Y' AND gcd.is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_instrument_type (instrument_type_id,
                                                    instrument_type
                                                   )
AS
   SELECT irm.instrument_type_id, irm.instrument_type
     FROM &APP_SCHEMA.irm_instrument_type_master irm
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_instrument (instrument_id,
                                               instrument_name,
                                               product_asset_class
                                              )
AS
   SELECT DISTINCT dim.instrument_id, dim.instrument_name,
                   pdm.product_asset_class
              FROM &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.irm_instrument_type_master irm,
                   &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.pdm_productmaster pdm
             WHERE dim.instrument_type_id = irm.instrument_type_id
               AND pdd.product_id = pdm.product_id
               AND dim.is_deleted = 'N'
               AND irm.is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_exchange (exchange_id,
                                             exchange_name,
                                             display_order
                                            )
AS
   SELECT emt.exchange_id, emt.exchange_name, emt.display_order
     FROM &APP_SCHEMA.emt_exchangemaster emt
    WHERE emt.is_active = 'Y'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_derivative_purpose (purpose_id,
                                                       purpose_name,
                                                       purpose_display_name,
                                                       display_order,
                                                       VERSION,
                                                       is_active,
                                                       is_deleted
                                                      )
AS
   SELECT "PURPOSE_ID", "PURPOSE_NAME", "PURPOSE_DISPLAY_NAME",
          "DISPLAY_ORDER", "VERSION", "IS_ACTIVE", "IS_DELETED"
     FROM &APP_SCHEMA.dpm_derivative_purpose_master
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_derivative_instrument (instrument_id,
                                                          instrument_name
                                                         )
AS
   SELECT DISTINCT dim.instrument_id, dim.instrument_name
              FROM &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.irm_instrument_type_master irm,
                   &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   &APP_SCHEMA.pac_product_asset_class pac
             WHERE dim.instrument_type_id = irm.instrument_type_id
               AND pdd.product_id = pdm.product_id
               AND pdm.product_asset_class = pac.asset_id
               AND pac.asset_desc <> 'Currency'
               AND dim.is_deleted = 'N'
               AND irm.is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_derivative_details (dr_id,
                                                       instrument_id,
                                                       price_point_id,
                                                       period_type_id,
                                                       prompt_delivery_calendar_id,
                                                       delivery_period_id,
                                                       prompt_date,
                                                       period_date,
                                                       period_month,
                                                       period_year,
                                                       period_start_date,
                                                       period_end_date,
                                                       strike_price,
                                                       strike_price_unit_id,
                                                       first_notice_date,
                                                       last_notice_date,
                                                       first_tradable_date,
                                                       last_tradable_date,
                                                       expiry_date,
                                                       created_date
                                                      )
AS
   SELECT "DR_ID", "INSTRUMENT_ID", "PRICE_POINT_ID", "PERIOD_TYPE_ID",
          "PROMPT_DELIVERY_CALENDAR_ID", "DELIVERY_PERIOD_ID", "PROMPT_DATE",
          "PERIOD_DATE", "PERIOD_MONTH", "PERIOD_YEAR", "PERIOD_START_DATE",
          "PERIOD_END_DATE", "STRIKE_PRICE", "STRIKE_PRICE_UNIT_ID",
          "FIRST_NOTICE_DATE", "LAST_NOTICE_DATE", "FIRST_TRADABLE_DATE",
          "LAST_TRADABLE_DATE", "EXPIRY_DATE", "CREATED_DATE"
     FROM &APP_SCHEMA.v_cdc_derivative_master
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_currency_trade_def (instrument_id,
                                                       product_desc,
                                                       product_id,
                                                       instrument_display_name,
                                                       instrument_type_id
                                                      )
AS
   SELECT DISTINCT dim.instrument_id, pdm.product_desc, pdm.product_id,
                   irm.instrument_display_name, irm.instrument_type_id
              FROM &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.irm_instrument_type_master irm,
                   &APP_SCHEMA.pac_product_asset_class pac,
                   &APP_SCHEMA.pdm_productmaster pdm
             WHERE dim.product_derivative_id = pdd.derivative_def_id
               AND dim.instrument_type_id = irm.instrument_type_id
               AND pdd.product_id = pdm.product_id
               AND pdm.product_asset_class = pac.asset_id
               AND pac.asset_desc = 'Currency'
               AND dim.is_deleted = 'N'
               AND pdd.is_deleted = 'N'
               AND irm.is_deleted = 'N'
               AND pdm.is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_currency_instrument (instrument_id,
                                                        instrument_display_name,
                                                        instrument_type_id
                                                       )
AS
   SELECT DISTINCT dim.instrument_id, irm.instrument_display_name,
                   irm.instrument_type_id
              FROM &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.irm_instrument_type_master irm
             WHERE dim.instrument_type_id = irm.instrument_type_id
               AND dim.is_deleted = 'N'
               AND irm.is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_currency (cur_id,
                                             cur_code,
                                             cur_name,
                                             is_sub_cur,
                                             decimals,
                                             display_order,
                                             VERSION,
                                             is_active,
                                             is_deleted
                                            )
AS
   SELECT "CUR_ID", "CUR_CODE", "CUR_NAME", "IS_SUB_CUR", "DECIMALS",
          "DISPLAY_ORDER", "VERSION", "IS_ACTIVE", "IS_DELETED"
     FROM &APP_SCHEMA.cm_currency_master
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_countrys (country_id,
                                             country_name,
                                             country_code,
                                             region_id,
                                             display_order,
                                             VERSION,
                                             is_active,
                                             is_deleted
                                            )
AS
   SELECT "COUNTRY_ID", "COUNTRY_NAME", "COUNTRY_CODE", "REGION_ID",
          "DISPLAY_ORDER", "VERSION", "IS_ACTIVE", "IS_DELETED"
     FROM &APP_SCHEMA.cym_countrymaster
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_corp_user_list (user_id,
                                                   username,
                                                   corporate_id
                                                  )
AS
   SELECT aku.user_id, (gab.firstname || ' ' || gab.lastname) username,
          uca.corporate_id
     FROM &APP_SCHEMA.ak_corporate_user aku,
          &APP_SCHEMA.gab_globaladdressbook gab,
          &APP_SCHEMA.uca_user_corporate_access uca
    WHERE aku.user_id = uca.user_id AND aku.gabid = gab.gabid
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_corp_profit_center (profit_center_id,
                                                       corporateid,
                                                       profit_center_name,
                                                       profit_center_short_name,
                                                       display_order,
                                                       VERSION,
                                                       is_active,
                                                       is_deleted
                                                      )
AS
   SELECT "PROFIT_CENTER_ID", "CORPORATEID", "PROFIT_CENTER_NAME",
          "PROFIT_CENTER_SHORT_NAME", "DISPLAY_ORDER", "VERSION", "IS_ACTIVE",
          "IS_DELETED"
     FROM &APP_SCHEMA.cpc_corporate_profit_center
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_corp_products (product_id,
                                                  product_desc,
                                                  user_id,
                                                  corporate_id,
                                                  product_asset_class
                                                 )
AS
   SELECT pdm.product_id, pdm.product_desc, utp.user_id, cpm.corporate_id,
          pdm.product_asset_class
     FROM &APP_SCHEMA.cpm_corporateproductmaster cpm,
          &APP_SCHEMA.pdm_productmaster pdm,
          &APP_SCHEMA.utp_user_tradable_products utp,
          &APP_SCHEMA.pac_product_asset_class pac,
          &APP_SCHEMA.ak_corporate_user aku
    WHERE cpm.product_id = pdm.product_id
      AND pdm.product_id = utp.product_id
      AND utp.user_id = aku.user_id
      AND pdm.product_asset_class = pac.asset_id
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_corp_derivative (derivative_def_id,
                                                    derivative_def_name
                                                   )
AS
   SELECT DISTINCT pdd.derivative_def_id, pdd.derivative_def_name
              FROM &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.dim_der_instrument_master dim
             WHERE dim.product_derivative_id = pdd.derivative_def_id
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_business_partners (bp_id,
                                                      companyname,
                                                      GROUP_ID,
                                                      corporate_id,
                                                      role_type_code
                                                     )
AS
   SELECT bpc.bp_id, phd.companyname, phd.GROUP_ID, bpc.corporate_id,
          bpr.role_type_code
     FROM &APP_SCHEMA.bpc_bp_corporates bpc,
          &APP_SCHEMA.phd_profileheaderdetails phd,
          &APP_SCHEMA.bpr_business_partner_roles bpr
    WHERE bpc.bp_id = phd.profileid
      AND phd.profileid = bpr.profile_id
      AND phd.is_active = 'Y'
      AND bpc.is_deleted = 'N'
      AND phd.is_deleted = 'N'
      AND bpr.is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_broker_account (account_id,
                                                   account_name,
                                                   corporate_id,
                                                   display_order
                                                  )
AS
   SELECT bca.account_id, bca.account_name, bca.corporate_id,
          bca.display_order
     FROM &APP_SCHEMA.bca_broker_clearer_account bca
    WHERE bca.is_active = 'Y'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_qum_quantity_unit (qty_unit_id,
                                                  qty_unit,
                                                  unit_type,
                                                  is_derrived,
                                                  decimals,
                                                  display_order,
                                                  VERSION,
                                                  is_active,
                                                  is_deleted,
                                                  qty_unit_desc
                                                 )
AS
   SELECT "QTY_UNIT_ID", "QTY_UNIT", "UNIT_TYPE", "IS_DERRIVED", "DECIMALS",
          "DISPLAY_ORDER", "VERSION", "IS_ACTIVE", "IS_DELETED",
          "QTY_UNIT_DESC"
     FROM &APP_SCHEMA.qum_quantity_unit_master
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_phy_valuation_details (vtm_id,
                                                      valuation_dr_ids)
AS
   SELECT   ppt.vtm_id,
            &APP_SCHEMA.stragg
               (DISTINCT &APP_SCHEMA.f_get_contract_item_val_dr_id
                   (pcm.corporate_id,
                    ppt.internal_contract_item_ref_no,
                    qat.instrument_id,
                    cpm.exch_valuation_month,
                    cpm.valuation_month_rule,
                    (CASE
                        WHEN cpm.valuation_month_rule = 'Shipment Start Date'
                           THEN pmd.delivery_from_date
                        WHEN cpm.valuation_month_rule = 'Shipment End Date'
                           THEN pmd.delivery_to_date
                        WHEN cpm.valuation_month_rule = 'Shipment Mid Date'
                           THEN (  pmd.delivery_from_date
                                 + (  (  pmd.delivery_to_date
                                       - pmd.delivery_from_date
                                      )
                                    / 2
                                   )
                                )
                        ELSE pmd.delivery_to_date
                     END
                    )
                   )
               ) valuation_dr_ids
       FROM ppt_portfolio_physical_trades ppt,
            &APP_SCHEMA.pcm_physical_contract_main pcm,
            &APP_SCHEMA.cpm_corporateproductmaster cpm,
            &APP_SCHEMA.pmd_physical_multiple_delivery pmd,
            (SELECT pdd.product_id, qat.quality_id, pdd.derivative_def_id,
                    pdd.derivative_def_name, dim.instrument_id,
                    dim.instrument_name, irm.instrument_type_id,
                    irm.instrument_type
               FROM &APP_SCHEMA.qat_quality_attributes qat,
                    &APP_SCHEMA.dim_der_instrument_master dim,
                    &APP_SCHEMA.pdd_product_derivative_def pdd,
                    &APP_SCHEMA.irm_instrument_type_master irm
              WHERE qat.instrument_id = pdd.derivative_def_id
                AND pdd.derivative_def_id = dim.product_derivative_id
                AND dim.instrument_type_id = irm.instrument_type_id
                AND irm.instrument_type = 'Future') qat
      WHERE ppt.product_id = cpm.product_id
        AND pcm.internal_contract_ref_no = ppt.internal_contract_ref_no
        AND ppt.internal_contract_item_ref_no =
                                             pmd.internal_contract_item_ref_no
   GROUP BY ppt.vtm_id
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_phy_commodity_price (internal_contract_item_ref_no,
                                                    internal_contract_ref_no,
                                                    asset,
                                                    asset_class,
                                                    trade_date,
                                                    maturity,
                                                    currency,
                                                    price,
                                                    cur_code,
                                                    product_id,
                                                    product_desc,
                                                    cur_id
                                                   )
AS
   SELECT DISTINCT MAX
                      (pci.internal_contract_item_ref_no
                      ) internal_contract_item_ref_no,
                   MAX (pcm.internal_contract_ref_no)
                                                     internal_contract_ref_no,
                   MAX (pam.asset_desc) asset, 'C' asset_class,
                   pcm.issue_date trade_date,
                   MAX (pmd.delivery_to_date) maturity,
                   MAX (cm.cur_code) currency,
                   &APP_SCHEMA.pkg_price.fn_contract_price
                               (MAX (pcm.corporate_id),
                                MAX (pci.internal_contract_item_ref_no),
                                SYSDATE
                               ) price,
                   MAX (cm.cur_code) cur_code, MAX (pdm.product_id)
                                                                   product_id,
                   MAX (pdm.product_desc) product_desc, MAX (cm.cur_id)
                                                                       cur_id
              FROM &APP_SCHEMA.pci_physical_contract_item pci,
                   &APP_SCHEMA.pcm_physical_contract_main pcm,
                   &APP_SCHEMA.pmd_physical_multiple_delivery pmd,
                   &APP_SCHEMA.cm_currency_master cm,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   pam_product_asset_mapping pam
             WHERE pcm.internal_contract_ref_no = pci.internal_contract_ref_no
               AND pmd.internal_contract_item_ref_no =
                                             pci.internal_contract_item_ref_no
               AND pci.product_id = pdm.product_id
               AND pci.pay_in_cur_id = cm.cur_id
               AND pam.product_id = pdm.product_id
          GROUP BY pcm.issue_date
   UNION
   SELECT DISTINCT MAX (pci.pwit_id) internal_contract_item_ref_no,
                   '' internal_contract_ref_no, MAX (pam.asset_desc) asset,
                   'C' asset_class, axs.eff_date trade_date,
                   MAX (pci.delivery_to_date) maturity,
                   MAX (cm.cur_code) currency,
                   &APP_SCHEMA.pkg_price.fn_contract_price
                                                (MAX (pci.corporate_id),
                                                 MAX (pci.pwit_id),
                                                 SYSDATE
                                                ) price,
                   MAX (cm.cur_code) cur_code, MAX (pdm.product_id)
                                                                   product_id,
                   MAX (pdm.product_desc) product_desc, MAX (cm.cur_id)
                                                                       cur_id
              FROM &APP_SCHEMA.pwit_physical_what_if_trade pci,
                   &APP_SCHEMA.cm_currency_master cm,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   &APP_SCHEMA.cam_common_action_mapping cam,
                   &APP_SCHEMA.axs_action_summary axs,
                   pam_product_asset_mapping pam
             WHERE pci.product_id = pdm.product_id
               AND pci.pay_in_currency_id = cm.cur_id
               AND pam.product_id = pdm.product_id
               AND pci.pwit_id = cam.table_primary_key
               AND cam.internal_action_ref_no = axs.internal_action_ref_no
          GROUP BY axs.eff_date
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_options_valuation_prices (internal_drt_ref_no,
                                                         drt_ref_no,
                                                         valuatuion_date,
                                                         spot_price,
                                                         strike_price,
                                                         intrinsicvalue,
                                                         option_price,
                                                         extrinsicvalue
                                                        )
AS
   SELECT DISTINCT fovi.internal_drt_ref_no, fovi.drt_ref_no,
                   fovi.valuatuion_date, fovi.spot_price, fovi.strike_price,
                   (NVL (fovi.strike_price, 0) - NVL (fovi.spot_price, 0)
                   ) intrinsicvalue,
                   NVL (fovo.market_price_for_iv, 0) option_price,
                   (  NVL (fovo.market_price_for_iv, 0)
                    - ((NVL (fovi.strike_price, 0) - NVL (fovi.spot_price, 0)
                       )
                      )
                   ) extrinsicvalue
              FROM fovi_fea_option_valu_input fovi,
                   fovo_fea_option_valu_output fovo
             WHERE fovi.internal_drt_ref_no = fovo.internal_drt_ref_no
               AND fovi.valuatuion_date = fovo.valuatuion_date
               AND fovi.drt_ref_no = fovo.trade_ref_no
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_trader_risk_exposure (rle_id,
                                                          process,
                                                          process_date,
                                                          qty_exposure_limit,
                                                          qty_exposure,
                                                          net_qty_exposure,
                                                          value_exposure_limit,
                                                          value_exposure,
                                                          net_value_exposure,
                                                          mtm_exposure,
                                                          m2m_exposure,
                                                          net_m2m_exposure,
                                                          limit_qty_unit_id,
                                                          limit_qty_unit,
                                                          qty_exp_unit,
                                                          qty_exp_unit_id,
                                                          exposure_curr_id,
                                                          credit_exp_cur_id,
                                                          value_exp_cur_code,
                                                          limit_currency,
                                                          contract_type
                                                         )
AS
   SELECT   MAX (rle.rle_id) rle_id, eod.process, eod.process_date,
            rle.qty_exposure qty_exposure_limit,
            SUM (eod.qty_exposure) qty_exposure,
            (  rle.qty_exposure
             - SUM
                  (&APP_SCHEMA.pkg_general.f_get_converted_quantity
                                                    (rle.product_id,
                                                     eod.qty_exp_unit_id,
                                                     rle.exposure_qty_unit_id,
                                                     eod.qty_exposure
                                                    )
                  )
            ) net_qty_exposure,
            rle.value_exposure value_exposure_limit,
            SUM (eod.value_exposure) value_exposure,
            (  rle.value_exposure
             - SUM
                  (&APP_SCHEMA.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.value_exposure
                                                        )
                  )
            ) net_value_exposure,
            rle.mtm_exposure, SUM (eod.m2m_exposure) m2m_exposure,
            (  rle.mtm_exposure
             - SUM
                  (&APP_SCHEMA.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.m2m_exposure
                                                        )
                  )
            ) net_m2m_exposure,
            rle.exposure_qty_unit_id limit_qty_unit_id,
            qum.qty_unit limit_qty_unit, MAX (eod.qty_exp_unit) qty_exp_unit,
            MAX (eod.qty_exp_unit_id) qty_exp_unit_id, rle.exposure_curr_id,
            MAX (eod.credit_exp_cur_id) credit_exp_cur_id,
            MAX (eod.value_exp_cur_code) value_exp_cur_code,
            cm.cur_code limit_currency,
            DECODE (rle.contract_type,
                    'Net', 'Net',
                    eod.contract_type
                   ) contract_type
       FROM rle_risk_limit_exposure rle,
            rlt_risk_limit_type rlt,
            v_cm_currency_master cm,
            v_qum_quantity_unit qum,
            pe_metals_build3_eod.tre_trader_risk_exposure eod
      WHERE rle.rlt_id = rlt.rlt_id
        AND rlt.risk_type = 'TRADER RISK LIMIT'
        AND rle.exposure_curr_id = cm.cur_id
        AND rle.exposure_qty_unit_id = qum.qty_unit_id
        AND rle.product_id = eod.product_id
        AND rle.limit_id = eod.trader_user_id
        AND (CASE
                WHEN rle.org_level_id = 'CorporateGroup'
                   THEN eod.GROUP_ID
                WHEN rle.org_level_id = 'Corporate'
                   THEN eod.corporate_id
                ELSE eod.profit_center_id
             END
            ) = rle.org_id
        AND rle.contract_type =
                   DECODE (rle.contract_type,
                           'Net', 'Net',
                           eod.contract_type
                          )
   GROUP BY eod.process,
            eod.process_date,
            rle.value_exposure,
            rle.exposure_curr_id,
            rle.qty_exposure,
            rle.exposure_qty_unit_id,
            qum.qty_unit,
            rle.mtm_exposure,
            cm.cur_code,
            DECODE (rle.contract_type, 'Net', 'Net', eod.contract_type)
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_of_physical_trades (corporate_id,
                                                        product_id,
                                                        product_desc,
                                                        quality_id,
                                                        item_quality_string,
                                                        internal_contract_item_ref_no,
                                                        cp_name,
                                                        internal_contract_ref_no,
                                                        contract_ref_no,
                                                        contract_type,
                                                        contract_party_profile_id,
                                                        contract_status,
                                                        user_id,
                                                        profit_center_id,
                                                        delivery_from_date,
                                                        delivery_to_date,
                                                        item_delivery_period_string,
                                                        created_date,
                                                        conc_type,
                                                        group_name,
                                                        quantity,
                                                        trader,
                                                        trader_user_id,
                                                        entity_name,
                                                        strategy_id,
                                                        strategy_name,
                                                        pay_in_cur_id,
                                                        price_type_id,
                                                        spread_type,
                                                        asset,
                                                        units,
                                                        delivery_date,
                                                        price_month,
                                                        proxy,
                                                        is_what_if
                                                       )
AS
   SELECT DISTINCT pcm.corporate_id, pdm.product_id, pdm.product_desc,
                   '' AS quality_id, '' AS item_quality_string,
                   pci.internal_contract_item_ref_no, phd.companyname cp_name,
                   '' AS internal_contract_ref_no, pcm.contract_ref_no,
                   pcm.contract_type, '' AS contract_party_profile_id,
                   pcm.contract_status, aku.user_id, cpc.profit_center_id,
                   SYSDATE AS delivery_from_date, SYSDATE AS delivery_to_date,
                   '' item_delivery_period_string,
                   pcm.issue_date created_date,
                   DECODE (pcm.contract_type,
                           'P', 'PURCHASE',
                           'S', 'SALES',
                           ''
                          ) conc_type,
                   ak.corporate_name group_name,
                   (pci.item_qty || ' ' || qum.qty_unit) quantity,
                   (gab.firstname || ' ' || gab.lastname) trader,
                   '' AS trader_user_id, cpc.profit_center_name entity_name,
                   css.strategy_id, css.strategy_name, '' AS pay_in_cur_id,
                   'FIXED' AS price_type_id, 'FIXED' AS spread_type,
                   pam.asset_desc AS asset,
                   (CASE
                       WHEN pcm.contract_type = 'P'
                          THEN (pci.item_qty / 1000000)
                       ELSE (-pci.item_qty / 1000000)
                    END
                   ) units,
                   TO_CHAR (SYSDATE, 'DD-MON-YYYY') delivery_date,
                   (TO_CHAR (SYSDATE, 'MON') || ' '
                    || TO_CHAR (SYSDATE, 'YYYY')
                   ) price_month,
                   pam.asset_desc proxy, 'N' is_what_if
              FROM &APP_SCHEMA.pci_physical_contract_item pci,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   pam_product_asset_mapping pam,
                   &APP_SCHEMA.pcm_physical_contract_main pcm,
                   &APP_SCHEMA.ak_corporate ak,
                   &APP_SCHEMA.cpc_corporate_profit_center cpc,
                   &APP_SCHEMA.css_corporate_strategy_setup css,
                   &APP_SCHEMA.qum_quantity_unit_master qum,
                   &APP_SCHEMA.ak_corporate_user aku,
                   &APP_SCHEMA.gab_globaladdressbook gab,
                   --&APP_SCHEMA.pcp_physical_contract_party pcp,
                   &APP_SCHEMA.phd_profileheaderdetails phd,
                   --&APP_SCHEMA.pmd_physical_multiple_delivery pmd,
                   --&APP_SCHEMA.piq_physical_item_quality piq,
                   &APP_SCHEMA.cm_currency_master cm
             WHERE                          -- pci.product_id = pdm.product_id
                   --AND pdm.product_id = pam.product_id
                   --AND pci.internal_contract_ref_no = pcm.internal_contract_ref_no
                   --AND pcm.corporate_id = ak.corporate_id
                   --AND pci.profit_center_id = cpc.profit_center_id
                   --AND pci.item_qty_unit_id = qum.qty_unit_id
                   --AND pcm.trader_user_id = aku.user_id
                   aku.gabid = gab.gabid
                                         --AND pcp.contract_party_profile_id = phd.profileid
                                         --AND pcm.internal_contract_ref_no = pcp.internal_contract_ref_no
                                        -- AND pci.strategy_acc_id = css.strategy_id(+)
                                         --AND pmd.internal_contract_item_ref_no =    pci.internal_contract_item_ref_no
                                         --AND piq.internal_contract_item_ref_no =  pci.internal_contract_item_ref_no
                                         --AND pci.pay_in_cur_id = cm.cur_id(+)
                                         --AND pcp.contract_party_type = 'CP'
                   AND pci.is_active = 'Y' AND 1 = 2
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_of_options (internal_derivative_ref_no,
                                                corporate_id,
                                                prompt_date,
                                                period_month,
                                                period_year,
                                                aggregate_id,
                                                derivative_ref_no,
                                                nominee_id,
                                                trade_date,
                                                trader_name,
                                                external_ref_id,
                                                delivery_date,
                                                buy_sell,
                                                expiry_date,
                                                clearer_name,
                                                clearer_account_no,
                                                purpose_name,
                                                instrument,
                                                tot_quantity_unit_id,
                                                tot_quantity,
                                                open_quantity,
                                                expired_quantity,
                                                exercised_quantity,
                                                qty_in_lots,
                                                open_lots,
                                                exercised_lots,
                                                expired_lots,
                                                alloc_physical,
                                                internal_contract_item_ref_no,
                                                internal_contract_ref_no,
                                                strategy_id,
                                                acc_type_name,
                                                price_premium,
                                                status,
                                                profit_center_name,
                                                order_type,
                                                strike_price,
                                                created_by,
                                                created_date,
                                                tot_quantity_string,
                                                price_premium_value,
                                                price_premium_unit_id,
                                                price_unit_name,
                                                strike_price_value,
                                                strike_price_unit_id,
                                                instrument_type,
                                                instrument_sub_type_id,
                                                option_sub_type
                                               )
AS
   SELECT drt.internal_derivative_ref_no internal_derivative_ref_no,
          drt.corporate_id, drm.prompt_date, drm.period_month period_month,
          drm.period_year period_year, dat.aggregate_trade_id aggregate_id,
          drt.derivative_ref_no derivative_ref_no, phd.companyname nominee_id,
          TO_CHAR (drt.trade_date, 'dd-Mon-YYYY') trade_date,
          'USR-01' trader_name, drt.external_ref_no external_ref_id,
          drm.prompt_date delivery_date, drt.trade_type buy_sell,
          DECODE (drt.option_expiry_date,
                  NULL, '',
                  TO_CHAR (drt.option_expiry_date, 'dd-Mon-YYYY')
                 ) expiry_date,
          pkg_crc_general.f_get_company_name
                                         (drt.clearer_profile_id)
                                                                 clearer_name,
          bca.account_name clearer_account_no,
          dpm.purpose_display_name purpose_name,
          dim.instrument_name instrument,
          drt.quantity_unit_id tot_quantity_unit_id,
          NVL (drt.total_quantity, '0') tot_quantity,
          NVL (drt.open_quantity, '0') open_quantity,
          NVL (drt.expired_quantity, '0') expired_quantity,
          NVL (drt.exercised_quantity, '0') exercised_quantity,
          NVL (drt.total_lots, '0') qty_in_lots,
          NVL (drt.open_lots, '0') open_lots,
          NVL (drt.exercised_lots, '0') exercised_lots,
          NVL (drt.expired_lots, '0') expired_lots, '0' alloc_physical,
          '' internal_contract_item_ref_no, '' internal_contract_ref_no,
          drt.strategy_id strategy_id, css.strategy_name acc_type_name,
          DECODE
             (drt.premium_discount,
              NULL, NULL,
                 drt.premium_discount
              || ' '
              || pkg_crc_general.f_get_price_unit
                                           (drt.premium_discount_price_unit_id)
             ) price_premium,
          DECODE (drt.status, 'Settled', 'Closed out', drt.status) status,
          cpc.profit_center_name profit_center_name,
          dtm.deal_type_display_name order_type,
          DECODE
             (drt.strike_price,
              NULL, drt.trade_price
               || ' '
               || pkg_crc_general.f_get_price_unit (drt.trade_price_unit_id),
                 drt.strike_price
              || ' '
              || pkg_crc_general.f_get_price_unit (drt.strike_price_unit_id)
             ) strike_price,
          pkg_crc_general.f_get_corporate_user_name
                                                   (drt.created_by)
                                                                   created_by,
          TO_CHAR (drt.created_date, 'dd-Mon-YYYY') created_date,
             drt.total_quantity
          || ' '
          || pkg_crc_general.f_get_quantity_unit (drt.quantity_unit_id)
                                                          tot_quantity_string,
          DECODE (drt.premium_discount,
                  NULL, NULL,
                  drt.premium_discount
                 ) price_premium_value,
          drt.premium_discount_price_unit_id price_premium_unit_id,
          pkg_crc_general.f_get_price_unit
                                     (drt.trade_price_unit_id)
                                                              price_unit_name,
          DECODE (drt.strike_price,
                  NULL, drt.trade_price,
                  drt.strike_price
                 ) strike_price_value,
          DECODE (drt.strike_price_unit_id,
                  NULL, drt.trade_price_unit_id,
                  drt.strike_price_unit_id
                 ) strike_price_unit_id,
          irm.instrument_type, dim.instrument_sub_type_id,
          istm.instrument_sub_type option_sub_type
     FROM &APP_SCHEMA.v_cdc_derivative_trade drt,
          &APP_SCHEMA.v_cdc_derivative_master drm,
          &APP_SCHEMA.cpc_corporate_profit_center cpc,
          &APP_SCHEMA.dtm_deal_type_master dtm,
          &APP_SCHEMA.pdd_product_derivative_def pdd,
          &APP_SCHEMA.dim_der_instrument_master dim,
          &APP_SCHEMA.bca_broker_clearer_account bca,
          &APP_SCHEMA.dpm_derivative_purpose_master dpm,
          &APP_SCHEMA.dat_derivative_aggregate_trade dat,
          &APP_SCHEMA.phd_profileheaderdetails phd,
          &APP_SCHEMA.irm_instrument_type_master irm,
          &APP_SCHEMA.css_corporate_strategy_setup css,
          &APP_SCHEMA.istm_instr_sub_type_master istm
    WHERE drt.dr_id = drm.dr_id
      AND drt.profit_center_id = cpc.profit_center_id(+)
      AND drt.deal_type_id = dtm.deal_type_id
      AND pdd.derivative_def_id = dim.product_derivative_id
      AND drm.instrument_id = dim.instrument_id
      AND dim.instrument_type_id = irm.instrument_type_id
      AND irm.is_sub_type_applicable = 'Y'
      AND phd.profileid(+) = drt.nominee_profile_id
      AND drt.purpose_id = dpm.purpose_id
      AND drt.strategy_id = css.strategy_id
      AND drt.status = 'Verified'
      AND drt.clearer_account_id = bca.account_id(+)
      AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
      AND drt.internal_derivative_ref_no = DECODE (drt.leg_no, 1, dat.leg_1_int_der_ref_no(+),
                                                   dat.leg_2_int_der_ref_no(+))
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_of_derivative_trades (dr_id,
                                                          internal_derivative_ref_no,
                                                          derivative_ref_no,
                                                          trade_type_id,
                                                          trade_type,
                                                          corporate_id,
                                                          product_id,
                                                          broker_profile_id,
                                                          trader_user_id,
                                                          trader,
                                                          instrument_id,
                                                          instrument_name,
                                                          instrument_type_id,
                                                          strategy_name,
                                                          prompt_date,
                                                          NAME,
                                                          derivative_def_id,
                                                          acc_type_id,
                                                          purpose_id,
                                                          trade_date,
                                                          expiry_date,
                                                          buy_sell,
                                                          broker_name,
                                                          exchange_name,
                                                          exchange_id,
                                                          product_desc,
                                                          corporate_name,
                                                          profit_center_id,
                                                          entity_name,
                                                          quantity,
                                                          price,
                                                          base_cur_id,
                                                          settlement_cur_id,
                                                          quality_id,
                                                          quality_name,
                                                          trade_price_type_id,
                                                          currency,
                                                          asset,
                                                          no_of_conc,
                                                          conc_size,
                                                          instrument_type,
                                                          instrument_sub_type,
                                                          option_type,
                                                          exercise_type,
                                                          strike_price,
                                                          status,
                                                          is_what_if
                                                         )
AS
   SELECT DISTINCT drt.dr_id, drt.internal_derivative_ref_no,
                   drt.derivative_ref_no, drt.deal_type_id trade_type_id,
                   dtm.deal_type_name trade_type, drt.corporate_id,
                   pdm.product_id, drt.broker_profile_id,
                   drt.trader_id trader_user_id,
                   (gab.firstname || ' ' || gab.lastname) trader,
                   dim.instrument_id, dim.instrument_name,
                   irm.instrument_type_id, css.strategy_name, drm.prompt_date,
                   (   TO_CHAR (drm.prompt_date, 'Mon')
                    || ' '
                    || TO_CHAR (drm.prompt_date, 'yyyy')
                   ) NAME,
                   pdd.derivative_def_id, drt.strategy_id acc_type_id,
                   drt.purpose_id,
                   TO_CHAR (drt.trade_date, 'dd-Mon-yyyy') trade_date,
                   TO_CHAR (drm.prompt_date, 'dd-Mon-yyyy') expiry_date,
                   drt.trade_type buy_sell, phd.companyname broker_name,
                   emt.exchange_name, pdd.exchange_id, pdm.product_desc,
                   ak.corporate_name, drt.profit_center_id,
                   cpc.profit_center_name entity_name,
                   (drt.open_quantity || ' ' || qum.qty_unit) quantity,
                   (CASE
                       WHEN irm.instrument_type IN ('Future', 'Forward')
                          THEN    drt.trade_price
                               || ' '
                               || (SELECT    cm.cur_code
                                          || '/'
                                          || DECODE (NVL (ppu.weight, 1),
                                                     1, '',
                                                     ppu.weight
                                                    )
                                          || ''
                                          || qum.qty_unit
                                     FROM &APP_SCHEMA.pum_price_unit_master ppu,
                                          &APP_SCHEMA.cm_currency_master cm,
                                          &APP_SCHEMA.qum_quantity_unit_master qum
                                    WHERE drt.trade_price_unit_id =
                                                             ppu.price_unit_id
                                      AND ppu.cur_id = cm.cur_id
                                      AND ppu.weight_unit_id = qum.qty_unit_id)
                       WHEN irm.instrument_type_id NOT IN
                                                        ('Future', 'Forward')
                          THEN    drt.strike_price
                               || ' '
                               || (SELECT    cm.cur_code
                                          || '/'
                                          || DECODE (NVL (ppu.weight, 1),
                                                     1, '',
                                                     ppu.weight
                                                    )
                                          || ''
                                          || qum.qty_unit
                                     FROM &APP_SCHEMA.pum_price_unit_master ppu,
                                          &APP_SCHEMA.cm_currency_master cm,
                                          &APP_SCHEMA.qum_quantity_unit_master qum
                                    WHERE drt.strike_price_unit_id =
                                                             ppu.price_unit_id
                                      AND ppu.cur_id = cm.cur_id
                                      AND ppu.weight_unit_id = qum.qty_unit_id)
                       ELSE ''
                    END
                   ) price,
                   pum.cur_id base_cur_id, drt.settlement_cur_id,
                   qat.quality_id, qat.quality_name, drt.trade_price_type_id,
                   cm.cur_code currency, pam.asset_desc asset,
                   (CASE
                       WHEN drt.trade_type = 'Buy'
                          THEN CASE
                                 WHEN irm.instrument_type = 'Future'
                                    THEN NVL (drt.total_lots, 0)
                                 ELSE NVL (drt.total_quantity, 0)
                              END
                       WHEN drt.trade_type = 'Sell'
                          THEN CASE
                                 WHEN irm.instrument_type = 'Forward'
                                    THEN NVL (-drt.total_quantity, 0)
                                 ELSE NVL (-drt.total_lots, 0)
                              END
                    END
                   ) no_of_conc,
                   (CASE
                       WHEN irm.instrument_type = 'Future'
                          THEN NVL ((NVL (pdd.lot_size, 0) / 1000000), 0)
                       ELSE NVL ((NVL (drt.total_quantity, 0) / 1000000), 0)
                    END
                   ) conc_size,
                   irm.instrument_type, istm.instrument_sub_type,
                   DECODE (irm.instrument_type,
                           'Option Call', 'C',
                           'Option Put', 'P',
                           ''
                          ) option_type,
                   DECODE (istm.instrument_sub_type,
                           'American', 'A',
                           'Option Put', 'E',
                           ''
                          ) exercise_type,
                   (CASE
                       WHEN irm.instrument_type IN
                                                ('Option Call', 'Option Put')
                          THEN /*&APP_SCHEMA.pkg_price.fn_contract_price
                                              (drt.corporate_id,
                                               drt.internal_derivative_ref_no,
                                               SYSDATE
                                              )*/ 0.00
                       WHEN irm.instrument_type IN ('Future', 'Forward')
                          THEN drt.trade_price
                       ELSE drt.strike_price
                    END
                   ) strike_price,
                   drt.status, drt.is_what_if
              FROM &APP_SCHEMA.v_cdc_derivative_trade drt,
                   &APP_SCHEMA.v_cdc_derivative_master drm,
                   &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.phd_profileheaderdetails phd,
                   &APP_SCHEMA.emt_exchangemaster emt,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   &APP_SCHEMA.irm_instrument_type_master irm,
                   &APP_SCHEMA.ak_corporate ak,
                   &APP_SCHEMA.cpc_corporate_profit_center cpc,
                   &APP_SCHEMA.css_corporate_strategy_setup css,
                   &APP_SCHEMA.dtm_deal_type_master dtm,
                   &APP_SCHEMA.pum_price_unit_master pum,
                   &APP_SCHEMA.qat_quality_attributes qat,
                   &APP_SCHEMA.ak_corporate_user aku,
                   &APP_SCHEMA.gab_globaladdressbook gab,
                   &APP_SCHEMA.qum_quantity_unit_master qum,
                   &APP_SCHEMA.istm_instr_sub_type_master istm,
                   &APP_SCHEMA.cm_currency_master cm,
                   pam_product_asset_mapping pam
             WHERE drt.dr_id = drm.dr_id
               AND drm.instrument_id = dim.instrument_id
               AND dim.product_derivative_id = pdd.derivative_def_id
               AND drt.broker_profile_id = phd.profileid(+)
               AND pdd.exchange_id = emt.exchange_id(+)
               AND pdd.product_id = pdm.product_id
               AND dim.instrument_type_id = irm.instrument_type_id
               AND drt.corporate_id = ak.corporate_id
               AND drt.profit_center_id = cpc.profit_center_id
               AND drt.strategy_id = css.strategy_id(+)
               AND drt.deal_type_id = dtm.deal_type_id
               AND drt.quality_id = qat.quality_id(+)
               AND drt.quantity_unit_id = qum.qty_unit_id
               AND drt.trade_price_unit_id = pum.price_unit_id
               AND drt.settlement_cur_id = cm.cur_id
               AND drt.trader_id = aku.user_id
               AND aku.gabid = gab.gabid
               AND pam.product_id = pdm.product_id(+)
               AND dim.instrument_sub_type_id = istm.instrument_sub_type_id(+)
               AND drt.status <> 'Delete'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_of_currency_trades (dr_id,
                                                        instrument_id,
                                                        instrument_type_id,
                                                        product_id,
                                                        corporate_id,
                                                        profit_center_id,
                                                        trader_user_id,
                                                        trader,
                                                        NAME,
                                                        internal_derivative_ref_no,
                                                        derivative_ref_no,
                                                        trade_type_id,
                                                        trade_type,
                                                        broker_profile_id,
                                                        bank_acc_id,
                                                        account_name,
                                                        derivative_def_id,
                                                        trade_date,
                                                        prompt_date,
                                                        buy_sell,
                                                        broker_name,
                                                        exchange_name,
                                                        exchange_id,
                                                        product_desc,
                                                        instrument_name,
                                                        instrument_type,
                                                        corporate_name,
                                                        entity_name,
                                                        base_cur_id,
                                                        settlement_cur_id,
                                                        status,
                                                        amount,
                                                        exchange_rate,
                                                        currency,
                                                        quote_currency,
                                                        ordr
                                                       )
AS
   WITH main_qry AS
        (SELECT ct.dr_id, drm.instrument_id, irm.instrument_type_id,
                pdm.product_id, ct.corporate_id, ct.profit_center_id,
                ct.trader_id trader_user_id,
                (gab.firstname || ' ' || gab.lastname) trader,
                (   TO_CHAR (drm.prompt_date, 'Mon')
                 || ' '
                 || TO_CHAR (drm.prompt_date, 'yyyy')
                ) NAME,
                ct.internal_treasury_ref_no internal_derivative_ref_no,
                ct.treasury_ref_no derivative_ref_no,
                ct.deal_type_id trade_type_id, dtm.deal_type_name trade_type,
                ct.bank_id broker_profile_id, ct.bank_acc_id,
                oba.account_name, pdd.derivative_def_id,
                TO_CHAR (ct.trade_date, 'dd-Mon-yyyy') trade_date,
                drm.prompt_date, ct.trade_type buy_sell,
                phd.companyname broker_name, emt.exchange_name,
                pdd.exchange_id, pdm.product_desc, dim.instrument_name,
                irm.instrument_type, ak.corporate_name,
                cpc.profit_center_name entity_name,
                MAX (DECODE (ct.is_base, 'Y', ct.cur_id)) OVER (PARTITION BY ct.internal_treasury_ref_no)
                                                                  base_cur_id,
                MAX (DECODE (ct.is_base, 'N', ct.cur_id)) OVER (PARTITION BY ct.internal_treasury_ref_no)
                                                            settlement_cur_id,
                ct.status, ct.amount amount, ct.exchange_rate,
                base_cm.cur_code currency, quote_cm.cur_code quote_currency,
                ROW_NUMBER () OVER (PARTITION BY ct.internal_treasury_ref_no ORDER BY ROWNUM)
                                                                         ordr
           FROM &APP_SCHEMA.v_cdc_treasury_trade ct,
                &APP_SCHEMA.v_cdc_derivative_master drm,
                &APP_SCHEMA.dim_der_instrument_master dim,
                &APP_SCHEMA.pdd_product_derivative_def pdd,
                &APP_SCHEMA.phd_profileheaderdetails phd,
                &APP_SCHEMA.emt_exchangemaster emt,
                &APP_SCHEMA.pdm_productmaster pdm,
                &APP_SCHEMA.irm_instrument_type_master irm,
                &APP_SCHEMA.cpc_corporate_profit_center cpc,
                &APP_SCHEMA.css_corporate_strategy_setup css,
                &APP_SCHEMA.cm_currency_master base_cm,
                &APP_SCHEMA.cm_currency_master quote_cm,
                &APP_SCHEMA.oba_our_bank_accounts oba,
                &APP_SCHEMA.ak_corporate ak,
                &APP_SCHEMA.ak_corporate_user aku,
                &APP_SCHEMA.gab_globaladdressbook gab,
                &APP_SCHEMA.dtm_deal_type_master dtm
          WHERE ct.dr_id = drm.dr_id
            AND drm.instrument_id = dim.instrument_id
            AND dim.product_derivative_id = pdd.derivative_def_id
            AND ct.bank_id = phd.profileid
            AND pdd.exchange_id = emt.exchange_id(+)
            AND pdd.product_id = pdm.product_id
            AND dim.instrument_type_id = irm.instrument_type_id
            AND ct.corporate_id = ak.corporate_id
            AND ct.profit_center_id = cpc.profit_center_id
            AND ct.strategy_id = css.strategy_id(+)
            AND ct.deal_type_id = dtm.deal_type_id
            AND pdm.base_cur_id = base_cm.cur_id(+)
            AND pdm.quote_cur_id = quote_cm.cur_id(+)
            AND oba.account_id = ct.bank_acc_id(+)
            AND ct.trader_id = aku.user_id
            AND aku.gabid = gab.gabid
            AND dim.is_deleted = 'N'
            AND pdd.is_deleted = 'N'
            AND irm.is_deleted = 'N'
            AND cpc.is_deleted = 'N'
            AND ct.status <> 'Delete'
            AND phd.is_active = 'Y')
   SELECT "DR_ID", "INSTRUMENT_ID", "INSTRUMENT_TYPE_ID", "PRODUCT_ID",
          "CORPORATE_ID", "PROFIT_CENTER_ID", "TRADER_USER_ID", "TRADER",
          "NAME", "INTERNAL_DERIVATIVE_REF_NO", "DERIVATIVE_REF_NO",
          "TRADE_TYPE_ID", "TRADE_TYPE", "BROKER_PROFILE_ID", "BANK_ACC_ID",
          "ACCOUNT_NAME", "DERIVATIVE_DEF_ID", "TRADE_DATE", "PROMPT_DATE",
          "BUY_SELL", "BROKER_NAME", "EXCHANGE_NAME", "EXCHANGE_ID",
          "PRODUCT_DESC", "INSTRUMENT_NAME", "INSTRUMENT_TYPE",
          "CORPORATE_NAME", "ENTITY_NAME", "BASE_CUR_ID", "SETTLEMENT_CUR_ID",
          "STATUS", "AMOUNT", "EXCHANGE_RATE", "CURRENCY", "QUOTE_CURRENCY",
          "ORDR"
     FROM main_qry
    WHERE ordr = 1
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_cp_risk_exposure (rle_id,
                                                      process,
                                                      process_date,
                                                      qty_exposure_limit,
                                                      qty_exposure,
                                                      net_qty_exposure,
                                                      value_exposure_limit,
                                                      value_exposure,
                                                      net_value_exposure,
                                                      mtm_exposure,
                                                      m2m_exposure,
                                                      net_m2m_exposure,
                                                      limit_qty_unit_id,
                                                      limit_qty_unit,
                                                      qty_exp_unit,
                                                      qty_exp_unit_id,
                                                      exposure_curr_id,
                                                      credit_exp_cur_id,
                                                      value_exp_cur_code,
                                                      limit_currency,
                                                      contract_type
                                                     )
AS
   SELECT   MAX (rle.rle_id) rle_id, eod.process, eod.process_date,
            rle.qty_exposure qty_exposure_limit,
            SUM (eod.qty_exposure) qty_exposure,
            (  rle.qty_exposure
             - SUM
                  (&APP_SCHEMA.pkg_general.f_get_converted_quantity
                                                    (rle.product_id,
                                                     eod.qty_exp_unit_id,
                                                     rle.exposure_qty_unit_id,
                                                     eod.qty_exposure
                                                    )
                  )
            ) net_qty_exposure,
            rle.value_exposure value_exposure_limit,
            SUM (eod.value_exposure) value_exposure,
            (  rle.value_exposure
             - SUM
                  (&APP_SCHEMA.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.value_exposure
                                                        )
                  )
            ) net_value_exposure,
            rle.mtm_exposure, SUM (eod.m2m_exposure) m2m_exposure,
            (  rle.mtm_exposure
             - SUM
                  (&APP_SCHEMA.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.m2m_exposure
                                                        )
                  )
            ) net_m2m_exposure,
            rle.exposure_qty_unit_id limit_qty_unit_id,
            qum.qty_unit limit_qty_unit, MAX (eod.qty_exp_unit) qty_exp_unit,
            MAX (eod.qty_exp_unit_id) qty_exp_unit_id, rle.exposure_curr_id,
            MAX (eod.credit_exp_cur_id) credit_exp_cur_id,
            MAX (eod.value_exp_cur_code) value_exp_cur_code,
            cm.cur_code limit_currency,
            DECODE (rle.contract_type,
                    'Net', 'Net',
                    eod.contract_type
                   ) contract_type
       FROM rle_risk_limit_exposure rle,
            rlt_risk_limit_type rlt,
            v_cm_currency_master cm,
            v_qum_quantity_unit qum,
            pe_metals_build3_eod.cre_cp_risk_exposure eod
      WHERE rle.rlt_id = rlt.rlt_id
        AND rlt.risk_type = 'CP RISK LIMIT'
        AND rle.exposure_curr_id = cm.cur_id
        AND rle.exposure_qty_unit_id = qum.qty_unit_id
        AND rle.product_id = eod.product_id
        AND rle.limit_id = eod.cp_profile_id
        AND (CASE
                WHEN rle.org_level_id = 'CorporateGroup'
                   THEN eod.GROUP_ID
                WHEN rle.org_level_id = 'Corporate'
                   THEN eod.corporate_id
                ELSE eod.profit_center_id
             END
            ) = rle.org_id
        AND rle.contract_type =
                   DECODE (rle.contract_type,
                           'Net', 'Net',
                           eod.contract_type
                          )
   GROUP BY eod.process,
            eod.process_date,
            rle.value_exposure,
            rle.exposure_curr_id,
            rle.qty_exposure,
            rle.exposure_qty_unit_id,
            qum.qty_unit,
            rle.mtm_exposure,
            cm.cur_code,
            DECODE (rle.contract_type, 'Net', 'Net', eod.contract_type)
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_interest_market_details (asset,
                                                        asset_class,
                                                        ird_id,
                                                        interest_curve,
                                                        interest_rate_desc,
                                                        trade_date,
                                                        currency,
                                                        price,
                                                        cur_id,
                                                        maturity,
                                                        maturity_date,
                                                        interest_rate_id
                                                       )
AS
   SELECT   cm.cur_code asset,
            (CASE
                WHEN (NVL (pm.equivalent_days, 1) * NVL (mm.forward_period, 1)
                     ) < 365
                   THEN 'R'
                WHEN (NVL (pm.equivalent_days, 1) * NVL (mm.forward_period, 1)
                     ) >= 365
                   THEN 'S'
                ELSE 'R'
             END
            ) asset_class,
            irh.ird_id, irs.interest_rate interest_curve,
            irs.interest_rate_desc, irh.trade_date, cm.cur_code currency,
            irh.interest_rate_value price, cm.cur_id,
            (CASE
                WHEN (NVL (pm.equivalent_days, 1) * NVL (mm.forward_period, 1)
                     ) < 365
                   THEN (  NVL (pm.equivalent_days, 1)
                         * NVL (mm.forward_period, 1)
                        )
                WHEN (NVL (pm.equivalent_days, 1) * NVL (mm.forward_period, 1)
                     ) >= 365
                   THEN (  NVL (pm.equivalent_days, 1)
                         * NVL (mm.forward_period, 1)
                         / 365
                        )
                ELSE 0
             END
            ) maturity,
            (  irh.trade_date
             + (NVL (pm.equivalent_days, 1) * NVL (mm.forward_period, 1))
            ) maturity_date,
            irs.interest_rate_id
       FROM &APP_SCHEMA.irs_interest_rate_setup irs,
            &APP_SCHEMA.v_cdc_interest_rates irh,
            &APP_SCHEMA.cm_currency_master cm,
            &APP_SCHEMA.mm_maturity_master mm,
            &APP_SCHEMA.pm_period_master pm
      WHERE irh.interest_rate_id = irs.interest_rate_id
        AND irs.rate_cur_id = cm.cur_id
        AND irh.maturity_id = mm.maturity_id
        AND mm.forward_period_type_id = pm.period_type_id
        AND irh.interest_rate_value IS NOT NULL
        AND irh.is_active = 'Y'
        AND irh.is_deleted = 'N'
        AND irs.is_active = 'Y'
        AND irs.is_deleted = 'N'
        AND irh.is_deleted = 'N'
   ORDER BY maturity, trade_date
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_interest_curves (interest_rate,
                                                interest_rate_id,
                                                interest_rate_desc,
                                                currency,
                                                cur_id,
                                                data_available_till,
                                                irh_id,
                                                on_date
                                               )
AS
   WITH ird_latest_on_dates AS
        (SELECT   ird.irh_id,
                  MAX (  ird.trade_date
                       + (  NVL (pm.equivalent_days, 0)
                          * NVL (mm.forward_period, 0)
                         )
                      ) on_date
             FROM &APP_SCHEMA.v_cdc_interest_rates ird,
                  &APP_SCHEMA.mm_maturity_master mm,
                  &APP_SCHEMA.pm_period_master pm
         GROUP BY ird.irh_id)
   SELECT DISTINCT irs.interest_rate, irs.interest_rate_id,
                   irs.interest_rate_desc, cm.cur_code currency, cm.cur_id,
                   irh.trade_date data_available_till, irh.irh_id,
                   ird.on_date
              FROM &APP_SCHEMA.irs_interest_rate_setup irs,
                   &APP_SCHEMA.v_cdc_interest_rates irh,
                   ird_latest_on_dates ird,
                   &APP_SCHEMA.cm_currency_master cm
             WHERE irs.interest_rate_id = irh.interest_rate_id
               AND irh.irh_id = ird.irh_id(+)
               AND irs.rate_cur_id = cm.cur_id
               AND irh.is_active = 'Y'
               AND irh.is_deleted = 'N'
               AND irs.is_active = 'Y'
               AND irs.is_deleted = 'N'
               AND irh.trade_date =
                       (SELECT MAX (irh1.trade_date)
                          FROM &APP_SCHEMA.v_cdc_interest_rates irh1
                         WHERE irh1.interest_rate_id = irh.interest_rate_id)
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_instrument_master (instrument_id,
                                                  instrument_name
                                                 )
AS
   SELECT DISTINCT dim.instrument_id, dim.instrument_name
              FROM &APP_SCHEMA.dim_der_instrument_master dim
             WHERE dim.is_deleted = 'N'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_gab_globaladdressbook (gabid,
                                                      ownercorporateid,
                                                      firstname,
                                                      lastname,
                                                      address,
                                                      useremail,
                                                      phone,
                                                      fax,
                                                      mobile,
                                                      department,
                                                      designation,
                                                      city,
                                                      state,
                                                      country,
                                                      homephone,
                                                      email_status,
                                                      profileid,
                                                      city_id,
                                                      zipcode,
                                                      is_default_pic,
                                                      is_active
                                                     )
AS
   SELECT "GABID", "OWNERCORPORATEID", "FIRSTNAME", "LASTNAME", "ADDRESS",
          "USEREMAIL", "PHONE", "FAX", "MOBILE", "DEPARTMENT", "DESIGNATION",
          "CITY", "STATE", "COUNTRY", "HOMEPHONE", "EMAIL_STATUS",
          "PROFILEID", "CITY_ID", "ZIPCODE", "IS_DEFAULT_PIC", "IS_ACTIVE"
     FROM &APP_SCHEMA.gab_globaladdressbook
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_der_valuation_details (vtm_id,
                                                      valuation_dr_ids)
AS
   SELECT   pdt.vtm_id,
            &APP_SCHEMA.stragg (DISTINCT drt.dr_id)
                                                             valuation_dr_ids
       FROM pdt_portfo_derivative_trades pdt,
            &APP_SCHEMA.v_cdc_derivative_trade drt
      WHERE pdt.internal_derivative_ref_no = drt.internal_derivative_ref_no
   GROUP BY pdt.vtm_id
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_currency_market_details (asset_class,
                                                        maturity,
                                                        trade_date,
                                                        base_cur_id,
                                                        cur_id,
                                                        asset,
                                                        price,
                                                        currency,
                                                        product_desc,
                                                        product_id,
                                                        dr_id,
                                                        instrument_type,
                                                        instrument_type_id,
                                                        instrument_id,
                                                        instrument_name,
                                                        product_derivative_id,
                                                        strike_price_unit_id,
                                                        product_asset_class,
                                                        strike_price
                                                       )
AS
   SELECT   'XS' asset_class, '0' maturity, cfq.trade_date trade_date,
            base_cm.cur_id base_cur_id, quote_cm.cur_id cur_id,
            (CASE
                WHEN MAX (base_cm.cur_code) = 'USD'
                   THEN MAX (quote_cm.cur_code)
                ELSE MAX (base_cm.cur_code)
             END
            ) asset,
            (CASE
                WHEN MAX (base_cm.cur_code) = 'USD'
                   THEN CASE
                          WHEN SUM (  NVL (cfq.rate, 0)
                                    + NVL (cfq.forward_point, 0)
                                   ) <> 0
                             THEN (  1
                                   / SUM (  NVL (cfq.rate, 0)
                                          + NVL (cfq.forward_point, 0)
                                         )
                                  )
                          ELSE 0
                       END
                ELSE SUM (NVL (cfq.rate, 0) + NVL (cfq.forward_point, 0))
             END
            ) price,
            (CASE
                WHEN MAX (base_cm.cur_code) = 'USD'
                   THEN MAX (base_cm.cur_code)
                ELSE MAX (quote_cm.cur_code)
             END
            ) currency,
            MAX (pdm.product_desc) product_desc,
            MAX (pdm.product_id) product_id, MAX (drm.dr_id) dr_id,
            MAX (irm.instrument_type) instrument_type,
            MAX (irm.instrument_type_id) instrument_type_id,
            MAX (dim.instrument_id) instrument_id,
            MAX (dim.instrument_name) instrument_name,
            MAX (dim.product_derivative_id) product_derivative_id,
            MAX (drm.strike_price_unit_id) strike_price_unit_id,
            MAX (pac.asset_desc) product_asset_class,
            MAX (drm.strike_price) strike_price
       FROM &APP_SCHEMA.v_cdc_derivative_master drm,
            &APP_SCHEMA.v_cdc_bank_fx_rates cfq,
            &APP_SCHEMA.dim_der_instrument_master dim,
            &APP_SCHEMA.pdd_product_derivative_def pdd,
            &APP_SCHEMA.emt_exchangemaster emt,
            &APP_SCHEMA.irm_instrument_type_master irm,
            &APP_SCHEMA.cm_currency_master base_cm,
            &APP_SCHEMA.cm_currency_master quote_cm,
            &APP_SCHEMA.pac_product_asset_class pac,
            &APP_SCHEMA.pdm_productmaster pdm
      WHERE cfq.instrument_id = drm.instrument_id
        AND cfq.dr_id = drm.dr_id
        AND pdd.product_id = pdm.product_id
        AND drm.instrument_id = dim.instrument_id
        AND dim.product_derivative_id = pdd.derivative_def_id
        AND pdd.exchange_id = emt.exchange_id(+)
        AND dim.instrument_type_id = irm.instrument_type_id
        AND pdm.base_cur_id = base_cm.cur_id
        AND pdm.quote_cur_id = quote_cm.cur_id
        AND pdm.product_asset_class = pac.asset_id
        AND pac.asset_desc = 'Currency'
        AND dim.is_deleted = 'N'
        AND pdd.is_deleted = 'N'
        AND irm.is_deleted = 'N'
        AND cfq.is_deleted = 'N'
        AND cfq.is_deleted = 'N'
        AND base_cm.is_deleted = 'N'
        AND quote_cm.is_deleted = 'N'
   GROUP BY cfq.trade_date, base_cm.cur_id, quote_cm.cur_id
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_currency_curves (instrument_name,
                                                instrument_id,
                                                instrument_type_id,
                                                instrument,
                                                instrument_symbol,
                                                calendar_id,
                                                calendar_name,
                                                product_desc,
                                                product_id,
                                                product_asset_class,
                                                currency,
                                                currency_id,
                                                quote_cur_id,
                                                quote_currency,
                                                created_date
                                               )
AS
   SELECT DISTINCT dim.instrument_name, dim.instrument_id,
                   irm.instrument_type_id, irm.instrument_type instrument,
                   dim.instrument_symbol, clm.calendar_id, clm.calendar_name,
                   pdm.product_desc, pdm.product_id,
                   pac.asset_desc product_asset_class,
                   base_cm.cur_code currency, base_cm.cur_id currency_id,
                   quote_cm.cur_id quote_cur_id,
                   quote_cm.cur_code quote_currency,
                   (SELECT MAX (cfq.trade_date)
                      FROM &APP_SCHEMA.v_cdc_bank_fx_rates cfq
                     WHERE cfq.instrument_id = dim.instrument_id)
                                                                 created_date
              FROM &APP_SCHEMA.v_cdc_derivative_master drm,
                   &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.irm_instrument_type_master irm,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   &APP_SCHEMA.pac_product_asset_class pac,
                   &APP_SCHEMA.cm_currency_master base_cm,
                   &APP_SCHEMA.cm_currency_master quote_cm,
                   &APP_SCHEMA.clm_calendar_master clm
             WHERE drm.instrument_id = dim.instrument_id
               AND dim.product_derivative_id = pdd.derivative_def_id
               AND dim.instrument_type_id = irm.instrument_type_id
               AND dim.holiday_calender_id = clm.calendar_id
               AND pdd.product_id = pdm.product_id
               AND pdm.base_cur_id = base_cm.cur_id(+)
               AND pdm.quote_cur_id = quote_cm.cur_id(+)
               AND pdm.product_asset_class = pac.asset_id
               AND pac.asset_desc = 'Currency'
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_commodity_market_details (asset,
                                                         asset_class,
                                                         trade_date,
                                                         product_asset_class,
                                                         maturity,
                                                         currency,
                                                         price,
                                                         exchange_name,
                                                         exchange_id,
                                                         product_desc,
                                                         product_id,
                                                         instrument_type,
                                                         instrument_type_id,
                                                         cur_code,
                                                         cur_id,
                                                         instrument_id,
                                                         instrument_name,
                                                         dq_id,
                                                         dr_id,
                                                         product_derivative_id,
                                                         instrument_pricing_id,
                                                         available_price_id,
                                                         price_unit_id
                                                        )
AS
   SELECT   pam.asset_desc asset, 'C' asset_class, dq.trade_date,
            MAX (pac.asset_desc) product_asset_class,
            MAX (TO_CHAR (drm.prompt_date, 'MM/DD/YYYY')) maturity,
            MAX (cm.cur_code) currency, MAX (NVL (dq.price, 0)) price,
            MAX (emt.exchange_name) exchange_name,
            MAX (emt.exchange_id) exchange_id,
            MAX (pdm.product_desc) product_desc,
            MAX (pdm.product_id) product_id,
            MAX (irm.instrument_type) instrument_type,
            MAX (irm.instrument_type_id) instrument_type_id,
            MAX (cm.cur_code) cur_code, MAX (cm.cur_id) cur_id,
            MAX (dim.instrument_id) instrument_id,
            MAX (dim.instrument_name) instrument_name, MAX (dq.dq_id) dq_id,
            MAX (dq.dr_id) dr_id,
            MAX (dim.product_derivative_id) product_derivative_id,
            MAX (dip.instrument_pricing_id) instrument_pricing_id,
            MAX (dq.available_price_id) available_price_id,
            MAX (dq.price_unit_id) price_unit_id
       FROM &APP_SCHEMA.v_cdc_derivative_master drm,
            &APP_SCHEMA.v_cdc_derivative_quotes dq,
            &APP_SCHEMA.dim_der_instrument_master dim,
            &APP_SCHEMA.apm_available_price_master apm,
            &APP_SCHEMA.dip_der_instrument_pricing dip,
            &APP_SCHEMA.pdd_product_derivative_def pdd,
            &APP_SCHEMA.pac_product_asset_class pac,
            &APP_SCHEMA.emt_exchangemaster emt,
            &APP_SCHEMA.irm_instrument_type_master irm,
            &APP_SCHEMA.pum_price_unit_master pum,
            &APP_SCHEMA.cm_currency_master cm,
            &APP_SCHEMA.pdm_productmaster pdm,
            pam_product_asset_mapping pam
      WHERE dq.dr_id = drm.dr_id
        AND drm.instrument_id = dim.instrument_id
        AND dim.product_derivative_id = pdd.derivative_def_id
        AND pdd.exchange_id = emt.exchange_id(+)
        AND dim.instrument_type_id = irm.instrument_type_id
        AND pdd.product_id = pam.product_id
        AND dim.instrument_id = dip.instrument_id
        AND dq.available_price_id = apm.available_price_id
        AND dq.price_unit_id = pum.price_unit_id
        AND pum.cur_id = cm.cur_id
        AND pam.product_id = pdm.product_id
        AND pdm.product_asset_class = pac.asset_id
        AND pac.asset_desc <> 'Currency'
   GROUP BY pam.asset_desc, drm.prompt_date, dq.trade_date
   ORDER BY pam.asset_desc, drm.prompt_date, dq.trade_date
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_commodity_curves (dr_id,
                                                 instrument_name,
                                                 instrument_id,
                                                 instrument_type,
                                                 instrument_type_id,
                                                 instrument,
                                                 instrument_symbol,
                                                 exchange_address,
                                                 exchange_id,
                                                 product_desc,
                                                 product_id,
                                                 quality_name,
                                                 quality_id,
                                                 holiday_calender,
                                                 calendar_id,
                                                 price_unit_name,
                                                 price_unit_id,
                                                 cur_code,
                                                 cur_id,
                                                 price_source_name,
                                                 price_source_id,
                                                 product_asset_class,
                                                 is_cash_settlement,
                                                 is_physical_settlement,
                                                 created_date,
                                                 is_phy_val_curve
                                                )
AS
   SELECT DISTINCT drm.dr_id, dim.instrument_name, dim.instrument_id,
                   (pdd.traded_on || ' Trade') instrument_type,
                   irm.instrument_type_id, irm.instrument_type instrument,
                   dim.instrument_symbol,
                   (emt.exchange_name || ' ' || emt.exchange_address
                   ) exchange_address,
                   emt.exchange_id, pdm.product_desc, pdm.product_id,
                   qat.quality_name, qat.quality_id,
                   clm.calendar_name holiday_calender, clm.calendar_id,
                   pum.price_unit_name, drt.trade_price_unit_id price_unit_id,
                   cm.cur_code, cm.cur_id, '' price_source_name,
                   '' price_source_id, pac.asset_desc product_asset_class,
                   is_cash_settlement, is_physical_settlement,
                   MAX (drt.created_date) OVER (PARTITION BY 1) created_date,
                   'N' is_phy_val_curve
              FROM &APP_SCHEMA.v_cdc_derivative_master drm,
                   &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.emt_exchangemaster emt,
                   &APP_SCHEMA.irm_instrument_type_master irm,
                   &APP_SCHEMA.pac_product_asset_class pac,
                   &APP_SCHEMA.pum_price_unit_master pum,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   &APP_SCHEMA.v_cdc_derivative_trade drt,
                   &APP_SCHEMA.cm_currency_master cm,
                   &APP_SCHEMA.clm_calendar_master clm,
                   &APP_SCHEMA.qat_quality_attributes qat
             WHERE drt.dr_id = drm.dr_id
               AND drm.instrument_id = dim.instrument_id
               AND dim.product_derivative_id = pdd.derivative_def_id
               AND pdd.product_id = pdm.product_id
               AND pdd.exchange_id = emt.exchange_id(+)
               AND dim.instrument_type_id = irm.instrument_type_id
               AND pum.cur_id = cm.cur_id
               AND dim.holiday_calender_id = clm.calendar_id
               AND pdm.product_asset_class = pac.asset_id
               AND drt.quality_id = qat.quality_id(+)
               AND drt.trade_price_unit_id = pum.price_unit_id(+)
               AND pac.asset_desc <> 'Currency'
   UNION
   SELECT DISTINCT drm.dr_id, dim.instrument_name, dim.instrument_id,
                   (pdd.traded_on || ' Trade') instrument_type,
                   irm.instrument_type_id, irm.instrument_type instrument,
                   dim.instrument_symbol,
                   (emt.exchange_name || ' ' || emt.exchange_address
                   ) exchange_address,
                   emt.exchange_id, pdm.product_desc, pdm.product_id,
                   qat.quality_name, qat.quality_id,
                   clm.calendar_name holiday_calender, clm.calendar_id,
                   pum.price_unit_name, ppu.price_unit_id price_unit_id,
                   cm.cur_code, cm.cur_id, '' price_source_name,
                   '' price_source_id, pac.asset_desc product_asset_class,
                   is_cash_settlement, is_physical_settlement,
                   MAX (pcm.issue_date) OVER (PARTITION BY 1) created_date,
                   'Y' is_phy_val_curve
              FROM &APP_SCHEMA.v_cdc_derivative_master drm,
                   &APP_SCHEMA.dim_der_instrument_master dim,
                   &APP_SCHEMA.pdd_product_derivative_def pdd,
                   &APP_SCHEMA.emt_exchangemaster emt,
                   &APP_SCHEMA.irm_instrument_type_master irm,
                   &APP_SCHEMA.pac_product_asset_class pac,
                   &APP_SCHEMA.pum_price_unit_master pum,
                   &APP_SCHEMA.pdm_productmaster pdm,
                   &APP_SCHEMA.pci_physical_contract_item pci,
                   &APP_SCHEMA.pcm_physical_contract_main pcm,
                   &APP_SCHEMA.pip_physical_item_pricing pip,
                   &APP_SCHEMA.ppu_product_price_units ppu,
                   &APP_SCHEMA.piq_physical_item_quality piq,
                   &APP_SCHEMA.cm_currency_master cm,
                   &APP_SCHEMA.clm_calendar_master clm,
                   &APP_SCHEMA.qat_quality_attributes qat,
                   &APP_SCHEMA.v_contract_item_val_month vcim
             WHERE pci.internal_contract_ref_no = pcm.internal_contract_ref_no
               AND ppu.product_id = pdm.product_id
               AND ppu.internal_price_unit_id = pip.price_unit_id
               AND drm.instrument_id = dim.instrument_id
               --dr_id
               AND pci.internal_contract_item_ref_no =
                                            vcim.internal_contract_item_ref_no
               AND vcim.val_dr_id = drm.dr_id
               AND dim.product_derivative_id = pdd.derivative_def_id
               AND pdd.product_id = pdm.product_id
               AND pdd.exchange_id = emt.exchange_id(+)
               AND dim.instrument_type_id = irm.instrument_type_id
               AND pum.cur_id = cm.cur_id
               AND dim.holiday_calender_id = clm.calendar_id
               AND pdm.product_asset_class = pac.asset_id
               AND piq.quality_id = qat.quality_id
               AND ppu.price_unit_id = pum.price_unit_id
               AND pac.asset_desc <> 'Currency'
               AND pci.internal_contract_item_ref_no =
                                             pip.internal_contract_item_ref_no
               AND pci.internal_contract_item_ref_no =
                                             piq.internal_contract_item_ref_no
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_cm_currency_master (cur_id,
                                                   cur_code,
                                                   cur_name,
                                                   is_sub_cur,
                                                   decimals,
                                                   display_order,
                                                   VERSION,
                                                   is_active,
                                                   is_deleted
                                                  )
AS
   SELECT "CUR_ID", "CUR_CODE", "CUR_NAME", "IS_SUB_CUR", "DECIMALS",
          "DISPLAY_ORDER", "VERSION", "IS_ACTIVE", "IS_DELETED"
     FROM &APP_SCHEMA.cm_currency_master
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_ak_corporate_user (user_id,
                                                  login_name,
                                                  PASSWORD,
                                                  supervisor_id,
                                                  lang_code,
                                                  registered,
                                                  TIME_ZONE,
                                                  want_message,
                                                  gabid,
                                                  password_updated_date,
                                                  password_updated_by,
                                                  user_status,
                                                  no_of_invalid_login_attempts,
                                                  password_reset_times,
                                                  last_reset_date,
                                                  last_reset_by,
                                                  user_type,
                                                  is_password_locked,
                                                  is_super_user
                                                 )
AS
   SELECT "USER_ID", "LOGIN_NAME", "PASSWORD", "SUPERVISOR_ID", "LANG_CODE",
          "REGISTERED", "TIME_ZONE", "WANT_MESSAGE", "GABID",
          "PASSWORD_UPDATED_DATE", "PASSWORD_UPDATED_BY", "USER_STATUS",
          "NO_OF_INVALID_LOGIN_ATTEMPTS", "PASSWORD_RESET_TIMES",
          "LAST_RESET_DATE", "LAST_RESET_BY", "USER_TYPE",
          "IS_PASSWORD_LOCKED", "IS_SUPER_USER"
     FROM &APP_SCHEMA.ak_corporate_user
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_ak_corporate (corporate_id,
                                             corporate_name,
                                             lang_code,
                                             TIME_ZONE,
                                             groupid,
                                             corp_short_name,
                                             base_cur_id,
                                             inv_cur_id,
                                             corp_display_name1,
                                             corp_display_name2,
                                             display_order,
                                             VERSION,
                                             is_active,
                                             is_deleted,
                                             is_internal_corporate
                                            )
AS
   SELECT "CORPORATE_ID", "CORPORATE_NAME", "LANG_CODE", "TIME_ZONE",
          "GROUPID", "CORP_SHORT_NAME", "BASE_CUR_ID", "INV_CUR_ID",
          "CORP_DISPLAY_NAME1", "CORP_DISPLAY_NAME2", "DISPLAY_ORDER",
          "VERSION", "IS_ACTIVE", "IS_DELETED", "IS_INTERNAL_CORPORATE"
     FROM &APP_SCHEMA.ak_corporate
/


/* Formatted on 2011/10/21 12:38 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_tag_prompt_months (prompt_month_id,
                                                  prompt_month_name,
                                                  prompt_date
                                                 )
AS
   SELECT DISTINCT (   TO_CHAR (drm.prompt_date, 'Mon')
                    || ' '
                    || TO_CHAR (drm.prompt_date, 'yyyy')
                   ) prompt_month_id,
                   (   TO_CHAR (drm.prompt_date, 'Mon')
                    || ' '
                    || TO_CHAR (drm.prompt_date, 'yyyy')
                   ) prompt_month_name,
                   drm.prompt_date
              FROM v_tag_derivative_details drm
          ORDER BY drm.prompt_date
/




CREATE OR REPLACE PACKAGE                      "PKG_CRC_GENERAL" IS

    -- All general packages and procedures
 
    FUNCTION f_get_currency_code(pc_cur_id VARCHAR2) RETURN VARCHAR2;

    FUNCTION f_get_quantity_unit(pc_quantity_unit_id VARCHAR2) RETURN VARCHAR2;
    
    FUNCTION f_get_price_unit(pc_price_unit_id VARCHAR2) RETURN VARCHAR2;
    
    FUNCTION f_get_company_name(pc_input_profile_id VARCHAR2) RETURN VARCHAR2;
    
    FUNCTION f_get_corporate_user_name(pc_input_user_id VARCHAR2) RETURN VARCHAR2;
  

--ENDS HERE
--
END;
/



CREATE OR REPLACE PACKAGE BODY                      "PKG_CRC_GENERAL" IS

    FUNCTION f_get_currency_code(pc_cur_id VARCHAR2) RETURN VARCHAR2 IS
        vc_currency_code VARCHAR2(15);
    BEGIN
        SELECT cm.cur_code
        INTO   vc_currency_code
        FROM   &APP_SCHEMA.cm_currency_master cm
        WHERE  cm.cur_id = pc_cur_id;
        RETURN(vc_currency_code);
    END;
    
    FUNCTION f_get_quantity_unit(pc_quantity_unit_id VARCHAR2) RETURN VARCHAR2 IS
        vc_qty_unit_id VARCHAR2(15);
    BEGIN
        SELECT qum.qty_unit
        INTO   vc_qty_unit_id
        FROM   &APP_SCHEMA.QUM_QUANTITY_UNIT_MASTER qum
        WHERE  qum.qty_unit_id = pc_quantity_unit_id;
        RETURN(vc_qty_unit_id);
    END;

    

    FUNCTION f_get_price_unit(pc_price_unit_id VARCHAR2) RETURN VARCHAR2 IS
        vc_price_unit VARCHAR2(50);
    BEGIN
        SELECT f_get_currency_code(ppu.cur_id) || ' / ' || ppu.weight || ' ' ||
               f_get_quantity_unit(ppu.weight_unit_id)
        INTO   vc_price_unit
        FROM   &APP_SCHEMA.PUM_PRICE_UNIT_MASTER ppu
        WHERE  ppu.price_unit_id = pc_price_unit_id;
        RETURN(vc_price_unit);
    END;

    FUNCTION f_get_company_name(pc_input_profile_id VARCHAR2) RETURN VARCHAR2 IS
        vc_company_name VARCHAR2(50);
    BEGIN
        SELECT phd.companyname
        INTO   vc_company_name
        FROM   &APP_SCHEMA.PHD_PROFILEHEADERDETAILS  phd
        WHERE  phd.profileid = pc_input_profile_id;
        RETURN(vc_company_name);
    END;

    FUNCTION f_get_corporate_user_name(pc_input_user_id VARCHAR2) RETURN VARCHAR2 IS
        vc_user_name VARCHAR2(50);
    BEGIN
        SELECT gab.firstname || ' ' || gab.lastname
        INTO   vc_user_name
        FROM   &APP_SCHEMA.ak_corporate_user     aku,
               &APP_SCHEMA.gab_globaladdressbook gab
        WHERE  aku.gabid = gab.gabid
        AND    aku.user_id = pc_input_user_id;
        RETURN(vc_user_name);
    END;

    
--ENDS HERE
END;
/
DROP VIEW V_COMMODITY_CURVES;

/* Formatted on 2011/08/10 23:46 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_commodity_curves (dr_id,
                                                 instrument_name,
                                                 instrument_id,
                                                 instrument_type,
                                                 instrument_type_id,
                                                 instrument,
                                                 instrument_symbol,
                                                 exchange_address,
                                                 exchange_id,
                                                 product_desc,
                                                 product_id,
                                                 quality_name,
                                                 quality_id,
                                                 holiday_calender,
                                                 calendar_id,
                                                 price_unit_name,
                                                 price_unit_id,
                                                 cur_code,
                                                 cur_id,
                                                 price_source_name,
                                                 price_source_id,
                                                 product_asset_class,
                                                 is_cash_settlement,
                                                 is_physical_settlement,
                                                 created_date,
                                                 is_phy_val_curve
                                                )
AS
   SELECT DISTINCT drm.dr_id, dim.instrument_name, dim.instrument_id,
                   (pdd.traded_on || ' Trade') instrument_type,
                   irm.instrument_type_id, irm.instrument_type instrument,
                   dim.instrument_symbol,
                   (emt.exchange_name || ' ' || emt.exchange_address
                   ) exchange_address,
                   emt.exchange_id, pdm.product_desc, pdm.product_id,
                   qat.quality_name, qat.quality_id,
                   clm.calendar_name holiday_calender, clm.calendar_id,
                   pum.price_unit_name, drt.trade_price_unit_id price_unit_id,
                   cm.cur_code, cm.cur_id, '' price_source_name,
                   '' price_source_id, pac.asset_desc product_asset_class,
                   is_cash_settlement, is_physical_settlement,
                   MAX (drt.created_date) OVER (PARTITION BY 1) created_date,
                   'N' is_phy_val_curve
              FROM traxys_automation_app.v_cdc_derivative_master drm,
                   traxys_automation_app.dim_der_instrument_master dim,
                   traxys_automation_app.pdd_product_derivative_def pdd,
                   traxys_automation_app.emt_exchangemaster emt,
                   traxys_automation_app.irm_instrument_type_master irm,
                   traxys_automation_app.pac_product_asset_class pac,
                   traxys_automation_app.pum_price_unit_master pum,
                   traxys_automation_app.pdm_productmaster pdm,
                   traxys_automation_app.v_cdc_derivative_trade drt,
                   traxys_automation_app.cm_currency_master cm,
                   traxys_automation_app.clm_calendar_master clm,
                   traxys_automation_app.qat_quality_attributes qat
             WHERE drt.dr_id = drm.dr_id
               AND drm.instrument_id = dim.instrument_id
               AND dim.product_derivative_id = pdd.derivative_def_id
               AND pdd.product_id = pdm.product_id
               AND pdd.exchange_id = emt.exchange_id(+)
               AND dim.instrument_type_id = irm.instrument_type_id
               AND pum.cur_id = cm.cur_id
               AND dim.holiday_calender_id = clm.calendar_id
               AND pdm.product_asset_class = pac.asset_id
               AND drt.quality_id = qat.quality_id(+)
               AND drt.trade_price_unit_id = pum.price_unit_id(+)
               AND pac.asset_desc <> 'Currency'
/*  UNION
   SELECT DISTINCT drm.dr_id, dim.instrument_name, dim.instrument_id,
                   (pdd.traded_on || ' Trade') instrument_type,
                   irm.instrument_type_id, irm.instrument_type instrument,
                   dim.instrument_symbol,
                   (emt.exchange_name || ' ' || emt.exchange_address
                   ) exchange_address,
                   emt.exchange_id, pdm.product_desc, pdm.product_id,
                   qat.quality_name, qat.quality_id,
                   clm.calendar_name holiday_calender, clm.calendar_id,
                   pum.price_unit_name, ppu.price_unit_id price_unit_id,
                   cm.cur_code, cm.cur_id, '' price_source_name,
                   '' price_source_id, pac.asset_desc product_asset_class,
                   is_cash_settlement, is_physical_settlement,
                   MAX (pcm.issue_date) OVER (PARTITION BY 1) created_date,
                   'Y' is_phy_val_curve
              FROM traxys_automation_app.v_cdc_derivative_master drm,
                   traxys_automation_app.dim_der_instrument_master dim,
                   traxys_automation_app.pdd_product_derivative_def pdd,
                   traxys_automation_app.emt_exchangemaster emt,
                   traxys_automation_app.irm_instrument_type_master irm,
                   traxys_automation_app.pac_product_asset_class pac,
                   traxys_automation_app.pum_price_unit_master pum,
                   traxys_automation_app.pdm_productmaster pdm,
                   traxys_automation_app.pci_physical_contract_item pci,
                   traxys_automation_app.pcm_physical_contract_main pcm,
                   traxys_automation_app.pip_physical_item_pricing pip,
                   traxys_automation_app.ppu_product_price_units ppu,
                   traxys_automation_app.piq_physical_item_quality piq,
                   traxys_automation_app.cm_currency_master cm,
                   traxys_automation_app.clm_calendar_master clm,
                   traxys_automation_app.qat_quality_attributes qat,
                   traxys_automation_app.v_contract_item_val_month vcim
             WHERE pci.internal_contract_ref_no = pcm.internal_contract_ref_no
               AND ppu.product_id = pdm.product_id
               AND ppu.internal_price_unit_id = pip.price_unit_id
               AND drm.instrument_id = dim.instrument_id
               --dr_id
               AND pci.internal_contract_item_ref_no =
                                            vcim.internal_contract_item_ref_no
               AND vcim.val_dr_id = drm.dr_id
               AND dim.product_derivative_id = pdd.derivative_def_id
               AND pdd.product_id = pdm.product_id
               AND pdd.exchange_id = emt.exchange_id(+)
               AND dim.instrument_type_id = irm.instrument_type_id
               AND pum.cur_id = cm.cur_id
               AND dim.holiday_calender_id = clm.calendar_id
               AND pdm.product_asset_class = pac.asset_id
               AND piq.quality_id = qat.quality_id
               AND ppu.price_unit_id = pum.price_unit_id
               AND pac.asset_desc <> 'Currency'
               AND pci.internal_contract_item_ref_no =
                                             pip.internal_contract_item_ref_no
               AND pci.internal_contract_item_ref_no =
                                             piq.internal_contract_item_ref_no;

*/



/* Formatted on 2011/08/11 01:35 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_trader_risk_exposure (rle_id,
                                                          process,
                                                          process_date,
                                                          qty_exposure_limit,
                                                          qty_exposure,
                                                          net_qty_exposure,
                                                          value_exposure_limit,
                                                          value_exposure,
                                                          net_value_exposure,
                                                          mtm_exposure,
                                                          m2m_exposure,
                                                          net_m2m_exposure,
                                                          limit_qty_unit_id,
                                                          limit_qty_unit,
                                                          qty_exp_unit,
                                                          qty_exp_unit_id,
                                                          exposure_curr_id,
                                                          credit_exp_cur_id,
                                                          value_exp_cur_code,
                                                          limit_currency,
                                                          contract_type
                                                         )
AS
   SELECT   MAX (rle.rle_id) rle_id, eod.process, eod.process_date,
            rle.qty_exposure qty_exposure_limit,
            SUM (eod.qty_exposure) qty_exposure,
            (  rle.qty_exposure
             - SUM
                  (traxys_automation_app.pkg_general.f_get_converted_quantity
                                                    (rle.product_id,
                                                     eod.qty_exp_unit_id,
                                                     rle.exposure_qty_unit_id,
                                                     eod.qty_exposure
                                                    )
                  )
            ) net_qty_exposure,
            rle.value_exposure value_exposure_limit,
            SUM (eod.value_exposure) value_exposure,
            (  rle.value_exposure
             - SUM
                  (traxys_automation_app.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.value_exposure
                                                        )
                  )
            ) net_value_exposure,
            rle.mtm_exposure, SUM (eod.m2m_exposure) m2m_exposure,
            (  rle.mtm_exposure
             - SUM
                  (traxys_automation_app.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.m2m_exposure
                                                        )
                  )
            ) net_m2m_exposure,
            rle.exposure_qty_unit_id limit_qty_unit_id,
            qum.qty_unit limit_qty_unit, MAX (eod.qty_exp_unit) qty_exp_unit,
            MAX (eod.qty_exp_unit_id) qty_exp_unit_id, rle.exposure_curr_id,
            MAX (eod.credit_exp_cur_id) credit_exp_cur_id,
            MAX (eod.value_exp_cur_code) value_exp_cur_code,
            cm.cur_code limit_currency,
            DECODE (rle.contract_type,
                    'Net', 'Net',
                    eod.contract_type
                   ) contract_type
       FROM rle_risk_limit_exposure rle,
            rlt_risk_limit_type rlt,
            v_cm_currency_master cm,
            v_qum_quantity_unit qum,
            TRAXYS_AUTOMATION_EOD.tre_trader_risk_exposure eod
      WHERE rle.rlt_id = rlt.rlt_id
        AND rlt.risk_type = 'TRADER RISK LIMIT'
        AND rle.exposure_curr_id = cm.cur_id
        AND rle.exposure_qty_unit_id = qum.qty_unit_id
        AND rle.product_id = eod.product_id
        AND rle.limit_id = eod.trader_user_id
        AND (CASE
                WHEN rle.org_level_id = 'CorporateGroup'
                   THEN eod.GROUP_ID
                WHEN rle.org_level_id = 'Corporate'
                   THEN eod.corporate_id
                ELSE eod.profit_center_id
             END
            ) = rle.org_id
        AND rle.contract_type =
                   DECODE (rle.contract_type,
                           'Net', 'Net',
                           eod.contract_type
                          )
   GROUP BY eod.process,
            eod.process_date,
            rle.value_exposure,
            rle.exposure_curr_id,
            rle.qty_exposure,
            rle.exposure_qty_unit_id,
            qum.qty_unit,
            rle.mtm_exposure,
            cm.cur_code,
            DECODE (rle.contract_type, 'Net', 'Net', eod.contract_type);


DROP VIEW V_LIST_CP_RISK_EXPOSURE;

/* Formatted on 2011/08/11 02:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW v_list_cp_risk_exposure (rle_id,
                                                      process,
                                                      process_date,
                                                      qty_exposure_limit,
                                                      qty_exposure,
                                                      net_qty_exposure,
                                                      value_exposure_limit,
                                                      value_exposure,
                                                      net_value_exposure,
                                                      mtm_exposure,
                                                      m2m_exposure,
                                                      net_m2m_exposure,
                                                      limit_qty_unit_id,
                                                      limit_qty_unit,
                                                      qty_exp_unit,
                                                      qty_exp_unit_id,
                                                      exposure_curr_id,
                                                      credit_exp_cur_id,
                                                      value_exp_cur_code,
                                                      limit_currency,
                                                      contract_type
                                                     )
AS
   SELECT   MAX (rle.rle_id) rle_id, eod.process, eod.process_date,
            rle.qty_exposure qty_exposure_limit,
            SUM (eod.qty_exposure) qty_exposure,
            (  rle.qty_exposure
             - SUM
                  (traxys_automation_app.pkg_general.f_get_converted_quantity
                                                    (rle.product_id,
                                                     eod.qty_exp_unit_id,
                                                     rle.exposure_qty_unit_id,
                                                     eod.qty_exposure
                                                    )
                  )
            ) net_qty_exposure,
            rle.value_exposure value_exposure_limit,
            SUM (eod.value_exposure) value_exposure,
            (  rle.value_exposure
             - SUM
                  (traxys_automation_app.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.value_exposure
                                                        )
                  )
            ) net_value_exposure,
            rle.mtm_exposure, SUM (eod.m2m_exposure) m2m_exposure,
            (  rle.mtm_exposure
             - SUM
                  (traxys_automation_app.pkg_general.f_get_converted_currency_amt
                                                        (rle.product_id,
                                                         eod.value_exp_cur_id,
                                                         rle.exposure_curr_id,
                                                         SYSDATE,
                                                         eod.m2m_exposure
                                                        )
                  )
            ) net_m2m_exposure,
            rle.exposure_qty_unit_id limit_qty_unit_id,
            qum.qty_unit limit_qty_unit, MAX (eod.qty_exp_unit) qty_exp_unit,
            MAX (eod.qty_exp_unit_id) qty_exp_unit_id, rle.exposure_curr_id,
            MAX (eod.credit_exp_cur_id) credit_exp_cur_id,
            MAX (eod.value_exp_cur_code) value_exp_cur_code,
            cm.cur_code limit_currency,
            DECODE (rle.contract_type,
                    'Net', 'Net',
                    eod.contract_type
                   ) contract_type
       FROM rle_risk_limit_exposure rle,
            rlt_risk_limit_type rlt,
            v_cm_currency_master cm,
            v_qum_quantity_unit qum,
            TRAXYS_AUTOMATION_EOD.cre_cp_risk_exposure eod
      WHERE rle.rlt_id = rlt.rlt_id
        AND rlt.risk_type = 'CP RISK LIMIT'
        AND rle.exposure_curr_id = cm.cur_id
        AND rle.exposure_qty_unit_id = qum.qty_unit_id
        AND rle.product_id = eod.product_id
        AND rle.limit_id = eod.cp_profile_id
        AND (CASE
                WHEN rle.org_level_id = 'CorporateGroup'
                   THEN eod.GROUP_ID
                WHEN rle.org_level_id = 'Corporate'
                   THEN eod.corporate_id
                ELSE eod.profit_center_id
             END
            ) = rle.org_id
        AND rle.contract_type =
                   DECODE (rle.contract_type,
                           'Net', 'Net',
                           eod.contract_type
                          )
   GROUP BY eod.process,
            eod.process_date,
            rle.value_exposure,
            rle.exposure_curr_id,
            rle.qty_exposure,
            rle.exposure_qty_unit_id,
            qum.qty_unit,
            rle.mtm_exposure,
            cm.cur_code,
            DECODE (rle.contract_type, 'Net', 'Net', eod.contract_type);


/


