DROP TABLE SAC_STOCK_ASSAY_CONTENT CASCADE CONSTRAINTS;

CREATE TABLE SAC_STOCK_ASSAY_CONTENT
(
  SAC_ID                VARCHAR2(15 CHAR) NOT NULL,
  INTERNAL_GMR_REF_NO   VARCHAR2(15 CHAR) NOT NULL,
  STOCK_TYPE            CHAR(1 CHAR)      DEFAULT 'P',
  INTERNAL_GRD_REF_NO   VARCHAR2(15 CHAR),
  INTERNAL_DGRD_REF_NO  VARCHAR2(15 CHAR),
  ELEMENT_ID            VARCHAR2(15 CHAR) NOT NULL,
  CURRENT_QTY_WET       NUMBER(25,10),
  CURRENT_QTY_DRY       NUMBER(25,10),
  TOTAL_QTY_IN_WET      NUMBER(25,10),
  TOTAL_QTY_IN_DRY      NUMBER(25,10),
  GRD_QTY_UNIT_ID		VARCHAR2(15 CHAR),
  ELEMENT_TOTAL_QTY     NUMBER(25,10),
  ELEMENT_CURRENT_QTY   NUMBER(25,10),
  ELEMENT_QTY_UNIT_ID	VARCHAR2(15 CHAR),
  LATEST_ASSAY_ID       VARCHAR2(15 CHAR),
  WTDAVGPOSTION_ASH_ID  VARCHAR2(15 CHAR),
  PARENT_ASH_ID         VARCHAR2(15 CHAR),
  GMR_ACTION_ID         VARCHAR2(30 CHAR)
);

ALTER TABLE SAC_STOCK_ASSAY_CONTENT
 ADD CONSTRAINT PK_SAC
 PRIMARY KEY
 (SAC_ID);

CREATE SEQUENCE SEQ_SAC
  START WITH 1
  MAXVALUE 1000000000000000000000000000
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;

DROP TABLE ACI_ASSAY_CONTENT_UPDATE_INPUT;
Create Table ACI_ASSAY_CONTENT_UPDATE_INPUT(
INTERNAL_GRD_NO VARCHAR2(15),
CONT_TYPE	VARCHAR2(10),
ASH_ID		VARCHAR2(15),
IS_DELETED		VARCHAR2(1)
);


/*******************************************************************************************************************/

CREATE OR REPLACE function fn_get_grd_dry_qty(grd_id varchar2, grd_item_qty number)
    return number is
    vn_deduct_qty       number;
    vn_deduct_total_qty number;
    vn_item_qty         number;
    vn_converted_qty    number;
  begin
    vn_item_qty         := grd_item_qty;
    vn_deduct_qty       := 0;
    vn_deduct_total_qty := 0;
    for cur_deduct_qty in (Select SAM.INTERNAL_GRD_REF_NO INTERNAL_GRD_REF_NO, PQCA.UNIT_OF_MEASURE UNIT_OF_MEASURE,
                           rm.ratio_name ratio_name ,rm.qty_unit_id_numerator qty_unit_id_numerator,
                           	rm.qty_unit_id_denominator qty_unit_id_denominator,pqca.typical typical,
                            ppm.product_id product_id,GRD.QTY_UNIT_ID as item_qty_unit_id
                            From 
                            SAM_STOCK_ASSAY_MAPPING SAM,
                            ASM_ASSAY_SUBLOT_MAPPING ASM,
                            PQCA_PQ_CHEMICAL_ATTRIBUTES PQCA,
                            GRD_GOODS_RECORD_DETAIL GRD,
                            ppm_product_properties_mapping ppm,
                            aml_attribute_master_list      aml,                                  
                            rm_ratio_master                rm,
                            ASH_ASSAY_HEADER		ASH
                            Where 
                            ASM.ASH_ID = SAM.ASH_ID
                            and SAM.IS_LATEST_POSITION_ASSAY ='Y' 
                            and SAM.INTERNAL_GRD_REF_NO =grd_id
                            and PQCA.ASM_ID = ASM.ASM_ID
                            and ppm.attribute_id = aml.attribute_id
                            and aml.attribute_id = pqca.element_id
                            and pqca.unit_of_measure = rm.ratio_id
                            and asm.ash_id = ash.ash_id
                            and ppm.deduct_for_wet_to_dry = 'Y'
                            and GRD.INTERNAL_GRD_REF_NO = SAM.INTERNAL_GRD_REF_NO
                            and PPM.PRODUCT_ID = GRD.PRODUCT_ID)
    loop
    
      if cur_deduct_qty.ratio_name = '%' then
        vn_deduct_qty := vn_item_qty * (cur_deduct_qty.typical / 100);
      else
        vn_converted_qty := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 cur_deduct_qty.qty_unit_id_denominator,
                                                                 vn_item_qty) *
                            cur_deduct_qty.typical;
        vn_deduct_qty    := pkg_general.f_get_converted_quantity(cur_deduct_qty.product_id,
                                                                 cur_deduct_qty.qty_unit_id_numerator,
                                                                 cur_deduct_qty.item_qty_unit_id,
                                                                 vn_converted_qty);
      
      end if;
      vn_deduct_total_qty := vn_deduct_total_qty + vn_deduct_qty;
    
    end loop;
    return grd_item_qty - vn_deduct_total_qty;
  end;
