
alter  table AGD_ALLOC_GROUP_DETAIL modify( INTERNAL_ACTION_REF_NO  null);
alter  table AGH_ALLOC_GROUP_HEADER modify( INTERNAL_ACTION_REF_NO  null);

alter  table CIGC_CONTRACT_ITEM_GMR_COST modify( COG_REF_NO  null);
alter  table CIGC_CONTRACT_ITEM_GMR_COST modify( IS_DELETED  null);
alter  table CIGC_CONTRACT_ITEM_GMR_COST modify( VERSION  null);
alter  table CIGCUL_CONTRCT_ITM_GMR_COST_UL modify( COGUL_REF_NO  null);
alter  table CIGCUL_CONTRCT_ITM_GMR_COST_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table CIGCUL_CONTRCT_ITM_GMR_COST_UL modify( ENTRY_TYPE  null);
alter  table CIGCUL_CONTRCT_ITM_GMR_COST_UL modify( COG_REF_NO  null);
alter  table CIGCUL_CONTRCT_ITM_GMR_COST_UL modify( IS_DELETED  null);
alter  table CIGCUL_CONTRCT_ITM_GMR_COST_UL modify( VERSION  null);

alter  table CS_COST_STORE modify( INTERNAL_COST_ID  null);
alter  table CS_COST_STORE modify( INTERNAL_ACTION_REF_NO  null);
alter  table CS_COST_STORE modify( COG_REF_NO  null);
alter  table CS_COST_STORE modify( COST_REF_NO  null);
alter  table CS_COST_STORE modify( COST_TYPE  null);
alter  table CS_COST_STORE modify( COST_COMPONENT_ID  null);
alter  table CS_COST_STORE modify( RATE_TYPE  null);
alter  table CS_COST_STORE modify( COST_VALUE  null);
alter  table CS_COST_STORE modify( TRANSACTION_AMT  null);
alter  table CS_COST_STORE modify( TRANSACTION_AMT_CUR_ID  null);
alter  table CS_COST_STORE modify( FX_TO_BASE  null);
alter  table CS_COST_STORE modify( TRANSACT_AMT_SIGN  null);
alter  table CS_COST_STORE modify( COST_ACC_TYPE  null);
alter  table CS_COST_STORE modify( BASE_AMT  null);
alter  table CS_COST_STORE modify( BASE_AMT_CUR_ID  null);
alter  table CS_COST_STORE modify( COST_IN_BASE_PRICE_UNIT_ID  null);
alter  table CS_COST_STORE modify( IS_INV_POSSIBLE  null);
alter  table CS_COST_STORE modify( VERSION  null);
alter  table CS_COST_STORE modify( IS_DELETED  null);
alter  table CSUL_COST_STORE_UL modify( INTERNAL_COST_UL_ID  null);
alter  table CSUL_COST_STORE_UL modify( INTERNAL_COST_ID  null);
alter  table CSUL_COST_STORE_UL modify( ENTRY_TYPE  null);
alter  table CSUL_COST_STORE_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table CSUL_COST_STORE_UL modify( COG_REF_NO  null);
alter  table CSUL_COST_STORE_UL modify( COST_REF_NO  null);
alter  table CSUL_COST_STORE_UL modify( COST_TYPE  null);
alter  table CSUL_COST_STORE_UL modify( COST_COMPONENT_ID  null);
alter  table CSUL_COST_STORE_UL modify( RATE_TYPE  null);
alter  table CSUL_COST_STORE_UL modify( COST_VALUE  null);
alter  table CSUL_COST_STORE_UL modify( TRANSACTION_AMT  null);
alter  table CSUL_COST_STORE_UL modify( TRANSACTION_AMT_CUR_ID  null);
alter  table CSUL_COST_STORE_UL modify( FX_TO_BASE  null);
alter  table CSUL_COST_STORE_UL modify( TRANSACT_AMT_SIGN  null);
alter  table CSUL_COST_STORE_UL modify( COST_ACC_TYPE  null);
alter  table CSUL_COST_STORE_UL modify( BASE_AMT  null);
alter  table CSUL_COST_STORE_UL modify( BASE_AMT_CUR_ID  null);
alter  table CSUL_COST_STORE_UL modify( COST_IN_BASE_PRICE_UNIT_ID  null);
alter  table CSUL_COST_STORE_UL modify( IS_INV_POSSIBLE  null);
alter  table CSUL_COST_STORE_UL modify( VERSION  null);
alter  table CSUL_COST_STORE_UL modify( IS_DELETED  null);

alter  table DGRD_DELIVERED_GRD modify( INTERNAL_ACTION_REF_NO  null);

