CREATE OR REPLACE PACKAGE pkg_logistics
IS
  
   FUNCTION f_get_min_tolerence (
      pc_int_contract_item_ref_no   VARCHAR2,
      pn_tolerence_qty              NUMBER
   )
      RETURN NUMBER;

   FUNCTION f_get_max_tolerence (
      pc_int_contract_item_ref_no   VARCHAR2,
      pn_tolerence_qty              NUMBER
   )
      RETURN NUMBER;
  FUNCTION f_get_warehouse_shed_name(pc_input_shed_id VARCHAR2)
    RETURN VARCHAR2;
 
END;
/


CREATE OR REPLACE PACKAGE BODY pkg_logistics IS

    /*
    * This f_get_min_tolerence will first find the min delta value( diff between item qty and min tolerence) and
    * then subtracts fromthe tolerence qty  to get the min tolerence value.
    */
    FUNCTION f_get_min_tolerence
    (
        pc_int_contract_item_ref_no VARCHAR2,
        pn_tolerence_qty            NUMBER
    ) RETURN NUMBER IS
        vc_tolerance_type      VARCHAR2(50);
        vn_tolerance_min       NUMBER;
        vn_item_qty            NUMBER;
        vn_min_item_qty        NUMBER;
        vn_min_tolerence_value NUMBER;
        vn_min_delta_value     NUMBER;
    BEGIN
        BEGIN
            vn_min_tolerence_value := 0;
            SELECT pci.tolerance_type,
                   pci.tolerance_min,
                   pci.item_qty
            INTO   vc_tolerance_type,
                   vn_tolerance_min,
                   vn_item_qty
            FROM   v_pci pci
            WHERE  pci.internal_contract_item_ref_no =
                   pc_int_contract_item_ref_no;
            IF vc_tolerance_type IS NOT NULL THEN
                IF vc_tolerance_type = 'Approx' THEN
                    vn_min_item_qty    := vn_tolerance_min;
                    vn_min_delta_value := vn_item_qty - vn_min_item_qty;
                ELSIF vc_tolerance_type = 'Percentage' THEN
                    vn_min_delta_value := vn_item_qty *
                                          (vn_tolerance_min / 100);
                END IF;
                dbms_output.put_line('vn_min_delta_value ' ||
                                     vn_min_delta_value);
                IF pn_tolerence_qty > vn_min_delta_value THEN
                    vn_min_tolerence_value := pn_tolerence_qty -
                                              vn_min_delta_value;
                ELSE
                    vn_min_tolerence_value := 0;
                END IF;
            END IF;
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('~~~ no data ~~~~');
                vn_min_tolerence_value := 0;
            WHEN OTHERS THEN
                vn_min_tolerence_value := 0;
        END;
        RETURN(vn_min_tolerence_value);
    END;

    /*
    * This f_get_min_tolerence will first find the min delta value( diff between item qty and min tolerence) and
    * then subtracts fromthe tolerence qty  to get the min tolerence value.
    */
    FUNCTION f_get_max_tolerence
    (
        pc_int_contract_item_ref_no VARCHAR2,
        pn_tolerence_qty            NUMBER
    ) RETURN NUMBER IS
        vc_tolerance_type      VARCHAR2(50);
        vn_tolerance_max       NUMBER;
        vn_item_qty            NUMBER;
        vn_max_item_qty        NUMBER;
        vn_max_delta_value     NUMBER;
        vn_max_tolerence_value NUMBER;
    BEGIN
        BEGIN
            vn_max_tolerence_value := 0;
            SELECT pci.tolerance_type,
                   pci.tolerance_max,
                   pci.item_qty
            INTO   vc_tolerance_type,
                   vn_tolerance_max,
                   vn_item_qty
            FROM   v_pci pci
            WHERE  pci.internal_contract_item_ref_no =
                   pc_int_contract_item_ref_no;
            IF vc_tolerance_type IS NOT NULL THEN
                IF vc_tolerance_type = 'Approx' THEN
                    vn_max_item_qty := vn_tolerance_max;
                    /* vn_max_delta_value := vn_max_item_qty - vn_item_qty;*/
                    vn_max_delta_value := vn_max_item_qty;
                ELSIF vc_tolerance_type = 'Percentage' THEN
                    vn_max_delta_value := vn_item_qty *
                                          (vn_tolerance_max / 100);
                END IF;
                vn_max_tolerence_value := pn_tolerence_qty + vn_max_delta_value;
            END IF;
        EXCEPTION
            WHEN no_data_found THEN
                dbms_output.put_line('~~~ no data ~~~~');
                vn_max_tolerence_value := 0;
            WHEN OTHERS THEN
                vn_max_tolerence_value := 0;
        END;
        RETURN(vn_max_tolerence_value);
    END;

    FUNCTION f_get_warehouse_shed_name(pc_input_shed_id VARCHAR2) RETURN VARCHAR2 IS
        vc_warehouse_shed_name VARCHAR2(150);
    BEGIN
        SELECT phd.companyname || ', ' || sld.storage_location_name
        INTO   vc_warehouse_shed_name
        FROM   bpsld_bp_storage_loc_det    bpsld,
               sld_storage_location_detail sld,
               phd_profileheaderdetails    phd
        WHERE  bpsld.storage_loc_id = sld.storage_loc_id
        AND    bpsld.profile_id = phd.profileid
        AND    bpsld.is_deleted = 'N'
        AND    sld.is_active = 'Y'
        AND    sld.is_deleted = 'N'
        AND    sld.storage_loc_id = pc_input_shed_id;
        RETURN(vc_warehouse_shed_name);
    END;

END;
/