CREATE OR REPLACE FUNCTION fn_get_val_date
(
    pc_delivery_calendar_id IN VARCHAR2,
    pc_exch_valuation_month IN VARCHAR2,
    pd_vm_delivery_date     IN DATE
) RETURN VARCHAR2 IS
    v_trade_date            DATE;
    is_month_app            VARCHAR2(10);
    vd_value_date           DATE;
    vc_delivery_calendar_id VARCHAR2(50);
BEGIN
    v_trade_date            := pd_vm_delivery_date;
    vc_delivery_calendar_id := pc_delivery_calendar_id;
    BEGIN
        IF pc_exch_valuation_month = 'Closest' THEN
            SELECT MIN(to_date(('01-' || mpcm.applicable_month || '-' ||
                               to_char(v_trade_date, 'YYYY')),
                               'dd/mm/yyyy'))
            INTO   vd_value_date
            FROM   mpcm_monthly_prompt_cal_month mpcm,
                   mnm_month_name_master         mnm,
                   mpc_monthly_prompt_calendar   mpc,
                   pm_period_master              pm
            WHERE  mpcm.prompt_delivery_calendar_id = vc_delivery_calendar_id
            AND    mpcm.applicable_month = mnm.month_name_id
            AND    mpcm.prompt_delivery_calendar_id =
                   mpc.prompt_delivery_calendar_id
            AND    mpc.period_type_id = pm.period_type_id
            AND    to_date(('01-' || mpcm.applicable_month || '-' ||
                           to_char(v_trade_date, 'YYYY')),
                           'dd/mm/yyyy') >= v_trade_date;
        END IF;
        IF pc_exch_valuation_month = 'Next' THEN
            SELECT MIN(to_date(('01-' || mpcm.applicable_month || '-' ||
                               to_char(v_trade_date, 'YYYY')),
                               'dd/mm/yyyy'))
            INTO   vd_value_date
            FROM   mpcm_monthly_prompt_cal_month mpcm,
                   mnm_month_name_master         mnm,
                   mpc_monthly_prompt_calendar   mpc,
                   pm_period_master              pm
            WHERE  mpcm.prompt_delivery_calendar_id = vc_delivery_calendar_id
            AND    mpcm.applicable_month = mnm.month_name_id
            AND    mpcm.prompt_delivery_calendar_id =
                   mpc.prompt_delivery_calendar_id
            AND    mpc.period_type_id = pm.period_type_id
            AND    to_date(('01-' || mpcm.applicable_month || '-' ||
                           to_char(v_trade_date, 'YYYY')),
                           'dd/mm/yyyy') > v_trade_date;
        END IF;
        IF pc_exch_valuation_month = 'Previous' THEN
            SELECT MAX(to_date(('01-' || mpcm.applicable_month || '-' ||
                               to_char(v_trade_date, 'YYYY')),
                               'dd/mm/yyyy'))
            INTO   vd_value_date
            FROM   mpcm_monthly_prompt_cal_month mpcm,
                   mnm_month_name_master         mnm,
                   mpc_monthly_prompt_calendar   mpc,
                   pm_period_master              pm
            WHERE  mpcm.prompt_delivery_calendar_id = vc_delivery_calendar_id
            AND    mpcm.applicable_month = mnm.month_name_id
            AND    mpcm.prompt_delivery_calendar_id =
                   mpc.prompt_delivery_calendar_id
            AND    mpc.period_type_id = pm.period_type_id
            AND    to_date(('01-' || mpcm.applicable_month || '-' ||
                           to_char(v_trade_date, 'YYYY')),
                           'dd/mm/yyyy') < v_trade_date;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            vd_value_date := NULL;
    END;
    IF vd_value_date IS NULL THEN
        BEGIN
            IF pc_exch_valuation_month = 'Closest' THEN
                SELECT MIN(to_date(('01-' || mpcm.applicable_month || '-' ||
                                   to_char(add_months(v_trade_date, 12),
                                            'YYYY')),
                                   'dd/mm/yyyy'))
                INTO   vd_value_date
                FROM   mpcm_monthly_prompt_cal_month mpcm,
                       mnm_month_name_master         mnm,
                       mpc_monthly_prompt_calendar   mpc,
                       pm_period_master              pm
                WHERE  mpcm.prompt_delivery_calendar_id =
                       vc_delivery_calendar_id
                AND    mpcm.applicable_month = mnm.month_name_id
                AND    mpcm.prompt_delivery_calendar_id =
                       mpc.prompt_delivery_calendar_id
                AND    mpc.period_type_id = pm.period_type_id
                AND    to_date(('01-' || mpcm.applicable_month || '-' ||
                               to_char(add_months(v_trade_date, 12), 'YYYY')),
                               'dd/mm/yyyy') >= v_trade_date;
            END IF;
            IF pc_exch_valuation_month = 'Next' THEN
                SELECT MIN(to_date(('01-' || mpcm.applicable_month || '-' ||
                                   to_char(add_months(v_trade_date, 12),
                                            'YYYY')),
                                   'dd/mm/yyyy'))
                INTO   vd_value_date
                FROM   mpcm_monthly_prompt_cal_month mpcm,
                       mnm_month_name_master         mnm,
                       mpc_monthly_prompt_calendar   mpc,
                       pm_period_master              pm
                WHERE  mpcm.prompt_delivery_calendar_id =
                       vc_delivery_calendar_id
                AND    mpcm.applicable_month = mnm.month_name_id
                AND    mpcm.prompt_delivery_calendar_id =
                       mpc.prompt_delivery_calendar_id
                AND    mpc.period_type_id = pm.period_type_id
                AND    to_date(('01-' || mpcm.applicable_month || '-' ||
                               to_char(add_months(v_trade_date, 12), 'YYYY')),
                               'dd/mm/yyyy') > v_trade_date;
            END IF;
            IF pc_exch_valuation_month = 'Previous' THEN
                SELECT MAX(cdate)
                INTO   vd_value_date
                FROM   (SELECT (to_date(('01-' || mpcm.applicable_month || '-' ||
                                        to_char(add_months(v_trade_date, -12),
                                                 'YYYY')),
                                        'dd/mm/yyyy')) cdate
                        FROM   mpcm_monthly_prompt_cal_month mpcm,
                               mnm_month_name_master         mnm,
                               mpc_monthly_prompt_calendar   mpc,
                               pm_period_master              pm
                        WHERE  mpcm.prompt_delivery_calendar_id =
                               vc_delivery_calendar_id
                        AND    mpcm.applicable_month = mnm.month_name_id
                        AND    mpcm.prompt_delivery_calendar_id =
                               mpc.prompt_delivery_calendar_id
                        AND    mpc.period_type_id = pm.period_type_id);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                vd_value_date := NULL;
        END;
    END IF;
    RETURN vd_value_date;
