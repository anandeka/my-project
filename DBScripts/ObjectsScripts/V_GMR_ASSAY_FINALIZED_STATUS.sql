CREATE OR REPLACE VIEW V_GMR_ASSAY_FINALIZED_STATUS
AS
SELECT gmr_out.internal_gmr_ref_no,
       (CASE
           WHEN gmr_intr.aff_count = gmr_intr.stock_count THEN
            (SELECT (CASE
                        WHEN COUNT(*) > 0 THEN
                         'N'
                        ELSE
                         'Y'
                    END) a_status
             FROM   ash_assay_header        ash,
                    grd_goods_record_detail grd
             WHERE  grd.internal_gmr_ref_no = ash.internal_gmr_ref_no
             AND    grd.internal_grd_ref_no = ash.internal_grd_ref_no
             AND    ash.internal_gmr_ref_no = gmr_out.internal_gmr_ref_no
             AND    ash.assay_type = 'Final Assay'
             AND    ash.is_final_assay_fully_finalized = 'N'
             AND    ash.is_active = 'Y')
           ELSE
            'N'
       END) assay_finalized
FROM   (SELECT gmr_temp.internal_gmr_ref_no,
               (SELECT COUNT(*) aff_count
                FROM   ash_assay_header        ash,
                       grd_goods_record_detail grd
                WHERE  ash.internal_gmr_ref_no = gmr_temp.internal_gmr_ref_no
                AND    grd.internal_gmr_ref_no = ash.internal_gmr_ref_no
                AND    grd.internal_grd_ref_no = ash.internal_grd_ref_no
                AND    ash.assay_type = 'Final Assay'
                AND    ash.is_final_assay_fully_finalized = 'Y'
                AND    ash.is_active = 'Y') aff_count,
               (nvl((SELECT COUNT(*) grd_count
                    FROM   grd_goods_record_detail grd
                    WHERE  grd.internal_gmr_ref_no =
                           gmr_temp.internal_gmr_ref_no
                    AND    grd.is_deleted = 'N'
                    AND    grd.status = 'Active'),
                    0) + nvl((SELECT COUNT(*) dgrd_count
                              FROM   dgrd_delivered_grd dgrd
                              WHERE  dgrd.internal_gmr_ref_no =
                                     gmr_temp.internal_gmr_ref_no
                              AND    dgrd.status = 'Active'),
                              0)) stock_count
        FROM   gmr_goods_movement_record gmr_temp
        WHERE  gmr_temp.is_deleted = 'N'
        AND    gmr_temp.is_internal_movement = 'N') gmr_intr,
       gmr_goods_movement_record gmr_out
WHERE  gmr_intr.internal_gmr_ref_no = gmr_out.internal_gmr_ref_no
AND    gmr_out.is_deleted = 'N'
AND    gmr_out.is_internal_movement = 'N';