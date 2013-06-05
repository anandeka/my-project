
-- column to hold the value as 'Y' when the price process is run from scheduler.
ALTER TABLE ppl_price_process_list
 ADD (is_scheduled  CHAR(1 CHAR) DEFAULT 'N' NOT NULL);
 
 