/

/*******************************************************************************************************************/
CREATE OR REPLACE PROCEDURE SP_UPDATEGRDASSAYYCONTENT
(
  P_GRDID IN varchar2,
  P_ASHID IN varchar2
 ) 
 is
 CURSOR CR_GRD_RECORD IS 
        Select SAM.INTERNAL_GRD_REF_NO INTERNAL_GRD_REF_NO,GRD.INTERNAL_GMR_REF_NO INTERNAL_GMR_REF_NO, 
        AML.ATTRIBUTE_ID ATTRIBUTE_ID ,AML.ATTRIBUTE_NAME, PQCA.UNIT_OF_MEASURE UNIT_OF_MEASURE,
        rm.ratio_name ratio_name ,rm.qty_unit_id_numerator qty_unit_id_numerator,
        rm.qty_unit_id_denominator qty_unit_id_denominator,pqca.typical typical,
        ppm.product_id product_id,GRD.QTY_UNIT_ID as item_qty_unit_id,
        GRD.TOTAL_QTY TOTAL_QTY,GRD.CURRENT_QTY CURRENT_QTY, fn_get_grd_dry_qty(GRD.INTERNAL_GRD_REF_NO, GRD.TOTAL_QTY) TOTAL_DRY_QTY,
        fn_get_grd_dry_qty(GRD.INTERNAL_GRD_REF_NO, GRD.CURRENT_QTY) CURRRENT_DRY_QTY,
         (case rm.ratio_name 
            WHEN '%' then                
                 (pqca.typical / 100)             
            ELSE
                pqca.typical * pkg_general.f_get_converted_quantity(AML.UNDERLYING_PRODUCT_ID,
                                                             GRD.QTY_UNIT_ID,
                                                             rm.qty_unit_id_denominator,
                                                             1)             		  
         END  )  as Mul_factor
        From 
        SAM_STOCK_ASSAY_MAPPING SAM,
        ASM_ASSAY_SUBLOT_MAPPING ASM,
        PQCA_PQ_CHEMICAL_ATTRIBUTES PQCA,
        GRD_GOODS_RECORD_DETAIL GRD,
        ppm_product_properties_mapping ppm,
        aml_attribute_master_list      aml,                                  
        rm_ratio_master                rm,
        ASH_ASSAY_HEADER		ASH
        Where 
        ASM.ASH_ID = SAM.ASH_ID
        and SAM.IS_LATEST_POSITION_ASSAY ='Y' 
        and PQCA.ASM_ID = ASM.ASM_ID
        and ppm.attribute_id = aml.attribute_id
        and aml.attribute_id = pqca.element_id
        and pqca.unit_of_measure = rm.ratio_id
        and asm.ash_id = ash.ash_id
        and GRD.INTERNAL_GRD_REF_NO = SAM.INTERNAL_GRD_REF_NO
        and PPM.PRODUCT_ID = GRD.PRODUCT_ID
        and GRD.INTERNAL_GRD_REF_NO =P_GRDID
        and ash.ash_id = P_ASHID;   
  
  qty_unit_id varchar2(15);
      
                  
