-- Created on 8/08/2012
declare
  cursor grd_pile_cur is
    select distinct grd.internal_grd_ref_no,
                    psr.pool_id
      from grd_goods_record_detail grd,
           psr_pool_stock_register psr
     where grd.status = 'Active'
       and grd.tolling_stock_type in
           ('MFT In Process Stock', 'Delta MFT IP Stock',
            'Free Metal IP Stock', 'Delta FM IP Stock')
       and psr.internal_grd_ref_no = grd.internal_grd_ref_no;

begin

  for grd_pile_cur_rows in grd_pile_cur
  loop
  --dbms_output.put_line(grd_pile_cur_rows.internal_grd_ref_no||':'||grd_pile_cur_rows.pool_id);
    update grd_goods_record_detail grd
       set grd.pool_id = grd_pile_cur_rows.pool_id
     where grd.internal_grd_ref_no = grd_pile_cur_rows.internal_grd_ref_no;
  end loop;
end;
