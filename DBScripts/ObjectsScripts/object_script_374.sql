ALTER TABLE pfd_d ADD weighted_avg_price NUMBER (25, 10);
ALTER TABLE pfd_d ADD priced_qty              NUMBER (25, 10);
ALTER  TABLE pfd_d ADD  any_day_pricing         CHAR(1 CHAR);
ALTER  TABLE pfd_d ADD fx_rate                 NUMBER (25, 10);
alter table POFH_PRICE_OPT_FIXATION_HEADER add TOTAL_PRICING_QTY number(25,10);