alter  table PCAD_PC_AGENCY_DETAIL modify( PCAD_ID  null);
alter  table PCAD_PC_AGENCY_DETAIL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCAD_PC_AGENCY_DETAIL modify( AGENCY_CP_ID  null);
alter  table PCAD_PC_AGENCY_DETAIL modify( VERSION  null);
alter  table PCAD_PC_AGENCY_DETAIL modify( IS_ACTIVE  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( PCADUL_ID  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( PCAD_ID  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( AGENCY_CP_ID  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( VERSION  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( ENTRY_TYPE  null);
alter  table PCADUL_PC_AGENCY_DETAIL_UL modify( IS_ACTIVE  null);

alter  table PCBPD_PC_BASE_PRICE_DETAIL modify( PCBPD_ID  null);
alter  table PCBPD_PC_BASE_PRICE_DETAIL modify( PRICE_BASIS  null);
alter  table PCBPD_PC_BASE_PRICE_DETAIL modify( VERSION  null);
alter  table PCBPD_PC_BASE_PRICE_DETAIL modify( IS_ACTIVE  null);
alter  table PCBPDUL_PC_BASE_PRICE_DTL_UL modify( PCBPDUL_ID  null);
alter  table PCBPDUL_PC_BASE_PRICE_DTL_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCBPDUL_PC_BASE_PRICE_DTL_UL modify( PCBPD_ID  null);
alter  table PCBPDUL_PC_BASE_PRICE_DTL_UL modify( PRICE_BASIS  null);
alter  table PCBPDUL_PC_BASE_PRICE_DTL_UL modify( VERSION  null);
alter  table PCBPDUL_PC_BASE_PRICE_DTL_UL modify( IS_ACTIVE  null);
alter  table PCBPDUL_PC_BASE_PRICE_DTL_UL modify( ENTRY_TYPE  null);


alter  table PCBPH_PC_BASE_PRICE_HEADER modify( PCBPH_ID  null);
alter  table PCBPH_PC_BASE_PRICE_HEADER modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCBPH_PC_BASE_PRICE_HEADER modify( VERSION  null);
alter  table PCBPH_PC_BASE_PRICE_HEADER modify( IS_ACTIVE  null);
alter  table PCBPHUL_PC_BASE_PRC_HEADER_UL modify( PCBPHUL_ID  null);
alter  table PCBPHUL_PC_BASE_PRC_HEADER_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCBPHUL_PC_BASE_PRC_HEADER_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCBPHUL_PC_BASE_PRC_HEADER_UL modify( VERSION  null);
alter  table PCBPHUL_PC_BASE_PRC_HEADER_UL modify( IS_ACTIVE  null);
alter  table PCBPHUL_PC_BASE_PRC_HEADER_UL modify( ENTRY_TYPE  null);

alter  table PCDB_PC_DELIVERY_BASIS modify( PCDB_ID  null);
alter  table PCDB_PC_DELIVERY_BASIS modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCDB_PC_DELIVERY_BASIS modify( INCO_TERM_ID  null);
alter  table PCDB_PC_DELIVERY_BASIS modify( COUNTRY_ID  null);
alter  table PCDB_PC_DELIVERY_BASIS modify( STATE_ID  null);
alter  table PCDB_PC_DELIVERY_BASIS modify( CITY_ID  null);
alter  table PCDB_PC_DELIVERY_BASIS modify( VERSION  null);
alter  table PCDB_PC_DELIVERY_BASIS modify( IS_ACTIVE  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( PCDBUL_ID  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( PCDB_ID  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( INCO_TERM_ID  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( COUNTRY_ID  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( STATE_ID  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( CITY_ID  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( VERSION  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( ENTRY_TYPE  null);
alter  table PCDBUL_PC_DELIVERY_BASIS_UL modify( IS_ACTIVE  null);


alter  table PCDD_DOCUMENT_DETAILS modify( PCDD_ID  null);
alter  table PCDD_DOCUMENT_DETAILS modify( DOC_ID  null);
alter  table PCDD_DOCUMENT_DETAILS modify( DOC_TYPE  null);
alter  table PCDD_DOCUMENT_DETAILS modify( VERSION  null);
alter  table PCDD_DOCUMENT_DETAILS modify( IS_ACTIVE  null);
alter  table PCDD_DOCUMENT_DETAILS modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( PCDDUL_ID  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( ENTRY_TYPE  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( PCDD_ID  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( DOC_ID  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( DOC_TYPE  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( VERSION  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( IS_ACTIVE  null);
alter  table PCDDUL_DOCUMENT_DETAILS_UL modify( INTERNAL_CONTRACT_REF_NO  null);

alter  table PCDIOB_DI_OPTIONAL_BASIS modify( PCDIOB_ID  null);
alter  table PCDIOB_DI_OPTIONAL_BASIS modify( PCDI_ID  null);
alter  table PCDIOB_DI_OPTIONAL_BASIS modify( PCDB_ID  null);
alter  table PCDIOB_DI_OPTIONAL_BASIS modify( VERSION  null);
alter  table PCDIOB_DI_OPTIONAL_BASIS modify( IS_ACTIVE  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( PCDIOBUL_ID  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( ENTRY_TYPE  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( PCDIOB_ID  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( PCDI_ID  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( PCDB_ID  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( VERSION  null);
alter  table PCDIOBUL_DI_OPTIONAL_BASIS_UL modify( IS_ACTIVE  null);

alter  table PCDIPE_DI_PRICING_ELEMENTS modify( PCDIPE_ID  null);
alter  table PCDIPE_DI_PRICING_ELEMENTS modify( PCDI_ID  null);
alter  table PCDIPE_DI_PRICING_ELEMENTS modify( PCBPH_ID  null);
alter  table PCDIPE_DI_PRICING_ELEMENTS modify( VERSION  null);
alter  table PCDIPE_DI_PRICING_ELEMENTS modify( IS_ACTIVE  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( PCDIPEUL_ID  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( ENTRY_TYPE  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( PCDIPE_ID  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( PCDI_ID  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( PCBPH_ID  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( VERSION  null);
alter  table PCDIPEUL_DI_PRICING_ELEMNT_UL modify( IS_ACTIVE  null);

alter  table PCDIQD_DI_QUALITY_DETAILS modify( PCDIQD_ID  null);
alter  table PCDIQD_DI_QUALITY_DETAILS modify( PCDI_ID  null);
alter  table PCDIQD_DI_QUALITY_DETAILS modify( PCPQ_ID  null);
alter  table PCDIQD_DI_QUALITY_DETAILS modify( VERSION  null);
alter  table PCDIQD_DI_QUALITY_DETAILS modify( IS_ACTIVE  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( PCDIQDUL_ID  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( ENTRY_TYPE  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( PCDIQD_ID  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( PCDI_ID  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( PCPQ_ID  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( VERSION  null);
alter  table PCDIQDUL_DI_QUALITY_DETAIL_UL modify( IS_ACTIVE  null);

alter  table PCDI_PC_DELIVERY_ITEM modify( PCDI_ID  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( DELIVERY_ITEM_NO  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( SUFFIX  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( BASIS_TYPE  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( DELIVERY_PERIOD_TYPE  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( QTY_UNIT_ID  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( VERSION  null);
alter  table PCDI_PC_DELIVERY_ITEM modify( IS_ACTIVE  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( PCDIUL_ID  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( PCDI_ID  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( DELIVERY_ITEM_NO  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( SUFFIX  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( BASIS_TYPE  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( DELIVERY_PERIOD_TYPE  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( QTY_UNIT_ID  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( VERSION  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( IS_ACTIVE  null);
alter  table PCDIUL_PC_DELIVERY_ITEM_UL modify( ENTRY_TYPE  null);


alter  table PCIPF_PCI_PRICING_FORMULA modify( PCIPF_ID  null);
alter  table PCIPF_PCI_PRICING_FORMULA modify( INTERNAL_CONTRACT_ITEM_REF_NO  null);
alter  table PCIPF_PCI_PRICING_FORMULA modify( PCBPH_ID  null);
alter  table PCIPF_PCI_PRICING_FORMULA modify( VERSION  null);
alter  table PCIPF_PCI_PRICING_FORMULA modify( IS_ACTIVE  null);
alter  table PCIPFUL_PCI_PRICING_FORMULA_UL modify( PCIPFUL_ID  null);
alter  table PCIPFUL_PCI_PRICING_FORMULA_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCIPFUL_PCI_PRICING_FORMULA_UL modify( ENTRY_TYPE  null);
alter  table PCIPFUL_PCI_PRICING_FORMULA_UL modify( PCIPF_ID  null);
alter  table PCIPFUL_PCI_PRICING_FORMULA_UL modify( PCBPH_ID  null);
alter  table PCIPFUL_PCI_PRICING_FORMULA_UL modify( VERSION  null);
alter  table PCIPFUL_PCI_PRICING_FORMULA_UL modify( IS_ACTIVE  null);


alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( INTERNAL_CONTRACT_ITEM_REF_NO  null);
alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( PCPQ_ID  null);
alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( PCDI_ID  null);
alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( ITEM_QTY  null);
alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( ITEM_QTY_UNIT_ID  null);
alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( DEL_DISTRIBUTION_ITEM_NO  null);
alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( VERSION  null);
alter  table PCI_PHYSICAL_CONTRACT_ITEM modify( IS_ACTIVE  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( PCIUL_ID  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( ENTRY_TYPE  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( INTERNAL_CONTRACT_ITEM_REF_NO  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( PCPQ_ID  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( PCDI_ID  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( ITEM_QTY  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( ITEM_QTY_UNIT_ID  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( DEL_DISTRIBUTION_ITEM_NO  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( VERSION  null);
alter  table PCIUL_PHY_CONTRACT_ITEM_UL modify( IS_ACTIVE  null);

alter  table PCJV_PC_JV_DETAIL modify( PCJV_ID  null);
alter  table PCJV_PC_JV_DETAIL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCJV_PC_JV_DETAIL modify( CP_ID  null);
alter  table PCJV_PC_JV_DETAIL modify( VERSION  null);
alter  table PCJV_PC_JV_DETAIL modify( IS_ACTIVE  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( PCJVUL_ID  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( PCJV_ID  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( CP_ID  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( VERSION  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( ENTRY_TYPE  null);
alter  table PCJVUL_PC_JV_DETAIL_UL modify( IS_ACTIVE  null);


alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( CONTRACT_REF_NO  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( ISSUE_DATE  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( TRADER_ID  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( CP_ID  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( INVOICE_CURRENCY_ID  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( PRODUCT_GROUP_TYPE  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( PURCHASE_SALES  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( CORPORATE_ID  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( VERSION  null);
alter  table PCM_PHYSICAL_CONTRACT_MAIN modify( IS_ACTIVE  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( PCMUL_ID  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( CONTRACT_REF_NO  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( ISSUE_DATE  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( MIDDLE_NO  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( TRADER_ID  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( CP_ID  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( INVOICE_CURRENCY_ID  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( PRODUCT_GROUP_TYPE  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( CONTRACT_TYPE  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( PURCHASE_SALES  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( CORPORATE_ID  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( VERSION  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( ENTRY_TYPE  null);
alter  table PCMUL_PHY_CONTRACT_MAIN_UL modify( IS_ACTIVE  null);


alter  table PCPDQD_PD_QUALITY_DETAILS modify( PCPDQD_ID  null);
alter  table PCPDQD_PD_QUALITY_DETAILS modify( PCQPD_ID  null);
alter  table PCPDQD_PD_QUALITY_DETAILS modify( PCPQ_ID  null);
alter  table PCPDQD_PD_QUALITY_DETAILS modify( VERSION  null);
alter  table PCPDQD_PD_QUALITY_DETAILS modify( IS_ACTIVE  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( PCPDQDUL_ID  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( PCPDQD_ID  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( PCQPD_ID  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( PCPQ_ID  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( VERSION  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( ENTRY_TYPE  null);
alter  table PCPDQDUL_PD_QUALITY_DTL_UL modify( IS_ACTIVE  null);


alter  table PCPD_PC_PRODUCT_DEFINITION modify( PCPD_ID  null);
alter  table PCPD_PC_PRODUCT_DEFINITION modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCPD_PC_PRODUCT_DEFINITION modify( PRODUCT_ID  null);
alter  table PCPD_PC_PRODUCT_DEFINITION modify( PROFIT_CENTER_ID  null);
alter  table PCPD_PC_PRODUCT_DEFINITION modify( QTY_UNIT_ID  null);
alter  table PCPD_PC_PRODUCT_DEFINITION modify( VERSION  null);
alter  table PCPD_PC_PRODUCT_DEFINITION modify( IS_ACTIVE  null);
alter  table PCPD_PC_PRODUCT_DEFINITION modify( STRATEGY_ID  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( PCPDUL_ID  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( PCPD_ID  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( PRODUCT_ID  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( PROFIT_CENTER_ID  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( QTY_UNIT_ID  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( VERSION  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( IS_ACTIVE  null);
alter  table PCPDUL_PC_PRODUCT_DEFINTN_UL modify( STRATEGY_ID  null);

alter  table PCPQ_PC_PRODUCT_QUALITY modify( PCPQ_ID  null);
alter  table PCPQ_PC_PRODUCT_QUALITY modify( PCPD_ID  null);
alter  table PCPQ_PC_PRODUCT_QUALITY modify( QUALITY_TEMPLATE_ID  null);
alter  table PCPQ_PC_PRODUCT_QUALITY modify( VERSION  null);
alter  table PCPQ_PC_PRODUCT_QUALITY modify( IS_ACTIVE  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( PCPQUL_ID  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( PCPQ_ID  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( PCPD_ID  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( QUALITY_TEMPLATE_ID  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( VERSION  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( IS_ACTIVE  null);
alter  table PCPQUL_PC_PRODUCT_QUALITY_UL modify( ENTRY_TYPE  null);


alter  table PCQPD_PC_QUAL_PREMIUM_DISCOUNT modify( PCQPD_ID  null);
alter  table PCQPD_PC_QUAL_PREMIUM_DISCOUNT modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCQPD_PC_QUAL_PREMIUM_DISCOUNT modify( PREMIUM_DISC_NAME  null);
alter  table PCQPD_PC_QUAL_PREMIUM_DISCOUNT modify( PREMIUM_DISC_UNIT_ID  null);
alter  table PCQPD_PC_QUAL_PREMIUM_DISCOUNT modify( VERSION  null);
alter  table PCQPD_PC_QUAL_PREMIUM_DISCOUNT modify( IS_ACTIVE  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( PCQPDUL_ID  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( PCQPD_ID  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( INTERNAL_CONTRACT_REF_NO  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( PREMIUM_DISC_NAME  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( PREMIUM_DISC_UNIT_ID  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( VERSION  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( IS_ACTIVE  null);
alter  table PCQPDUL_PC_QUAL_PRM_DISCNT_UL modify( ENTRY_TYPE  null);


alter  table PFFXD_PHY_FORMULA_FX_DETAILS modify( PFFXD_ID  null);
alter  table PFFXD_PHY_FORMULA_FX_DETAILS modify( IS_ACTIVE  null);
alter  table PFFXDUL_PHY_FORMULA_FX_DTL_UL modify( PFFXDUL_ID  null);
alter  table PFFXDUL_PHY_FORMULA_FX_DTL_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PFFXDUL_PHY_FORMULA_FX_DTL_UL modify( ENTRY_TYPE  null);
alter  table PFFXDUL_PHY_FORMULA_FX_DTL_UL modify( PFFXD_ID  null);
alter  table PFFXDUL_PHY_FORMULA_FX_DTL_UL modify( VERSION  null);
alter  table PFFXDUL_PHY_FORMULA_FX_DTL_UL modify( IS_ACTIVE  null);

alter  table PFQPP_PHY_FORMULA_QP_PRICING modify( PFQPP_ID  null);
alter  table PFQPP_PHY_FORMULA_QP_PRICING modify( PPFH_ID  null);
alter  table PFQPP_PHY_FORMULA_QP_PRICING modify( QP_PRICING_PERIOD_TYPE  null);
alter  table PFQPP_PHY_FORMULA_QP_PRICING modify( IS_ACTIVE  null);
alter  table PFQPPUL_PHY_FORMULA_QP_PRC_UL modify( PFQPPUL_ID  null);
alter  table PFQPPUL_PHY_FORMULA_QP_PRC_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PFQPPUL_PHY_FORMULA_QP_PRC_UL modify( ENTRY_TYPE  null);
alter  table PFQPPUL_PHY_FORMULA_QP_PRC_UL modify( PFQPP_ID  null);
alter  table PFQPPUL_PHY_FORMULA_QP_PRC_UL modify( PPFH_ID  null);
alter  table PFQPPUL_PHY_FORMULA_QP_PRC_UL modify( QP_PRICING_PERIOD_TYPE  null);
alter  table PFQPPUL_PHY_FORMULA_QP_PRC_UL modify( IS_ACTIVE  null);


alter  table PPFH_PHY_PRICE_FORMULA_HEADER modify( PPFH_ID  null);
alter  table PPFH_PHY_PRICE_FORMULA_HEADER modify( PCBPD_ID  null);
alter  table PPFH_PHY_PRICE_FORMULA_HEADER modify( VERSION  null);
alter  table PPFH_PHY_PRICE_FORMULA_HEADER modify( IS_ACTIVE  null);
alter  table PPFHUL_PHY_PRICE_FRMLA_HDR_UL modify( PPFHUL_ID  null);
alter  table PPFHUL_PHY_PRICE_FRMLA_HDR_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PPFHUL_PHY_PRICE_FRMLA_HDR_UL modify( ENTRY_TYPE  null);
alter  table PPFHUL_PHY_PRICE_FRMLA_HDR_UL modify( PPFH_ID  null);
alter  table PPFHUL_PHY_PRICE_FRMLA_HDR_UL modify( PCBPD_ID  null);
alter  table PPFHUL_PHY_PRICE_FRMLA_HDR_UL modify( VERSION  null);
alter  table PPFHUL_PHY_PRICE_FRMLA_HDR_UL modify( IS_ACTIVE  null);


alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( PPFD_ID  null);
alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( PPFH_ID  null);
alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( INSTRUMENT_ID  null);
alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( PRICE_SOURCE_ID  null);
alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( AVAILABLE_PRICE_TYPE_ID  null);
alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( OFF_DAY_PRICE  null);
alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( VERSION  null);
alter  table PPFD_PHY_PRICE_FORMULA_DETAILS modify( IS_ACTIVE  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( PPFDUL_ID  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( INTERNAL_ACTION_REF_NO  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( ENTRY_TYPE  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( PPFD_ID  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( PPFH_ID  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( INSTRUMENT_ID  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( PRICE_SOURCE_ID  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( AVAILABLE_PRICE_TYPE_ID  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( OFF_DAY_PRICE  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( VERSION  null);
alter  table PPFDUL_PHY_PRICE_FRMULA_DTL_UL modify( IS_ACTIVE  null);



alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( ciqs_id);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify(total_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( item_qty_unit_id  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( open_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( gmr_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( title_transferred_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( price_fixed_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( allocated_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( prov_invoiced_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( final_invoiced_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( advance_payment_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( fulfilled_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( shipped_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( fin_swap_invoice_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( unallocated_qty  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( version  null);
alter table CIQS_CONTRACT_ITEM_QTY_STATUS modify( is_active  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(ciqs_id  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(entry_type  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(total_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(item_qty_unit_id  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(open_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(gmr_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(title_transferred_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(price_fixed_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(allocated_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(prov_invoiced_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(final_invoiced_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(advance_payment_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(fulfilled_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(shipped_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(fin_swap_invoice_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(unallocated_qty_delta  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(version  null);
alter table CIQSL_CONTRACT_ITM_QTY_STS_LOG modify(is_active  null);


alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(diqs_id  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(pcdi_id  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(total_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(item_qty_unit_id  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(open_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(gmr_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(title_transferred_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(price_fixed_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(allocated_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(prov_invoiced_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(final_invoiced_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(advance_payment_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(fulfilled_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(shipped_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(fin_swap_invoice_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(unallocated_qty  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(version  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(is_active  null); 
alter table DIQS_DELIVERY_ITEM_QTY_STATUS modify(called_off_qty  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(diqs_id  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(entry_type  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(pcdi_id  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(total_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(item_qty_unit_id  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(open_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(gmr_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(title_transferred_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(price_fixed_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(allocated_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(prov_invoiced_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(final_invoiced_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(advance_payment_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(fulfilled_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(shipped_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(fin_swap_invoice_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(unallocated_qty_delta  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(version  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(is_active  null); 
alter table DIQSL_DELIVERY_ITM_QTY_STS_LOG modify(called_off_qty_delta  null); 


alter table CQS_CONTRACT_QTY_STATUS modify(cqs_id  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(internal_contract_ref_no  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(total_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(item_qty_unit_id  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(open_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(gmr_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(title_transferred_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(price_fixed_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(allocated_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(prov_invoiced_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(final_invoiced_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(advance_payment_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(fulfilled_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(shipped_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(fin_swap_invoice_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(unallocated_qty  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(version  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(is_active  null); 
alter table CQS_CONTRACT_QTY_STATUS modify(called_off_qty  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(cqs_id  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(entry_type  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(internal_contract_ref_no  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(total_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(item_qty_unit_id  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(open_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(gmr_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(title_transferred_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(price_fixed_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(allocated_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(prov_invoiced_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(final_invoiced_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(advance_payment_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(fulfilled_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(shipped_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(fin_swap_invoice_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(unallocated_qty_delta  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(version  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(is_active  null); 
alter table CQSL_CONTRACT_QTY_STATUS_LOG modify(called_off_qty_delta  null); 

alter table GRDL_GOODS_RECORD_DETAIL_LOG modify(ENTRY_TYPE  null); 

alter table PCPCH_PC_PAYBLE_CONTENT_HEADER modify(PCPCH_ID  null); 
alter table PCPCH_PC_PAYBLE_CONTENT_HEADER modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCPCH_PC_PAYBLE_CONTENT_HEADER modify(RANGE_UNIT_ID  null); 
alter table PCPCH_PC_PAYBLE_CONTENT_HEADER modify(ELEMENT_ID  null); 
alter table PCPCH_PC_PAYBLE_CONTENT_HEADER modify(SLAB_TIER  null); 
alter table PCPCH_PC_PAYBLE_CONTENT_HEADER modify(VERSION  null); 
alter table PCPCH_PC_PAYBLE_CONTENT_HEADER modify(IS_ACTIVE  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(PCPCHUL_ID  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(ENTRY_TYPE  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(PCPCH_ID  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(RANGE_UNIT_ID  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(ELEMENT_ID  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(VERSION  null); 
alter table PCPCHUL_PAYBLE_CONTNT_HEADR_UL modify(IS_ACTIVE  null); 


alter table PQD_PAYABLE_QUALITY_DETAILS modify(PQD_ID  null); 
alter table PQD_PAYABLE_QUALITY_DETAILS modify(PCPCH_ID  null); 
alter table PQD_PAYABLE_QUALITY_DETAILS modify(PCPQ_ID  null); 
alter table PQD_PAYABLE_QUALITY_DETAILS modify(VERSION  null); 
alter table PQD_PAYABLE_QUALITY_DETAILS modify(IS_ACTIVE  null); 
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(PQDUL_ID  null); 
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(ENTRY_TYPE  null);
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(PQD_ID  null);  
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(PCPCH_ID  null); 
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(PCPQ_ID  null); 
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(VERSION  null);
alter table PQDUL_PAYABLE_QUALITY_DTL_UL modify(IS_ACTIVE  null); 


alter table PCEPC_PC_ELEM_PAYABLE_CONTENT modify(PCEPC_ID  null); 
alter table PCEPC_PC_ELEM_PAYABLE_CONTENT modify(PCPCH_ID  null); 
alter table PCEPC_PC_ELEM_PAYABLE_CONTENT modify(VERSION  null); 
alter table PCEPC_PC_ELEM_PAYABLE_CONTENT modify(IS_ACTIVE  null); 
alter table PCEPCUL_ELEM_PAYBLE_CONTENT_UL modify(PCEPCUL_ID  null); 
alter table PCEPCUL_ELEM_PAYBLE_CONTENT_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCEPCUL_ELEM_PAYBLE_CONTENT_UL modify(ENTRY_TYPE  null); 
alter table PCEPCUL_ELEM_PAYBLE_CONTENT_UL modify(PCEPC_ID  null); 
alter table PCEPCUL_ELEM_PAYBLE_CONTENT_UL modify(PCPCH_ID  null); 
alter table PCEPCUL_ELEM_PAYBLE_CONTENT_UL modify(VERSION  null); 
alter table PCEPCUL_ELEM_PAYBLE_CONTENT_UL modify(IS_ACTIVE  null); 


alter table PCTH_PC_TREATMENT_HEADER modify(PCTH_ID  null); 
alter table PCTH_PC_TREATMENT_HEADER modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCTH_PC_TREATMENT_HEADER modify(RANGE_TYPE  null);
alter table PCTH_PC_TREATMENT_HEADER modify(VERSION  null); 
alter table PCTH_PC_TREATMENT_HEADER modify(IS_ACTIVE  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(PCTHUL_ID  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(ENTRY_TYPE  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(PCTH_ID  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(RANGE_TYPE  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(VERSION  null); 
alter table PCTHUL_TREATMENT_HEADER_UL modify(IS_ACTIVE  null); 



alter table TED_TREATMENT_ELEMENT_DETAILS modify(TED_ID  null); 
alter table TED_TREATMENT_ELEMENT_DETAILS modify(PCTH_ID  null); 
alter table TED_TREATMENT_ELEMENT_DETAILS modify(ELEMENT_ID  null);
alter table TED_TREATMENT_ELEMENT_DETAILS modify(VERSION  null); 
alter table TED_TREATMENT_ELEMENT_DETAILS modify(IS_ACTIVE  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(TEDUL_ID  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(ENTRY_TYPE  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(TED_ID  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(PCTH_ID  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(ELEMENT_ID  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(VERSION  null); 
alter table TEDUL_TREATMENT_ELEMENT_DTL_UL modify(IS_ACTIVE  null); 


alter table TQD_TREATMENT_QUALITY_DETAILS modify(TQD_ID  null); 
alter table TQD_TREATMENT_QUALITY_DETAILS modify(PCTH_ID  null); 
alter table TQD_TREATMENT_QUALITY_DETAILS modify(PCPQ_ID  null);
alter table TQD_TREATMENT_QUALITY_DETAILS modify(VERSION  null); 
alter table TQD_TREATMENT_QUALITY_DETAILS modify(IS_ACTIVE  null);
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(TQDUL_ID  null); 
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(ENTRY_TYPE  null); 
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(TQD_ID  null); 
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(PCTH_ID  null); 
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(PCPQ_ID  null); 
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(VERSION  null); 
alter table TQDUL_TREATMENT_QUALITY_DTL_UL modify(IS_ACTIVE  null); 



alter table PCETC_PC_ELEM_TREATMENT_CHARGE modify(PCETC_ID  null); 
alter table PCETC_PC_ELEM_TREATMENT_CHARGE modify(PCTH_ID  null); 
alter table PCETC_PC_ELEM_TREATMENT_CHARGE modify(VERSION  null); 
alter table PCETC_PC_ELEM_TREATMENT_CHARGE modify(IS_ACTIVE  null); 
alter table PCETCUL_ELEM_TREATMNT_CHRG_UL modify(PCETCUL_ID  null); 
alter table PCETCUL_ELEM_TREATMNT_CHRG_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCETCUL_ELEM_TREATMNT_CHRG_UL modify(ENTRY_TYPE  null); 
alter table PCETCUL_ELEM_TREATMNT_CHRG_UL modify(PCETC_ID  null); 
alter table PCETCUL_ELEM_TREATMNT_CHRG_UL modify(PCTH_ID  null); 
alter table PCETCUL_ELEM_TREATMNT_CHRG_UL modify(VERSION  null); 
alter table PCETCUL_ELEM_TREATMNT_CHRG_UL modify(IS_ACTIVE  null); 
 

alter table PCAPH_PC_ATTR_PENALTY_HEADER modify(PCAPH_ID  null); 
alter table PCAPH_PC_ATTR_PENALTY_HEADER modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCAPH_PC_ATTR_PENALTY_HEADER modify(RANGE_UNIT_ID  null); 
alter table PCAPH_PC_ATTR_PENALTY_HEADER modify(SLAB_TIER  null);
alter table PCAPH_PC_ATTR_PENALTY_HEADER modify(VERSION  null); 
alter table PCAPH_PC_ATTR_PENALTY_HEADER modify(IS_ACTIVE  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(PCAPHUL_ID  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(ENTRY_TYPE  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(PCAPH_ID  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(RANGE_UNIT_ID  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(SLAB_TIER  null);
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(VERSION  null); 
alter table PCAPHUL_ATTR_PENALTY_HEADER_UL modify(IS_ACTIVE  null); 


alter table PCAP_PC_ATTRIBUTE_PENALTY modify(PCAP_ID  null); 
alter table PCAP_PC_ATTRIBUTE_PENALTY modify(PCAPH_ID  null); 
alter table PCAP_PC_ATTRIBUTE_PENALTY modify(VERSION  null); 
alter table PCAP_PC_ATTRIBUTE_PENALTY modify(IS_ACTIVE  null); 
alter table PCAPUL_ATTRIBUTE_PENALTY_UL modify(PCAPUL_ID  null); 
alter table PCAPUL_ATTRIBUTE_PENALTY_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCAPUL_ATTRIBUTE_PENALTY_UL modify(ENTRY_TYPE  null); 
alter table PCAPUL_ATTRIBUTE_PENALTY_UL modify(PCAP_ID  null); 
alter table PCAPUL_ATTRIBUTE_PENALTY_UL modify(PCAPH_ID  null);
alter table PCAPUL_ATTRIBUTE_PENALTY_UL modify(VERSION  null); 
alter table PCAPUL_ATTRIBUTE_PENALTY_UL modify(IS_ACTIVE  null); 


alter table PAD_PENALTY_ATTRIBUTE_DETAILS modify(PAD_ID  null); 
alter table PAD_PENALTY_ATTRIBUTE_DETAILS modify(PCAPH_ID  null); 
alter table PAD_PENALTY_ATTRIBUTE_DETAILS modify(ELEMENT_ID  null); 
alter table PAD_PENALTY_ATTRIBUTE_DETAILS modify(VERSION  null); 
alter table PAD_PENALTY_ATTRIBUTE_DETAILS modify(IS_ACTIVE  null); 
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(PADUL_ID  null); 
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(ENTRY_TYPE  null); 
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(PAD_ID  null); 
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(PCAPH_ID  null);
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(ELEMENT_ID  null);
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(VERSION  null); 
alter table PADUL_PENALTY_ATTRIBUTE_DTL_UL modify(IS_ACTIVE  null); 


alter table PCAR_PC_ASSAYING_RULES modify(PCAR_ID  null); 
alter table PCAR_PC_ASSAYING_RULES modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCAR_PC_ASSAYING_RULES modify(VERSION  null); 
alter table PCAR_PC_ASSAYING_RULES modify(IS_ACTIVE  null); 
alter table PCARUL_ASSAYING_RULES_UL modify(PCARUL_ID  null); 
alter table PCARUL_ASSAYING_RULES_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCARUL_ASSAYING_RULES_UL modify(ENTRY_TYPE  null); 
alter table PCARUL_ASSAYING_RULES_UL modify(PCAR_ID  null); 
alter table PCARUL_ASSAYING_RULES_UL modify(INTERNAL_CONTRACT_REF_NO  null);
alter table PCARUL_ASSAYING_RULES_UL modify(VERSION  null); 
alter table PCARUL_ASSAYING_RULES_UL modify(IS_ACTIVE  null); 

alter table PCAESL_ASSAY_ELEM_SPLIT_LIMITS modify(PCAESL_ID  null); 
alter table PCAESL_ASSAY_ELEM_SPLIT_LIMITS modify(PCAR_ID  null); 
alter table PCAESL_ASSAY_ELEM_SPLIT_LIMITS modify(ASSAY_MAX_OP  null); 
alter table PCAESL_ASSAY_ELEM_SPLIT_LIMITS modify(VERSION  null); 
alter table PCAESL_ASSAY_ELEM_SPLIT_LIMITS modify(IS_ACTIVE  null); 
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(PCAESLUL_ID  null); 
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(ENTRY_TYPE  null); 
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(PCAESL_ID  null); 
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(PCAR_ID  null);
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(ASSAY_MAX_OP  null);
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(VERSION  null); 
alter table PCAESLUL_ASSAY_ELM_SPLT_LMT_UL modify(IS_ACTIVE  null); 


alter table ARQD_ASSAY_QUALITY_DETAILS modify(ARQD_ID  null); 
alter table ARQD_ASSAY_QUALITY_DETAILS modify(PCAR_ID  null); 
alter table ARQD_ASSAY_QUALITY_DETAILS modify(PCPQ_ID  null); 
alter table ARQD_ASSAY_QUALITY_DETAILS modify(VERSION  null); 
alter table ARQD_ASSAY_QUALITY_DETAILS modify(IS_ACTIVE  null); 
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(ARQDUL_ID  null); 
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(ENTRY_TYPE  null); 
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(ARQD_ID  null); 
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(PCAR_ID  null);
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(PCPQ_ID  null);
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(VERSION  null); 
alter table ARQDUL_ASSAY_QUALITY_DTL_UL modify(IS_ACTIVE  null); 


alter table PQD_PENALTY_QUALITY_DETAILS modify(PQD_ID  null); 
alter table PQD_PENALTY_QUALITY_DETAILS modify(PCAPH_ID  null); 
alter table PQD_PENALTY_QUALITY_DETAILS modify(PCPQ_ID  null); 
alter table PQD_PENALTY_QUALITY_DETAILS modify(VERSION  null); 
alter table PQD_PENALTY_QUALITY_DETAILS modify(IS_ACTIVE  null); 
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(PQDUL_ID  null); 
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(ENTRY_TYPE  null);
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(PQD_ID  null);  
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(PCAPH_ID  null); 
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(PCPQ_ID  null); 
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(VERSION  null);
alter table PQDUL_PENALTY_QUALITY_DTL_UL modify(IS_ACTIVE  null); 


alter table PCRH_PC_REFINING_HEADER modify(PCRH_ID  null); 
alter table PCRH_PC_REFINING_HEADER modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCRH_PC_REFINING_HEADER modify(RANGE_TYPE  null); 
alter table PCRH_PC_REFINING_HEADER modify(VERSION  null); 
alter table PCRH_PC_REFINING_HEADER modify(IS_ACTIVE  null); 
alter table PCRHUL_REFINING_HEADER_UL modify(PCRHUL_ID  null); 
alter table PCRHUL_REFINING_HEADER_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCRHUL_REFINING_HEADER_UL modify(ENTRY_TYPE  null);
alter table PCRHUL_REFINING_HEADER_UL modify(PCRH_ID  null);  
alter table PCRHUL_REFINING_HEADER_UL modify(INTERNAL_CONTRACT_REF_NO  null); 
alter table PCRHUL_REFINING_HEADER_UL modify(RANGE_TYPE  null); 
alter table PCRHUL_REFINING_HEADER_UL modify(VERSION  null);
alter table PCRHUL_REFINING_HEADER_UL modify(IS_ACTIVE  null); 


alter table RQD_REFINING_QUALITY_DETAILS modify(RQD_ID  null); 
alter table RQD_REFINING_QUALITY_DETAILS modify(PCRH_ID  null); 
alter table RQD_REFINING_QUALITY_DETAILS modify(PCPQ_ID  null); 
alter table RQD_REFINING_QUALITY_DETAILS modify(VERSION  null); 
alter table RQD_REFINING_QUALITY_DETAILS modify(IS_ACTIVE  null);
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(RQDUL_ID  null); 
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(ENTRY_TYPE  null);
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(RQD_ID  null);  
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(PCRH_ID  null); 
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(PCPQ_ID  null); 
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(VERSION  null);
alter table RQDUL_REFINING_QUALITY_DTL_UL modify(IS_ACTIVE  null); 


alter table RED_REFINING_ELEMENT_DETAILS modify(RED_ID  null); 
alter table RED_REFINING_ELEMENT_DETAILS modify(PCRH_ID  null); 
alter table RED_REFINING_ELEMENT_DETAILS modify(ELEMENT_ID  null); 
alter table RED_REFINING_ELEMENT_DETAILS modify(VERSION  null); 
alter table RED_REFINING_ELEMENT_DETAILS modify(IS_ACTIVE  null); 
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(REDUL_ID  null); 
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(ENTRY_TYPE  null);
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(RED_ID  null);  
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(PCRH_ID  null); 
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(ELEMENT_ID  null); 
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(VERSION  null);
alter table REDUL_REFINING_ELEMENT_DTL_UL modify(IS_ACTIVE  null); 


alter table PCERC_PC_ELEM_REFINING_CHARGE modify(PCERC_ID  null); 
alter table PCERC_PC_ELEM_REFINING_CHARGE modify(PCRH_ID  null);  
alter table PCERC_PC_ELEM_REFINING_CHARGE modify(VERSION  null); 
alter table PCERC_PC_ELEM_REFINING_CHARGE modify(IS_ACTIVE  null);
alter table PCERCUL_ELEM_REFING_CHARGE_UL modify(PCERCUL_ID  null); 
alter table PCERCUL_ELEM_REFING_CHARGE_UL modify(INTERNAL_ACTION_REF_NO  null); 
alter table PCERCUL_ELEM_REFING_CHARGE_UL modify(ENTRY_TYPE  null);
alter table PCERCUL_ELEM_REFING_CHARGE_UL modify(PCERC_ID  null);  
alter table PCERCUL_ELEM_REFING_CHARGE_UL modify(PCRH_ID  null); 
alter table PCERCUL_ELEM_REFING_CHARGE_UL modify(VERSION  null);
alter table PCERCUL_ELEM_REFING_CHARGE_UL modify(IS_ACTIVE  null); 
