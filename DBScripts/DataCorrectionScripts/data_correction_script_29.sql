update SAM_STOCK_ASSAY_MAPPING sam
set sam.parent_stock_ref_no = (select ASH.INTERNAL_GRD_REF_NO 
                              from ASH_ASSAY_HEADER ash
                              where ASH.ASH_ID = SAM.ASH_ID);