begin
	FOR cur_record_rows IN CR_GRD_RECORD 
        
    LOOP  
    
    delete from SAC_STOCK_ASSAY_CONTENT WHERE INTERNAL_GRD_REF_NO =cur_record_rows.INTERNAL_GRD_REF_NO and   ELEMENT_ID =  cur_record_rows.ATTRIBUTE_ID;  
    if (cur_record_rows.ratio_name ='%') then
    	qty_unit_id :=cur_record_rows.item_qty_unit_id;
    else
    	qty_unit_id := cur_record_rows.qty_unit_id_numerator;
    end if;
    
    Insert into SAC_STOCK_ASSAY_CONTENT (
    SAC_ID,INTERNAL_GMR_REF_NO,STOCK_TYPE,INTERNAL_GRD_REF_NO,ELEMENT_ID,
    CURRENT_QTY_WET,CURRENT_QTY_DRY,TOTAL_QTY_IN_WET,TOTAL_QTY_IN_DRY,GRD_QTY_UNIT_ID,    
  	ELEMENT_CURRENT_QTY,ELEMENT_TOTAL_QTY,ELEMENT_QTY_UNIT_ID,
    LATEST_ASSAY_ID,WTDAVGPOSTION_ASH_ID,PARENT_ASH_ID,GMR_ACTION_ID)     
    VALUES  
    (SEQ_SAC.nextval,cur_record_rows.INTERNAL_GMR_REF_NO,'P',cur_record_rows.INTERNAL_GRD_REF_NO,cur_record_rows.ATTRIBUTE_ID,
    cur_record_rows.CURRENT_QTY,cur_record_rows.CURRRENT_DRY_QTY,cur_record_rows.TOTAL_QTY,  cur_record_rows.TOTAL_DRY_QTY,cur_record_rows.item_qty_unit_id,
    (cur_record_rows.CURRENT_QTY*cur_record_rows.Mul_factor) ,(cur_record_rows.TOTAL_QTY*cur_record_rows.Mul_factor), qty_unit_id,   
    P_ASHID,P_ASHID,P_ASHID,'ToChange');
        
    end loop;


end;
/

/******************************************************************************************************************/
CREATE OR REPLACE PROCEDURE updateAssayContent(p_TYPE VARCHAR2,
p_GRD VARCHAR2, 
p_ASHID VARCHAR2) IS
TYPE cur_typ IS REF CURSOR;
c cur_typ;
query_str VARCHAR2(500);
where_clause VARCHAR2(200);
v_GRD VARCHAR2(15);
v_DGRD VARCHAR2(15);
v_ASHID VARCHAR2(15);
v_STOCK_TYPE VARCHAR2(1);
v_param varchar2(15);

BEGIN
    IF (p_TYPE ='ASSAY')  THEN
            where_clause:=' AND ASH_ID =:id'; 
            v_param:=p_ASHID;
    end if;

   if (p_TYPE ='GRD')  then
   		where_clause:=' AND INTERNAL_GRD_REF_NO =:id';
        v_param:=p_GRD;
  end if;
  
  if (p_TYPE ='DGRD')  then
   		where_clause:=' AND INTERNAL_DGRD_REF_NO =:id';
        v_param:=p_GRD;   
  END IF;
query_str:='Select INTERNAL_GRD_REF_NO,INTERNAL_DGRD_REF_NO,ASH_ID,STOCK_TYPE  From SAM_STOCK_ASSAY_MAPPING  Where IS_LATEST_POSITION_ASSAY ='|| '''Y''';
query_str:= query_str|| where_clause;
  dbms_output.put_line(query_str);

