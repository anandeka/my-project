ALTER TABLE INVD_INVENTORY_DETAIL
 MODIFY TRANSACTION_DATE DATE ;

alter table CS_COST_STORE add IS_ACTUAL_POSTED_IN_COG char(1 ) DEFAULT 'N';
ALTER TABLE sid_stock_inventory_detail ADD weightnote_qty NUMBER (20,5);