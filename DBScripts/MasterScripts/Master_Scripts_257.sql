update GMC_GRID_MENU_CONFIGURATION gmc
set gmc.MENU_DISPLAY_NAME = 'Cancel Contract'
where GMC.MENU_ID = 'LOCA_1_2'

update AMC_APP_MENU_CONFIGURATION amc
set amc.MENU_DISPLAY_NAME = 'List All'
where amc.MENU_ID = 'TOL-M6_M3'