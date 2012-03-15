CREATE OR REPLACE VIEW v_gmr_sac_qty 
AS
SELECT   t.internal_gmr_ref_no, SUM (t.total_qty_in_wet) total_qty_in_wet,
         SUM (t.total_qty_in_dry) total_qty_in_dry,
         SUM (t.current_qty_dry) current_qty_dry,
         SUM (t.current_qty_wet) current_qty_wet, t.grd_qty_unit_id
    FROM (SELECT   sac.internal_gmr_ref_no, sac.internal_grd_ref_no,
                   sac.total_qty_in_wet, sac.total_qty_in_dry,
                   sac.current_qty_dry, sac.current_qty_wet,
                   sac.grd_qty_unit_id
              FROM sac_stock_assay_content sac
            -- WHERE sac.internal_gmr_ref_no = 'GMR-58'
          GROUP BY sac.internal_gmr_ref_no,
                   sac.internal_grd_ref_no,
                   sac.total_qty_in_wet,
                   sac.total_qty_in_dry,
                   sac.current_qty_dry,
                   sac.current_qty_wet,
                   sac.grd_qty_unit_id) t
GROUP BY t.internal_gmr_ref_no, t.grd_qty_unit_id