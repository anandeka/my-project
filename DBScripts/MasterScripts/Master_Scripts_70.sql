UPDATE gm_grid_master gm
   SET gm.default_record_model_state =
          '[
                    {header: "Activity Date", width: 100, sortable: true,  dataIndex: "activityDate"},
                    {header: "GMR Ref No.", width: 100, sortable: true, renderer:renderInternalGMRRefNo, dataIndex: "gmrRefNo"},            
                    {header: "Contract Item Ref No.", width: 100, sortable: true, renderer:hrefLink, dataIndex: "itemRefNos"},
                    {header: "First Activity", width: 120, sortable: true,  dataIndex: "firstActivity"},
                    {header: "Current Activity", width: 120, sortable: true,  dataIndex: "currentActivity"},
                    {header: "Vessel / Voyage Name", width: 120, sortable: true, renderer:renderVesselVoyageName, dataIndex: "vesselVoyageName"},
                    {header: "CP Name" , width: 100, sortable: true, renderer:renderCpProfile ,dataIndex: "CPName"},
                    {header: "B/L No. or Receipt No", width: 80, sortable: true,  renderer:renderBLRecieptNo, dataIndex: "blOrReceiptNo"},
                    {header: "B/L Date. or Receipt Date", width: 80, sortable: true,  renderer:renderBLRecieptDate,  dataIndex: "blOrReceiptDate"},
                    {header: "Warehouse", width: 130, sortable: true,   renderer:renderWarehouseShed, dataIndex: "warehouseName"},
                    {header: "Product Specification", width: 200, sortable: true, dataIndex: "productSpecs"},
                    {header: "Current GMR Qty", width: 100, sortable: true,align:"right", renderer:renderGMRQtyDetails, dataIndex: "currentGMRQty"},
                    {header: "TT In Qty", width: 120, sortable: true,align:"right", renderer:renderTTInQty, dataIndex: "ttInQty"},
                    {header: "TT Out Qty", width: 120, sortable: true,align:"right", renderer:renderTTOutQty,  dataIndex: "ttOutQty"},
                    {header: "TT None Qty", width: 120, sortable: true,align:"right", renderer:renderTTNoneQty,  dataIndex: "ttNoneQty"},
                    {header: "GMR Status", width: 80, sortable: true,  dataIndex: "status"},
                    {header: "Activity Ref.No.", width: 80, sortable: true,  dataIndex: "actionRefNo"},
                    {header: "Is Internal Movement.", width: 80, sortable: true,  dataIndex: "isInternalMovement"},
                    {header: "Title Transfer Status", width: 80, sortable: true,  dataIndex: "titleTransferStatus"},
                    {header: "Created Date", width: 80, sortable: true,  dataIndex: "createdDate"},
                    {header: "Created By", width: 80, sortable: true,  dataIndex: "createdBy"},
                    {header: "Last Updated Date", width: 80, sortable: true,  dataIndex: "updatedDate"},
                    {header: "Updated By", width: 80, sortable: true,  dataIndex: "updatedBy"}

			 ]'
 WHERE gm.grid_id = 'LOG';


SET DEFINE OFF
UPDATE gm_grid_master gm
   SET gm.default_column_model_state =
          '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"activityDate","header":"Activity Date","id":1,"sortable":true,"width":100},{"dataIndex":"gmrRefNo","header":"GMR Ref No.","id":2,"sortable":true,"width":100},{"dataIndex":"itemRefNos","header":"Contract Item Ref No.","id":3,"sortable":true,"width":100},{"dataIndex":"firstActivity","header":"First Activity","id":4,"sortable":true,"width":120},{"dataIndex":"currentActivity","header":"Current Activity","id":5,"sortable":true,"width":120},{"dataIndex":"vesselVoyageName","header":"Vessel / Voyage Name","id":6,"sortable":true,"width":120},{"dataIndex":"CPName","header":"CP Name","id":7,"sortable":true,"width":100},{"dataIndex":"blOrReceiptNo","header":"B/L No. or Receipt No","id":8,"sortable":true,"width":80},{"dataIndex":"blOrReceiptDate","header":"B/L Date. or Receipt Date","id":9,"sortable":true,"width":80},{"dataIndex":"warehouseName","header":"Warehouse","id":10,"sortable":true,"width":130},{"dataIndex":"productSpecs","header":"Product Specification","id":11,"sortable":true,"width":200},{"align":"right","dataIndex":"currentGMRQty","header":"Current GMR Qty","id":12,"sortable":true,"width":100},{"align":"right","dataIndex":"ttInQty","header":"TT In Qty","id":13,"sortable":true,"width":120},{"align":"right","dataIndex":"ttOutQty","header":"TT Out Qty","id":14,"sortable":true,"width":120},{"align":"right","dataIndex":"ttNoneQty","header":"TT None Qty","id":15,"sortable":true,"width":120},{"dataIndex":"status","header":"GMR Status","id":16,"sortable":true,"width":80},{"dataIndex":"actionRefNo","header":"Activity Ref.No.","id":17,"sortable":true,"width":80},{"dataIndex":"isInternalMovement","header":"Is Internal Movement.","id":18,"sortable":true,"width":80},{"dataIndex":"titleTransferStatus","header":"Title Transfer Status","id":19,"sortable":true,"width":80},{"dataIndex":"createdDate","header":"Created Date","id":20,"sortable":true,"width":111},{"dataIndex":"createdBy","header":"Created By","id":21,"sortable":true,"width":80},{"dataIndex":"updatedDate","header":"Last Updated Date","id":22,"sortable":true,"width":130},{"dataIndex":"updatedBy","header":"Updated By","id":23,"sortable":true,"width":80}]'
 WHERE gm.grid_id = 'LOG';
SET DEFINE ON