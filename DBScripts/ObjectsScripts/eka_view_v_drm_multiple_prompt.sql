CREATE OR REPLACE FORCE VIEW v_drm_multiple_prompt 
AS
  select drm_main.dr_id,
          drm_main.instrument_id,
          drm_main.prompt_date
     from drm_derivative_master drm_main,
          (select drm.instrument_id,
                  drm.prompt_date,
                  count(*) no_of_drids
             from drm_derivative_master      drm,
                  dim_der_instrument_master  dim,
                  irm_instrument_type_master irm
            where drm.is_expired = 'N'
              and drm.is_deleted = 'N'
              and drm.instrument_id = dim.instrument_id
              and dim.instrument_type_id = irm.instrument_type_id
              and irm.instrument_type in ('Future', 'Forward')
              and dim.is_active = 'Y'
              and dim.is_deleted = 'N'
              and irm.is_active = 'Y'
              and irm.is_deleted = 'N'
              and drm.price_point_id is null
            group by drm.instrument_id,
                     drm.prompt_date
           having count(*) > 1) t
    where drm_main.instrument_id = t.instrument_id
      and drm_main.prompt_date = t.prompt_date
      and drm_main.is_deleted = 'N'
      and drm_main.is_expired = 'N';

