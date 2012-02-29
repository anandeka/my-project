/**********************************************************************************************************************************************************************************
  FETCH QUERY NEEDS TO BE INSERTED MANUALLY FOR DGM_ID='DGM-ASC'  (ELEMENT TO TRACK DOCUMENT QUERY FOR SELF ASSAY )
************************************************************************************************************************************************************************************/



INSERT INTO AS_ASSAY_CHILD_D (
LOT_REF_NO    ,
SUBLOTORDERING,
ELEMENTORDERING,
NET_WEIGHT,
NET_WEIGHT_UNIT_NAME ,
ELEMENT_NAME ,
ASSAY_VALUE ,
ASSAY_UOM,
INTERNAL_DOC_REF_NO           
)
SELECT DISTINCT ASM.SUB_LOT_NO AS LOT_REF_NO,
                ASM.ORDERING AS SUBLOTORDERING,
                PQCA.ORDERING AS ELEMENTORDERING,
                (CASE WHEN (ASH.ASSAY_TYPE) <> 'Provisional Assay' THEN 
                (ASM.DRY_WEIGHT)
                ELSE
                (ASM.NET_WEIGHT)
                END)  AS NET_WEIGHT,
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
            
            AND PQCA.TYPICAL<>'0'
            AND ASM.ASH_ID = ?
            AND PQCA.ELEMENT_ID IN (?)
            order by ASM.ORDERING,PQCA.ORDERING