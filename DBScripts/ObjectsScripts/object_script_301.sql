ALTER TABLE YPD_YIELD_PCT_DETAIL MODIFY(YIELD_PCT NUMBER(10,4));
DROP SNAPSHOT LOG ON  YPD_YIELD_PCT_DETAIL;
CREATE MATERIALIZED VIEW LOG ON  YPD_YIELD_PCT_DETAIL;