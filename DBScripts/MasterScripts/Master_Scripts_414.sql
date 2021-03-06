declare
fetchqry1 clob := 'INSERT INTO AS_ASSAY_CHILD_D (
LOT_REF_NO    ,
SUBLOTORDERING,
ELEMENTORDERING,
NET_WEIGHT,
DRY_WEIGHT,
IS_DEDUCTIBLE,
NET_WEIGHT_UNIT_NAME ,
ELEMENT_NAME ,
ASSAY_VALUE ,
ASSAY_UOM,
INTERNAL_DOC_REF_NO           
)
SELECT DISTINCT 
                (CASE WHEN  ASM.SUBLOT_REF_NO is not null THEN 
                ASM.SUBLOT_REF_NO
                ELSE
                ASH.LOT_NO
                END)  AS LOT_REF_NO,
                ASM.ORDERING AS SUBLOTORDERING,
                PQCA.ORDERING AS ELEMENTORDERING,
                (CASE WHEN (ASH.ASSAY_TYPE) <> ''Provisional Assay'' THEN 
                (ASM.DRY_WEIGHT)
                ELSE
                (ASM.NET_WEIGHT)
                END)  AS NET_WEIGHT,
                ASM.DRY_WEIGHT AS DRY_WEIGHT,
                PQCA.IS_DEDUCTIBLE AS IS_DEDUCTIBLE,
                QUM.QTY_UNIT AS NET_WEIGHT_UNIT_NAME,
               AML.ATTRIBUTE_NAME AS ELEMENT_NAME,
               PQCA.TYPICAL AS ASSAY_VALUE,
                RM.RATIO_NAME AS ASSAY_UOM,?
           FROM ASM_ASSAY_SUBLOT_MAPPING ASM,
                ASH_ASSAY_HEADER ASH,
                QUM_QUANTITY_UNIT_MASTER QUM,
                RM_RATIO_MASTER RM,
                PQCA_PQ_CHEMICAL_ATTRIBUTES PQCA,
                AML_ATTRIBUTE_MASTER_LIST AML
          WHERE ASM.NET_WEIGHT_UNIT = QUM.QTY_UNIT_ID
            AND ASM.ASH_ID=ASH.ASH_ID
            AND ASM.ASM_ID = PQCA.ASM_ID
            AND PQCA.UNIT_OF_MEASURE = RM.RATIO_ID
            AND PQCA.ELEMENT_ID=AML.ATTRIBUTE_ID
            AND ASM.ASH_ID = ?
            AND PQCA.ELEMENT_ID IN (?)
            order by ASM.ORDERING,PQCA.ORDERING';

begin
  
 update DGM_DOCUMENT_GENERATION_MASTER  set FETCH_QUERY=fetchqry1 where DGM_ID='DGM-ASC' and ACTIVITY_ID='CREATE_ASSAY';
  
end;