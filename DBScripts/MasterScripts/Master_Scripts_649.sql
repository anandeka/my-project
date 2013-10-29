INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called,
             icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID,
             is_deleted
            )
     VALUES ('HCH', 'Holiday Change Handling', 6, 2,
             '/metals/loadHolidayHandlingListing.action?method=loadHolidayHandlingListing&gridId=HCH_LIST',
             NULL, 'PE1', NULL, 'Period End', '',
             'N'
            );



INSERT INTO amc_app_menu_configuration
            (menu_id, menu_display_name, display_seq_no, menu_level_no,
             link_called,
             icon_class, menu_parent_id, acl_id, tab_id, FEATURE_ID,
             is_deleted
            )
     VALUES ('HCH-List', 'List All', 1, 3,
             '/metals/loadHolidayHandlingListing.action?method=loadHolidayHandlingListing&gridId=HCH_LIST',
             NULL, 'HCH', NULL, 'Period End', NULL,
             'N'
            );


INSERT INTO gm_grid_master
            (grid_id, grid_name,
             default_column_model_state,
             tab_id, url,
             default_record_model_state,
             other_url, screen_specific_jsp,
             screen_specific_js
            )
     VALUES ('HCH_LIST', 'List Of Quantity Exposure Process',
             '[
 	    {
			header : "Calender",
			width : 150,
			sortable : true,
			dataIndex : "calender"
		},{
			header : "Hoilday Date",
			width : 150,
			sortable : true,
			dataIndex : "holidayDate"
		},{
			header : "Change Type",
			width : 150,
			sortable : true,
			dataIndex : "changeType"
		},{
			header : "Change Done By",
			width : 150,
			sortable : true,
			dataIndex : "updatedBy"
		},{
			header : "Activity Date",
			width : 150,
			sortable : true,
			dataIndex : "activityDate"
		},{
			header : "Status",
			width : 150,
			sortable : true,
			dataIndex : "status"
		},{
			header : "Process Id,
			width : 150,
			sortable : true,
			renderer : processIdDetailsLink
		}
		
	]',
             NULL, NULL,
             '[
	  {
		  	name : "calender",
		  	mapping : "calender"
	  },{
		  	name : "holidayDate",
		  	mapping : "holidayDate"
	  },{
			name : "changeType",
			mapping : "changeType"
	  },{
			name : "updatedBy",
			mapping : "updatedBy"
	  },{
			name : "activityDate",
			mapping : "activityDate"
	  },{
			name : "status",
			mapping : "status"
	  },{
			name : "processId",
			mapping : "processId"
	  }
	]',
             NULL, 'periodend/listOfHolidayHandling.jsp',
             '/private/js/periodend/listOfHoildayHandlingProcess.js'
            );

