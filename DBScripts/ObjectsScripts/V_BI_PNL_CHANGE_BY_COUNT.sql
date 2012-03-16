CREATE OR REPLACE VIEW V_BI_PNL_CHANGE_BY_COUNT AS
select corporate_id,
       profit_center_id,
       profit_center_name,
       change_percentage change_percent,
       no_of_trades
  from (select corporate_id,
               profit_center_id,
               profit_center_name,
               change_percentage,
               count(*) no_of_trades
          from mv_unpnl_phy_change_by_trade
         group by corporate_id,
                  profit_center_id,
                  profit_center_name,
                  change_percentage)