END;
/
CREATE OR REPLACE PROCEDURE sp_populate_pdcvm(pc_prompt_del_calendar_id VARCHAR2) IS
    CURSOR cur_months IS
        SELECT to_date('01' || to_char((to_date('01-Jan-2001') + r),'Mon-yyyy')) cdate
        FROM   (SELECT rownum - 1 r
                FROM   all_objects
                WHERE  rownum <=
                       (to_date('01-Jan-2049')) - (to_date('01-Jan-2001')) + 1)
       group by to_date('01' || to_char((to_date('01-Jan-2001') + r),'Mon-yyyy'));
    vd_closest_date  DATE;
    vd_previous_date DATE;
    vd_next_date     DATE;
BEGIN
    FOR cur_months_rows IN cur_months LOOP
        SELECT fn_get_val_date(pc_prompt_del_calendar_id,
                               'Closest',
                               cur_months_rows.cdate)
        INTO   vd_closest_date
        FROM   dual;
        SELECT fn_get_val_date(pc_prompt_del_calendar_id,
                               'Next',
                               cur_months_rows.cdate)
        INTO   vd_next_date
        FROM   dual;
        SELECT fn_get_val_date(pc_prompt_del_calendar_id,
                               'Previous',
                               cur_months_rows.cdate)
        INTO   vd_previous_date
        FROM   dual;
        INSERT INTO pdcvm_pdc_valuation_month
            (prompt_delivery_calendar_id,
             shipment_month_year,
             val_month_year_closest,
             val_month_year_previous,
             val_month_year_next)
        VALUES
            (pc_prompt_del_calendar_id,
             cur_months_rows.cdate,
             vd_closest_date,
             vd_previous_date,
             vd_next_date);
    END LOOP;
END;
/

CREATE OR REPLACE TRIGGER TRG_POPULATE_PDCVM AFTER INSERT ON PDC_PROMPT_DELIVERY_CALENDAR
FOR EACH ROW 
BEGIN
sp_populate_pdcvm(:NEW.PROMPT_DELIVERY_CALENDAR_ID);
END;
/

--
-- Use this script to populate PDCVM Initially in the system
--
DECLARE
    CURSOR cur_pdc IS
        SELECT pdc.prompt_delivery_calendar_id
FROM   pdc_prompt_delivery_calendar pdc;
BEGIN
    FOR cur_pdc_rows IN cur_pdc LOOP
        sp_populate_pdcvm(cur_pdc_rows.prompt_delivery_calendar_id);
    END LOOP;
END;
commit;
/
