viewpoint native;

define 
  number tot_ord_amt = ((sod_det:sod_qty_ord - sod_det:sod_qty_ship)*sod_det:sod_price*so_mstr:so_ex_rate divide so_mstr:so_ex_rate2)

where 
  sod_det:sod_domain = 
    "in001"

sum/domain="sod_det"/hold="so_hold_hf1"
  tot_ord_amt/decimalplaces=2/heading="Total Open Order Amount"/commas 
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
