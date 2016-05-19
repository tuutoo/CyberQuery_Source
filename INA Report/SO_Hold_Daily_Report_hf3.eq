viewpoint native;

define

  file codemstr = access code_mstr,
    set code_mstr:code_domain = ar_mstr:ar_domain,
        code_mstr:code_fldname = "xx_sohd_logic",
        code_mstr:code_value = "ar_due",
    one to one,
    null fill on failure;

  number cr_tolerance = if(codemstr:code_cmmt <> null)
                        then
                          VAL(SUBFIELD(codemstr:code_cmmt,",",1))
                        else
                          0;

  number grace_day = if(codemstr:code_cmmt <> null)
                        then
                          VAL(SUBFIELD(codemstr:code_cmmt,",",2))
                        else
                          10000;

where 
    ar_mstr:ar_domain = 'in001' and
    ar_mstr:ar_type <> "P" and
    ar_mstr:ar_type <> "A" and
    (ar_type <> "D" or ar_draft = 1) and
    ar_mstr:ar_due_date + grace_day < todaysdate and
    ar_mstr:ar_amt - ar_applied > cr_tolerance and
    ar_mstr:ar_amt > 0 and
    ar_mstr:ar_open = 1

list/domain="ar_mstr" /hold="so_hold_hf3"--/nototals/nodetail
  ar_mstr:ar_bill
  ar_mstr:ar_nbr
  ar_mstr:ar_due_date
sorted by
  ar_mstr:ar_bill
  ar_mstr:ar_due_date
top of ar_mstr:ar_bill
  ar_mstr:ar_bill /keyelement=1
  ar_mstr:ar_nbr
  ar_mstr:ar_due_date
