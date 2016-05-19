viewpoint native;

define
  string output_name = "D:\Supplier_Scorecards\New_Uploads\New_SC\CHINA\SC_AP_CHINA_"+ str(todaysdate,"YYYY_MM_DD");
  number UM_Conv = if prh_hist:prh_um like "MT" then (prh_hist:prh_um_conv) divide 1000 else prh_hist:prh_um_conv;
  
  string FinalUM = if prh_hist:prh_um = "MT" then "KG" else prh_hist:prh_um;
  
  number Qty_Rcvd = if prh_hist:prh_um = "MT" then prh_hist:prh_rcvd*1000 else prh_hist:prh_rcvd;
  date start_of_year = date("1.Jan." + str(year(todaysdate)));
  file pod = access pod_det,
    set pod_det:pod_domain = prh_hist:prh_domain,
    pod_det:pod_nbr = prh_hist:prh_nbr,
    pod_det:pod_line = prh_hist:prh_line,
    one to one;
  
  number Qty_Ord = if prh_hist:prh_um = "MT" then pod:pod_qty_ord*1000 else pod:pod_qty_ord;

-- 141118 add for China SC
  file vpmaster = access vp_mstr,
    set vp_mstr:vp_domain = prh_hist:prh_domain,
    vp_mstr:vp_vend = prh_hist:prh_vend,
    vp_mstr:vp_part = prh_hist:prh_part;

  string SupplierType = if ad_mstr:ad_ctry[1,2] = "CH" then "Local"
                        else "Global";  

  date Need_Date = if SupplierType = "Local" 
  then pod:pod_due_date
  else pod:pod_need;

  date ETD_Date = if (pos("^",pod:pod__chr01) = 0 and pos("@",pod:pod__chr01) <> 0 )then
  date(trun(subfield(pod:pod__chr01,"@",9)),"USA")
  else if (pos("^",pod:pod__chr01) <> 0 and pos("@",pod:pod__chr01) <> 0 ) then
  date(trun(subfield(subfield(pod:pod__chr01,"^",2),"@",9)),"USA");

  date ETA_Date = if (pos("^",pod:pod__chr01) = 0 and pos("@",pod:pod__chr01) <> 0 ) then
  date(trun(subfield(pod:pod__chr01,"@",7)),"USA")
  else if (pos("^",pod:pod__chr01) <> 0 and pos("@",pod:pod__chr01) <> 0 ) then
  date(trun(subfield(subfield(pod:pod__chr01,"^",2),"@",7)),"USA");

  date Received_Date = if (SupplierType = "Global" and vpmaster:vp__chr01 begins "EX" and ETD_Date <> null)
  then ETD_Date
  else if (SupplierType = "Global" and vpmaster:vp__chr01 not begins "EX" and ETA_Date <> null)
  then ETA_Date
  else prh_hist:prh_rcp_date;
--141118 add end.
  

  file ptp = access ptp_det,
    set ptp_det:ptp_domain = prh_hist:prh_domain,
    ptp_det:ptp_site = prh_hist:prh_site,
    ptp_det:ptp_part = prh_hist:prh_part,
    one to one;
  
  date Perf_Date = if prh_hist:prh_rcp_date-ptp:ptp_pur_lead > po_mstr:po_ord_date then
  prh_hist:prh_rcp_date else
  po_mstr:po_ord_date+ptp:ptp_pur_lead;
  
  --string suppliername = if vd_mstr:vd__chr01 <> "" then vd_mstr:vd__chr01 else vd_mstr:vd_addr;--if vd_mstr:vd_sort contains "? then "" else if vd_mstr:vd_sort contains "a" then vd_mstr:vd_sort else if vd_mstr:vd_sort contains "e" then vd_mstr:vd_sort else if vd_mstr:vd_sort contains "i" then vd_mstr:vd_sort else if vd_mstr:vd_sort contains "o" then vd_mstr:vd_sort else if vd_mstr:vd_sort contains "u" then vd_mstr:vd_sort else null/heading="Supplier Name"
  
  -- Use Regexp to filter out error Chinese names
  string suppliername = if vd_mstr:vd__chr01[1] = @"[A-Za-z0-9]" then vd_mstr:vd__chr01 else ("CN Name - " + vd_mstr:vd_addr);
  
  file po = access po_mstr,
    set po_mstr:po_domain = prh_hist:prh_domain,
    po_mstr:po_nbr = prh_hist:prh_nbr,
    one to one;
  
where 
  prh_hist:prh_site one of
    "ksrolp",
    "gzrolp",
    "kstolp",
    "gztolp",
    "511F",
    "512F",
    "513F",
    "BHBR",
    "CDDC",
    "KSBOND",
    "KSCHEM",
    "KSGRPP",
    "KSREFP",
    "UNBOND",
    "WHDC",
    "SYDC"
  and vd_mstr:vd_addr not begins 
    "A90"
  and prh_hist:prh_part not begins 
    "DCK"
  and prh_hist:prh_part not begins 
    "MFG"
  and Qty_Ord > 
    0
  and Qty_Rcvd > 
    0
  and prh_hist:prh_rcp_date >= start_of_year
  and pod:pod_status one of
    "C"

list/domain="prh_hist"/nototals/csv=output_name
  if
  suppliername <> null
  then{

  suppliername/heading="Supplier Name" /duplicates
  prh_hist:prh_site/heading="Site Name"
  si_mstr:si_entity/heading="Site Code" /duplicates
  prh_hist:prh_nbr + "_" + str(prh_hist:prh_line)/heading="Order Number"
  prh_hist:prh_part/heading="Part Nbr"
  UM_Conv/heading="UM Conv"/decimalplaces= 4
  Qty_Ord/heading="Qty Ordered"/decimalplaces=2/commas
  Qty_Rcvd/heading = "Qty Received"/decimalplaces=2
  FinalUM/heading="Qty Units"
  pt_mstr:pt__dec01/heading="Width"/decimalplaces=2/nocommas /duplicates
  pt_mstr:pt__chr02/heading="Unit Width" /duplicates
  po:po_ord_date/mask="yyyy/mm/dd"/heading="Ord Date"  /duplicates
  pod:pod_due_date/mask="yyyy/mm/dd"/heading="Due Date" /duplicates
  Perf_Date/mask="yyyy/mm/dd"/heading="Perf Date" /duplicates
  Need_Date/mask="yyyy/mm/dd"/heading="Need Date"  /duplicates
  Received_Date/mask="yyyy/mm/dd"/heading="Received Date" /duplicates
  --Vineetha said UM should be @column F 2014/04/16 -- UM_Conv/heading="UM Conv"/decimalplaces= 4
  pod:pod_so_job/heading="Excuse"
  -- for validation
  --#SupplierType/heading="SupplierType"
  --#vpmaster:vp__chr01/heading="IncoTerms"
  --#pod:pod_due_date/heading="pod:pod_due_date"/mask="yyyy/mm/dd"
  --#pod:pod_need/heading="pod:pod_need"/mask="yyyy/mm/dd"
  --#ETD_Date/heading="ETD_Date"/mask="yyyy/mm/dd"
  --#ETA_Date/heading="ETA_Date"/mask="yyyy/mm/dd"
  --#prh_hist:prh_rcp_date/heading="GRN_Date"/mask="yyyy/mm/dd"
  }

sorted by
  prh_hist:prh_nbr
  ad_mstr:ad_name
  pod:pod_due_date
