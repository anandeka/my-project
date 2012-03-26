ALTER TABLE DIM_MONTH ADD(MNTH_DISPLAY VARCHAR2(2000 CHAR));
ALTER TABLE DIM_MONTH ADD(MNTH_ORDER NUMBER);

DECLARE
    CURSOR cur_new_col IS
        SELECT dm.mnth_desc mnth_display,
               to_number(dm.year_id || '' || dm.mnth_id) mnth_order,
               dm.mnth_desc
        FROM   dim_month dm;
BEGIN
    FOR i IN cur_new_col LOOP
        UPDATE dim_month dmt
        SET    dmt.mnth_display = i.mnth_display,
               dmt.mnth_order   = i.mnth_order
        WHERE  dmt.mnth_desc = i.mnth_desc;
    END LOOP;
END;
/