OPEN c FOR query_str USING v_param;
LOOP
FETCH c INTO v_GRD,v_DGRD, v_ASHID,v_STOCK_TYPE;
    
EXIT WHEN c%NOTFOUND;
dbms_output.put_line(v_GRD);
	IF (v_STOCK_TYPE ='P')  THEN
     	SP_UPDATEGRDASSAYYCONTENT(v_GRD,v_ASHID);
    end if;

-- process row here
END LOOP;
CLOSE c;
END;
/
/******************************************************************************************************************/
CREATE OR REPLACE PROCEDURE processAssayContentInput IS



 Cursor ASSAY_CONTENT_UPDATE IS Select INTERNAL_GRD_NO,CONT_TYPE,ASH_ID from ACI_ASSAY_CONTENT_UPDATE_INPUT Where IS_DELETED  ='N';
	BEGIN

	FOR cur_record_rows IN ASSAY_CONTENT_UPDATE 
        
    LOOP  


	IF (cur_record_rows.CONT_TYPE ='ASSAY')  THEN
    dbms_output.put_line('Calling updateAssayContent');
    updateAssayContent(cur_record_rows.CONT_TYPE ,NULL , cur_record_rows.ASH_ID );
    	UPDATE ACI_ASSAY_CONTENT_UPDATE_INPUT SET  IS_DELETED ='Y'  WHERE ASH_ID = cur_record_rows.ASH_ID;    
    end if;
    IF (cur_record_rows.CONT_TYPE ='GRD')  THEN
    	dbms_output.put_line('Calling updateAssayContent');
    	updateAssayContent(cur_record_rows.CONT_TYPE ,cur_record_rows.INTERNAL_GRD_NO , NULL );
    UPDATE ACI_ASSAY_CONTENT_UPDATE_INPUT SET  IS_DELETED ='Y'  WHERE INTERNAL_GRD_NO = cur_record_rows.INTERNAL_GRD_NO;
    end if;	

END LOOP;

	delete from ACI_ASSAY_CONTENT_UPDATE_INPUT WHERE  IS_DELETED ='Y' ;
END;
/

/******************************************************************************************************************/

CREATE OR REPLACE PROCEDURE processAssayContentInput IS


 Cursor ASSAY_CONTENT_UPDATE IS Select INTERNAL_GRD_NO,CONT_TYPE,ASH_ID from ACI_ASSAY_CONTENT_UPDATE_INPUT Where IS_DELETED  ='N';
	BEGIN

	FOR cur_record_rows IN ASSAY_CONTENT_UPDATE 
        
    LOOP  


	IF (cur_record_rows.CONT_TYPE ='ASSAY')  THEN
    dbms_output.put_line('Calling updateAssayContent');
    updateAssayContent(cur_record_rows.CONT_TYPE ,NULL , cur_record_rows.ASH_ID );
    	UPDATE ACI_ASSAY_CONTENT_UPDATE_INPUT SET  IS_DELETED ='Y'  WHERE ASH_ID = cur_record_rows.ASH_ID;    
    end if;
    IF (cur_record_rows.CONT_TYPE ='GRD')  THEN
    	dbms_output.put_line('Calling updateAssayContent');
    	updateAssayContent(cur_record_rows.CONT_TYPE ,cur_record_rows.INTERNAL_GRD_NO , NULL );
    UPDATE ACI_ASSAY_CONTENT_UPDATE_INPUT SET  IS_DELETED ='Y'  WHERE INTERNAL_GRD_NO = cur_record_rows.INTERNAL_GRD_NO;
    end if;	

END LOOP;

	--delete from ACI_ASSAY_CONTENT_UPDATE_INPUT WHERE  IS_DELETED ='Y' ;
END;
/

/*******************************************************************************************************************/
DROP TRIGGER TRG_INSERT_UPDATE_SAM;

CREATE OR REPLACE TRIGGER "TRG_INSERT_UPDATE_SAM" 
AFTER INSERT OR UPDATE
ON SAM_STOCK_ASSAY_MAPPING FOR EACH ROW
BEGIN
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
END;
/
