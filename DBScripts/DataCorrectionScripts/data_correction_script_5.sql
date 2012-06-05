rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
DECLARE
  CURSOR agrd_stock IS
  
    SELECT agrd.action_no,
           (SELECT s_agrd.pqpa_phy_attribute_group_no
              FROM agmr_action_gmr s_agmr, agrd_action_grd s_agrd
             WHERE s_agmr.internal_gmr_ref_no = s_agrd.internal_gmr_ref_no
               AND s_agmr.action_no = s_agrd.action_no
               AND s_agrd.status = 'Active'
               AND s_agrd.tolling_stock_type = 'None Tolling'
               AND s_agmr.gmr_latest_action_action_id IN
                   ('shipmentDetail', 'railDetail', 'airDetail')
               AND s_agrd.pqpa_phy_attribute_group_no IS NOT NULL
               AND s_agrd.internal_grd_ref_no = agrd.internal_grd_ref_no
               AND s_agrd.internal_gmr_ref_no = agrd.internal_gmr_ref_no) AS phy_attribute_group_no,
           agrd.internal_gmr_ref_no,
           agrd.internal_grd_ref_no
      FROM agmr_action_gmr agmr, agrd_action_grd agrd
     WHERE agmr.internal_gmr_ref_no = agrd.internal_gmr_ref_no
       AND agmr.action_no = agrd.action_no
       AND agrd.status = 'Active'
       AND agrd.tolling_stock_type = 'None Tolling'
       AND agmr.gmr_latest_action_action_id = 'landingDetail'
       AND agrd.pqpa_phy_attribute_group_no IS NULL;
    
     vc_seq VARCHAR2(50);

BEGIN
  FOR eachitem IN agrd_stock LOOP
    SELECT 'PHY-GRP-' || seq_phy_group.NEXTVAL INTO vc_seq FROM dual;
    --- update agrd for landing with new group no  
    UPDATE agrd_action_grd agrd
       SET agrd.pqpa_phy_attribute_group_no = vc_seq
     WHERE agrd.internal_grd_ref_no = eachitem.internal_grd_ref_no
       AND agrd.action_no = eachitem.action_no;
  
    DECLARE
      CURSOR phyattribute IS
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
