insert into wns_assay_d_gmr
(
    internal_doc_ref_no, contract_type, buyer, seller, gmr_ref_no, 
    shipment_date, arrival_date, bl_no, bl_date, vessel_name, 
    mode_of_transport, container_no, senders_ref_no, tare_weight, 
    no_of_pieces, qty_unit
)    
with old_wns_data as
(
select 
    internal_doc_ref_no, contract_type, buyer, seller, 
    gmr_ref_no, shipment_date, arrival_date, bl_no, 
    bl_date, vessel_name, mode_of_transport, container_no, 
    null senders_ref_no, null tare_weight, null no_of_pieces, null qty_unit,
    row_number() over (partition by wnsd.internal_doc_ref_no order by rownum) ordr
from wns_assay_d wnsd
)
select 
    internal_doc_ref_no, contract_type, buyer, seller, gmr_ref_no, 
    shipment_date, arrival_date, bl_no, bl_date, vessel_name, 
    mode_of_transport, container_no, senders_ref_no, tare_weight, 
    no_of_pieces, qty_unit
from 
old_wns_data 
where ordr=1;