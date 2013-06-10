

Begin
  for rc in 
      (select 
    akc.corporate_id corp_id, akc.corporate_name 
    from ak_corporate akc where akc.is_internal_corporate = 'N')
  loop

    --Year Filter
    Insert into RFC_REPORT_FILTER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 1, 1, 'Year', 'GFF1012', 1, 'Y');
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 'RFP1060', 'yearList');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 'RFP1062', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 'RFP1063', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 'RFP1064', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 'RFP1065', '1');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 'RFP1066', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY01', 'RFP1061', 'Year');
       
    --Month  Filter
    Insert into RFC_REPORT_FILTER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 1, 2, 'Month', 'GFF1012', 1, 'Y');
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 'RFP1060', 'MonthList');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 'RFP1062', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 'RFP1061', 'Month');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 'RFP1063', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 'RFP1064', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 'RFP1065', '1');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY02', 'RFP1066', 'Yes');
       
    --Product  Filter
    Insert into RFC_REPORT_FILTER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 1, 5, 'Product', 'GFF1011', 1, 'N');
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 'RFP1045', 'allProducts');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 'RFP1046', 'Product');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 'RFP1047', 'No');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 'RFP1048', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 'RFP1049', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 'RFP1050', '1');   
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '370', 'RFC370PHY04', 'RFP1051', 'multiple'); 
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

    --Year Filter
    Insert into RFC_REPORT_FILTER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 1, 1, 'Year', 'GFF1012', 1, 'Y');
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 'RFP1060', 'yearList');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 'RFP1062', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 'RFP1063', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 'RFP1064', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 'RFP1065', '1');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 'RFP1066', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY01', 'RFP1061', 'Year');
       
    --Month  Filter
    Insert into RFC_REPORT_FILTER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 1, 2, 'Month', 'GFF1012', 1, 'Y');
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 'RFP1060', 'MonthList');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 'RFP1062', 'Yes');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 'RFP1061', 'Month');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 'RFP1063', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 'RFP1064', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 'RFP1065', '1');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY02', 'RFP1066', 'Yes');
       
    --Product  Filter
    Insert into RFC_REPORT_FILTER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 1, 5, 'Product', 'GFF1011', 1, 'N');
       
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 'RFP1045', 'allProducts');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 'RFP1046', 'Product');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 'RFP1047', 'No');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 'RFP1048', 'Filter');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 'RFP1049', 'reportForm');
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 'RFP1050', '1');   
    Insert into RPC_RF_PARAMETER_CONFIG
       (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
     Values
       (rc.corp_id, '372', 'RFC372PHY04', 'RFP1051', 'multiple');
   ---------------------------------------------------------------------------------------------------------------
   
   Insert into RFC_REPORT_FILTER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 1, 1, 'Year', 'GFF1012', 1, 'Y');
		   
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 'RFP1060', 'yearList');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 'RFP1062', 'Yes');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 'RFP1063', 'Filter');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 'RFP1064', 'reportForm');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 'RFP1065', '1');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 'RFP1066', 'Yes');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY01', 'RFP1061', 'Year');
		   
		--Month  Filter
		Insert into RFC_REPORT_FILTER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 1, 2, 'Month', 'GFF1012', 1, 'Y');
		   
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 'RFP1060', 'MonthList');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 'RFP1062', 'Yes');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 'RFP1061', 'Month');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 'RFP1063', 'Filter');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 'RFP1064', 'reportForm');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 'RFP1065', '1');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY02', 'RFP1066', 'Yes');
		   
		--Product  Filter
		Insert into RFC_REPORT_FILTER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 1, 5, 'Product', 'GFF1011', 1, 'N');
		   
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 'RFP1045', 'allProducts');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 'RFP1046', 'Product');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 'RFP1047', 'No');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 'RFP1048', 'Filter');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 'RFP1049', 'reportForm');
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 'RFP1050', '1');   
		Insert into RPC_RF_PARAMETER_CONFIG
		   (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
		 Values
		   (rc.corp_id, '369', 'RFC369PHY04', 'RFP1051', 'multiple');    
--------------------------------------------------------------------------------------------------------

Insert into RFC_REPORT_FILTER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 1, 1, 'Year', 'GFF1012', 1, 'Y');
           
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 'RFP1060', 'yearList');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 'RFP1062', 'Yes');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 'RFP1063', 'Filter');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 'RFP1064', 'reportForm');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 'RFP1065', '1');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 'RFP1066', 'Yes');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY01', 'RFP1061', 'Year');
           
        --Month  Filter
        Insert into RFC_REPORT_FILTER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 1, 2, 'Month', 'GFF1012', 1, 'Y');
           
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 'RFP1060', 'MonthList');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 'RFP1062', 'Yes');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 'RFP1061', 'Month');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 'RFP1063', 'Filter');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 'RFP1064', 'reportForm');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 'RFP1065', '1');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY02', 'RFP1066', 'Yes');
           
        --Product  Filter
        Insert into RFC_REPORT_FILTER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 1, 5, 'Product', 'GFF1011', 1, 'N');
           
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 'RFP1045', 'allProducts');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 'RFP1046', 'Product');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 'RFP1047', 'No');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 'RFP1048', 'Filter');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 'RFP1049', 'reportForm');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 'RFP1050', '1');   
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '371', 'RFC371PHY04', 'RFP1051', 'multiple');    
-------------------------------------------------------------------------------------------------------------------------
/*
Metal Balance Report related Corporate Script...        ::Raj, 3rd Jun 2013
*/
 --Year Filter
        Insert into RFC_REPORT_FILTER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 1, 1, 'Year', 'GFF1012', 1, 'Y');
           
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 'RFP1060', 'yearList');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 'RFP1062', 'Yes');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 'RFP1063', 'Filter');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 'RFP1064', 'reportForm');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 'RFP1065', '1');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 'RFP1066', 'Yes');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY01', 'RFP1061', 'Year');
           
        --Month  Filter
        Insert into RFC_REPORT_FILTER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 1, 2, 'Month', 'GFF1012', 1, 'Y');
           
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 'RFP1060', 'MonthList');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 'RFP1062', 'Yes');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 'RFP1061', 'Month');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 'RFP1063', 'Filter');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 'RFP1064', 'reportForm');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 'RFP1065', '1');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY02', 'RFP1066', 'Yes');
           
        --Product  Filter
        Insert into RFC_REPORT_FILTER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, LABEL_COLUMN_NUMBER, LABEL_ROW_NUMBER, LABEL, FIELD_ID, COLSPAN, IS_MANDATORY)
         Values
           (rc.corp_id, '373', 'RFC373PHY04', 1, 5, 'Product', 'GFF1011', 1, 'N');
           
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY04', 'RFP1045', 'allProducts');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY04', 'RFP1046', 'ProductId');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY04', 'RFP1047', 'No');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY04', 'RFP1048', 'Filter');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY04', 'RFP1049', 'reportForm');
        Insert into RPC_RF_PARAMETER_CONFIG
           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
         Values
           (rc.corp_id, '373', 'RFC373PHY04', 'RFP1050', '1');   
--        Insert into RPC_RF_PARAMETER_CONFIG
--           (CORPORATE_ID, REPORT_ID, LABEL_ID, PARAMETER_ID, REPORT_PARAMETER_NAME)
--         Values
--           (rc.corp_id, '373', 'RFC373PHY04', 'RFP1051', 'multiple');   

    COMMIT;
  end loop;
end;
/




       