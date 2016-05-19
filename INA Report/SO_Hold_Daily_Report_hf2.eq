viewpoint native;

define
  file sotx2d = access tx2d_det,
    set tx2d_det:tx2d_domain = so_mstr:so_domain,
    tx2d_det:tx2d_ref = so_mstr:so_nbr;

  number tot_tax = (sotx2d:tx2d_totamt + sotx2d:tx2d_cur_tax_amt) * so_mstr:so_ex_rate divide so_mstr:so_ex_rate2

where 
  so_mstr:so_domain = 
    "in001"
  and sotx2d:tx2d_tr_type = 
    "13"
  and sotx2d:tx2d_nbr = 
    ""

sum/domain="so_mstr"/hold="so_hold_hf2"
  tot_tax/decimalplaces=2/heading="Total Tax Amount"/commas

by
  so_mstr:so_bill /keyelement=1
  /*
  so_mstr:so_nbr
  sod_det:sod_qty_ord
  sod_det:sod_qty_ship
  sod_det:sod_price
  so_mstr:so_ex_rate 
  so_mstr:so_ex_rate2 
  */
