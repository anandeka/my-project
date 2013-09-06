alter table PPL_PRICE_PROCESS_LIST add  IS_FREE_METAL_FIXATION  CHAR(1) default 'N'; 
  alter table PPL_PRICE_PROCESS_LIST drop column FMUH_ID;