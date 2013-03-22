Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('BL_Date', 'BL Date');

Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('BaseDate', 'BL_Date', 'N', 3);
   
INSERT INTO pyme_payment_term_ext
            (pymex_id, base_date,
             fetch_query,
             is_active
            )
     VALUES (2, 'BL_Date',
             'select max(GMR.BL_DATE)
from
GMR_GOODS_MOVEMENT_RECORD gmr
where
GMR.INTERNAL_GMR_REF_NO IN (:values)',
             'Y'
            );

Insert into SLV_STATIC_LIST_VALUE
   (VALUE_ID, VALUE_TEXT)
 Values
   ('MAInvCreateDate', 'MAInvCreateDate');
   
Insert into SLS_STATIC_LIST_SETUP
   (LIST_TYPE, VALUE_ID, IS_DEFAULT, DISPLAY_ORDER)
 Values
   ('BaseDate', 'MAInvCreateDate', 'N', 4);
   
   
INSERT INTO pyme_payment_term_ext
            (pymex_id, base_date,
             fetch_query,
             is_active
            )
     VALUES (3, 'MAInvCreateDate',
             'select LAST_DAY(TRUNC(LAST_DAY(sysdate))) from dual,GMR_GOODS_MOVEMENT_RECORD gmr where
                GMR.INTERNAL_GMR_REF_NO IN (:values)',
             'Y'
            );
   



