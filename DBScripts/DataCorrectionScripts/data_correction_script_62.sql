--GMR-11945-BLD
--978637-- allocated_qty= -151423.87413(Old Value)
--985632-- allocated_qty= -555220.87181(Old Value)
UPDATE pfd_price_fixation_details pfd
   SET pfd.allocated_qty = '0'
 WHERE pfd.pfd_id IN (978637, 985632);