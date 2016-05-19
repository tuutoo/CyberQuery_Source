viewpoint native;

define
  file codemstr = access code_mstr,
    set code_mstr:code_domain = sod_det:sod_domain,
    code_mstr:code_fldname = "xx_sohd_logic",
    code_mstr:code_value = "ar_due",
    one to one,
    null fill on failure;
  
  number grace_day = if(codemstr:code_cmmt <> null)
                        then
                          VAL(SUBFIELD(codemstr:code_cmmt,",",2))
                        else
                          10000;
  
  file armstr = access so_hold_hf3,
    set so_hold_hf3:ar_bill = so_mstr:so_bill,
    one to one,
    null fill on failure;
  
  string over_due_inv = if(so_mstr:so_stat = "HD")
                        then
                          armstr:ar_nbr
                        else
                          "";
  
  file so_openamt = access so_hold_hf1,
    set so_hold_hf1:so_bill = so_mstr:so_bill,
    one to one,
    zero fill on failure;
  
  file so_opextax = access so_hold_hf2,
    set so_hold_hf2:so_bill = so_mstr:so_bill,
    one to one,
    zero fill on failure;
  
  number so_tot_bl = so_openamt:tot_ord_amt + so_opextax:tot_tax;
  
  number cr_tolerance = if(codemstr:code_cmmt <> null)
                        then
                          VAL(SUBFIELD(codemstr:code_cmmt,",",1))
                        else
                          0;
  
  string rsn_on_hold = if(so_mstr:so_stat = "HD" and cm_mstr:cm_balance +  so_tot_bl >= cm_mstr:cm_cr_limit + cr_tolerance) and armstr:ar_nbr <> ""
                       then
                         "Both Overdue"
                       else if(so_mstr:so_stat = "HD" and (cm_mstr:cm_balance +  so_tot_bl >= cm_mstr:cm_cr_limit + cr_tolerance) and armstr:ar_nbr = "")
                       then
                         "Credit Overdue"
                       else if(so_mstr:so_stat = "HD" and (cm_mstr:cm_balance +  so_tot_bl < cm_mstr:cm_cr_limit + cr_tolerance) and armstr:ar_nbr <> "")
                       then
                         "Invoice Overdue"
                       else
                         "";
  
  file ordso_tr = access so_hold_hf4,
    set so_hold_hf4:tr_nbr = so_mstr:so_nbr,
    one to one,
    null fill on failure;
  
  string last_modfied = if so_mstr:so_stat = "HD" 
                        then
                          ordso_tr:tr_userid
                        else
                          "";
where 
  sod_det:sod_domain = 
    "in001"

sum/domain="sod_det"
  sod_det:sod_qty_ord/decimalplaces=2/commas

by
  pl_mstr:entity/duplicates
  so_mstr:so_nbr
  so_mstr:so_ord_date/mask="DD/MM/YYYY"
  so_mstr:so_req_date/mask="DD/MM/YYYY"
  so_mstr:so_due_date/mask="DD/MM/YYYY"
  so_mstr:so_po
  so_mstr:so_bill
  cm_mstr:cm_region
  ad_mstr:ad_county
  ad_mstr:ad_sort
  so_mstr:so_slspsn[1]
  so_mstr:so_cr_terms
  so_mstr:so_stat/heading="SO Stat"
  last_modfied/heading="Last ModifiedBy"
  cm_mstr:cm_balance/decimalplaces=2/heading="Cust BL"
  --so_openamt:tot_ord_amt
  --so_opextax:tot_tax
  so_tot_bl/heading="Ord Bl"
  cm_mstr:cm_cr_limit/decimalplaces=2
  --codemstr:code_cmmt
  cr_tolerance/heading="Cr Tolerance"
  over_due_inv/heading="OverDue Inv"/noduplicates
  rsn_on_hold/heading="OverDue Reason"
  grace_day/heading="Grace Day"
  switch(cm_mstr:cm_cr_hold)
    case 0 :"No"
    case 1 :"Yes"
    default :"No"/heading="Cust Hold"/noduplicates
