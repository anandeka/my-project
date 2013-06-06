CREATE OR REPLACE VIEW V_BI_MB_INVENTORY_BY_SMELTERS AS
select t.corporate_id,
       t.product_id,
       t.product_name,
       t.smelter_id,
       t.smelter_name,
       round(sum(t.contained_qty), 2) contained_quantity,
       round(sum(t.in_process_qty), 2) inprocess_quantity,
       round(sum(t.stock_qty), 2) stock_quantity,
       -- round(sum(t.debt_qty),2) debt_qty,
       round(sum(t.contained_qty), 2) + round(sum(t.in_process_qty), 2) +
       round(sum(t.stock_qty), 2) net_quantity,
       t.qty_unit_id base_qty_unit_id,
       t.qty_unit base_qty_unit
  from (
        -- Contained Qty and Debt Qty
        SELECT akc.corporate_id,
                akc.corporate_name,
                pdm.product_id,
                pdm.product_desc product_name,
                qum.qty_unit_id,
                qum.qty_unit,
                phd_smelter.profileid smelter_id,
                phd_smelter.companyname smelter_name,
                SUM(CASE
                      WHEN spq.qty_type = 'Payable' THEN
                       pkg_general.f_get_converted_quantity(pdm.product_id,
                                                            spq.qty_unit_id,
                                                            pdm.base_quantity_unit,
                                                            spq.payable_qty)
                      ELSE
                       0
                    END) contained_qty,
                0 in_process_qty,
                0 stock_qty,
                SUM(CASE
                      WHEN spq.qty_type = 'Returnable' THEN
                       pkg_general.f_get_converted_quantity(pdm.product_id,
                                                            spq.qty_unit_id,
                                                            pdm.base_quantity_unit,
                                                            spq.payable_qty)
                      ELSE
                       0
                    END) debt_qty
          FROM grd_goods_record_detail    grd,
                gmr_goods_movement_record  gmr,
                pci_physical_contract_item pci,
               pcdi_pc_delivery_item      pcdi,
                pcm_physical_contract_main pcm,
                ak_corporate               akc,
                spq_stock_payable_qty      spq,
                aml_attribute_master_list  aml,
                qum_quantity_unit_master   qum,
                pdm_productmaster          pdm,
                phd_profileheaderdetails   phd_smelter
         WHERE grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           AND gmr.corporate_id = akc.corporate_id
           AND spq.internal_grd_ref_no = grd.internal_grd_ref_no
           AND spq.element_id = aml.attribute_id
           AND aml.underlying_product_id = pdm.product_id
           AND pdm.base_quantity_unit = qum.qty_unit_id
           AND grd.tolling_stock_type IN ('None Tolling') ---added for 79231
           AND grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           AND pci.pcdi_id = pcdi.pcdi_id
           AND pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           AND grd.is_deleted = 'N'
           AND grd.status = 'Active' ---added for 79231
           AND gmr.is_deleted = 'N'
           AND spq.is_active = 'Y'
          AND grd.warehouse_profile_id = phd_smelter.profileid(+)
          AND grd.inventory_status = 'In'
         GROUP BY akc.corporate_id,
                   akc.corporate_name,
                   pdm.product_id,
                   pdm.product_desc,
                   qum.qty_unit_id,
                   qum.qty_unit,
                   phd_smelter.profileid,
                   phd_smelter.companyname
        union all
        -- In Process Qty
        select akc.corporate_id,
               akc.corporate_name,
               pdm.product_id,
               pdm.product_desc product_name,
               qum.qty_unit_id,
               qum.qty_unit,
               phd_smelter.profileid smelter_id,
               phd_smelter.companyname smelter_name,
               sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                        grd.qty_unit_id,
                                                        pdm.base_quantity_unit,
                                                        grd.current_qty)) * -1 contained_qty,
               sum(pkg_general.f_get_converted_quantity(pdm.product_id,
                                                        grd.qty_unit_id,
                                                        pdm.base_quantity_unit,
                                                        grd.current_qty)) in_process_qty,
               0 stock_qty,
               0 debt_qty
          from grd_goods_record_detail    grd,
               gmr_goods_movement_record  gmr,
               PCI_PHYSICAL_CONTRACT_ITEM pci,
               PCDI_PC_DELIVERY_ITEM      pcdi,
               PCM_PHYSICAL_CONTRACT_MAIN pcm,
               ak_corporate               akc,
               --spq_stock_payable_qty      spq,
               aml_attribute_master_list  aml,
               qum_quantity_unit_master   qum,
               pdm_productmaster          pdm,
               phd_profileheaderdetails   phd_smelter
         where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and gmr.corporate_id = akc.corporate_id
           --and spq.internal_gmr_ref_no = gmr.internal_gmr_ref_no
          -- and spq.internal_grd_ref_no = grd.parent_internal_grd_ref_no---added for 79231
           --and grd.element_id = spq.element_id
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and pci.pcdi_id = pcdi.pcdi_id
           and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           AND grd.warehouse_profile_id = phd_smelter.profileid(+)
           and grd.element_id = aml.attribute_id
           and aml.underlying_product_id = pdm.product_id
           and pdm.base_quantity_unit = qum.qty_unit_id
          and NVL(grd.tolling_stock_type, 'NA') IN
               ('MFT In Process Stock', 'Free Metal IP Stock',
                'Delta MFT IP Stock', 'Delta FM IP Stock')
           and grd.is_deleted = 'N'
           and grd.status = 'Active'
           and gmr.is_deleted = 'N'
           ---and spq.is_active = 'Y'
            --and spq.is_stock_split = 'N'---added for 79231
        
         group by akc.corporate_id,
                  akc.corporate_name,
                  pdm.product_id,
                  pdm.product_desc,
                  qum.qty_unit_id,
                  qum.qty_unit,
                  phd_smelter.profileid,
                  phd_smelter.companyname
        -- Stock Qty Inventory in Base Metal Contracts
        union all
        select akc.corporate_id,
               akc.corporate_name,
               pdm.product_id,
               pdm.product_desc product_name,
               qum.qty_unit_id,
               qum.qty_unit,
               phd_smelter.profileid smelter_id,
               phd_smelter.companyname smelter_name,
               0,
               0,
               sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                        grd.qty_unit_id,
                                                        pdm.base_quantity_unit,
                                                        grd.current_qty)) stock_qty,
               0
          from grd_goods_record_detail    grd,
               gmr_goods_movement_record  gmr,
               PCI_PHYSICAL_CONTRACT_ITEM pci,
              PCDI_PC_DELIVERY_ITEM      pcdi,
              PCM_PHYSICAL_CONTRACT_MAIN pcm,
               ak_corporate               akc,
               pdm_productmaster          pdm,
               qum_quantity_unit_master   qum,
               phd_profileheaderdetails   phd_smelter
         where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and gmr.corporate_id = akc.corporate_id
           and grd.product_id = pdm.product_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and grd.internal_contract_item_ref_no =
               pci.internal_contract_item_ref_no
           and pci.pcdi_id = pcdi.pcdi_id
          and pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
           and grd.warehouse_profile_id = phd_smelter.profileid
           and grd.is_deleted = 'N'
           and grd.status = 'Active'
           and gmr.is_deleted = 'N'
           and grd.tolling_stock_type = 'None Tolling'
           and grd.inventory_status = 'In'
           and pdm.product_type_id = 'Standard'
        
         group by akc.corporate_id,
                  akc.corporate_name,
                  pdm.product_id,
                  pdm.product_desc,
                  qum.qty_unit_id,
                  qum.qty_unit,
                  phd_smelter.profileid,
                  phd_smelter.companyname
        -- Stock Qty for In Process Stock
        union all
        select akc.corporate_id,
               akc.corporate_name,
               pdm.product_id,
               pdm.product_desc product_name,
               qum.qty_unit_id,
               qum.qty_unit,
               phd_smelter.profileid smelter_id,
               phd_smelter.companyname smelter_name,
               0 contained_qty,
               sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                        grd.qty_unit_id,
                                                        pdm.base_quantity_unit,
                                                        grd.current_qty)) * (-1) in_process_qty,
               sum(pkg_general.f_get_converted_quantity(grd.product_id,
                                                        grd.qty_unit_id,
                                                        pdm.base_quantity_unit,
                                                        grd.current_qty)) stock_qty,
               0 debt_qty
          from grd_goods_record_detail      grd,
               gmr_goods_movement_record    gmr,
               wrd_warehouse_receipt_detail wrd,
               ak_corporate                 akc,
               pdm_productmaster            pdm,
               qum_quantity_unit_master     qum,
               phd_profileheaderdetails     phd_smelter
         where grd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and grd.tolling_stock_type = 'RM In Process Stock'
           and gmr.internal_gmr_ref_no = wrd.internal_gmr_ref_no
           and gmr.corporate_id = akc.corporate_id
           and grd.product_id = pdm.product_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           --and wrd.smelter_cp_id = phd_smelter.profileid
            AND grd.warehouse_profile_id = phd_smelter.profileid(+)
        
         group by akc.corporate_id,
                  akc.corporate_name,
                  pdm.product_id,
                  pdm.product_desc,
                  qum.qty_unit_id,
                  qum.qty_unit,
                  phd_smelter.profileid,
                  phd_smelter.companyname
        union all
        select akc.corporate_id,
               akc.corporate_name,
               pdm.product_id,
               pdm.product_desc product_name,
               qum.qty_unit_id,
               qum.qty_unit,
               phd_smelter.profileid smelter_id,
               phd_smelter.companyname smelter_name,
               0 contained_qty,
               0 in_process_qty,
               sum(pkg_general.f_get_converted_quantity(dgrd.product_id,
                                                        dgrd.net_weight_unit_id,
                                                        pdm.base_quantity_unit,
                                                        dgrd.current_qty)) * -1 stock_qty,
               0 debt_qty
          from dgrd_delivered_grd        dgrd,
               gmr_goods_movement_record gmr,
               ak_corporate              akc,
               pdm_productmaster         pdm,
               qum_quantity_unit_master  qum,
               phd_profileheaderdetails  phd_smelter
         where dgrd.internal_gmr_ref_no = gmr.internal_gmr_ref_no
           and dgrd.tolling_stock_type = 'Return Material Stock'
           and gmr.corporate_id = akc.corporate_id
           and dgrd.product_id = pdm.product_id
           and pdm.base_quantity_unit = qum.qty_unit_id
           and dgrd.warehouse_profile_id = phd_smelter.profileid
        
         group by akc.corporate_id,
                  akc.corporate_name,
                  pdm.product_id,
                  pdm.product_desc,
                  qum.qty_unit_id,
                  qum.qty_unit,
                  phd_smelter.profileid,
                  phd_smelter.companyname) t
 group by t.corporate_id,
          t.corporate_name,
          t.product_id,
          t.product_name,
          t.qty_unit_id,
          t.qty_unit,
          t.smelter_id,
          t.smelter_name ;
          
