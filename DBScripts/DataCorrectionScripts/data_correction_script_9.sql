UPDATE ppl_price_process_list ppl
   SET ppl.process_type = 'Average Pricing Process'
 WHERE ppl.process_type IS NULL;