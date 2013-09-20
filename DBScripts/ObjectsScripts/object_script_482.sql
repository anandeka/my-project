
ALTER TABLE gmr_goods_movement_record  DROP COLUMN shipment_date;
ALTER TABLE gmrul_gmr_ul  DROP COLUMN shipment_date;

ALTER TABLE gmr_goods_movement_record ADD (shipment_date VARCHAR2 (30),weightnote_date VARCHAR2 (30),updated_by VARCHAR2 (15),updated_date TIMESTAMP(6));

ALTER TABLE gmrul_gmr_ul ADD (shipment_date VARCHAR2 (30),weightnote_date VARCHAR2 (30),updated_by VARCHAR2 (15),updated_date VARCHAR2 (50));