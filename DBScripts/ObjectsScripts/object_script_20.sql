ALTER TABLE ash_assay_header ADD(self_assay_ash_id VARCHAR2 (15 CHAR),cp_assay_ash_id VARCHAR2 (15 CHAR),
pricing_assay_ash_id VARCHAR2 (15 CHAR),use_for_pricing CHAR (1 BYTE),use_for_position CHAR (1 BYTE),POSITION_ASSAY_ASH_ID VARCHAR2 (15 Char),WT_AVERAGE_ASSAY_ASH_ID VARCHAR2 (15 Char),
IS_DELETE CHAR (1 BYTE),PREV_PRICING_ASSAY_ASH_ID VARCHAR2 (15 Char));
