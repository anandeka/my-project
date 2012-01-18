CREATE OR REPLACE PACKAGE pkg_price IS

    -- Author  : JANARDHANA
    -- Created : 12/8/2011 2:34:26 PM
    -- Purpose : Online Price Calculation for Contracts and GMRs
    PROCEDURE sp_calc_contract_price
    (
        pc_int_contract_item_ref_no VARCHAR2,
        pd_trade_date               DATE,
        pn_price                    OUT NUMBER,
        pc_price_unit_id            OUT VARCHAR2
    );

    PROCEDURE sp_calc_gmr_price
    (
        pc_internal_gmr_ref_no VARCHAR2,
        pd_trade_date          DATE,
        pn_price               OUT NUMBER,
        pc_price_unit_id       OUT VARCHAR2
    );

    PROCEDURE sp_calc_contract_conc_price
    (
        pc_int_contract_item_ref_no VARCHAR2,
        pc_element_id               VARCHAR2,
        pd_trade_date               DATE,
        pn_price                    OUT NUMBER,
        pc_price_unit_id            OUT VARCHAR2
    );

    PROCEDURE sp_calc_conc_gmr_price
    (
        pc_internal_gmr_ref_no VARCHAR2,
        pc_element_id          VARCHAR2,
        pd_trade_date          DATE,
        pn_price               OUT NUMBER,
        pc_price_unit_id       OUT VARCHAR2
    );

    FUNCTION f_get_next_day
    (
        pd_date     IN DATE,
        pc_day      IN VARCHAR2,
        pn_position IN NUMBER
    ) RETURN DATE;

    FUNCTION f_is_day_holiday
    (
        pc_instrumentid IN VARCHAR2,
        pc_trade_date   DATE
    ) RETURN BOOLEAN;

    FUNCTION f_get_next_month_prompt_date
    (
        pc_promp_del_cal_id VARCHAR2,
        pd_trade_date       DATE
    ) RETURN DATE;

