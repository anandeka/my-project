rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
DECLARE
  CURSOR grd_stock IS
    SELECT grd.internal_grd_ref_no,
           pci.internal_contract_item_ref_no,
           pci.phy_attribute_group_no
      FROM grd_goods_record_detail grd, v_pci pci
     WHERE grd.internal_contract_item_ref_no =
           pci.internal_contract_item_ref_no(+)
       AND grd.status = 'Active'
       AND grd.tolling_stock_type = 'None Tolling'
       and pci.phy_attribute_group_no is not null
       and grd.pqpa_phy_attribute_group_no IS NULL;
    
     vc_seq VARCHAR2(50);

BEGIN
  FOR eachitem IN grd_stock LOOP
    SELECT 'PHY-GRP-' || seq_phy_group.NEXTVAL INTO vc_seq FROM dual;
    --update GRD with new groupNo
    UPDATE grd_goods_record_detail grd
       SET grd.pqpa_phy_attribute_group_no = vc_seq
     WHERE grd.internal_contract_item_ref_no =
           eachitem.internal_contract_item_ref_no
       AND grd.internal_grd_ref_no = eachitem.internal_grd_ref_no;
   --- update only for shipment,rail,air detail AGRD  with new group no  
    UPDATE agrd_action_grd grd
       SET grd.pqpa_phy_attribute_group_no = vc_seq
     WHERE grd.internal_grd_ref_no = eachitem.internal_grd_ref_no
       AND grd.action_no =
           (SELECT agrd.action_no
              FROM agmr_action_gmr agmr, agrd_action_grd agrd
             WHERE agmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
               AND agmr.action_no = agrd.action_no
               AND agrd.internal_grd_ref_no = eachitem.internal_grd_ref_no
               AND agrd.status = 'Active'
               AND agrd.tolling_stock_type = 'None Tolling'
               AND agmr.gmr_latest_action_action_id in ('shipmentDetail','railDetail','airDetail','warehouseReceipt'));
    
     DECLARE CURSOR
     phyattribute IS
            SELECT pqpa.attribute_id, pqpa.attribute_value, pqpa.rejection
              FROM pqpa_pq_physical_attributes pqpa
             WHERE pqpa.phy_attribute_group_no =
                   eachitem.phy_attribute_group_no;
  
    pqpqid VARCHAR2(50);
    BEGIN
      FOR phyattribute_rows IN phyattribute LOOP
      
        SELECT seq_pqpa.NEXTVAL INTO pqpqid FROM dual;
        INSERT INTO pqpa_pq_physical_attributes
        VALUES
          (pqpqid,
           vc_seq,
           phyattribute_rows.attribute_id,
           phyattribute_rows.attribute_value,
           phyattribute_rows.rejection,
           0,
           'Y');
      END LOOP;
    
    END;
  END LOOP;

  COMMIT;
END;
/
