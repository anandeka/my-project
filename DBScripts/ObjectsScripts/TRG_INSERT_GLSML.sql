CREATE OR REPLACE TRIGGER "TRG_INSERT_GLSML"
   AFTER INSERT OR UPDATE
   ON glsm_gmr_link_stock_mapping
   FOR EACH ROW
BEGIN
   IF UPDATING
   THEN
      IF :NEW.is_active = 'Y'
      THEN
         -- update the record
         INSERT INTO glsml_gmr_link_stock_map_log
                     (glsm_id, gld_id,
                      internal_action_ref_no,
                      source_internal_gmr_ref_no,
                      source_gmr_ref_no,
                      source_internal_stock_ref_no,
                      source_stock_ref_no, source_stock_qty,
                      source_stock_unit_id,
                      target_internal_gmr_ref_no,
                      target_gmr_ref_no,
                      target_internal_stock_ref_no,
                      target_stock_ref_no, target_stock_qty,
                      target_stock_unit_id, is_active, VERSION, entry_type
                     )
              VALUES (:NEW.glsm_id, :NEW.gld_id,
                      :NEW.internal_action_ref_no,
                      :NEW.source_internal_gmr_ref_no,
                      :NEW.source_gmr_ref_no,
                      :NEW.source_internal_stock_ref_no,
                      :NEW.source_stock_ref_no, :NEW.source_stock_qty,
                      :NEW.source_stock_unit_id,
                      :NEW.target_internal_gmr_ref_no,
                      :NEW.target_gmr_ref_no,
                      :NEW.target_internal_stock_ref_no,
                      :NEW.target_stock_ref_no, :NEW.target_stock_qty,
                      :NEW.target_stock_unit_id, 'Y', :NEW.VERSION,'Update'
                     );
      ELSE
         -- IsActive is Cancelled
         INSERT INTO glsml_gmr_link_stock_map_log
                     (glsm_id, gld_id,
                      internal_action_ref_no,
                      source_internal_gmr_ref_no,
                      source_gmr_ref_no,
                      source_internal_stock_ref_no,
                      source_stock_ref_no, source_stock_qty,
                      source_stock_unit_id,
                      target_internal_gmr_ref_no,
                      target_gmr_ref_no,
                      target_internal_stock_ref_no,
                      target_stock_ref_no, target_stock_qty,
                      target_stock_unit_id, is_active, VERSION, entry_type
                     )
              VALUES (:NEW.glsm_id, :NEW.gld_id,
                      :NEW.internal_action_ref_no,
                      :NEW.source_internal_gmr_ref_no,
                      :NEW.source_gmr_ref_no,
                      :NEW.source_internal_stock_ref_no,
                      :NEW.source_stock_ref_no, :NEW.source_stock_qty,
                      :NEW.source_stock_unit_id,
                      :NEW.target_internal_gmr_ref_no,
                      :NEW.target_gmr_ref_no,
                      :NEW.target_internal_stock_ref_no,
                      :NEW.target_stock_ref_no, :NEW.target_stock_qty,
                      :NEW.target_stock_unit_id, 'N', :NEW.VERSION, 'Update'
                     );
      END IF;
   ELSE
      -- New Entry ( Entry Type=Insert)
      INSERT INTO glsml_gmr_link_stock_map_log
                  (glsm_id, gld_id, internal_action_ref_no,
                   source_internal_gmr_ref_no, source_gmr_ref_no,
                   source_internal_stock_ref_no,
                   source_stock_ref_no, source_stock_qty,
                   source_stock_unit_id,
                   target_internal_gmr_ref_no, target_gmr_ref_no,
                   target_internal_stock_ref_no,
                   target_stock_ref_no, target_stock_qty,
                   target_stock_unit_id, is_active, VERSION, entry_type
                  )
           VALUES (:NEW.glsm_id, :NEW.gld_id, :NEW.internal_action_ref_no,
                   :NEW.source_internal_gmr_ref_no, :NEW.source_gmr_ref_no,
                   :NEW.source_internal_stock_ref_no,
                   :NEW.source_stock_ref_no, :NEW.source_stock_qty,
                   :NEW.source_stock_unit_id,
                   :NEW.target_internal_gmr_ref_no, :NEW.target_gmr_ref_no,
                   :NEW.target_internal_stock_ref_no,
                   :NEW.target_stock_ref_no, :NEW.target_stock_qty,
                   :NEW.target_stock_unit_id, 'Y', :NEW.VERSION, 'Insert'
                  );
   END IF;
END;
/