ALTER TABLE ash_assay_header ADD(
    CONSTRAINT fk_ash_quality_id
     FOREIGN KEY (quality_id)
     REFERENCES qat_quality_attributes (quality_id),

    CONSTRAINT fk_ash_net_weight_unit
     FOREIGN KEY (net_weight_unit)
     REFERENCES qum_quantity_unit_master (qty_unit_id),


    CONSTRAINT fk_ash_int_action_ref_no
     FOREIGN KEY (internal_action_ref_no)
     REFERENCES axs_action_summary (internal_action_ref_no)
)