
update SLV_STATIC_LIST_VALUE set value_text='Container'  where value_id='Container';

insert INTO SLV_STATIC_LIST_VALUE (VALUE_ID,VALUE_TEXT) values ('Lot','Lot');

insert INTO SLS_STATIC_LIST_SETUP (LIST_TYPE,VALUE_ID,IS_DEFAULT,DISPLAY_ORDER) values ('UnitOfMeasure','Lot','N','3');