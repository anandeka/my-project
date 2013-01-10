
ALTER TABLE sdd_d  ADD(loading_state VARCHAR2(500));

ALTER TABLE sdd_d  ADD(destination_state VARCHAR2(500));

ALTER TABLE sdd_d  ADD(trans_shipment_state VARCHAR2(500));

ALTER TABLE sdd_d  ADD(trans_shipment_country VARCHAR2(500));


ALTER TABLE sad_d  ADD(loading_state VARCHAR2(500));

ALTER TABLE sad_d  ADD(destination_state VARCHAR2(500));

ALTER TABLE sad_d  ADD(trans_shipment_state VARCHAR2(500));

ALTER TABLE sad_d  ADD(trans_shipment_country VARCHAR2(500));