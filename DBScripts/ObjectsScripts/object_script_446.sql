DROP SNAPSHOT LOG ON  FMUH_FREE_METAL_UTILITY_HEADER;
DROP SNAPSHOT LOG ON  FMED_FREE_METAL_ELEMT_DETAILS;
DROP SNAPSHOT LOG ON  FMPFH_PRICE_FIXATION_HEADER;

CREATE MATERIALIZED VIEW LOG ON  FMUH_FREE_METAL_UTILITY_HEADER;
CREATE MATERIALIZED VIEW LOG ON  FMED_FREE_METAL_ELEMT_DETAILS;
CREATE MATERIALIZED VIEW LOG ON  FMPFH_PRICE_FIXATION_HEADER;