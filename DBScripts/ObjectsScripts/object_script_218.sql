alter table pp_product_premium add(VALUATION_POINT_ID  VARCHAR2(15 CHAR));

UPDATE pp_product_premium pp
   SET valuation_point_id =
          (SELECT min(mvp.mvp_id) as mvp_id
             FROM mvp_m2m_valuation_point mvp
            WHERE pp.product_id = mvp.product_id
              AND pp.corporate_id = mvp.corporate_id
              AND mvp.is_active = 'Y' )
              where PP.VALUATION_POINT_ID is  null;
              
 alter table pp_product_premium modify(VALUATION_POINT_ID  VARCHAR2(15 CHAR) NOT NULL);