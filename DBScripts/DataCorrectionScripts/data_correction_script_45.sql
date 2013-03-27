update ASM_ASSAY_SUBLOT_MAPPING asm
set ASM.NET_WEIGHT=(select PCPQ.QTY_MAX_VAL from PCPQUL_PC_PRODUCT_QUALITY_UL pcpq where PCPQ.ASSAY_HEADER_ID= ASM.ASH_ID)
where ASM.NET_WEIGHT is null
and ASM.ASH_ID IN (select ASH.ASH_ID from ASH_ASSAY_HEADER ash where ASH.ASSAY_TYPE='Contractual Assay');

update ASH_ASSAY_HEADER ash
set ash.NET_WEIGHT=(select PCPQ.QTY_MAX_VAL from PCPQUL_PC_PRODUCT_QUALITY_UL pcpq where PCPQ.ASSAY_HEADER_ID= ash.ASH_ID)
where ash.NET_WEIGHT is null and ASH.ASSAY_TYPE='Contractual Assay';
commit;

DECLARE
   CURSOR ash_cursor
   IS
      SELECT   ASH.ASH_ID
          FROM ash_assay_header ash where ASH.ASSAY_TYPE='Contractual Assay'
      ;
BEGIN
   FOR ash_cur_rows IN ash_cursor
   LOOP
      UPDATE ASM_ASSAY_SUBLOT_MAPPING asm
         SET ASM.DRY_WET_QTY_RATIO = (1- (SELECT SUM (PQCA.TYPICAL)/100
                                 FROM PQCA_PQ_CHEMICAL_ATTRIBUTES pqca
                                WHERE PQCA.ASM_ID = ASM.ASM_ID and PQCA.IS_DEDUCTIBLE='Y'))
       WHERE ASM.ASH_ID = ash_cur_rows.ash_id;
   END LOOP;
END;
/
commit;
update ASM_ASSAY_SUBLOT_MAPPING asm
set ASM.DRY_WEIGHT=ASM.NET_WEIGHT*ASM.DRY_WET_QTY_RATIO
where ASM.DRY_WET_QTY_RATIO is not null 
and ASM.DRY_WEIGHT is null
and ASM.ASH_ID IN(select ASH.ASH_ID from ASH_ASSAY_HEADER ash where ASH.ASSAY_TYPE IN('Contractual Assay'));
commit;
DECLARE
   CURSOR ash_cursor
   IS
       SELECT   ASH.ASH_ID
          FROM ash_assay_header ash where ASH.ASSAY_TYPE='Contractual Assay'
      ;
BEGIN
   FOR ash_cur_rows IN ash_cursor
   LOOP
      UPDATE ash_assay_header ash
         SET ash.dry_weight = (SELECT SUM (asm.dry_weight)
                                 FROM asm_assay_sublot_mapping asm
                                WHERE ash.ash_id = asm.ash_id)
       WHERE ash.ASH_ID = ash_cur_rows.ash_id;
   END LOOP;
END;
/
commit;