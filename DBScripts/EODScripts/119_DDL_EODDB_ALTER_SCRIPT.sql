drop MATERIALIZED VIEW PFD_PRICE_FIXATION_DETAILS;
drop table PFD_PRICE_FIXATION_DETAILS;
create materialized view PFD_PRICE_FIXATION_DETAILS  refresh fast on demand with primary key as  
select * from  PFD_PRICE_FIXATION_DETAILS@eka_appdb where is_exposure='Y';
