create or replace function f_get_payment_due_date(p_int_gmr_ref_no      varchar2,
                                                  p_int_contract_ref_no varchar2)
---------------------------------------------------------------------------------------------
  --    Function:           F_Get_Payment_Due_Date
  --    Created On:        19th, Feb 2013
  --    Created By:        G.A.Raju
  --    Purpose:           To get payment due date  
  ------------------------------------------------------------------------------------------------
 return date is
  lv_payterm_id    pym_payment_terms_master.payment_term_id%type;
  lv_base_date_fld pym_payment_terms_master.base_date%type;
  lv_fetch_qry     pyme_payment_term_ext.fetch_query%type;
  lv_base_date     date;
  lv_no_of_days    number;
  -- vc_pay_due_date_disp varchar2(20);
  vd_pay_due_date date;

begin
  --vc_pay_due_date_disp := '';
  select pcm.payment_term_id
    into lv_payterm_id
    from pcm_physical_contract_main pcm
   where pcm.internal_contract_ref_no = p_int_contract_ref_no;

  select pym.base_date,
         pym.number_of_credit_days
    into lv_base_date_fld,
         lv_no_of_days
    from pym_payment_terms_master pym
   where pym.payment_term_id = lv_payterm_id;

  if lv_base_date_fld = 'Arrival_Date' then
    begin
      select fetch_query
        into lv_fetch_qry
        from pyme_payment_term_ext pyme
       where pyme.base_date = lv_base_date_fld;
      execute immediate replace(lv_fetch_qry,
                                '(:values)',
                                '(''' || p_int_gmr_ref_no || ''')')
        into lv_base_date;
    exception
      when others then
        lv_base_date := null;
    end;
  else
    if lv_base_date_fld <> 'Invoice_Date' then
      begin
        select fetch_query
          into lv_fetch_qry
          from pyme_payment_term_ext pyme
         where pyme.base_date = lv_base_date_fld;
        execute immediate replace(lv_fetch_qry,
                                  '(:values)',
                                  '(''' || p_int_gmr_ref_no || ''')')
          into lv_base_date;
      exception
        when others then
          lv_base_date := null;
      end;
    end if;
  end if;

  if lv_base_date is null or lv_base_date_fld = 'Invoice_Date' then
    select to_date(substr(max(to_char(axs.created_date,
                                      'yyyymmddhh24missff9') ||
                              to_char(iss.invoice_issue_date,
                                      'yyyymmddhh24miss')),
                          24),
                   'yyyymmddhh24miss')
      into lv_base_date
      from is_invoice_summary          iss,
           iid_invoicable_item_details iid,
           iam_invoice_action_mapping  iam,
           axs_action_summary          axs
     where iss.internal_invoice_ref_no = iid.internal_invoice_ref_no
       and iam.internal_invoice_ref_no = iss.internal_invoice_ref_no
       and iam.invoice_action_ref_no = axs.internal_action_ref_no
       and iid.internal_contract_ref_no = p_int_contract_ref_no
       and iid.internal_gmr_ref_no = p_int_gmr_ref_no
       and iss.is_active = 'Y'
       and nvl(iss.is_free_metal, 'N') <> 'Y'
       and iid.is_active = 'Y';
  end if;
  if lv_base_date is not null then
    vd_pay_due_date := lv_base_date + nvl(lv_no_of_days, 0);
  end if;

  return vd_pay_due_date;
exception
  when others then
    return null;
end;
/
