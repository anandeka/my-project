UPDATE gm_grid_master gm
   SET gm.default_column_model_state =
          '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","hideable":false,"id":"checker","sortable":false,"width":20},{"dataIndex":"activityDate","header":"Activity Date","id":1,"sortable":true,"width":100},{"dataIndex":"gmrRefNo","header":"GMR Ref No.","id":2,"sortable":true,"width":100},{"dataIndex":"itemRefNos","header":"Contract Item Ref No.","id":3,"sortable":true,"width":100},{"dataIndex":"firstActivity","header":"First Activity","id":4,"sortable":true,"width":120},{"dataIndex":"currentActivity","header":"Current Activity","id":5,"sortable":true,"width":120},{"dataIndex":"vesselVoyageName","header":"Vessel / Voyage Name","id":6,"sortable":true,"width":120},{"dataIndex":"CPName","header":"CP Name","id":7,"sortable":true,"width":100},{"dataIndex":"blOrReceiptNo","header":"B/L No. or Receipt No","id":8,"sortable":true,"width":80},{"dataIndex":"blOrReceiptDate","header":"B/L Date. or Receipt Date","id":9,"sortable":true,"width":80},{"dataIndex":"warehouseName","header":"Warehouse","id":10,"sortable":true,"width":130},{"dataIndex":"productSpecs","header":"Product Specification","id":11,"sortable":true,"width":200},{"align":"right","dataIndex":"currentGMRQty","header":"Current GMR Qty","id":12,"sortable":true,"width":100},{"align":"right","dataIndex":"ttInQty","header":"TT In Qty","id":13,"sortable":true,"width":120},{"align":"right","dataIndex":"ttOutQty","header":"TT Out Qty","id":14,"sortable":true,"width":120},{"align":"right","dataIndex":"ttNoneQty","header":"TT None Qty","id":15,"sortable":true,"width":120},{"dataIndex":"status","header":"GMR Status","id":16,"sortable":true,"width":80},{"dataIndex":"actionRefNo","header":"Activity Ref.No.","id":17,"sortable":true,"width":80},{"dataIndex":"isInternalMovement","header":"Is Internal Movement.","id":18,"sortable":true,"width":80}]'
          
where GM.GRID_ID='LOG';