END; 
/
CREATE OR REPLACE PACKAGE BODY pkg_price IS

    PROCEDURE sp_calc_contract_price
    (
        pc_int_contract_item_ref_no VARCHAR2,
        pd_trade_date               DATE,
        pn_price                    OUT NUMBER,
        pc_price_unit_id            OUT VARCHAR2
    ) IS
        CURSOR cur_pcdi IS
            SELECT pcdi.pcdi_id,
                   pcdi.delivery_period_type,
                   pcdi.delivery_from_month,
                   pcdi.delivery_from_year,
                   pcdi.delivery_to_month,
                   pcdi.delivery_to_year,
                   pcdi.delivery_from_date,
                   pcdi.delivery_to_date,
                   pd_trade_date eod_trade_date,
                   pcdi.basis_type,
                   nvl(pcdi.transit_days, 0) transit_days,
                   pcdi.price_option_call_off_status,
                   pci.internal_contract_item_ref_no,
                   pci.item_qty,
                   pci.item_qty_unit_id,
                   pcpd.qty_unit_id,
                   pcpd.product_id,
                   qat.instrument_id,
                   ps.price_source_id,
                   apm.available_price_id,
                   vdip.ppu_price_unit_id,
                   div.price_unit_id,
                   dim.delivery_calender_id,
                   pdc.is_daily_cal_applicable,
                   pdc.is_monthly_cal_applicable
            FROM   pcdi_pc_delivery_item        pcdi,
                   pci_physical_contract_item   pci,
                   pcm_physical_contract_main   pcm,
                   ak_corporate                 akc,
                   pcpd_pc_product_definition   pcpd,
                   pcpq_pc_product_quality      pcpq,
                   v_contract_exchange_detail   qat,
                   dim_der_instrument_master    dim,
                   div_der_instrument_valuation div,
                   ps_price_source              ps,
                   apm_available_price_master   apm,
                   pum_price_unit_master        pum,
                   v_der_instrument_price_unit  vdip,
                   pdc_prompt_delivery_calendar pdc
            WHERE  pcdi.pcdi_id = pci.pcdi_id
            AND    pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
            AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
            AND    pci.pcpq_id = pcpq.pcpq_id
            AND    pcm.corporate_id = akc.corporate_id
            AND    pcm.contract_status = 'In Position'
            AND    pcm.contract_type = 'BASEMETAL'
            AND    pci.internal_contract_item_ref_no =
                   qat.internal_contract_item_ref_no(+)
            AND    qat.instrument_id = dim.instrument_id(+)
            AND    dim.instrument_id = div.instrument_id(+)
            AND    div.is_deleted(+) = 'N'
            AND    div.price_source_id = ps.price_source_id(+)
            AND    div.available_price_id = apm.available_price_id(+)
            AND    div.price_unit_id = pum.price_unit_id(+)
            AND    dim.instrument_id = vdip.instrument_id(+)
            AND    dim.delivery_calender_id =
                   pdc.prompt_delivery_calendar_id(+)
            AND    pci.item_qty > 0
            AND    pcpd.is_active = 'Y'
            AND    pcpq.is_active = 'Y'
            AND    pcdi.is_active = 'Y'
            AND    pci.is_active = 'Y'
            AND    pcm.is_active = 'Y'
            AND    pci.internal_contract_item_ref_no =
                   pc_int_contract_item_ref_no;
        CURSOR cur_called_off(pc_pcdi_id VARCHAR2) IS
            SELECT poch.poch_id,
                   poch.internal_action_ref_no,
                   pcbpd.pcbpd_id,
                   pcbpd.price_basis,
                   pcbpd.price_value,
                   pcbpd.price_unit_id,
                   pcbpd.fx_to_base,
                   pcbpd.qty_to_be_priced
            FROM   poch_price_opt_call_off_header poch,
                   pocd_price_option_calloff_dtls pocd,
                   pcbpd_pc_base_price_detail     pcbpd,
                   pcbph_pc_base_price_header     pcbph
            WHERE  poch.pcdi_id = pc_pcdi_id
            AND    poch.poch_id = pocd.poch_id
            AND    pocd.pcbpd_id = pcbpd.pcbpd_id
            AND    pcbpd.pcbph_id = pcbph.pcbph_id
            AND    poch.is_active = 'Y'
            AND    pocd.is_active = 'Y'
            AND    pcbpd.is_active = 'Y'
            AND    pcbph.is_active = 'Y';
        CURSOR cur_not_called_off(pc_pcdi_id VARCHAR2, pc_int_cont_item_ref_no VARCHAR2) IS
            SELECT pcbpd.pcbpd_id,
                   pcbph.internal_contract_ref_no,
                   pcbpd.price_basis,
                   pcbpd.price_value,
                   pcbpd.price_unit_id,
                   pcbpd.fx_to_base,
                   pcbpd.qty_to_be_priced
            FROM   pci_physical_contract_item pci,
                   pcipf_pci_pricing_formula  pcipf,
                   pcbph_pc_base_price_header pcbph,
                   pcbpd_pc_base_price_detail pcbpd
            WHERE  pci.internal_contract_item_ref_no =
                   pcipf.internal_contract_item_ref_no
            AND    pcipf.pcbph_id = pcbph.pcbph_id
            AND    pcbph.pcbph_id = pcbpd.pcbph_id
            AND    pci.pcdi_id = pc_pcdi_id
            AND    pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
            AND    pci.is_active = 'Y'
            AND    pcipf.is_active = 'Y'
            AND    pcbpd.is_active = 'Y'
            AND    pcbph.is_active = 'Y';
        vn_contract_price              NUMBER;
        vc_price_unit_id               VARCHAR2(15);
        vn_total_quantity              NUMBER;
        vn_qty_to_be_priced            NUMBER;
        vn_total_contract_value        NUMBER;
        vn_average_price               NUMBER;
        vd_qp_start_date               DATE;
        vd_qp_end_date                 DATE;
        vc_period                      VARCHAR2(15);
        vd_shipment_date               DATE;
        vd_arrival_date                DATE;
        vc_before_price_dr_id          VARCHAR2(15);
        vn_before_qp_price             NUMBER;
        vc_before_qp_price_unit_id     VARCHAR2(15);
        vd_3rd_wed_of_qp               DATE;
        vc_holiday                     CHAR(1);
        vn_after_qp_price              NUMBER;
        vc_after_qp_price_unit_id      VARCHAR2(10);
        vd_dur_qp_start_date           DATE;
        vd_dur_qp_end_date             DATE;
        vn_during_val_price            NUMBER;
        vc_during_val_price_unit_id    VARCHAR2(15);
        vn_during_total_set_price      NUMBER;
        vn_during_total_val_price      NUMBER;
        vn_count_set_qp                NUMBER;
        vn_count_val_qp                NUMBER;
        vn_workings_days               NUMBER;
        vd_quotes_date                 DATE;
        vn_after_count                 NUMBER;
        vn_after_price                 NUMBER;
        vn_during_qp_price             NUMBER;
        vc_after_price_dr_id           VARCHAR2(15);
        vc_during_price_dr_id          VARCHAR2(15);
        vc_during_qp_price_unit_id     VARCHAR2(15);
        vn_market_flag                 CHAR(1);
        vn_any_day_cont_price_fix_qty  NUMBER;
        vn_any_day_cont_price_ufix_qty NUMBER;
        vn_any_day_unfixed_qty         NUMBER;
        vn_any_day_fixed_qty           NUMBER;
        vc_prompt_month                VARCHAR2(15);
        vc_prompt_year                 NUMBER;
        vc_prompt_date                 DATE;
    BEGIN
        FOR cur_pcdi_rows IN cur_pcdi LOOP
            vn_total_contract_value := 0;
            IF cur_pcdi_rows.price_option_call_off_status IN
               ('Called Off', 'Not Applicable') THEN
                FOR cur_called_off_rows IN cur_called_off(cur_pcdi_rows.pcdi_id) LOOP
                    IF cur_called_off_rows.price_basis = 'Fixed' THEN
                        vn_contract_price       := cur_called_off_rows.price_value;
                        vn_total_quantity       := cur_pcdi_rows.item_qty;
                        vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                        vn_total_contract_value := vn_total_contract_value +
                                                   vn_total_quantity *
                                                   (vn_qty_to_be_priced / 100) *
                                                   vn_contract_price;
                        vc_price_unit_id        := cur_called_off_rows.price_unit_id;
                    ELSIF cur_called_off_rows.price_basis IN
                          ('Index', 'Formula') THEN
                        FOR cc1 IN (SELECT ppfh.ppfh_id,
                                           ppfh.price_unit_id ppu_price_unit_id,
                                           ppu.price_unit_id,
                                           pocd.qp_period_type,
                                           pofh.qp_start_date,
                                           pofh.qp_end_date,
                                           pfqpp.is_qp_any_day_basis,
                                           pofh.qty_to_be_fixed,
                                           pofh.priced_qty,
                                           pofh.pofh_id,
                                           pofh.no_of_prompt_days,
                                           nvl(pofh.no_of_prompt_days_fixed,0)no_of_prompt_days_fixed,
                                           nvl(pofh.no_of_prompt_days,0) - nvl(pofh.no_of_prompt_days_fixed,0)no_of_day_unfixed
                                    FROM   poch_price_opt_call_off_header poch,
                                           pocd_price_option_calloff_dtls pocd,
                                           pcbpd_pc_base_price_detail     pcbpd,
                                           ppfh_phy_price_formula_header  ppfh,
                                           pfqpp_phy_formula_qp_pricing   pfqpp,
                                           pofh_price_opt_fixation_header pofh,
                                           v_ppu_pum                      ppu
                                    WHERE  poch.poch_id = pocd.poch_id
                                    AND    pocd.pcbpd_id = pcbpd.pcbpd_id
                                    AND    pcbpd.pcbpd_id = ppfh.pcbpd_id
                                    AND    ppfh.ppfh_id = pfqpp.ppfh_id
                                    AND    pocd.pocd_id = pofh.pocd_id(+)
                                    AND    pcbpd.pcbpd_id =
                                           cur_called_off_rows.pcbpd_id
                                    AND    poch.poch_id =
                                           cur_called_off_rows.poch_id
                                    AND    ppfh.price_unit_id =
                                           ppu.product_price_unit_id
                                    AND    poch.is_active = 'Y'
                                    AND    pocd.is_active = 'Y'
                                    AND    pcbpd.is_active = 'Y'
                                    AND    ppfh.is_active = 'Y'
                                    AND    pfqpp.is_active = 'Y'
                                    -- and pofh.is_active(+) = 'Y'
                                    ) LOOP
                            IF cur_pcdi_rows.basis_type = 'Shipment' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_shipment_date := last_day('01-' ||
                                                                 cur_pcdi_rows.delivery_to_month || '-' ||
                                                                 cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_arrival_date := vd_shipment_date +
                                                   cur_pcdi_rows.transit_days;
                            ELSIF cur_pcdi_rows.basis_type = 'Arrival' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_arrival_date := last_day('01-' ||
                                                                cur_pcdi_rows.delivery_to_month || '-' ||
                                                                cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_shipment_date := vd_arrival_date -
                                                    cur_pcdi_rows.transit_days;
                            END IF;
                            IF cc1.qp_period_type = 'Period' THEN
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            ELSIF cc1.qp_period_type = 'Month' THEN
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            ELSIF cc1.qp_period_type = 'Date' THEN
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            ELSIF cc1.qp_period_type = 'Event' THEN
                                BEGIN
                                    SELECT dieqp.expected_qp_start_date,
                                           dieqp.expected_qp_end_date
                                    INTO   vd_qp_start_date,
                                           vd_qp_end_date
                                    FROM   di_del_item_exp_qp_details dieqp
                                    WHERE  dieqp.pcdi_id =
                                           cur_pcdi_rows.pcdi_id
                                    AND    dieqp.pcbpd_id =
                                           cur_called_off_rows.pcbpd_id
                                    AND    dieqp.is_active = 'Y';
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vd_qp_start_date := cc1.qp_start_date;
                                        vd_qp_end_date   := cc1.qp_end_date;
                                    WHEN OTHERS THEN
                                        vd_qp_start_date := cc1.qp_start_date;
                                        vd_qp_end_date   := cc1.qp_end_date;
                                END;
                            ELSE
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            END IF;
                            IF cur_pcdi_rows.eod_trade_date >= vd_qp_start_date AND
                               cur_pcdi_rows.eod_trade_date <= vd_qp_end_date THEN
                                vc_period := 'During QP';
                            ELSIF cur_pcdi_rows.eod_trade_date <
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date < vd_qp_end_date THEN
                                vc_period := 'Before QP';
                            ELSIF cur_pcdi_rows.eod_trade_date >
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date > vd_qp_end_date THEN
                                vc_period := 'After QP';
                            END IF;
                            IF vc_period = 'Before QP' THEN
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_before_qp_price,
                                           vc_before_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_before_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_before_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_before_qp_price         := 0;
                                        vc_before_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := cur_pcdi_rows.item_qty;
                                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_before_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            ELSIF vc_period = 'After QP' THEN
                                vn_after_price := 0;
                                vn_after_count := 0;
                                FOR pfd_price IN (SELECT pfd.user_price,
                                                         pfd.price_unit_id
                                                  FROM   poch_price_opt_call_off_header poch,
                                                         pocd_price_option_calloff_dtls pocd,
                                                         pofh_price_opt_fixation_header pofh,
                                                         pfd_price_fixation_details     pfd
                                                  WHERE  poch.poch_id =
                                                         pocd.poch_id
                                                  AND    pocd.pocd_id =
                                                         pofh.pocd_id
                                                  AND    pfd.pofh_id =
                                                         cc1.pofh_id
                                                  AND    pofh.pofh_id =
                                                         pfd.pofh_id
                                                  AND    poch.is_active = 'Y'
                                                  AND    pocd.is_active = 'Y'
                                                  AND    pofh.is_active = 'Y'
                                                  AND    pfd.is_active = 'Y') LOOP
                                    vn_after_price            := vn_after_price +
                                                                 pfd_price.user_price;
                                    vn_after_count            := vn_after_count + 1;
                                    vc_after_qp_price_unit_id := pfd_price.price_unit_id;
                                END LOOP;
                                IF vn_after_count = 0 THEN
                                    vn_after_qp_price       := 0;
                                    vn_total_contract_value := 0;
                                    vn_total_quantity       := cur_pcdi_rows.item_qty;
                                ELSE
                                    vn_after_qp_price       := vn_after_price /
                                                               vn_after_count;
                                    vn_total_quantity       := cur_pcdi_rows.item_qty;
                                    vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                                    vn_total_contract_value := vn_total_contract_value +
                                                               vn_total_quantity *
                                                               (vn_qty_to_be_priced / 100) *
                                                               vn_after_qp_price;
                                    vc_price_unit_id        := vc_after_qp_price_unit_id;
                                END IF;
                            ELSIF vc_period = 'During QP' THEN
                                vd_dur_qp_start_date          := vd_qp_start_date;
                                vd_dur_qp_end_date            := vd_qp_end_date;
                                vn_during_total_set_price     := 0;
                                vn_count_set_qp               := 0;
                                vn_any_day_cont_price_fix_qty := 0;
                                vn_any_day_fixed_qty          := 0;
                                FOR cc IN (SELECT pfd.user_price,
                                                  pfd.qty_fixed
                                           FROM   poch_price_opt_call_off_header poch,
                                                  pocd_price_option_calloff_dtls pocd,
                                                  pofh_price_opt_fixation_header pofh,
                                                  pfd_price_fixation_details     pfd
                                           WHERE  poch.poch_id = pocd.poch_id
                                           AND    pocd.pocd_id = pofh.pocd_id
                                           AND    pofh.pofh_id = cc1.pofh_id
                                           AND    pofh.pofh_id = pfd.pofh_id
                                           AND    pfd.as_of_date >=
                                                  vd_dur_qp_start_date
                                           AND    pfd.as_of_date <=
                                                  pd_trade_date
                                           AND    poch.is_active = 'Y'
                                           AND    pocd.is_active = 'Y'
                                           AND    pofh.is_active = 'Y'
                                           AND    pfd.is_active = 'Y') LOOP
                                    vn_during_total_set_price     := vn_during_total_set_price +
                                                                     cc.user_price;
                                    vn_any_day_cont_price_fix_qty := vn_any_day_cont_price_fix_qty +
                                                                     (cc.user_price *
                                                                     cc.qty_fixed);
                                    vn_any_day_fixed_qty          := vn_any_day_fixed_qty +
                                                                     cc.qty_fixed;
                                    vn_count_set_qp               := vn_count_set_qp + 1;
                                END LOOP;
                                IF cc1.is_qp_any_day_basis = 'Y' THEN
                                    vn_market_flag := 'N';
                                ELSE
                                    vn_market_flag := 'Y';
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_during_val_price,
                                           vc_during_val_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_during_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_during_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_during_val_price         := 0;
                                        vc_during_val_price_unit_id := NULL;
                                END;
                                vn_during_total_val_price := 0;
                                vn_count_val_qp           := 0;
                                vd_dur_qp_start_date      := pd_trade_date + 1;
                                IF vn_market_flag = 'N' THEN
                                    vn_during_total_val_price      := vn_during_total_val_price +
                                                                      vn_during_val_price;
                                    vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                                      vn_any_day_fixed_qty;
                                    vn_count_val_qp                := vn_count_val_qp + 1;
                                    vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                                                      vn_during_total_val_price);
                                ELSE
                                  /*  WHILE vd_dur_qp_start_date <=
                                          vd_dur_qp_end_date LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_dur_qp_start_date) THEN
                                            vc_holiday := 'Y';
                                        ELSE
                                            vc_holiday := 'N';
                                        END IF;
                                        IF vc_holiday = 'N' THEN
                                            vn_during_total_val_price := vn_during_total_val_price +
                                                                         vn_during_val_price;
                                            vn_count_val_qp           := vn_count_val_qp + 1;
                                        END IF;
                                        vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                                    END LOOP;*/
                                    vn_count_val_qp := cc1.no_of_day_unfixed;
                                     vn_during_total_val_price := vn_during_total_val_price +
                                                                         vn_during_val_price * vn_count_val_qp;

                                END IF;
                                IF (vn_count_val_qp + vn_count_set_qp) <> 0 THEN
                                    IF vn_market_flag = 'N' THEN
                                        vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                                              vn_any_day_cont_price_ufix_qty) /
                                                              cc1.qty_to_be_fixed;
                                    ELSE
                                        vn_during_qp_price := (vn_during_total_set_price +
                                                              vn_during_total_val_price) /
                                                              (vn_count_set_qp +
                                                              vn_count_val_qp);
                                    END IF;
                                    vn_total_quantity       := cur_pcdi_rows.item_qty;
                                    vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                                    vn_total_contract_value := vn_total_contract_value +
                                                               vn_total_quantity *
                                                               (vn_qty_to_be_priced / 100) *
                                                               vn_during_qp_price;
                                ELSE
                                    vn_total_quantity       := cur_pcdi_rows.item_qty;
                                    vn_total_contract_value := 0;
                                END IF;
                                vc_price_unit_id := cc1.ppu_price_unit_id;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
                vn_average_price := round(vn_total_contract_value /
                                          vn_total_quantity,
                                          3);
            ELSIF cur_pcdi_rows.price_option_call_off_status = 'Not Called Off' THEN
                FOR cur_not_called_off_rows IN cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                                  cur_pcdi_rows.internal_contract_item_ref_no) LOOP
                    IF cur_not_called_off_rows.price_basis = 'Fixed' THEN
                        vn_contract_price       := cur_not_called_off_rows.price_value;
                        vn_total_quantity       := cur_pcdi_rows.item_qty;
                        vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                        vn_total_contract_value := vn_total_contract_value +
                                                   vn_total_quantity *
                                                   (vn_qty_to_be_priced / 100) *
                                                   vn_contract_price;
                        vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
                    ELSIF cur_not_called_off_rows.price_basis IN
                          ('Index', 'Formula') THEN
                        FOR cc1 IN (SELECT pfqpp.qp_pricing_period_type,
                                           pfqpp.qp_period_from_date,
                                           pfqpp.qp_period_to_date,
                                           pfqpp.qp_month,
                                           pfqpp.qp_year,
                                           pfqpp.qp_date,
                                           ppfh.price_unit_id ppu_price_unit_id,
                                           ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                                    FROM   ppfh_phy_price_formula_header ppfh,
                                           pfqpp_phy_formula_qp_pricing  pfqpp,
                                           v_ppu_pum                     ppu
                                    WHERE  ppfh.ppfh_id = pfqpp.ppfh_id
                                    AND    ppfh.pcbpd_id =
                                           cur_not_called_off_rows.pcbpd_id
                                    AND    ppfh.is_active = 'Y'
                                    AND    pfqpp.is_active = 'Y'
                                    AND    ppfh.price_unit_id =
                                           ppu.product_price_unit_id) LOOP
                            IF cur_pcdi_rows.basis_type = 'Shipment' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_shipment_date := last_day('01-' ||
                                                                 cur_pcdi_rows.delivery_to_month || '-' ||
                                                                 cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_arrival_date := vd_shipment_date +
                                                   cur_pcdi_rows.transit_days;
                            ELSIF cur_pcdi_rows.basis_type = 'Arrival' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_arrival_date := last_day('01-' ||
                                                                cur_pcdi_rows.delivery_to_month || '-' ||
                                                                cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_shipment_date := vd_arrival_date -
                                                    cur_pcdi_rows.transit_days;
                            END IF;
                            IF cc1.qp_pricing_period_type = 'Period' THEN
                                vd_qp_start_date := cc1.qp_period_from_date;
                                vd_qp_end_date   := cc1.qp_period_to_date;
                            ELSIF cc1.qp_pricing_period_type = 'Month' THEN
                                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                                    cc1.qp_year;
                                vd_qp_end_date   := last_day(vd_qp_start_date);
                            ELSIF cc1.qp_pricing_period_type = 'Date' THEN
                                vd_qp_start_date := cc1.qp_date;
                                vd_qp_end_date   := cc1.qp_date;
                            ELSIF cc1.qp_pricing_period_type = 'Event' THEN
                                BEGIN
                                    SELECT dieqp.expected_qp_start_date,
                                           dieqp.expected_qp_end_date
                                    INTO   vd_qp_start_date,
                                           vd_qp_end_date
                                    FROM   di_del_item_exp_qp_details dieqp
                                    WHERE  dieqp.pcdi_id =
                                           cur_pcdi_rows.pcdi_id
                                    AND    dieqp.pcbpd_id =
                                           cur_not_called_off_rows.pcbpd_id
                                    AND    dieqp.is_active = 'Y';
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vd_qp_start_date := cc1.qp_period_from_date;
                                        vd_qp_end_date   := cc1.qp_period_to_date;
                                    WHEN OTHERS THEN
                                        vd_qp_start_date := cc1.qp_period_from_date;
                                        vd_qp_end_date   := cc1.qp_period_to_date;
                                END;
                            ELSE
                                vd_qp_start_date := cc1.qp_period_from_date;
                                vd_qp_end_date   := cc1.qp_period_to_date;
                            END IF;
                            IF cur_pcdi_rows.eod_trade_date >= vd_qp_start_date AND
                               cur_pcdi_rows.eod_trade_date <= vd_qp_end_date THEN
                                vc_period := 'During QP';
                            ELSIF cur_pcdi_rows.eod_trade_date <
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date < vd_qp_end_date THEN
                                vc_period := 'Before QP';
                            ELSIF cur_pcdi_rows.eod_trade_date >
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date > vd_qp_end_date THEN
                                vc_period := 'After QP';
                            END IF;
                            IF vc_period = 'Before QP' THEN
                                ---- get third wednesday of QP period
                                --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_before_qp_price,
                                           vc_before_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_before_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_before_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_before_qp_price         := 0;
                                        vc_before_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := cur_pcdi_rows.item_qty;
                                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_before_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            ELSIF vc_period = 'After QP' THEN
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_after_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_after_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_after_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_after_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_after_qp_price,
                                           vc_after_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_after_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_after_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_after_qp_price         := 0;
                                        vc_after_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := cur_pcdi_rows.item_qty;
                                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_after_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            ELSIF vc_period = 'During QP' THEN
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_during_qp_price,
                                           vc_during_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_during_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_during_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_during_qp_price         := 0;
                                        vc_during_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := cur_pcdi_rows.item_qty;
                                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_during_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
                vn_average_price := round(vn_total_contract_value /
                                          vn_total_quantity,
                                          3);
            END IF;
        END LOOP;
        pn_price         := vn_average_price;
        pc_price_unit_id := vc_price_unit_id;
    END;

    PROCEDURE sp_calc_gmr_price
    (
        pc_internal_gmr_ref_no VARCHAR2,
        pd_trade_date          DATE,
        pn_price               OUT NUMBER,
        pc_price_unit_id       OUT VARCHAR2
    ) IS
        CURSOR cur_gmr IS
            SELECT gmr.corporate_id,
                   gmr.internal_gmr_ref_no,
                   gmr.gmr_ref_no,
                   gmr.current_qty,
                   pofh.qp_start_date,
                   pofh.qp_end_date,
                   pofh.pofh_id,
                   pd_trade_date eod_trade_date,
                   qat.instrument_id,
                   ps.price_source_id,
                   apm.available_price_id,
                   vdip.ppu_price_unit_id,
                   div.price_unit_id,
                   pocd.is_any_day_pricing,
                   pofh.qty_to_be_fixed,
                   round(pofh.priced_qty, 4) priced_qty,
                   pofh.no_of_prompt_days,
                   pocd.pcbpd_id,
                   dim.delivery_calender_id,
                   pdc.is_daily_cal_applicable,
                   pdc.is_monthly_cal_applicable
            FROM   gmr_goods_movement_record gmr,
                   (SELECT grd.internal_gmr_ref_no,
                           grd.quality_id,
                           grd.product_id
                    FROM   grd_goods_record_detail grd
                    WHERE  grd.status = 'Active'
                    AND    grd.is_deleted = 'N'
                    AND    nvl(grd.inventory_status, 'NA') <> 'Out'
                    GROUP  BY grd.internal_gmr_ref_no,
                              grd.quality_id,
                              grd.product_id) grd,
                   pdm_productmaster pdm,
                   pdtm_product_type_master pdtm,
                   pofh_price_opt_fixation_header pofh,
                   pocd_price_option_calloff_dtls pocd,
                   v_gmr_exchange_details qat,
                   dim_der_instrument_master dim,
                   div_der_instrument_valuation div,
                   ps_price_source ps,
                   apm_available_price_master apm,
                   pum_price_unit_master pum,
                   v_der_instrument_price_unit vdip,
                   pdc_prompt_delivery_calendar pdc
            WHERE  gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
            AND    grd.product_id = pdm.product_id
            AND    pdm.product_type_id = pdtm.product_type_id
            AND    pdtm.product_type_name = 'Standard'
            AND    gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
            AND    pofh.pocd_id = pocd.pocd_id
            AND    gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
            AND    qat.instrument_id = dim.instrument_id(+)
            AND    dim.instrument_id = div.instrument_id(+)
            AND    div.is_deleted(+) = 'N'
            AND    div.price_source_id = ps.price_source_id(+)
            AND    div.available_price_id = apm.available_price_id(+)
            AND    div.price_unit_id = pum.price_unit_id(+)
            AND    dim.instrument_id = vdip.instrument_id(+)
            AND    dim.delivery_calender_id =
                   pdc.prompt_delivery_calendar_id(+)
            AND    gmr.is_deleted = 'N'
            AND    pofh.is_active = 'Y'
            AND    gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
            UNION ALL
            SELECT gmr.corporate_id,
                   gmr.internal_gmr_ref_no,
                   gmr.gmr_ref_no,
                   gmr.current_qty,
                   pofh.qp_start_date,
                   pofh.qp_end_date,
                   pofh.pofh_id,
                   pd_trade_date eod_trade_date,
                   qat.instrument_id,
                   ps.price_source_id,
                   apm.available_price_id,
                   vdip.ppu_price_unit_id,
                   div.price_unit_id,
                   pocd.is_any_day_pricing,
                   pofh.qty_to_be_fixed,
                   round(pofh.priced_qty, 4) priced_qty,
                   pofh.no_of_prompt_days,
                   pocd.pcbpd_id,
                   dim.delivery_calender_id,
                   pdc.is_daily_cal_applicable,
                   pdc.is_monthly_cal_applicable
            FROM   gmr_goods_movement_record gmr,
                   (SELECT grd.internal_gmr_ref_no,
                           grd.quality_id,
                           grd.product_id
                    FROM   dgrd_delivered_grd grd
                    WHERE  grd.status = 'Active'
                    AND    nvl(grd.inventory_status, 'NA') <> 'Out'
                    GROUP  BY grd.internal_gmr_ref_no,
                              grd.quality_id,
                              grd.product_id) grd,
                   pdm_productmaster pdm,
                   pdtm_product_type_master pdtm,
                   pofh_price_opt_fixation_header pofh,
                   pocd_price_option_calloff_dtls pocd,
                   v_gmr_exchange_details qat,
                   dim_der_instrument_master dim,
                   div_der_instrument_valuation div,
                   ps_price_source ps,
                   apm_available_price_master apm,
                   pum_price_unit_master pum,
                   v_der_instrument_price_unit vdip,
                   pdc_prompt_delivery_calendar pdc
            WHERE  gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
            AND    grd.product_id = pdm.product_id
            AND    pdm.product_type_id = pdtm.product_type_id
            AND    pdtm.product_type_name = 'Standard'
            AND    gmr.internal_gmr_ref_no = pofh.internal_gmr_ref_no
            AND    pofh.pocd_id = pocd.pocd_id
            AND    gmr.internal_gmr_ref_no = qat.internal_gmr_ref_no(+)
            AND    qat.instrument_id = dim.instrument_id(+)
            AND    dim.instrument_id = div.instrument_id(+)
            AND    div.is_deleted(+) = 'N'
            AND    div.price_source_id = ps.price_source_id(+)
            AND    div.available_price_id = apm.available_price_id(+)
            AND    div.price_unit_id = pum.price_unit_id(+)
            AND    dim.instrument_id = vdip.instrument_id(+)
            AND    dim.delivery_calender_id =
                   pdc.prompt_delivery_calendar_id(+)
            AND    gmr.is_deleted = 'N'
            AND    pofh.is_active = 'Y'
            AND    gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no;
        vd_qp_start_date               DATE;
        vd_qp_end_date                 DATE;
        vc_period                      VARCHAR2(50);
        vd_3rd_wed_of_qp               DATE;
        workings_days                  NUMBER;
        vd_quotes_date                 DATE;
        vc_before_price_dr_id          VARCHAR2(15);
        vn_before_qp_price             NUMBER;
        vc_before_qp_price_unit_id     VARCHAR2(15);
        vn_total_contract_value        NUMBER;
        vn_after_price                 NUMBER;
        vn_after_count                 NUMBER;
        vn_after_qp_price              NUMBER;
        vc_after_qp_price_unit_id      VARCHAR2(15);
        vd_dur_qp_start_date           DATE;
        vd_dur_qp_end_date             DATE;
        vn_during_total_set_price      NUMBER;
        vn_count_set_qp                NUMBER;
        vc_during_price_dr_id          VARCHAR2(15);
        vn_during_val_price            NUMBER;
        vc_during_val_price_unit_id    VARCHAR2(15);
        vn_during_total_val_price      NUMBER;
        vn_count_val_qp                NUMBER;
        vc_holiday                     CHAR(1);
        vn_during_qp_price             NUMBER;
        vn_market_flag                 CHAR(1);
        vn_any_day_cont_price_fix_qty  NUMBER;
        vn_any_day_cont_price_ufix_qty NUMBER;
        vn_any_day_unfixed_qty         NUMBER;
        vn_any_day_fixed_qty           NUMBER;
        vc_price_unit_id               VARCHAR2(15);
        vc_ppu_price_unit_id           VARCHAR2(15);
        vc_pcbpd_id                    VARCHAR2(15);
        vc_prompt_month                VARCHAR2(15);
        vc_prompt_year                 NUMBER;
        vc_prompt_date                 DATE;
    BEGIN
        FOR cur_gmr_rows IN cur_gmr LOOP
            vn_total_contract_value        := 0;
            vn_market_flag                 := NULL;
            vn_any_day_cont_price_fix_qty  := 0;
            vn_any_day_cont_price_ufix_qty := 0;
            vn_any_day_unfixed_qty         := 0;
            vn_any_day_fixed_qty           := 0;
            vc_pcbpd_id                    := cur_gmr_rows.pcbpd_id;
            vc_price_unit_id               := NULL;
            vc_ppu_price_unit_id           := NULL;
            vd_qp_start_date               := cur_gmr_rows.qp_start_date;
            vd_qp_end_date                 := cur_gmr_rows.qp_end_date;
            IF cur_gmr_rows.eod_trade_date >= vd_qp_start_date AND
               cur_gmr_rows.eod_trade_date <= vd_qp_end_date THEN
                vc_period := 'During QP';
            ELSIF cur_gmr_rows.eod_trade_date < vd_qp_start_date AND
                  cur_gmr_rows.eod_trade_date < vd_qp_end_date THEN
                vc_period := 'Before QP';
            ELSIF cur_gmr_rows.eod_trade_date > vd_qp_start_date AND
                  cur_gmr_rows.eod_trade_date > vd_qp_end_date THEN
                vc_period := 'After QP';
            END IF;
            BEGIN
                SELECT ppu.product_price_unit_id,
                       ppu.price_unit_id
                INTO   vc_ppu_price_unit_id,
                       vc_price_unit_id
                FROM   ppfh_phy_price_formula_header ppfh,
                       v_ppu_pum                     ppu
                WHERE  ppfh.pcbpd_id = vc_pcbpd_id
                AND    ppfh.price_unit_id = ppu.product_price_unit_id
                AND    rownum <= 1;
            EXCEPTION
                WHEN no_data_found THEN
                    vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
                    vc_price_unit_id     := cur_gmr_rows.price_unit_id;
                WHEN OTHERS THEN
                    vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
                    vc_price_unit_id     := cur_gmr_rows.price_unit_id;
            END;
            IF vc_period = 'Before QP' THEN
                IF cur_gmr_rows.is_daily_cal_applicable = 'Y' THEN
                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date, 'Wed', 3);
                    WHILE TRUE LOOP
                        IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                            vd_3rd_wed_of_qp) THEN
                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                        ELSE
                            EXIT;
                        END IF;
                    END LOOP;
                    --- get 3rd wednesday  before QP period 
                    -- Get the quotation date = Trade Date +2 working Days
                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                        workings_days  := 0;
                        vd_quotes_date := pd_trade_date + 1;
                        WHILE workings_days <> 2 LOOP
                            IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                vd_quotes_date) THEN
                                vd_quotes_date := vd_quotes_date + 1;
                            ELSE
                                workings_days := workings_days + 1;
                                IF workings_days <> 2 THEN
                                    vd_quotes_date := vd_quotes_date + 1;
                                END IF;
                            END IF;
                        END LOOP;
                        vd_3rd_wed_of_qp := vd_quotes_date;
                    END IF;
                    BEGIN
                        SELECT drm.dr_id
                        INTO   vc_before_price_dr_id
                        FROM   drm_derivative_master drm
                        WHERE  drm.instrument_id = cur_gmr_rows.instrument_id
                        AND    drm.prompt_date = vd_3rd_wed_of_qp
                        AND    rownum <= 1
                        AND    drm.price_point_id IS NULL
                        AND    drm.is_deleted = 'N';
                    EXCEPTION
                        WHEN no_data_found THEN
                            vc_before_price_dr_id := NULL;
                    END;
                ELSIF cur_gmr_rows.is_daily_cal_applicable = 'N' AND
                      cur_gmr_rows.is_monthly_cal_applicable = 'Y' THEN
                    vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                    vd_qp_end_date);
                    vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                    vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                    BEGIN
                        SELECT drm.dr_id
                        INTO   vc_before_price_dr_id
                        FROM   drm_derivative_master drm
                        WHERE  drm.instrument_id = cur_gmr_rows.instrument_id
                        AND    drm.period_month = vc_prompt_month
                        AND    drm.period_year = vc_prompt_year
                        AND    rownum <= 1
                        AND    drm.price_point_id IS NULL
                        AND    drm.is_deleted = 'N';
                    EXCEPTION
                        WHEN no_data_found THEN
                            vc_before_price_dr_id := NULL;
                    END;
                END IF;
                BEGIN
                    SELECT dqd.price,
                           dqd.price_unit_id
                    INTO   vn_before_qp_price,
                           vc_before_qp_price_unit_id
                    FROM   dq_derivative_quotes        dq,
                           dqd_derivative_quote_detail dqd
                    WHERE  dq.dq_id = dqd.dq_id
                    AND    dqd.dr_id = vc_before_price_dr_id
                    AND    dq.instrument_id = cur_gmr_rows.instrument_id
                    AND    dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                    AND    dq.price_source_id = cur_gmr_rows.price_source_id
                    AND    dqd.price_unit_id = vc_price_unit_id
                    AND    dq.is_deleted = 'N'
                    AND    dqd.is_deleted = 'N'
                    AND    dq.trade_date =
                           (SELECT MAX(dq.trade_date)
                             FROM   dq_derivative_quotes        dq,
                                    dqd_derivative_quote_detail dqd
                             WHERE  dq.dq_id = dqd.dq_id
                             AND    dqd.dr_id = vc_before_price_dr_id
                             AND    dq.instrument_id =
                                    cur_gmr_rows.instrument_id
                             AND    dqd.available_price_id =
                                    cur_gmr_rows.available_price_id
                             AND    dq.price_source_id =
                                    cur_gmr_rows.price_source_id
                             AND    dqd.price_unit_id = vc_price_unit_id
                             AND    dq.is_deleted = 'N'
                             AND    dqd.is_deleted = 'N'
                             AND    dq.trade_date <= pd_trade_date);
                EXCEPTION
                    WHEN no_data_found THEN
                        vn_before_qp_price         := 0;
                        vc_before_qp_price_unit_id := NULL;
                END;
                vn_total_contract_value := vn_total_contract_value +
                                           vn_before_qp_price;
            ELSIF vc_period = 'After QP' THEN
                vn_after_price := 0;
                vn_after_count := 0;
                FOR pfd_price IN (SELECT pfd.user_price,
                                         pfd.price_unit_id
                                  FROM   poch_price_opt_call_off_header poch,
                                         pocd_price_option_calloff_dtls pocd,
                                         pofh_price_opt_fixation_header pofh,
                                         pfd_price_fixation_details     pfd
                                  WHERE  poch.poch_id = pocd.poch_id
                                  AND    pocd.pocd_id = pofh.pocd_id
                                  AND    pfd.pofh_id = cur_gmr_rows.pofh_id
                                  AND    pofh.pofh_id = pfd.pofh_id
                                  AND    poch.is_active = 'Y'
                                  AND    pocd.is_active = 'Y'
                                  AND    pofh.is_active = 'Y'
                                  AND    pfd.is_active = 'Y') LOOP
                    vn_after_price := vn_after_price + pfd_price.user_price;
                    vn_after_count := vn_after_count + 1;
                END LOOP;
                IF vn_after_count = 0 THEN
                    vn_after_qp_price         := 0;
                    vn_total_contract_value   := 0;
                    vc_after_qp_price_unit_id := NULL;
                ELSE
                    vn_after_qp_price       := vn_after_price / vn_after_count;
                    vn_total_contract_value := vn_total_contract_value +
                                               vn_after_qp_price;
                END IF;
            ELSIF vc_period = 'During QP' THEN
                vd_dur_qp_start_date      := vd_qp_start_date;
                vd_dur_qp_end_date        := vd_qp_end_date;
                vn_during_total_set_price := 0;
                vn_count_set_qp           := 0;
                FOR cc IN (SELECT pfd.user_price,
                                  pfd.as_of_date,
                                  pfd.qty_fixed,
                                  pofh.final_price,
                                  pocd.is_any_day_pricing
                           FROM   poch_price_opt_call_off_header poch,
                                  pocd_price_option_calloff_dtls pocd,
                                  pofh_price_opt_fixation_header pofh,
                                  pfd_price_fixation_details     pfd
                           WHERE  poch.poch_id = pocd.poch_id
                           AND    pocd.pocd_id = pofh.pocd_id
                           AND    pofh.pofh_id = cur_gmr_rows.pofh_id
                           AND    pofh.pofh_id = pfd.pofh_id
                           AND    pfd.as_of_date >= vd_dur_qp_start_date
                           AND    pfd.as_of_date <= pd_trade_date
                           AND    poch.is_active = 'Y'
                           AND    pocd.is_active = 'Y'
                           AND    pofh.is_active = 'Y'
                           AND    pfd.is_active = 'Y') LOOP
                    vn_during_total_set_price := vn_during_total_set_price +
                                                 cc.user_price;
                    vn_count_set_qp           := vn_count_set_qp + 1;
                    vn_any_day_fixed_qty      := vn_any_day_fixed_qty +
                                                 cc.qty_fixed;
                END LOOP;
                IF cur_gmr_rows.is_any_day_pricing = 'Y' THEN
                    vn_market_flag := 'N';
                ELSE
                    vn_market_flag := 'Y';
                END IF;
                -- get the third wednes day
                IF cur_gmr_rows.is_daily_cal_applicable = 'Y' THEN
                    vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                       'Wed',
                                                       3);
                    WHILE TRUE LOOP
                        IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                            vd_3rd_wed_of_qp) THEN
                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                        ELSE
                            EXIT;
                        END IF;
                    END LOOP;
                    --- get 3rd wednesday  before QP period 
                    -- Get the quotation date = Trade Date +2 working Days
                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                        workings_days  := 0;
                        vd_quotes_date := pd_trade_date + 1;
                        WHILE workings_days <> 2 LOOP
                            IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                vd_quotes_date) THEN
                                vd_quotes_date := vd_quotes_date + 1;
                            ELSE
                                workings_days := workings_days + 1;
                                IF workings_days <> 2 THEN
                                    vd_quotes_date := vd_quotes_date + 1;
                                END IF;
                            END IF;
                        END LOOP;
                        vd_3rd_wed_of_qp := vd_quotes_date;
                    END IF;
                    BEGIN
                        SELECT drm.dr_id
                        INTO   vc_during_price_dr_id
                        FROM   drm_derivative_master drm
                        WHERE  drm.instrument_id = cur_gmr_rows.instrument_id
                        AND    drm.prompt_date = vd_3rd_wed_of_qp
                        AND    rownum <= 1
                        AND    drm.price_point_id IS NULL
                        AND    drm.is_deleted = 'N';
                    EXCEPTION
                        WHEN no_data_found THEN
                            vc_during_price_dr_id := NULL;
                    END;
                ELSIF cur_gmr_rows.is_daily_cal_applicable = 'N' AND
                      cur_gmr_rows.is_monthly_cal_applicable = 'Y' THEN
                    vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                    vd_qp_end_date);
                    vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                    vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                    BEGIN
                        SELECT drm.dr_id
                        INTO   vc_during_price_dr_id
                        FROM   drm_derivative_master drm
                        WHERE  drm.instrument_id = cur_gmr_rows.instrument_id
                        AND    drm.period_month = vc_prompt_month
                        AND    drm.period_year = vc_prompt_year
                        AND    rownum <= 1
                        AND    drm.price_point_id IS NULL
                        AND    drm.is_deleted = 'N';
                    EXCEPTION
                        WHEN no_data_found THEN
                            vc_during_price_dr_id := NULL;
                    END;
                END IF;
                BEGIN
                    SELECT dqd.price,
                           dqd.price_unit_id
                    INTO   vn_during_val_price,
                           vc_during_val_price_unit_id
                    FROM   dq_derivative_quotes        dq,
                           dqd_derivative_quote_detail dqd
                    WHERE  dq.dq_id = dqd.dq_id
                    AND    dqd.dr_id = vc_during_price_dr_id
                    AND    dq.instrument_id = cur_gmr_rows.instrument_id
                    AND    dqd.available_price_id =
                           cur_gmr_rows.available_price_id
                    AND    dq.price_source_id = cur_gmr_rows.price_source_id
                    AND    dqd.price_unit_id = vc_price_unit_id
                    AND    dq.is_deleted = 'N'
                    AND    dqd.is_deleted = 'N'
                    AND    dq.trade_date =
                           (SELECT MAX(dq.trade_date)
                             FROM   dq_derivative_quotes        dq,
                                    dqd_derivative_quote_detail dqd
                             WHERE  dq.dq_id = dqd.dq_id
                             AND    dqd.dr_id = vc_during_price_dr_id
                             AND    dq.instrument_id =
                                    cur_gmr_rows.instrument_id
                             AND    dqd.available_price_id =
                                    cur_gmr_rows.available_price_id
                             AND    dq.price_source_id =
                                    cur_gmr_rows.price_source_id
                             AND    dqd.price_unit_id = vc_price_unit_id
                             AND    dq.is_deleted = 'N'
                             AND    dqd.is_deleted = 'N'
                             AND    dq.trade_date <= pd_trade_date);
                EXCEPTION
                    WHEN no_data_found THEN
                        vn_during_val_price         := 0;
                        vc_during_val_price_unit_id := NULL;
                END;
                vn_during_total_val_price := 0;
                vn_count_val_qp           := 0;
                vd_dur_qp_start_date      := pd_trade_date + 1;
                IF vn_market_flag = 'N' THEN
                    vn_during_total_val_price      := vn_during_total_val_price +
                                                      vn_during_val_price;
                    vn_any_day_unfixed_qty         := cur_gmr_rows.qty_to_be_fixed -
                                                      vn_any_day_fixed_qty;
                    vn_count_val_qp                := vn_count_val_qp + 1;
                    vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                                      vn_during_total_val_price);
                ELSE
                    WHILE vd_dur_qp_start_date <= vd_dur_qp_end_date LOOP
                        IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                            vd_dur_qp_start_date) THEN
                            vc_holiday := 'Y';
                        ELSE
                            vc_holiday := 'N';
                        END IF;
                        IF vc_holiday = 'N' THEN
                            vn_during_total_val_price := vn_during_total_val_price +
                                                         vn_during_val_price;
                            vn_count_val_qp           := vn_count_val_qp + 1;
                        END IF;
                        vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                    END LOOP;
                END IF;
                IF (vn_count_val_qp + vn_count_set_qp) <> 0 THEN
                    IF vn_market_flag = 'N' THEN
                        vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                              vn_any_day_cont_price_ufix_qty) /
                                              cur_gmr_rows.qty_to_be_fixed;
                    ELSE
                        vn_during_qp_price := (vn_during_total_set_price +
                                              vn_during_total_val_price) /
                                              (vn_count_set_qp +
                                              vn_count_val_qp);
                    END IF;
                    vn_total_contract_value := vn_total_contract_value +
                                               vn_during_qp_price;
                ELSE
                    vn_total_contract_value := 0;
                END IF;
            END IF;
        END LOOP;
        pn_price         := vn_total_contract_value;
        pc_price_unit_id := vc_ppu_price_unit_id;
    END;

    PROCEDURE sp_calc_contract_conc_price
    (
        pc_int_contract_item_ref_no VARCHAR2,
        pc_element_id               VARCHAR2,
        pd_trade_date               DATE,
        pn_price                    OUT NUMBER,
        pc_price_unit_id            OUT VARCHAR2
    ) IS
        CURSOR cur_pcdi IS
            SELECT pcdi.pcdi_id,
                   pcm.corporate_id,
                   pcdi.internal_contract_ref_no,
                   ceqs.element_id,
                   ceqs.payable_qty,
                   ceqs.payable_qty_unit_id,
                   pcdi.delivery_item_no,
                   pcdi.delivery_period_type,
                   pcdi.delivery_from_month,
                   pcdi.delivery_from_year,
                   pcdi.delivery_to_month,
                   pcdi.delivery_to_year,
                   pcdi.delivery_from_date,
                   pcdi.delivery_to_date,
                   pd_trade_date eod_trade_date,
                   pcdi.basis_type,
                   nvl(pcdi.transit_days, 0) transit_days,
                   pcdi.qp_declaration_date,
                   pci.internal_contract_item_ref_no,
                   pcm.contract_ref_no,
                   pci.item_qty,
                   pci.item_qty_unit_id,
                   pcpd.qty_unit_id,
                   pcpd.product_id,
                   aml.underlying_product_id,
                   tt.instrument_id,
                   akc.base_cur_id,
                   tt.instrument_name,
                   tt.price_source_id,
                   tt.price_source_name,
                   tt.available_price_id,
                   tt.available_price_name,
                   tt.price_unit_name,
                   tt.ppu_price_unit_id,
                   tt.price_unit_id,
                   tt.delivery_calender_id,
                   tt.is_daily_cal_applicable,
                   tt.is_monthly_cal_applicable
            FROM   pcdi_pc_delivery_item pcdi,
                   v_contract_payable_qty ceqs,
                   pci_physical_contract_item pci,
                   pcm_physical_contract_main pcm,
                   ak_corporate akc,
                   pcpd_pc_product_definition pcpd,
                   pcpq_pc_product_quality pcpq,
                   aml_attribute_master_list aml,
                   (SELECT qat.internal_contract_item_ref_no,
                           qat.element_id,
                           qat.instrument_id,
                           dim.instrument_name,
                           ps.price_source_id,
                           ps.price_source_name,
                           apm.available_price_id,
                           apm.available_price_name,
                           pum.price_unit_name,
                           vdip.ppu_price_unit_id,
                           div.price_unit_id,
                           dim.delivery_calender_id,
                           pdc.is_daily_cal_applicable,
                           pdc.is_monthly_cal_applicable
                    FROM   v_contract_exchange_detail   qat,
                           dim_der_instrument_master    dim,
                           div_der_instrument_valuation div,
                           ps_price_source              ps,
                           apm_available_price_master   apm,
                           pum_price_unit_master        pum,
                           v_der_instrument_price_unit  vdip,
                           pdc_prompt_delivery_calendar pdc
                    WHERE  qat.instrument_id = dim.instrument_id
                    AND    dim.instrument_id = div.instrument_id
                    AND    div.is_deleted = 'N'
                    AND    div.price_source_id = ps.price_source_id
                    AND    div.available_price_id = apm.available_price_id
                    AND    div.price_unit_id = pum.price_unit_id
                    AND    dim.instrument_id = vdip.instrument_id
                    AND    dim.delivery_calender_id =
                           pdc.prompt_delivery_calendar_id) tt
            WHERE  pcdi.pcdi_id = pci.pcdi_id
            AND    pci.internal_contract_item_ref_no =
                   ceqs.internal_contract_item_ref_no
            AND    pcdi.internal_contract_ref_no = pcm.internal_contract_ref_no
            AND    pcm.internal_contract_ref_no = pcpd.internal_contract_ref_no
            AND    pci.pcpq_id = pcpq.pcpq_id
            AND    pcm.corporate_id = akc.corporate_id
            AND    pcm.contract_status = 'In Position'
            AND    pcm.contract_type = 'CONCENTRATES'
            AND    ceqs.element_id = aml.attribute_id
            AND    ceqs.internal_contract_item_ref_no =
                   tt.internal_contract_item_ref_no(+)
            AND    ceqs.element_id = tt.element_id(+)
            AND    pci.item_qty > 0
            AND    ceqs.payable_qty > 0
            AND    pcpd.is_active = 'Y'
            AND    pcpq.is_active = 'Y'
            AND    pcdi.is_active = 'Y'
            AND    pci.is_active = 'Y'
            AND    pcm.is_active = 'Y'
            AND    pci.internal_contract_item_ref_no =
                   pc_int_contract_item_ref_no
            AND    ceqs.element_id = pc_element_id;
        CURSOR cur_called_off(pc_pcdi_id VARCHAR2, pc_element_id VARCHAR2) IS
            SELECT poch.poch_id,
                   poch.internal_action_ref_no,
                   pocd.pricing_formula_id,
                   pcbpd.pcbpd_id,
                   pcbpd.price_basis,
                   pcbpd.price_value,
                   pcbpd.price_unit_id,
                   pcbpd.tonnage_basis,
                   pcbpd.fx_to_base,
                   pcbpd.qty_to_be_priced,
                   pcbph.price_description
            FROM   poch_price_opt_call_off_header poch,
                   pocd_price_option_calloff_dtls pocd,
                   pcbpd_pc_base_price_detail     pcbpd,
                   pcbph_pc_base_price_header     pcbph
            WHERE  poch.pcdi_id = pc_pcdi_id
            AND    pcbpd.element_id = pc_element_id
            AND    poch.poch_id = pocd.poch_id
            AND    pocd.pcbpd_id = pcbpd.pcbpd_id
            AND    pcbpd.pcbph_id = pcbph.pcbph_id
            AND    poch.is_active = 'Y'
            AND    pocd.is_active = 'Y'
            AND    pcbpd.is_active = 'Y'
            AND    pcbph.is_active = 'Y';
        CURSOR cur_not_called_off(pc_pcdi_id VARCHAR2, pc_element_id VARCHAR2, pc_int_cont_item_ref_no VARCHAR2) IS
            SELECT pcbpd.pcbpd_id,
                   pcbph.internal_contract_ref_no,
                   pcbpd.price_basis,
                   pcbpd.price_value,
                   pcbpd.price_unit_id,
                   pcbpd.tonnage_basis,
                   pcbpd.fx_to_base,
                   pcbpd.qty_to_be_priced,
                   pcbph.price_description
            FROM   pci_physical_contract_item pci,
                   pcipf_pci_pricing_formula  pcipf,
                   pcbph_pc_base_price_header pcbph,
                   pcbpd_pc_base_price_detail pcbpd
            WHERE  pci.internal_contract_item_ref_no =
                   pcipf.internal_contract_item_ref_no
            AND    pcipf.pcbph_id = pcbph.pcbph_id
            AND    pcbph.pcbph_id = pcbpd.pcbph_id
            AND    pci.pcdi_id = pc_pcdi_id
            AND    pcbpd.element_id = pc_element_id
            AND    pci.internal_contract_item_ref_no = pc_int_cont_item_ref_no
            AND    pci.is_active = 'Y'
            AND    pcipf.is_active = 'Y'
            AND    pcbpd.is_active = 'Y'
            AND    pcbph.is_active = 'Y';
        vn_contract_price              NUMBER;
        vc_price_unit_id               VARCHAR2(15);
        vn_total_quantity              NUMBER;
        vn_total_contract_value        NUMBER;
        vd_shipment_date               DATE;
        vd_arrival_date                DATE;
        vd_qp_start_date               DATE;
        vd_qp_end_date                 DATE;
        vc_period                      VARCHAR2(20);
        vd_3rd_wed_of_qp               DATE;
        vn_workings_days               NUMBER;
        vd_quotes_date                 DATE;
        vc_before_price_dr_id          VARCHAR2(15);
        vn_before_qp_price             NUMBER;
        vc_before_qp_price_unit_id     VARCHAR2(15);
        vn_qty_to_be_priced            NUMBER;
        vn_after_price                 NUMBER;
        vn_after_count                 NUMBER;
        vc_after_qp_price_unit_id      VARCHAR2(15);
        vn_after_qp_price              NUMBER;
        vd_dur_qp_start_date           DATE;
        vd_dur_qp_end_date             DATE;
        vn_during_total_set_price      NUMBER;
        vn_count_set_qp                NUMBER;
        vn_any_day_cont_price_fix_qty  NUMBER;
        vn_any_day_fixed_qty           NUMBER;
        vn_market_flag                 CHAR(1);
        vc_during_price_dr_id          VARCHAR2(15);
        vn_during_val_price            NUMBER;
        vc_during_val_price_unit_id    VARCHAR2(15);
        vn_during_total_val_price      NUMBER;
        vn_count_val_qp                NUMBER;
        vn_any_day_unfixed_qty         NUMBER;
        vn_any_day_cont_price_ufix_qty NUMBER;
        vc_holiday                     CHAR(10);
        vn_during_qp_price             NUMBER;
        vn_average_price               NUMBER;
        vc_after_price_dr_id           VARCHAR2(15);
        vc_during_qp_price_unit_id     VARCHAR2(15);
        vc_price_option_call_off_sts   VARCHAR2(50);
        vc_pcdi_id                     VARCHAR2(15);
        vc_element_id                  VARCHAR2(15);
        vc_prompt_month                VARCHAR2(15);
        vc_prompt_year                 NUMBER;
        vc_prompt_date                 DATE;
    BEGIN
        FOR cur_pcdi_rows IN cur_pcdi LOOP
            vc_pcdi_id    := cur_pcdi_rows.pcdi_id;
            vc_element_id := cur_pcdi_rows.element_id;
            BEGIN
                SELECT dipq.price_option_call_off_status
                INTO   vc_price_option_call_off_sts
                FROM   dipq_delivery_item_payable_qty dipq
                WHERE  dipq.pcdi_id = vc_pcdi_id
                AND    dipq.element_id = vc_element_id
                AND    dipq.is_active = 'Y';
            EXCEPTION
                WHEN no_data_found THEN
                    vc_price_option_call_off_sts := NULL;
            END;
            vn_total_contract_value := 0;
            vd_qp_start_date        := NULL;
            vd_qp_end_date          := NULL;
            IF vc_price_option_call_off_sts IN ('Called Off', 'Not Applicable') THEN
                FOR cur_called_off_rows IN cur_called_off(cur_pcdi_rows.pcdi_id,
                                                          cur_pcdi_rows.element_id) LOOP
                    IF cur_called_off_rows.price_basis = 'Fixed' THEN
                        vn_contract_price       := cur_called_off_rows.price_value;
                        vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                        cur_pcdi_rows.payable_qty_unit_id,
                                                                                        cur_pcdi_rows.item_qty_unit_id,
                                                                                        cur_pcdi_rows.payable_qty);
                        vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                        vn_total_contract_value := vn_total_contract_value +
                                                   vn_total_quantity *
                                                   (vn_qty_to_be_priced / 100) *
                                                   vn_contract_price;
                        vc_price_unit_id        := cur_called_off_rows.price_unit_id;
                    ELSIF cur_called_off_rows.price_basis IN
                          ('Index', 'Formula') THEN
                        FOR cc1 IN (SELECT ppfh.ppfh_id,
                                           ppfh.price_unit_id ppu_price_unit_id,
                                           ppu.price_unit_id,
                                           pocd.qp_period_type,
                                           pofh.qp_start_date,
                                           pofh.qp_end_date,
                                           pfqpp.event_name,
                                           pfqpp.no_of_event_months,
                                           pfqpp.is_qp_any_day_basis,
                                           pofh.qty_to_be_fixed,
                                           pofh.priced_qty,
                                           pofh.pofh_id
                                    FROM   poch_price_opt_call_off_header poch,
                                           pocd_price_option_calloff_dtls pocd,
                                           pcbpd_pc_base_price_detail     pcbpd,
                                           ppfh_phy_price_formula_header  ppfh,
                                           pfqpp_phy_formula_qp_pricing   pfqpp,
                                           pofh_price_opt_fixation_header pofh,
                                           v_ppu_pum                      ppu
                                    WHERE  poch.poch_id = pocd.poch_id
                                    AND    pocd.pcbpd_id = pcbpd.pcbpd_id
                                    AND    pcbpd.pcbpd_id = ppfh.pcbpd_id
                                    AND    ppfh.ppfh_id = pfqpp.ppfh_id
                                    AND    pocd.pocd_id = pofh.pocd_id(+)
                                    AND    pcbpd.pcbpd_id =
                                           cur_called_off_rows.pcbpd_id
                                    AND    poch.poch_id =
                                           cur_called_off_rows.poch_id
                                    AND    ppfh.price_unit_id =
                                           ppu.product_price_unit_id
                                    AND    poch.is_active = 'Y'
                                    AND    pocd.is_active = 'Y'
                                    AND    pcbpd.is_active = 'Y'
                                    AND    ppfh.is_active = 'Y'
                                    AND    pfqpp.is_active = 'Y'
                                    -- and pofh.is_active(+) = 'Y'
                                    ) LOOP
                            IF cur_pcdi_rows.basis_type = 'Shipment' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_shipment_date := last_day('01-' ||
                                                                 cur_pcdi_rows.delivery_to_month || '-' ||
                                                                 cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_arrival_date := vd_shipment_date +
                                                   cur_pcdi_rows.transit_days;
                            ELSIF cur_pcdi_rows.basis_type = 'Arrival' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_arrival_date := last_day('01-' ||
                                                                cur_pcdi_rows.delivery_to_month || '-' ||
                                                                cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_shipment_date := vd_arrival_date -
                                                    cur_pcdi_rows.transit_days;
                            END IF;
                            IF cc1.qp_period_type = 'Period' THEN
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            ELSIF cc1.qp_period_type = 'Month' THEN
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            ELSIF cc1.qp_period_type = 'Date' THEN
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            ELSIF cc1.qp_period_type = 'Event' THEN
                                BEGIN
                                    SELECT dieqp.expected_qp_start_date,
                                           dieqp.expected_qp_end_date
                                    INTO   vd_qp_start_date,
                                           vd_qp_end_date
                                    FROM   di_del_item_exp_qp_details dieqp
                                    WHERE  dieqp.pcdi_id =
                                           cur_pcdi_rows.pcdi_id
                                    AND    dieqp.pcbpd_id =
                                           cur_called_off_rows.pcbpd_id
                                    AND    dieqp.is_active = 'Y';
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vd_qp_start_date := cc1.qp_start_date;
                                        vd_qp_end_date   := cc1.qp_end_date;
                                    WHEN OTHERS THEN
                                        vd_qp_start_date := cc1.qp_start_date;
                                        vd_qp_end_date   := cc1.qp_end_date;
                                END;
                            ELSE
                                vd_qp_start_date := cc1.qp_start_date;
                                vd_qp_end_date   := cc1.qp_end_date;
                            END IF;
                            IF cur_pcdi_rows.eod_trade_date >= vd_qp_start_date AND
                               cur_pcdi_rows.eod_trade_date <= vd_qp_end_date THEN
                                vc_period := 'During QP';
                            ELSIF cur_pcdi_rows.eod_trade_date <
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date < vd_qp_end_date THEN
                                vc_period := 'Before QP';
                            ELSIF cur_pcdi_rows.eod_trade_date >
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date > vd_qp_end_date THEN
                                vc_period := 'After QP';
                            END IF;
                            IF vc_period = 'Before QP' THEN
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_before_qp_price,
                                           vc_before_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_before_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_before_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_before_qp_price         := 0;
                                        vc_before_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                                cur_pcdi_rows.payable_qty);
                                vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_before_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            ELSIF vc_period = 'After QP' THEN
                                vn_after_price := 0;
                                vn_after_count := 0;
                                FOR pfd_price IN (SELECT pfd.user_price,
                                                         pfd.price_unit_id
                                                  FROM   poch_price_opt_call_off_header poch,
                                                         pocd_price_option_calloff_dtls pocd,
                                                         pofh_price_opt_fixation_header pofh,
                                                         pfd_price_fixation_details     pfd
                                                  WHERE  poch.poch_id =
                                                         pocd.poch_id
                                                  AND    pocd.pocd_id =
                                                         pofh.pocd_id
                                                  AND    pfd.pofh_id =
                                                         cc1.pofh_id
                                                  AND    pofh.pofh_id =
                                                         pfd.pofh_id
                                                  AND    poch.is_active = 'Y'
                                                  AND    pocd.is_active = 'Y'
                                                  AND    pofh.is_active = 'Y'
                                                  AND    pfd.is_active = 'Y') LOOP
                                    vn_after_price            := vn_after_price +
                                                                 pfd_price.user_price;
                                    vn_after_count            := vn_after_count + 1;
                                    vc_after_qp_price_unit_id := pfd_price.price_unit_id;
                                END LOOP;
                                IF vn_after_count = 0 THEN
                                    vn_after_qp_price       := 0;
                                    vn_total_contract_value := 0;
                                    vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                    cur_pcdi_rows.payable_qty_unit_id,
                                                                                                    cur_pcdi_rows.item_qty_unit_id,
                                                                                                    cur_pcdi_rows.payable_qty);
                                ELSE
                                    vn_after_qp_price       := vn_after_price /
                                                               vn_after_count;
                                    vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                    cur_pcdi_rows.payable_qty_unit_id,
                                                                                                    cur_pcdi_rows.item_qty_unit_id,
                                                                                                    cur_pcdi_rows.payable_qty);
                                    vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                                    vn_total_contract_value := vn_total_contract_value +
                                                               vn_total_quantity *
                                                               (vn_qty_to_be_priced / 100) *
                                                               vn_after_qp_price;
                                    vc_price_unit_id        := vc_after_qp_price_unit_id;
                                END IF;
                            ELSIF vc_period = 'During QP' THEN
                                vd_dur_qp_start_date          := vd_qp_start_date;
                                vd_dur_qp_end_date            := vd_qp_end_date;
                                vn_during_total_set_price     := 0;
                                vn_count_set_qp               := 0;
                                vn_any_day_cont_price_fix_qty := 0;
                                vn_any_day_fixed_qty          := 0;
                                FOR cc IN (SELECT pfd.user_price,
                                                  pfd.as_of_date,
                                                  pfd.qty_fixed
                                           FROM   poch_price_opt_call_off_header poch,
                                                  pocd_price_option_calloff_dtls pocd,
                                                  pofh_price_opt_fixation_header pofh,
                                                  pfd_price_fixation_details     pfd
                                           WHERE  poch.poch_id = pocd.poch_id
                                           AND    pocd.pocd_id = pofh.pocd_id
                                           AND    pofh.pofh_id = cc1.pofh_id
                                           AND    pofh.pofh_id = pfd.pofh_id
                                           AND    pfd.as_of_date >=
                                                  vd_dur_qp_start_date
                                           AND    pfd.as_of_date <=
                                                  pd_trade_date
                                           AND    poch.is_active = 'Y'
                                           AND    pocd.is_active = 'Y'
                                           AND    pofh.is_active = 'Y'
                                           AND    pfd.is_active = 'Y') LOOP
                                    vn_during_total_set_price     := vn_during_total_set_price +
                                                                     cc.user_price;
                                    vn_any_day_cont_price_fix_qty := vn_any_day_cont_price_fix_qty +
                                                                     (cc.user_price *
                                                                     cc.qty_fixed);
                                    vn_any_day_fixed_qty          := vn_any_day_fixed_qty +
                                                                     cc.qty_fixed;
                                    vn_count_set_qp               := vn_count_set_qp + 1;
                                END LOOP;
                                IF cc1.is_qp_any_day_basis = 'Y' THEN
                                    vn_market_flag := 'N';
                                ELSE
                                    vn_market_flag := 'Y';
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    -- get the third wednes day
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    rownum <= 1
                                        AND    drm.price_point_id IS NULL
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_during_val_price,
                                           vc_during_val_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_during_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_during_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_during_val_price         := 0;
                                        vc_during_val_price_unit_id := NULL;
                                END;
                                vn_during_total_val_price := 0;
                                vn_count_val_qp           := 0;
                                vd_dur_qp_start_date      := pd_trade_date + 1;
                                IF vn_market_flag = 'N' THEN
                                    vn_during_total_val_price      := vn_during_total_val_price +
                                                                      vn_during_val_price;
                                    vn_any_day_unfixed_qty         := cc1.qty_to_be_fixed -
                                                                      vn_any_day_fixed_qty;
                                    vn_count_val_qp                := vn_count_val_qp + 1;
                                    vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                                                      vn_during_total_val_price);
                                ELSE
                                    WHILE vd_dur_qp_start_date <=
                                          vd_dur_qp_end_date LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_dur_qp_start_date) THEN
                                            vc_holiday := 'Y';
                                        ELSE
                                            vc_holiday := 'N';
                                        END IF;
                                        IF vc_holiday = 'N' THEN
                                            vn_during_total_val_price := vn_during_total_val_price +
                                                                         vn_during_val_price;
                                            vn_count_val_qp           := vn_count_val_qp + 1;
                                        END IF;
                                        vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                                    END LOOP;
                                END IF;
                                IF (vn_count_val_qp + vn_count_set_qp) <> 0 THEN
                                    IF vn_market_flag = 'N' THEN
                                        vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                                              vn_any_day_cont_price_ufix_qty) /
                                                              cc1.qty_to_be_fixed;
                                    ELSE
                                        vn_during_qp_price := (vn_during_total_set_price +
                                                              vn_during_total_val_price) /
                                                              (vn_count_set_qp +
                                                              vn_count_val_qp);
                                    END IF;
                                    vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                    cur_pcdi_rows.payable_qty_unit_id,
                                                                                                    cur_pcdi_rows.item_qty_unit_id,
                                                                                                    cur_pcdi_rows.payable_qty);
                                    vn_qty_to_be_priced     := cur_called_off_rows.qty_to_be_priced;
                                    vn_total_contract_value := vn_total_contract_value +
                                                               vn_total_quantity *
                                                               (vn_qty_to_be_priced / 100) *
                                                               vn_during_qp_price;
                                    vc_price_unit_id        := cc1.ppu_price_unit_id;
                                ELSE
                                    vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                    cur_pcdi_rows.payable_qty_unit_id,
                                                                                                    cur_pcdi_rows.item_qty_unit_id,
                                                                                                    cur_pcdi_rows.payable_qty);
                                    vn_total_contract_value := 0;
                                    vc_price_unit_id        := cc1.ppu_price_unit_id;
                                END IF;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
                vn_average_price := round(vn_total_contract_value /
                                          vn_total_quantity,
                                          3);
            ELSIF vc_price_option_call_off_sts = 'Not Called Off' THEN
                FOR cur_not_called_off_rows IN cur_not_called_off(cur_pcdi_rows.pcdi_id,
                                                                  cur_pcdi_rows.element_id,
                                                                  cur_pcdi_rows.internal_contract_item_ref_no) LOOP
                    IF cur_not_called_off_rows.price_basis = 'Fixed' THEN
                        vn_contract_price       := cur_not_called_off_rows.price_value;
                        vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                        cur_pcdi_rows.payable_qty_unit_id,
                                                                                        cur_pcdi_rows.item_qty_unit_id,
                                                                                        cur_pcdi_rows.payable_qty);
                        vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                        vn_total_contract_value := vn_total_contract_value +
                                                   vn_total_quantity *
                                                   (vn_qty_to_be_priced / 100) *
                                                   vn_contract_price;
                        vc_price_unit_id        := cur_not_called_off_rows.price_unit_id;
                    ELSIF cur_not_called_off_rows.price_basis IN
                          ('Index', 'Formula') THEN
                        FOR cc1 IN (SELECT pfqpp.qp_pricing_period_type,
                                           pfqpp.qp_period_from_date,
                                           pfqpp.qp_period_to_date,
                                           pfqpp.qp_month,
                                           pfqpp.qp_year,
                                           pfqpp.qp_date,
                                           ppfh.price_unit_id ppu_price_unit_id,
                                           ppu.price_unit_id --pum price unit id, as quoted available in this unit only
                                    FROM   ppfh_phy_price_formula_header ppfh,
                                           pfqpp_phy_formula_qp_pricing  pfqpp,
                                           v_ppu_pum                     ppu
                                    WHERE  ppfh.ppfh_id = pfqpp.ppfh_id
                                    AND    ppfh.pcbpd_id =
                                           cur_not_called_off_rows.pcbpd_id
                                    AND    ppfh.is_active = 'Y'
                                    AND    pfqpp.is_active = 'Y'
                                    AND    ppfh.price_unit_id =
                                           ppu.product_price_unit_id) LOOP
                            IF cur_pcdi_rows.basis_type = 'Shipment' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_shipment_date := last_day('01-' ||
                                                                 cur_pcdi_rows.delivery_to_month || '-' ||
                                                                 cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_shipment_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_arrival_date := vd_shipment_date +
                                                   cur_pcdi_rows.transit_days;
                            ELSIF cur_pcdi_rows.basis_type = 'Arrival' THEN
                                IF cur_pcdi_rows.delivery_period_type = 'Month' THEN
                                    vd_arrival_date := last_day('01-' ||
                                                                cur_pcdi_rows.delivery_to_month || '-' ||
                                                                cur_pcdi_rows.delivery_to_year);
                                ELSIF cur_pcdi_rows.delivery_period_type =
                                      'Date' THEN
                                    vd_arrival_date := cur_pcdi_rows.delivery_to_date;
                                END IF;
                                vd_shipment_date := vd_arrival_date -
                                                    cur_pcdi_rows.transit_days;
                            END IF;
                            IF cc1.qp_pricing_period_type = 'Period' THEN
                                vd_qp_start_date := cc1.qp_period_from_date;
                                vd_qp_end_date   := cc1.qp_period_to_date;
                            ELSIF cc1.qp_pricing_period_type = 'Month' THEN
                                vd_qp_start_date := '01-' || cc1.qp_month || '-' ||
                                                    cc1.qp_year;
                                vd_qp_end_date   := last_day(vd_qp_start_date);
                            ELSIF cc1.qp_pricing_period_type = 'Date' THEN
                                vd_qp_start_date := cc1.qp_date;
                                vd_qp_end_date   := cc1.qp_date;
                            ELSIF cc1.qp_pricing_period_type = 'Event' THEN
                                BEGIN
                                    SELECT dieqp.expected_qp_start_date,
                                           dieqp.expected_qp_end_date
                                    INTO   vd_qp_start_date,
                                           vd_qp_end_date
                                    FROM   di_del_item_exp_qp_details dieqp
                                    WHERE  dieqp.pcdi_id =
                                           cur_pcdi_rows.pcdi_id
                                    AND    dieqp.pcbpd_id =
                                           cur_not_called_off_rows.pcbpd_id
                                    AND    dieqp.is_active = 'Y';
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vd_qp_start_date := cc1.qp_period_from_date;
                                        vd_qp_end_date   := cc1.qp_period_to_date;
                                    WHEN OTHERS THEN
                                        vd_qp_start_date := cc1.qp_period_from_date;
                                        vd_qp_end_date   := cc1.qp_period_to_date;
                                END;
                            ELSE
                                vd_qp_start_date := cc1.qp_period_from_date;
                                vd_qp_end_date   := cc1.qp_period_to_date;
                            END IF;
                            IF cur_pcdi_rows.eod_trade_date >= vd_qp_start_date AND
                               cur_pcdi_rows.eod_trade_date <= vd_qp_end_date THEN
                                vc_period := 'During QP';
                            ELSIF cur_pcdi_rows.eod_trade_date <
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date < vd_qp_end_date THEN
                                vc_period := 'Before QP';
                            ELSIF cur_pcdi_rows.eod_trade_date >
                                  vd_qp_start_date AND
                                  cur_pcdi_rows.eod_trade_date > vd_qp_end_date THEN
                                vc_period := 'After QP';
                            END IF;
                            IF vc_period = 'Before QP' THEN
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    ---- get third wednesday of QP period
                                    --  If 3rd Wednesday of QP End date is not a prompt date, get the next valid prompt date
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_before_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_before_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_before_qp_price,
                                           vc_before_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_before_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_before_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_before_qp_price         := 0;
                                        vc_before_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                                cur_pcdi_rows.payable_qty);
                                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_before_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            ELSIF vc_period = 'After QP' THEN
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_after_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_after_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_after_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_after_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_after_qp_price,
                                           vc_after_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_after_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_after_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_after_qp_price         := 0;
                                        vc_after_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                                cur_pcdi_rows.payable_qty);
                                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_after_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            ELSIF vc_period = 'During QP' THEN
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'Y' THEN
                                    vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                                       'Wed',
                                                                       3);
                                    WHILE TRUE LOOP
                                        IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                            vd_3rd_wed_of_qp) THEN
                                            vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                                        ELSE
                                            EXIT;
                                        END IF;
                                    END LOOP;
                                    --- get 3rd wednesday  before QP period 
                                    -- Get the quotation date = Trade Date +2 working Days
                                    IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                                        vn_workings_days := 0;
                                        vd_quotes_date   := pd_trade_date + 1;
                                        WHILE vn_workings_days <> 2 LOOP
                                            IF f_is_day_holiday(cur_pcdi_rows.instrument_id,
                                                                vd_quotes_date) THEN
                                                vd_quotes_date := vd_quotes_date + 1;
                                            ELSE
                                                vn_workings_days := vn_workings_days + 1;
                                                IF vn_workings_days <> 2 THEN
                                                    vd_quotes_date := vd_quotes_date + 1;
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        vd_3rd_wed_of_qp := vd_quotes_date;
                                    END IF;
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.prompt_date =
                                               vd_3rd_wed_of_qp
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                IF cur_pcdi_rows.is_daily_cal_applicable = 'N' AND
                                   cur_pcdi_rows.is_monthly_cal_applicable = 'Y' THEN
                                    vc_prompt_date  := f_get_next_month_prompt_date(cur_pcdi_rows.delivery_calender_id,
                                                                                    vd_qp_end_date);
                                    vc_prompt_month := to_char(vc_prompt_date,
                                                               'Mon');
                                    vc_prompt_year  := to_char(vc_prompt_date,
                                                               'YYYY');
                                    BEGIN
                                        SELECT drm.dr_id
                                        INTO   vc_during_price_dr_id
                                        FROM   drm_derivative_master drm
                                        WHERE  drm.instrument_id =
                                               cur_pcdi_rows.instrument_id
                                        AND    drm.period_month =
                                               vc_prompt_month
                                        AND    drm.period_year = vc_prompt_year
                                        AND    drm.price_point_id IS NULL
                                        AND    rownum <= 1
                                        AND    drm.is_deleted = 'N';
                                    EXCEPTION
                                        WHEN no_data_found THEN
                                            vc_during_price_dr_id := NULL;
                                    END;
                                END IF;
                                BEGIN
                                    SELECT dqd.price,
                                           dqd.price_unit_id
                                    INTO   vn_during_qp_price,
                                           vc_during_qp_price_unit_id
                                    FROM   dq_derivative_quotes        dq,
                                           dqd_derivative_quote_detail dqd
                                    WHERE  dq.dq_id = dqd.dq_id
                                    AND    dqd.dr_id = vc_during_price_dr_id
                                    AND    dq.instrument_id =
                                           cur_pcdi_rows.instrument_id
                                    AND    dqd.available_price_id =
                                           cur_pcdi_rows.available_price_id
                                    AND    dq.price_source_id =
                                           cur_pcdi_rows.price_source_id
                                    AND    dqd.price_unit_id =
                                           cc1.price_unit_id
                                    AND    dq.is_deleted = 'N'
                                    AND    dqd.is_deleted = 'N'
                                    AND    dq.trade_date =
                                           (SELECT MAX(dq.trade_date)
                                             FROM   dq_derivative_quotes        dq,
                                                    dqd_derivative_quote_detail dqd
                                             WHERE  dq.dq_id = dqd.dq_id
                                             AND    dqd.dr_id =
                                                    vc_during_price_dr_id
                                             AND    dq.instrument_id =
                                                    cur_pcdi_rows.instrument_id
                                             AND    dqd.available_price_id =
                                                    cur_pcdi_rows.available_price_id
                                             AND    dq.price_source_id =
                                                    cur_pcdi_rows.price_source_id
                                             AND    dqd.price_unit_id =
                                                    cc1.price_unit_id
                                             AND    dq.is_deleted = 'N'
                                             AND    dqd.is_deleted = 'N'
                                             AND    dq.trade_date <=
                                                    pd_trade_date);
                                EXCEPTION
                                    WHEN no_data_found THEN
                                        vn_during_qp_price         := 0;
                                        vc_during_qp_price_unit_id := NULL;
                                END;
                                vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_pcdi_rows.underlying_product_id,
                                                                                                cur_pcdi_rows.payable_qty_unit_id,
                                                                                                cur_pcdi_rows.item_qty_unit_id,
                                                                                                cur_pcdi_rows.payable_qty);
                                vn_qty_to_be_priced     := cur_not_called_off_rows.qty_to_be_priced;
                                vn_total_contract_value := vn_total_contract_value +
                                                           vn_total_quantity *
                                                           (vn_qty_to_be_priced / 100) *
                                                           vn_during_qp_price;
                                vc_price_unit_id        := cc1.ppu_price_unit_id;
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
                vn_average_price := round(vn_total_contract_value /
                                          vn_total_quantity,
                                          3);
            END IF;
        END LOOP;
        pn_price         := vn_average_price;
        pc_price_unit_id := vc_price_unit_id;
    END;

    PROCEDURE sp_calc_conc_gmr_price
    (
        pc_internal_gmr_ref_no VARCHAR2,
        pc_element_id          VARCHAR2,
        pd_trade_date          DATE,
        pn_price               OUT NUMBER,
        pc_price_unit_id       OUT VARCHAR2
    ) IS
        CURSOR cur_gmr IS
            SELECT gmr.corporate_id,
                   gmr.internal_gmr_ref_no,
                   gmr.gmr_ref_no,
                   gmr.current_qty,
                   gmr.qty_unit_id,
                   grd.product_id,
                   pd_trade_date eod_trade_date,
                   tt.instrument_id,
                   tt.instrument_name,
                   tt.price_source_id,
                   tt.price_source_name,
                   tt.available_price_id,
                   tt.available_price_name,
                   tt.price_unit_name,
                   tt.ppu_price_unit_id,
                   tt.price_unit_id,
                   tt.delivery_calender_id,
                   tt.is_daily_cal_applicable,
                   tt.is_monthly_cal_applicable,
                   spq.element_id,
                   spq.payable_qty,
                   spq.qty_unit_id payable_qty_unit_id
            FROM   gmr_goods_movement_record gmr,
                   (SELECT grd.internal_gmr_ref_no,
                           grd.quality_id,
                           grd.product_id
                    FROM   grd_goods_record_detail grd
                    WHERE  grd.status = 'Active'
                    AND    grd.is_deleted = 'N'
                    AND    nvl(grd.inventory_status, 'NA') <> 'Out'
                    GROUP  BY grd.internal_gmr_ref_no,
                              grd.quality_id,
                              grd.product_id) grd,
                   pdm_productmaster pdm,
                   pdtm_product_type_master pdtm,
                   v_gmr_stockpayable_qty spq,
                   (SELECT qat.internal_gmr_ref_no,
                           qat.instrument_id,
                           qat.element_id,
                           dim.instrument_name,
                           ps.price_source_id,
                           ps.price_source_name,
                           apm.available_price_id,
                           apm.available_price_name,
                           pum.price_unit_name,
                           vdip.ppu_price_unit_id,
                           div.price_unit_id,
                           dim.delivery_calender_id,
                           pdc.is_daily_cal_applicable,
                           pdc.is_monthly_cal_applicable
                    FROM   v_gmr_exchange_details        qat,
                           dim_der_instrument_master    dim,
                           div_der_instrument_valuation div,
                           ps_price_source              ps,
                           apm_available_price_master   apm,
                           pum_price_unit_master        pum,
                           v_der_instrument_price_unit  vdip,
                           pdc_prompt_delivery_calendar pdc
                    WHERE  qat.instrument_id = dim.instrument_id
                    AND    dim.instrument_id = div.instrument_id
                    AND    div.is_deleted = 'N'
                    AND    div.price_source_id = ps.price_source_id
                    AND    div.available_price_id = apm.available_price_id
                    AND    div.price_unit_id = pum.price_unit_id
                    AND    dim.instrument_id = vdip.instrument_id
                    AND    dim.delivery_calender_id =
                           pdc.prompt_delivery_calendar_id) tt
            WHERE  gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
            AND    grd.product_id = pdm.product_id
            AND    pdm.product_type_id = pdtm.product_type_id
            AND    pdtm.product_type_name = 'Composite'
            AND    tt.element_id = spq.element_id
            AND    tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
            AND    gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
            AND    gmr.is_deleted = 'N'
            AND    gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
            AND    spq.element_id = pc_element_id
            UNION ALL
            SELECT gmr.corporate_id,
                   gmr.internal_gmr_ref_no,
                   gmr.gmr_ref_no,
                   gmr.current_qty,
                   gmr.qty_unit_id,
                   grd.product_id,
                   pd_trade_date eod_trade_date,
                   tt.instrument_id,
                   tt.instrument_name,
                   tt.price_source_id,
                   tt.price_source_name,
                   tt.available_price_id,
                   tt.available_price_name,
                   tt.price_unit_name,
                   tt.ppu_price_unit_id,
                   tt.price_unit_id,
                   tt.delivery_calender_id,
                   tt.is_daily_cal_applicable,
                   tt.is_monthly_cal_applicable,
                   spq.element_id,
                   spq.payable_qty,
                   spq.qty_unit_id payable_qty_unit_id
            FROM   gmr_goods_movement_record gmr,
                   (SELECT grd.internal_gmr_ref_no,
                           grd.quality_id,
                           grd.product_id
                    FROM   dgrd_delivered_grd grd
                    WHERE  grd.status = 'Active'
                    AND    nvl(grd.inventory_status, 'NA') <> 'Out'
                    GROUP  BY grd.internal_gmr_ref_no,
                              grd.quality_id,
                              grd.product_id) grd,
                   pdm_productmaster pdm,
                   pdtm_product_type_master pdtm,
                   v_gmr_stockpayable_qty spq,
                   (SELECT qat.internal_gmr_ref_no,
                           qat.instrument_id,
                           qat.element_id,
                           dim.instrument_name,
                           ps.price_source_id,
                           ps.price_source_name,
                           apm.available_price_id,
                           apm.available_price_name,
                           pum.price_unit_name,
                           vdip.ppu_price_unit_id,
                           div.price_unit_id,
                           dim.delivery_calender_id,
                           pdc.is_daily_cal_applicable,
                           pdc.is_monthly_cal_applicable
                    FROM   v_gmr_exchange_details        qat,
                           dim_der_instrument_master    dim,
                           div_der_instrument_valuation div,
                           ps_price_source              ps,
                           apm_available_price_master   apm,
                           pum_price_unit_master        pum,
                           v_der_instrument_price_unit  vdip,
                           pdc_prompt_delivery_calendar pdc
                    WHERE  qat.instrument_id = dim.instrument_id
                    AND    dim.instrument_id = div.instrument_id
                    AND    div.is_deleted = 'N'
                    AND    div.price_source_id = ps.price_source_id
                    AND    div.available_price_id = apm.available_price_id
                    AND    div.price_unit_id = pum.price_unit_id
                    AND    dim.instrument_id = vdip.instrument_id
                    AND    dim.delivery_calender_id =
                           pdc.prompt_delivery_calendar_id) tt
            WHERE  gmr.internal_gmr_ref_no = grd.internal_gmr_ref_no
            AND    grd.product_id = pdm.product_id
            AND    pdm.product_type_id = pdtm.product_type_id
            AND    pdm.product_type_id = 'Composite'
            AND    tt.element_id = spq.element_id
            AND    tt.internal_gmr_ref_no = spq.internal_gmr_ref_no
            AND    gmr.internal_gmr_ref_no = tt.internal_gmr_ref_no(+)
            AND    gmr.is_deleted = 'N'
            AND    gmr.internal_gmr_ref_no = pc_internal_gmr_ref_no
            AND    spq.element_id = pc_element_id;
        CURSOR cur_gmr_ele(pc_internal_gmr_ref_no VARCHAR2, pc_element_id VARCHAR2) IS
            SELECT pofh.internal_gmr_ref_no,
                   pofh.pofh_id,
                   pofh.qp_start_date,
                   pofh.qp_end_date,
                   pofh.qty_to_be_fixed,
                   pcbpd.element_id,
                   pcbpd.pcbpd_id,
                   pcbpd.qty_to_be_priced,
                   pocd.is_any_day_pricing,
                   pcbpd.price_basis,
                   pcbph.price_description
            FROM   pofh_price_opt_fixation_header pofh,
                   pocd_price_option_calloff_dtls pocd,
                   pcbpd_pc_base_price_detail     pcbpd,
                   pcbph_pc_base_price_header     pcbph
            WHERE  pofh.internal_gmr_ref_no = pc_internal_gmr_ref_no
            AND    pofh.pocd_id = pocd.pocd_id
            AND    pocd.pcbpd_id = pcbpd.pcbpd_id
            AND    pcbpd.pcbph_id = pcbph.pcbph_id
            AND    pcbpd.element_id = pc_element_id
            AND    pofh.is_active = 'Y'
            AND    pocd.is_active = 'Y'
            AND    pcbpd.is_active = 'Y'
            AND    pcbph.is_active = 'Y';
        vd_qp_start_date               DATE;
        vd_qp_end_date                 DATE;
        vc_period                      VARCHAR2(50);
        vd_3rd_wed_of_qp               DATE;
        vn_workings_days               NUMBER;
        vd_quotes_date                 DATE;
        vc_before_price_dr_id          VARCHAR2(15);
        vn_before_qp_price             NUMBER;
        vc_before_qp_price_unit_id     VARCHAR2(15);
        vn_total_contract_value        NUMBER;
        vn_after_price                 NUMBER;
        vn_after_count                 NUMBER;
        vn_after_qp_price              NUMBER;
        vc_after_qp_price_unit_id      VARCHAR2(15);
        vd_dur_qp_start_date           DATE;
        vd_dur_qp_end_date             DATE;
        vn_during_total_set_price      NUMBER;
        vn_count_set_qp                NUMBER;
        vc_during_price_dr_id          VARCHAR2(15);
        vn_during_val_price            NUMBER;
        vc_during_val_price_unit_id    VARCHAR2(15);
        vn_during_total_val_price      NUMBER;
        vn_count_val_qp                NUMBER;
        vc_holiday                     CHAR(1);
        vn_during_qp_price             NUMBER;
        vn_market_flag                 CHAR(1);
        vn_any_day_cont_price_fix_qty  NUMBER;
        vn_any_day_cont_price_ufix_qty NUMBER;
        vn_any_day_unfixed_qty         NUMBER;
        vn_any_day_fixed_qty           NUMBER;
        vc_price_unit_id               VARCHAR2(15);
        vc_ppu_price_unit_id           VARCHAR2(15);
        vc_price_name                  VARCHAR2(100);
        vc_pcbpd_id                    VARCHAR2(15);
        vc_prompt_month                VARCHAR2(15);
        vc_prompt_year                 NUMBER;
        vc_prompt_date                 DATE;
        vn_qty_to_be_priced            NUMBER;
        vn_total_quantity              NUMBER;
        vn_average_price               NUMBER;
    BEGIN
        FOR cur_gmr_rows IN cur_gmr LOOP
            vn_total_contract_value := 0;
            FOR cur_gmr_ele_rows IN cur_gmr_ele(cur_gmr_rows.internal_gmr_ref_no,
                                                cur_gmr_rows.element_id) LOOP
                vn_market_flag                 := NULL;
                vn_any_day_cont_price_fix_qty  := 0;
                vn_any_day_cont_price_ufix_qty := 0;
                vn_any_day_unfixed_qty         := 0;
                vn_any_day_fixed_qty           := 0;
                vc_pcbpd_id                    := cur_gmr_ele_rows.pcbpd_id;
                vc_price_unit_id               := NULL;
                vc_ppu_price_unit_id           := NULL;
                vd_qp_start_date               := cur_gmr_ele_rows.qp_start_date;
                vd_qp_end_date                 := cur_gmr_ele_rows.qp_end_date;
                IF cur_gmr_rows.eod_trade_date >= vd_qp_start_date AND
                   cur_gmr_rows.eod_trade_date <= vd_qp_end_date THEN
                    vc_period := 'During QP';
                ELSIF cur_gmr_rows.eod_trade_date < vd_qp_start_date AND
                      cur_gmr_rows.eod_trade_date < vd_qp_end_date THEN
                    vc_period := 'Before QP';
                ELSIF cur_gmr_rows.eod_trade_date > vd_qp_start_date AND
                      cur_gmr_rows.eod_trade_date > vd_qp_end_date THEN
                    vc_period := 'After QP';
                END IF;
                BEGIN
                    SELECT ppu.product_price_unit_id,
                           ppu.price_unit_id,
                           ppu.price_unit_name
                    INTO   vc_ppu_price_unit_id,
                           vc_price_unit_id,
                           vc_price_name
                    FROM   ppfh_phy_price_formula_header ppfh,
                           v_ppu_pum                     ppu
                    WHERE  ppfh.pcbpd_id = vc_pcbpd_id
                    AND    ppfh.price_unit_id = ppu.product_price_unit_id
                    AND    rownum <= 1;
                EXCEPTION
                    WHEN no_data_found THEN
                        vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
                        vc_price_unit_id     := cur_gmr_rows.price_unit_id;
                        vc_price_name        := cur_gmr_rows.price_unit_name;
                    WHEN OTHERS THEN
                        vc_ppu_price_unit_id := cur_gmr_rows.ppu_price_unit_id;
                        vc_price_unit_id     := cur_gmr_rows.price_unit_id;
                        vc_price_name        := cur_gmr_rows.price_unit_name;
                END;
                IF vc_period = 'Before QP' THEN
                    IF cur_gmr_rows.is_daily_cal_applicable = 'Y' THEN
                        vd_3rd_wed_of_qp := f_get_next_day(vd_qp_end_date,
                                                           'Wed',
                                                           3);
                        WHILE TRUE LOOP
                            IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                vd_3rd_wed_of_qp) THEN
                                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                            ELSE
                                EXIT;
                            END IF;
                        END LOOP;
                        --- get 3rd wednesday  before QP period 
                        -- Get the quotation date = Trade Date +2 working Days
                        IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                            vn_workings_days := 0;
                            vd_quotes_date   := pd_trade_date + 1;
                            WHILE vn_workings_days <> 2 LOOP
                                IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                    vd_quotes_date) THEN
                                    vd_quotes_date := vd_quotes_date + 1;
                                ELSE
                                    vn_workings_days := vn_workings_days + 1;
                                    IF vn_workings_days <> 2 THEN
                                        vd_quotes_date := vd_quotes_date + 1;
                                    END IF;
                                END IF;
                            END LOOP;
                            vd_3rd_wed_of_qp := vd_quotes_date;
                        END IF;
                        ---- get the dr_id             
                        BEGIN
                            SELECT drm.dr_id
                            INTO   vc_before_price_dr_id
                            FROM   drm_derivative_master drm
                            WHERE  drm.instrument_id =
                                   cur_gmr_rows.instrument_id
                            AND    drm.prompt_date = vd_3rd_wed_of_qp
                            AND    rownum <= 1
                            AND    drm.price_point_id IS NULL
                            AND    drm.is_deleted = 'N';
                        EXCEPTION
                            WHEN no_data_found THEN
                                vc_before_price_dr_id := NULL;
                        END;
                    ELSIF cur_gmr_rows.is_daily_cal_applicable = 'N' AND
                          cur_gmr_rows.is_monthly_cal_applicable = 'Y' THEN
                        vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                        vd_qp_end_date);
                        vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                        vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                        ---- get the dr_id             
                        BEGIN
                            SELECT drm.dr_id
                            INTO   vc_before_price_dr_id
                            FROM   drm_derivative_master drm
                            WHERE  drm.instrument_id =
                                   cur_gmr_rows.instrument_id
                            AND    drm.period_month = vc_prompt_month
                            AND    drm.period_year = vc_prompt_year
                            AND    rownum <= 1
                            AND    drm.price_point_id IS NULL
                            AND    drm.is_deleted = 'N';
                        EXCEPTION
                            WHEN no_data_found THEN
                                vc_before_price_dr_id := NULL;
                        END;
                    END IF;
                    BEGIN
                        SELECT dqd.price,
                               dqd.price_unit_id
                        INTO   vn_before_qp_price,
                               vc_before_qp_price_unit_id
                        FROM   dq_derivative_quotes        dq,
                               dqd_derivative_quote_detail dqd
                        WHERE  dq.dq_id = dqd.dq_id
                        AND    dqd.dr_id = vc_before_price_dr_id
                        AND    dq.instrument_id = cur_gmr_rows.instrument_id
                        AND    dqd.available_price_id =
                               cur_gmr_rows.available_price_id
                        AND    dq.price_source_id =
                               cur_gmr_rows.price_source_id
                        AND    dqd.price_unit_id = vc_price_unit_id
                        AND    dq.is_deleted = 'N'
                        AND    dqd.is_deleted = 'N'
                        AND    dq.trade_date =
                               (SELECT MAX(dq.trade_date)
                                 FROM   dq_derivative_quotes        dq,
                                        dqd_derivative_quote_detail dqd
                                 WHERE  dq.dq_id = dqd.dq_id
                                 AND    dqd.dr_id = vc_before_price_dr_id
                                 AND    dq.instrument_id =
                                        cur_gmr_rows.instrument_id
                                 AND    dqd.available_price_id =
                                        cur_gmr_rows.available_price_id
                                 AND    dq.price_source_id =
                                        cur_gmr_rows.price_source_id
                                 AND    dqd.price_unit_id = vc_price_unit_id
                                 AND    dq.is_deleted = 'N'
                                 AND    dqd.is_deleted = 'N'
                                 AND    dq.trade_date <= pd_trade_date);
                    EXCEPTION
                        WHEN no_data_found THEN
                            vn_before_qp_price         := 0;
                            vc_before_qp_price_unit_id := NULL;
                    END;
                    vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                                    cur_gmr_rows.payable_qty_unit_id,
                                                                                    cur_gmr_rows.qty_unit_id,
                                                                                    cur_gmr_rows.payable_qty);
                    vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
                    vn_total_contract_value := vn_total_contract_value +
                                               vn_total_quantity *
                                               (vn_qty_to_be_priced / 100) *
                                               vn_before_qp_price;
                ELSIF vc_period = 'After QP' THEN
                    vn_after_price := 0;
                    vn_after_count := 0;
                    FOR pfd_price IN (SELECT pfd.user_price,
                                             pfd.price_unit_id,
                                             pofh.final_price
                                      FROM   poch_price_opt_call_off_header poch,
                                             pocd_price_option_calloff_dtls pocd,
                                             pofh_price_opt_fixation_header pofh,
                                             pfd_price_fixation_details     pfd
                                      WHERE  poch.poch_id = pocd.poch_id
                                      AND    pocd.pocd_id = pofh.pocd_id
                                      AND    pfd.pofh_id =
                                             cur_gmr_ele_rows.pofh_id
                                      AND    pofh.pofh_id = pfd.pofh_id
                                      AND    poch.is_active = 'Y'
                                      AND    pocd.is_active = 'Y'
                                      AND    pofh.is_active = 'Y'
                                      AND    pfd.is_active = 'Y') LOOP
                        vn_after_price := vn_after_price + pfd_price.user_price;
                        vn_after_count := vn_after_count + 1;
                    END LOOP;
                    IF vn_after_count = 0 THEN
                        vn_after_qp_price         := 0;
                        vn_total_contract_value   := 0;
                        vc_after_qp_price_unit_id := NULL;
                        vn_total_quantity         := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                                          cur_gmr_rows.payable_qty_unit_id,
                                                                                          cur_gmr_rows.qty_unit_id,
                                                                                          cur_gmr_rows.payable_qty);
                    ELSE
                        vn_after_qp_price       := vn_after_price /
                                                   vn_after_count;
                        vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                                        cur_gmr_rows.payable_qty_unit_id,
                                                                                        cur_gmr_rows.qty_unit_id,
                                                                                        cur_gmr_rows.payable_qty);
                        vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
                        vn_total_contract_value := vn_total_contract_value +
                                                   vn_total_quantity *
                                                   (vn_qty_to_be_priced / 100) *
                                                   vn_after_price;
                    END IF;
                ELSIF vc_period = 'During QP' THEN
                    vd_dur_qp_start_date      := vd_qp_start_date;
                    vd_dur_qp_end_date        := vd_qp_end_date;
                    vn_during_total_set_price := 0;
                    vn_count_set_qp           := 0;
                    FOR cc IN (SELECT pfd.user_price,
                                      pfd.as_of_date,
                                      pfd.qty_fixed,
                                      pofh.final_price,
                                      pocd.is_any_day_pricing
                               FROM   poch_price_opt_call_off_header poch,
                                      pocd_price_option_calloff_dtls pocd,
                                      pofh_price_opt_fixation_header pofh,
                                      pfd_price_fixation_details     pfd
                               WHERE  poch.poch_id = pocd.poch_id
                               AND    pocd.pocd_id = pofh.pocd_id
                               AND    pofh.pofh_id = cur_gmr_ele_rows.pofh_id
                               AND    pofh.pofh_id = pfd.pofh_id
                               AND    pfd.as_of_date >= vd_dur_qp_start_date
                               AND    pfd.as_of_date <= pd_trade_date
                               AND    poch.is_active = 'Y'
                               AND    pocd.is_active = 'Y'
                               AND    pofh.is_active = 'Y'
                               AND    pfd.is_active = 'Y') LOOP
                        vn_during_total_set_price := vn_during_total_set_price +
                                                     cc.user_price;
                        vn_count_set_qp           := vn_count_set_qp + 1;
                        vn_any_day_fixed_qty      := vn_any_day_fixed_qty +
                                                     cc.qty_fixed;
                    END LOOP;
                    IF cur_gmr_ele_rows.is_any_day_pricing = 'Y' THEN
                        vn_market_flag := 'N';
                    ELSE
                        vn_market_flag := 'Y';
                    END IF;
                    IF cur_gmr_rows.is_daily_cal_applicable = 'Y' THEN
                        -- get the third wednes day
                        vd_3rd_wed_of_qp := f_get_next_day(vd_dur_qp_end_date,
                                                           'Wed',
                                                           3);
                        WHILE TRUE LOOP
                            IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                vd_3rd_wed_of_qp) THEN
                                vd_3rd_wed_of_qp := vd_3rd_wed_of_qp + 1;
                            ELSE
                                EXIT;
                            END IF;
                        END LOOP;
                        --- get 3rd wednesday  before QP period 
                        -- Get the quotation date = Trade Date +2 working Days
                        IF vd_3rd_wed_of_qp <= pd_trade_date THEN
                            vn_workings_days := 0;
                            vd_quotes_date   := pd_trade_date + 1;
                            WHILE vn_workings_days <> 2 LOOP
                                IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                    vd_quotes_date) THEN
                                    vd_quotes_date := vd_quotes_date + 1;
                                ELSE
                                    vn_workings_days := vn_workings_days + 1;
                                    IF vn_workings_days <> 2 THEN
                                        vd_quotes_date := vd_quotes_date + 1;
                                    END IF;
                                END IF;
                            END LOOP;
                            vd_3rd_wed_of_qp := vd_quotes_date;
                        END IF;
                        BEGIN
                            SELECT drm.dr_id
                            INTO   vc_during_price_dr_id
                            FROM   drm_derivative_master drm
                            WHERE  drm.instrument_id =
                                   cur_gmr_rows.instrument_id
                            AND    drm.prompt_date = vd_3rd_wed_of_qp
                            AND    rownum <= 1
                            AND    drm.price_point_id IS NULL
                            AND    drm.is_deleted = 'N';
                        EXCEPTION
                            WHEN no_data_found THEN
                                vc_during_price_dr_id := NULL;
                        END;
                    ELSIF cur_gmr_rows.is_daily_cal_applicable = 'N' AND
                          cur_gmr_rows.is_monthly_cal_applicable = 'Y' THEN
                        vc_prompt_date  := f_get_next_month_prompt_date(cur_gmr_rows.delivery_calender_id,
                                                                        vd_qp_end_date);
                        vc_prompt_month := to_char(vc_prompt_date, 'Mon');
                        vc_prompt_year  := to_char(vc_prompt_date, 'YYYY');
                        ---- get the dr_id             
                        BEGIN
                            SELECT drm.dr_id
                            INTO   vc_during_price_dr_id
                            FROM   drm_derivative_master drm
                            WHERE  drm.instrument_id =
                                   cur_gmr_rows.instrument_id
                            AND    drm.period_month = vc_prompt_month
                            AND    drm.period_year = vc_prompt_year
                            AND    rownum <= 1
                            AND    drm.price_point_id IS NULL
                            AND    drm.is_deleted = 'N';
                        EXCEPTION
                            WHEN no_data_found THEN
                                vc_during_price_dr_id := NULL;
                        END;
                    END IF;
                    BEGIN
                        SELECT dqd.price,
                               dqd.price_unit_id
                        INTO   vn_during_val_price,
                               vc_during_val_price_unit_id
                        FROM   dq_derivative_quotes        dq,
                               dqd_derivative_quote_detail dqd
                        WHERE  dq.dq_id = dqd.dq_id
                        AND    dqd.dr_id = vc_during_price_dr_id
                        AND    dq.instrument_id = cur_gmr_rows.instrument_id
                        AND    dqd.available_price_id =
                               cur_gmr_rows.available_price_id
                        AND    dq.price_source_id =
                               cur_gmr_rows.price_source_id
                        AND    dqd.price_unit_id = vc_price_unit_id
                        AND    dq.is_deleted = 'N'
                        AND    dqd.is_deleted = 'N'
                        AND    dq.trade_date =
                               (SELECT MAX(dq.trade_date)
                                 FROM   dq_derivative_quotes        dq,
                                        dqd_derivative_quote_detail dqd
                                 WHERE  dq.dq_id = dqd.dq_id
                                 AND    dqd.dr_id = vc_during_price_dr_id
                                 AND    dq.instrument_id =
                                        cur_gmr_rows.instrument_id
                                 AND    dqd.available_price_id =
                                        cur_gmr_rows.available_price_id
                                 AND    dq.price_source_id =
                                        cur_gmr_rows.price_source_id
                                 AND    dqd.price_unit_id = vc_price_unit_id
                                 AND    dq.is_deleted = 'N'
                                 AND    dqd.is_deleted = 'N'
                                 AND    dq.trade_date <= pd_trade_date);
                    EXCEPTION
                        WHEN no_data_found THEN
                            vn_during_val_price         := 0;
                            vc_during_val_price_unit_id := NULL;
                    END;
                    vn_during_total_val_price := 0;
                    vn_count_val_qp           := 0;
                    vd_dur_qp_start_date      := pd_trade_date + 1;
                    IF vn_market_flag = 'N' THEN
                        vn_during_total_val_price      := vn_during_total_val_price +
                                                          vn_during_val_price;
                        vn_any_day_unfixed_qty         := cur_gmr_ele_rows.qty_to_be_fixed -
                                                          vn_any_day_fixed_qty;
                        vn_count_val_qp                := vn_count_val_qp + 1;
                        vn_any_day_cont_price_ufix_qty := (vn_any_day_unfixed_qty *
                                                          vn_during_total_val_price);
                    ELSE
                        WHILE vd_dur_qp_start_date <= vd_dur_qp_end_date LOOP
                            IF f_is_day_holiday(cur_gmr_rows.instrument_id,
                                                vd_dur_qp_start_date) THEN
                                vc_holiday := 'Y';
                            ELSE
                                vc_holiday := 'N';
                            END IF;
                            IF vc_holiday = 'N' THEN
                                vn_during_total_val_price := vn_during_total_val_price +
                                                             vn_during_val_price;
                                vn_count_val_qp           := vn_count_val_qp + 1;
                            END IF;
                            vd_dur_qp_start_date := vd_dur_qp_start_date + 1;
                        END LOOP;
                    END IF;
                    IF (vn_count_val_qp + vn_count_set_qp) <> 0 THEN
                        IF vn_market_flag = 'N' THEN
                            vn_during_qp_price := (vn_any_day_cont_price_fix_qty +
                                                  vn_any_day_cont_price_ufix_qty) /
                                                  cur_gmr_ele_rows.qty_to_be_fixed;
                        ELSE
                            vn_during_qp_price := (vn_during_total_set_price +
                                                  vn_during_total_val_price) /
                                                  (vn_count_set_qp +
                                                  vn_count_val_qp);
                        END IF;
                        vn_total_quantity       := pkg_general.f_get_converted_quantity(cur_gmr_rows.product_id,
                                                                                        cur_gmr_rows.payable_qty_unit_id,
                                                                                        cur_gmr_rows.qty_unit_id,
                                                                                        cur_gmr_rows.payable_qty);
                        vn_qty_to_be_priced     := cur_gmr_ele_rows.qty_to_be_priced;
                        vn_total_contract_value := vn_total_contract_value +
                                                   vn_total_quantity *
                                                   (vn_qty_to_be_priced / 100) *
                                                   vn_during_qp_price;
                    ELSE
                        vn_total_contract_value := 0;
                    END IF;
                END IF;
            END LOOP;
            vn_average_price := round(vn_total_contract_value /
                                      vn_total_quantity,
                                      3);
        END LOOP;
        pn_price         := vn_average_price;
        pc_price_unit_id := vc_ppu_price_unit_id;
    END;

    FUNCTION f_get_next_day
    (
        pd_date     IN DATE,
        pc_day      IN VARCHAR2,
        pn_position IN NUMBER
    ) RETURN DATE IS
        vd_position_date DATE;
    BEGIN
        SELECT next_day((trunc(pd_date, 'Mon') - 1), pc_day) +
               ((pn_position * 7) - 7)
        INTO   vd_position_date
        FROM   dual;
        RETURN vd_position_date;
    END;

    FUNCTION f_is_day_holiday
    (
        pc_instrumentid IN VARCHAR2,
        pc_trade_date   DATE
    ) RETURN BOOLEAN IS
        vn_counter    NUMBER(1);
        vb_result_val BOOLEAN;
    BEGIN
        --Checking the Week End Holiday List
        BEGIN
            SELECT COUNT(*)
            INTO   vn_counter
            FROM   dual
            WHERE  to_char(pc_trade_date, 'Dy') IN
                   (SELECT clwh.holiday
                    FROM   dim_der_instrument_master    dim,
                           clm_calendar_master          clm,
                           clwh_calendar_weekly_holiday clwh
                    WHERE  dim.holiday_calender_id = clm.calendar_id
                    AND    clm.calendar_id = clwh.calendar_id
                    AND    dim.instrument_id = pc_instrumentid
                    AND    clm.is_deleted = 'N'
                    AND    clwh.is_deleted = 'N');
            IF (vn_counter = 1) THEN
                vb_result_val := TRUE;
            ELSE
                vb_result_val := FALSE;
            END IF;
            IF (vb_result_val = FALSE) THEN
                --Checking Other Holiday List
                SELECT COUNT(*)
                INTO   vn_counter
                FROM   dual
                WHERE  TRIM(pc_trade_date) IN
                       (SELECT TRIM(hl.holiday_date)
                        FROM   hm_holiday_master         hm,
                               hl_holiday_list           hl,
                               dim_der_instrument_master dim,
                               clm_calendar_master       clm
                        WHERE  hm.holiday_id = hl.holiday_id
                        AND    dim.holiday_calender_id = clm.calendar_id
                        AND    clm.calendar_id = hm.calendar_id
                        AND    dim.instrument_id = pc_instrumentid
                        AND    hm.is_deleted = 'N'
                        AND    hl.is_deleted = 'N');
                IF (vn_counter = 1) THEN
                    vb_result_val := TRUE;
                ELSE
                    vb_result_val := FALSE;
                END IF;
            END IF;
        END;
        RETURN vb_result_val;
    END;

    FUNCTION f_get_next_month_prompt_date
    (
        pc_promp_del_cal_id VARCHAR2,
        pd_trade_date       DATE
    ) RETURN DATE IS
        CURSOR cur_monthly_prompt_rule IS
            SELECT mpc.*
            FROM   mpc_monthly_prompt_calendar mpc
            WHERE  mpc.prompt_delivery_calendar_id = pc_promp_del_cal_id;
        CURSOR cr_applicable_months IS
            SELECT mpcm.*
            FROM   mpcm_monthly_prompt_cal_month mpcm,
                   mnm_month_name_master         mnm
            WHERE  mpcm.prompt_delivery_calendar_id = pc_promp_del_cal_id
            AND    mpcm.applicable_month = mnm.month_name_id
            ORDER  BY mnm.display_order;
        vc_pdc_period_type_id      VARCHAR2(15);
        vc_month_prompt_start_date DATE;
        vc_equ_period_type         NUMBER;
        cr_monthly_prompt_rule_rec cur_monthly_prompt_rule%ROWTYPE;
        vc_period_to               NUMBER;
        vd_start_date              DATE;
        vd_end_date                DATE;
        vc_month                   VARCHAR2(15);
        vn_year                    NUMBER;
        vn_month_count             NUMBER(5);
        vd_prompt_date             DATE;
    BEGIN
        vc_month_prompt_start_date := pd_trade_date;
        vn_month_count             := 0;
        BEGIN
            SELECT pm.period_type_id
            INTO   vc_pdc_period_type_id
            FROM   pm_period_master pm
            WHERE  pm.period_type_name = 'Month';
        END;
        OPEN cur_monthly_prompt_rule;
        FETCH cur_monthly_prompt_rule
            INTO cr_monthly_prompt_rule_rec;
        vc_period_to := cr_monthly_prompt_rule_rec.period_for; --no of forward months required
        BEGIN
            SELECT pm.equivalent_days
            INTO   vc_equ_period_type
            FROM   pm_period_master pm
            WHERE  pm.period_type_id =
                   cr_monthly_prompt_rule_rec.period_type_id;
        END;
        vd_start_date := vc_month_prompt_start_date;
        vd_end_date   := vc_month_prompt_start_date +
                         (vc_period_to * vc_equ_period_type);
        FOR cr_applicable_months_rec IN cr_applicable_months LOOP
            vc_month_prompt_start_date := to_date(('01-' ||
                                                  cr_applicable_months_rec.applicable_month || '-' ||
                                                  to_char(vd_start_date,
                                                           'YYYY')),
                                                  'dd/mm/yyyy');
            --------------------
            IF (vc_month_prompt_start_date >=
               to_date(('01-' || to_char(vd_start_date, 'Mon-YYYY')),
                        'dd/mm/yyyy') AND
               vc_month_prompt_start_date <= vd_end_date) THEN
                vn_month_count := vn_month_count + 1;
                IF vn_month_count = 1 THEN
                    vc_month := to_char(vc_month_prompt_start_date, 'Mon');
                    vn_year  := to_char(vc_month_prompt_start_date, 'YYYY');
                END IF;
            END IF;
            EXIT WHEN vn_month_count > 1;
            ---------------
        END LOOP;
        CLOSE cur_monthly_prompt_rule;
        IF vc_month IS NOT NULL AND
           vn_year IS NOT NULL THEN
            vd_prompt_date := to_date('01-' || vc_month || '-' || vn_year,
                                      'dd-Mon-yyyy');
        END IF;
        RETURN vd_prompt_date;
    END;

END; 
/
