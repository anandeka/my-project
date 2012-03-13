create or replace view v_dqd_derivative_quote_detail as
select dqd_id,
       dq_id,
       dr_id,
       available_price_id,
       price,
       price_unit_id,
       delta,
       gamma,
       theta,
       wega,
       is_deleted,
       charm,
       lambda,
       rho,
       volatility,
       riskfree_rate,
       interest_rate,
       spot_rate,
       is_manual
  from dqd_derivative_quote_detail dqd
 where dqd.dr_id not in(select drm.dr_id
          from v_drm_multiple_prompt drm)

union
select dqd.dqd_id || new_drm.dr_id dqd_id,
       dqd.dq_id,
       new_drm.dr_id dr_id,
       dqd.available_price_id,
       dqd.price,
       dqd.price_unit_id,
       dqd.delta,
       dqd.gamma,
       dqd.theta,
       dqd.wega,
       dqd.is_deleted,
       dqd.charm,
       dqd.lambda,
       dqd.rho,
       dqd.volatility,
       dqd.riskfree_rate,
       dqd.interest_rate,
       dqd.spot_rate,
       dqd.is_manual
  from dq_derivative_quotes        dq,
       drm_derivative_master       drm,
       v_drm_multiple_prompt       new_drm,
       dqd_derivative_quote_detail dqd
 where dq.dq_id = dqd.dq_id
   and dqd.dr_id = drm.dr_id
   and drm.instrument_id = new_drm.instrument_id
   and drm.prompt_date = new_drm.prompt_date
   and drm.dr_id <> new_drm.dr_id
