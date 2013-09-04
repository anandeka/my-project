CREATE OR REPLACE  VIEW  V_TOLLING_STOCKS (internal_gmr_ref_no,productId,quality_id,product_desc,quality_name)
AS
SELECT   grd.internal_gmr_ref_no internal_gmr_ref_no, f_string_aggregate (grd.product_id) AS productId,
         f_string_aggregate (grd.quality_id) AS quality_id,
         f_string_aggregate (pdm.product_desc) as product_desc,
         f_string_aggregate (qat.quality_name) as quality_name
    FROM grd_goods_record_detail grd,
         qat_quality_attributes qat,
         pdm_productmaster pdm
   WHERE qat.quality_id = grd.quality_id
     AND qat.product_id = pdm.product_id
     AND grd.tolling_stock_type IN
            ('RM Out Process Stock', 'In Process Adjustment Stock',
             'Clone Stock')
     AND pdm.product_id = grd.product_id
     AND grd.is_deleted = 'N'
 GROUP BY grd.internal_gmr_ref_no
UNION ALL
SELECT   dgrd.internal_gmr_ref_no As internal_gmr_ref_no, f_string_aggregate (dgrd.product_id) AS productId,
         f_string_aggregate (dgrd.quality_id) AS quality_id,
         f_string_aggregate (pdm.product_desc) as product_desc,
         f_string_aggregate (qat.quality_name) as quality_name
    FROM dgrd_delivered_grd dgrd,
         qat_quality_attributes qat,
         pdm_productmaster pdm
   WHERE qat.quality_id = dgrd.quality_id
     AND qat.product_id = pdm.product_id
     AND dgrd.tolling_stock_type IN ('Return Material Stock')
     AND pdm.product_id = dgrd.product_id
     AND dgrd.status = 'Active'
GROUP BY dgrd.internal_gmr_ref_no;