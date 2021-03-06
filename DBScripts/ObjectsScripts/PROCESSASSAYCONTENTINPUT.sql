CREATE OR REPLACE PROCEDURE PROCESSASSAYCONTENTINPUT IS
BEGIN
		UPDATE ACI_ASSAY_CONTENT_UPDATE_INPUT SET  IS_DELETED ='Y';
		
for Cur_record  in ( Select CONT_TYPE, SAM.INTERNAL_GRD_REF_NO INTERNAL_GRD_REF_NO ,SAM.ASH_ID   ASH_ID
		From SAM_STOCK_ASSAY_MAPPING  SAM,
		ACI_ASSAY_CONTENT_UPDATE_INPUT ACI 
		Where ACI.IS_DELETED  ='Y' 
		AND SAM.IS_LATEST_POSITION_ASSAY ='Y' 
		AND CONT_TYPE='GRD'
		AND SAM.STOCK_TYPE ='P'
		AND ACI.INTERNAL_GRD_NO = SAM.INTERNAL_GRD_REF_NO
		UNION
		Select  CONT_TYPE,SAM.INTERNAL_GRD_REF_NO,SAM.ASH_ID  
		From SAM_STOCK_ASSAY_MAPPING  SAM,
		ACI_ASSAY_CONTENT_UPDATE_INPUT ACI 
		Where ACI.IS_DELETED  ='Y' 
		AND CONT_TYPE='ASSAY' 
		AND SAM.STOCK_TYPE ='P'
		AND SAM.IS_LATEST_POSITION_ASSAY ='Y' 
		AND ACI.ASH_ID = SAM.ASH_ID )
   loop
		SP_UPDATEGRDASSAYYCONTENT(Cur_record.INTERNAL_GRD_REF_NO ,Cur_record.ASH_ID);
   end loop;

		delete from ACI_ASSAY_CONTENT_UPDATE_INPUT WHERE  IS_DELETED ='Y';
End;
/
