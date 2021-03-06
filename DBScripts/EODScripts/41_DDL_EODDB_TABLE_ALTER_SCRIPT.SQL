ALTER TABLE AGD_ALLOC_GROUP_DETAIL  MODIFY (  QTY_IN_SALES_UNIT NUMBER (35,10) );
ALTER TABLE AGD_ALLOC_GROUP_DETAIL  MODIFY (  QTY NUMBER (35,10) );
ALTER TABLE AGDUL_ALLOC_GROUP_DETAIL_UL   MODIFY(QTY_IN_SALES_UNIT VARCHAR2(30 CHAR));
ALTER TABLE AGDUL_ALLOC_GROUP_DETAIL_UL    MODIFY(QTY VARCHAR2(30 CHAR));
ALTER TABLE AGH_ALLOC_GROUP_HEADER  MODIFY (  ALLOC_ITEM_QTY NUMBER (35,10) );
ALTER TABLE AGH_ALLOC_GROUP_HEADER  MODIFY (  GRAVITY NUMBER (35,10) );
ALTER TABLE AGHUL_ALLOC_GROUP_HEADER_UL   MODIFY(ALLOC_ITEM_QTY VARCHAR2(30 CHAR));
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  QTY NUMBER (35,10) );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  TOLLING_QTY NUMBER (35,10) );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  MOVED_OUT_QTY NUMBER (35,10) );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  CURRENT_QTY NUMBER (35,10) );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  GRAVITY NUMBER (35,10) );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  RELEASED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  PLAN_SHIP_QTY NUMBER (35,10) DEFAULT 0  );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  FINAL_WEIGHT NUMBER (35,10) DEFAULT 0 );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  LANDED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  WEIGHED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE AGMR_ACTION_GMR  MODIFY (  SHIPPED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE ASM_ASSAY_SUBLOT_MAPPING  MODIFY (  NET_WEIGHT NUMBER (35,10) );
ALTER TABLE ASM_ASSAY_SUBLOT_MAPPING  MODIFY (  DRY_WEIGHT NUMBER (35,10) );
ALTER TABLE CIGCUL_CONTRCT_ITM_GMR_COST_UL   MODIFY(QTY VARCHAR2(30 CHAR));
ALTER TABLE CIGCUL_CONTRCT_ITM_GMR_COST_UL   MODIFY(QTY_IN_BASE_QTY_UNIT VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(COST_VALUE VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(TRANSACTION_AMT VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(FX_TO_BASE VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(BASE_AMT VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(COST_IN_BASE_PRICE_UNIT_ID VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(COST_IN_TRANSACT_PRICE_UNIT_ID VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(ESTIMATED_AMT VARCHAR2(30 CHAR));
ALTER TABLE CSUL_COST_STORE_UL   MODIFY(DELTA_COST_IN_BASE_PRICE_ID VARCHAR2(30 CHAR));
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  P_SHIPPED_NET_WEIGHT NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  ITEM_PRICE NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  P_SHIPPED_GROSS_WEIGHT NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  GRAVITY NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  CURRENT_QTY NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  VESSEL_QTY_BEFORE_DISCHARGE NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  TOTAL_QTY NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  GROSS_WEIGHT NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  NET_WEIGHT NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  REALIZED_QTY NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  OLD_NET_WEIGHT NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  P_SHIPPED_TARE_WEIGHT NUMBER (35,10) );
ALTER TABLE DGRD_DELIVERED_GRD  MODIFY (  TARE_WEIGHT NUMBER (35,10) );
ALTER TABLE FSH_FIN_SETTLEMENT_HEADER  MODIFY (  SETTLEMENT_PRICE NUMBER (35,10) );
ALTER TABLE FSH_FIN_SETTLEMENT_HEADER  MODIFY (  MARKET_PRICE NUMBER (35,10) );
ALTER TABLE FSH_FIN_SETTLEMENT_HEADER  MODIFY (  CONTRACT_PRICE NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  LOADED_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  TT_OUT_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  FULFILLED_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  CURRENT_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  DISCHARGED_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  VOYAGE_ALLOC_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  MOVED_OUT_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  GRAVITY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  TT_UNDER_CMA_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  TOLLING_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  ADD (  CARRY_OVER_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  TT_IN_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  TOTAL_GROSS_WEIGHT NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  TT_NONE_QTY NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  TOTAL_TARE_WEIGHT NUMBER (35,10) );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  SHIPPED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  LANDED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  FINAL_WEIGHT NUMBER (35,10) DEFAULT 0 );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  RELEASED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  WEIGHED_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE GMR_GOODS_MOVEMENT_RECORD  MODIFY (  PLAN_SHIP_QTY NUMBER (35,10) DEFAULT 0 );
ALTER TABLE GMRUL_GMR_UL  MODIFY(LOADED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(TT_OUT_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(FULFILLED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(CURRENT_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(DISCHARGED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(VOYAGE_ALLOC_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(MOVED_OUT_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(TT_UNDER_CMA_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(TOLLING_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  ADD(CARRY_OVER_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(TT_IN_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  ADD(TOTAL_GROSS_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(TT_NONE_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  ADD(TOTAL_TARE_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(SHIPPED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(LANDED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(FINAL_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(RELEASED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(WEIGHED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  MODIFY(PLAN_SHIP_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  ADD(GROSS_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  ADD(REALIZED_QTY VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  ADD(OLD_NET_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE GMRUL_GMR_UL  ADD(TARE_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  LANDED_GROSS_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  TITLE_TRANSFER_OUT_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  ALLOCATED_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  TOLLING_QTY NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  WRITE_OFF_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  RELEASE_SHIPPED_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  SHIPPED_NET_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  CURRENT_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  SHIPPED_GROSS_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  GROSS_WEIGHT_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  DISCHARGED_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  MOVED_OUT_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  TARE_WEIGHT_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  CARRY_OVER_QTY NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  GRAVITY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  TOTAL_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRDL_GOODS_RECORD_DETAIL_LOG  MODIFY (  LANDED_NET_QTY_DELTA NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  RELEASE_SHIPPED_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  LANDED_NET_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  CURRENT_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  ALLOCATED_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  GROSS_WEIGHT NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  CARRY_OVER_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  MOVED_OUT_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  SHIPPED_GROSS_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  TOLLING_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  TOTAL_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  GRAVITY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  DISCHARGED_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  WRITE_OFF_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  TARE_WEIGHT NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  LANDED_GROSS_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  SHIPPED_NET_QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  QTY NUMBER (35,10) );
ALTER TABLE GRD_GOODS_RECORD_DETAIL  MODIFY (  TITLE_TRANSFER_OUT_QTY NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  TOTAL_AMOUNT_TO_PAY NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  INVOICED_QTY NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  TOTAL_OTHER_CHARGE_AMOUNT NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  API_ADJUSTED_AMOUNT NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  FX_TO_BASE NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  TOTAL_TAX_AMOUNT NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  ADD (  ACCRUED_PUR_AMT NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  NEW_INVOICED_QTY NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  AMOUNT_PAID NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  AMOUNT_TO_PAY_BEFORE_ADJ NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  INVOICED_PRICE NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  TOTAL_INVOICE_ITEM_AMOUNT NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  MODIFY (  NEW_FX_RATE NUMBER (35,10) );
ALTER TABLE IS_INVOICE_SUMMARY  ADD (  PROV_PCTG_AMT NUMBER (35,10) );
ALTER TABLE LDC_LOCATION_DIFF_COST  MODIFY (  COST_VALUE NUMBER (35,10)  );
ALTER TABLE MOGRD_MOVED_OUT_GRD  MODIFY (  GROSS_WEIGHT NUMBER (35,10) );
ALTER TABLE MOGRD_MOVED_OUT_GRD  MODIFY (  TARE_WEIGHT NUMBER (35,10) );
ALTER TABLE MOGRD_MOVED_OUT_GRD  MODIFY (  MOVED_OUT_QTY NUMBER (35,10) );
ALTER TABLE MOGRDUL_MOVED_OUT_GRD_UL MODIFY(MOVED_OUT_QTY VARCHAR2(30 CHAR));
ALTER TABLE MOGRDUL_MOVED_OUT_GRD_UL MODIFY(TARE_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE MOGRDUL_MOVED_OUT_GRD_UL MODIFY(GROSS_WEIGHT VARCHAR2(30 CHAR));
ALTER TABLE PFQPP_PHY_FORMULA_QP_PRICING  MODIFY (  QTY_TO_BE_PRICED NUMBER (35,10) );
ALTER TABLE PFQPPUL_PHY_FORMULA_QP_PRC_UL MODIFY(QTY_TO_BE_PRICED VARCHAR2(30 CHAR));
ALTER TABLE PPFD_PHY_PRICE_FORMULA_DETAILS  MODIFY (  BASIS NUMBER (35,10) );
ALTER TABLE VDUL_VOYAGE_DETAIL_UL  MODIFY (  DECLARED_VALUE_CUSTOMS NUMBER (35,10) );
ALTER TABLE VDUL_VOYAGE_DETAIL_UL  MODIFY (  VOYAGE_QUANTITY NUMBER (35,10) );
ALTER TABLE VD_VOYAGE_DETAIL  MODIFY (  VOYAGE_QUANTITY NUMBER (35,10) );
ALTER TABLE VD_VOYAGE_DETAIL  MODIFY (  DECLARED_VALUE_CUSTOMS NUMBER (35,10) );
