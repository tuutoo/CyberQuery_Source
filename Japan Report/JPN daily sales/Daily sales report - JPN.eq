viewpoint native;

define
  string PtDrawSource = subfield(pt_mstr:pt_draw,",",2);
  
  number LenPtDraw = Len(subfield(pt_mstr:pt_draw,",",2));
  
  string ProductSource = PtDrawSource[LenPtDraw - 1, LenPtDraw];
  
  string DocID = idh_hist:idh_inv_nbr + "_" + idh_hist:idh_nbr + "_" + str(idh_hist:idh_line);
  
  file um = access um_mstr,
    set um_mstr:um_domain = idh_hist:idh_domain,
    um_mstr:um_part = idh_hist:idh_part,
    um_mstr:um_um = idh_hist:idh_um,
    um_mstr:um_alt_um = "m2",
    one to one,
    null fill on failure,
    outer join;
  
  number Volume = if um:um_conv <> 0
                    then idh_hist:idh_qty_inv * (1 divide um:um_conv)
                  else
                    idh_hist:idh_qty_inv * idh_hist:idh_um_conv;
  
  number ExRate = ih_hist:ih_ex_rate2 divide ih_hist:ih_ex_rate;
  
  number Sales = idh_hist:idh_qty_inv * idh_hist:idh_price * ExRate;
  
  number GLAmount = idh_hist:idh_qty_inv * idh_hist:idh_std_cost;
  
  number Margin = Sales - GLAmount;
  
  date Today = todaysdate;
  
  file glc = access glc_cal,
    set glc_cal:glc_domain = idh_hist:idh_domain,
    glc_cal:glc_end = today,
    using third index,
    one to one,
    approximate;
  
  date FisMonthStart = if (glc:glc_domain = idh_hist:idh_domain and
                          glc:glc_start <= todaysdate and
                          glc:glc_end >= todaysdate)
                       then
                         glc:glc_start;
  
where 
  ( ih_hist:ih_inv_date >= 
    FisMonthStart )
  and idh_hist:idh_domain begins 
    "JP"

list/nototals/domain="idh_hist"
  --FisMonthStart
  pl_mstr:entity/duplicates/heading="Entity" 
  ih_hist:ih_bill/heading="Customer Code"/duplicates 
  cm_mstr:cm_sort/duplicates/heading="Customer Name" 
  ad_mstr:ad_country/duplicates/heading="Customer Country" 
  idh_hist:idh_part/heading="Product Code" 
  pt_mstr:pt_desc1+" "+pt_mstr:pt_desc2/heading="Product Description"/displaywidth=54 
  --pt_mstr:pt_draw
  ProductSource/heading="Product Source" 
  ih_hist:ih_inv_date/duplicates/mask="yyyy/mm/dd"/heading="Trans Date" 
  DocID/heading="Document ID" 
  idh_hist:idh_inv_nbr 
  ih_hist:ih_curr/duplicates/heading="Currency" 
  idh_hist:idh_um 
  pt_mstr:item_width/heading="Width" 
  pt_mstr:item_length/heading="Length" 
  idh_hist:idh_qty_inv/decimalplaces=2/heading="Quantity" 
  ExRate/heading="Exchange Rate"/decimalplaces=6/duplicates 
  Volume/heading="Volume"/decimalplaces=2 
  Sales/heading="Sales"/decimalplaces=2/displaywidth=20 
  GLAmount/heading="GL Amout"/decimalplaces=2/displaywidth=20 
  Margin/heading="Margin"/decimalplaces=2/displaywidth=20 
  (Margin) divide (Sales) * 100/heading="Margin%"/mask="99.99%"

sorted by
  ih_hist:ih_inv_date/descending
  idh_hist:idh_inv_nbr/descending
  idh_hist:idh_line
