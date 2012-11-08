ALTER TABLE gmr_goods_movement_record DROP CONSTRAINT chk_gmr_tolling_gmr_type;

ALTER TABLE gmr_goods_movement_record ADD (CONSTRAINT chk_gmr_tolling_gmr_type CHECK (tolling_gmr_type IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility','In Process Adjustment')));
                                
ALTER TABLE agmr_action_gmr DROP CONSTRAINT chk_agmr_tolling_gmr_type;

ALTER TABLE agmr_action_gmr ADD (CONSTRAINT chk_agmr_tolling_gmr_type CHECK (tolling_gmr_type IN ('None Tolling','Mark For Tolling','Received Materials','Output Process',
                                'Process Activity','Input Process','Pledge','Financial Settlement',
                                'Return Material','Free Metal Utility','In Process Adjustment')));
                                
ALTER TABLE grd_goods_record_detail DROP CONSTRAINT chk_grd_tolling_stock_type;


ALTER TABLE grd_goods_record_detail ADD (CONSTRAINT chk_grd_tolling_stock_type
 CHECK (tolling_stock_type IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock','In Process Adjustment Stock')));

ALTER TABLE agrd_action_grd DROP CONSTRAINT chk_agrd_tolling_stock_type;


ALTER TABLE agrd_action_grd ADD (CONSTRAINT chk_agrd_tolling_stock_type
 CHECK (tolling_stock_type IN ('None Tolling','MFT In Process Stock','Delta MFT IP Stock',
                                    'Commercial Fee Stock','RM In Process Stock','RM Out Process Stock',
                                    'Process Activity','Clone Stock','Input Process','Output Process',
                                    'Free Material Stock','Pledge Stock','Financial Settlement Stock',
                                    'Free Metal IP Stock','Delta FM IP Stock','Free Metal Utility Stock','In Process Adjustment Stock')));