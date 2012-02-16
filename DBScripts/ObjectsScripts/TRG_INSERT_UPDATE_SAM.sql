DROP TRIGGER TRG_INSERT_UPDATE_SAM;

CREATE OR REPLACE TRIGGER "TRG_INSERT_UPDATE_SAM" 
AFTER INSERT OR UPDATE
ON SAM_STOCK_ASSAY_MAPPING FOR EACH ROW
BEGIN

      IF    :NEW.IS_LATEST_POSITION_ASSAY = 'Y'
      THEN
      INSERT INTO ACI_ASSAY_CONTENT_UPDATE_INPUT
            (INTERNAL_GRD_NO,
            CONT_TYPE, 
            ASH_ID, 
               IS_DELETED) 
        VALUES (:NEW.INTERNAL_GRD_REF_NO,
            'ASSAY',
            :NEW.ASH_ID, 
            'N'
               );    
       END IF;
                
               
END;
/

