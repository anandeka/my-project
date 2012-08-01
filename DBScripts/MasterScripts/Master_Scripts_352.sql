
Insert into GM_GRID_MASTER
   (GRID_ID, GRID_NAME, DEFAULT_COLUMN_MODEL_STATE, TAB_ID, URL, 
    DEFAULT_RECORD_MODEL_STATE, OTHER_URL, SCREEN_SPECIFIC_JSP, SCREEN_SPECIFIC_JS)
 Values
   ('TCLOST', 'List Of Standard Text', '[{"dataIndex":"","fixed":true,"header":"<div class=\"x-grid3-hd-checker\">&#160;</div>","id":"checker","sortable":false,"width":20},
{"dataIndex":"documentType","header":"Document Name","id":1,"sortable":true,"width":100},
{"dataIndex":"txtShortName","header":"Text Name","id":2,"sortable":true,"width":120},
{"dataIndex":"txtDescription","header":"Content","id":3,"sortable":true,"width":250}]', NULL, NULL, 
    '[
                        {name: ''txtId'', mapping: ''txtId''},
                        {name: ''documentType'', mapping: ''documentType''},
                        {name: ''txtShortName'', mapping: ''txtShortName''},    
                        {name: ''txtDescription'', mapping: ''txtDescription''}
                    ]', '/private/jsp/physical/termsnconditions/termsnconditionspopup.jsp', '/private/jsp/physical/termsnconditions/tncstandardtextlist.jsp', '/private/js/physical/termsconditions/tncstandardtextlist.js');
