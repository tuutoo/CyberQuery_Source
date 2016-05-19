viewpoint native;
define

  string output_name = "D:\Supplier_Scorecards\New_Uploads\New_SC\INA\SC_AP_ASEAN_"+ str(todaysdate,"YYYY_MM_IN_DD");
  file ptp = access ptp_det,
    set ptp_det:ptp_domain = prh_hist:prh_domain,
    ptp_det:ptp_part = prh_hist:prh_part,
    ptp_det:ptp_site = prh_hist:prh_site,
    one to one,
    zero fill on failure;
  
  date Perf_Date = if prh_hist:prh_rcp_date - ptp:ptp_pur_lead > po_mstr:po_ord_date then prh_hist:prh_rcp_date
                     else po_mstr:po_ord_date + ptp:ptp_pur_lead;

  date start_of_year = date("1.Jan." + str(year(todaysdate)));
  
  number UM_Conv = if prh_hist:prh_um like "MT" then (prh_hist:prh_um_conv) divide 1000
         else if prh_hist:prh_um like "M2" then 1
         else prh_hist:prh_um_conv;
  
  string FinalUM = if prh_hist:prh_um = "MT" then "KG" else prh_hist:prh_um;
  
  file pod = access pod_det,
    set pod_det:pod_domain = prh_hist:prh_domain,
    pod_det:pod_nbr = prh_hist:prh_nbr,
    pod_det:pod_line = prh_hist:prh_line,
    one to one;
  
  number Qty_Ord = if prh_hist:prh_um = "MT" then pod:pod__dec01*1000 else pod:pod__dec01;
  
  number Qty_Rcvd = if prh_hist:prh_um = "MT" then prh_hist:prh_rcvd*1000 else prh_hist:prh_rcvd;
  
  string SupplierType = if ad_mstr:ad_addr begins "A9" then "Intra"
                        else if ad_mstr:ad_country = "India" then "Local"
                        else "Global";
  
  date Doc_Dat = if pos("^",pod_det:pod__chr01) = 0 then
  date(subfield(pod_det:pod__chr01,"@",7))
  else
  date(subfield(subfield(pod_det:pod__chr01,"^",2),"@",7));
  
  date Global_Date = if Doc_Dat <> null then
  Doc_Dat
  else
  prh_hist:prh_rcp_date;
  
  date Act_Shp_Dat = if pos("^",pod_det:pod__chr01) = 0 then
  date(subfield(pod_det:pod__chr01,"@",4))
  else
  date(subfield(subfield(pod_det:pod__chr01,"^",2),"@",4));
  
  file vpmaster = access vp_mstr,
    set vp_mstr:vp_domain = prh_hist:prh_domain,
    vp_mstr:vp_vend = prh_hist:prh_vend,
    vp_mstr:vp_part = prh_hist:prh_part;
  
  date Intra_Date = if Act_Shp_Dat <> null then
  Act_Shp_Dat
  else
  prh_hist:prh_rcp_date - round(vpmaster:vp__dec02);
  
  date Received_Date = if SupplierType = "Global"
  then Global_Date
  else if SupplierType = "Intra"
  then Intra_Date
  else prh_hist:prh_rcp_date;
  
  file si = access si_mstr,
    set si_mstr:si_domain = prh_hist:prh_domain,
    si_mstr:si_site = prh_hist:prh_site,
    one to one;
  
  file po = access po_mstr,
    set po_mstr:po_domain = prh_hist:prh_domain,
    po_mstr:po_nbr = prh_hist:prh_nbr,
    one to one;

where 
  --#month(Received_Date) = month(todaysdate-6)
  --#and year(Received_Date) = year(todaysdate)
  Received_Date >= start_of_year
  and prh_hist:prh_domain one of "IN001"
  and po_mstr:po_nbr not begins "CL"
  and  
  (pt_mstr:pt_prod_line begins "1R" 
   or
   pt_mstr:pt_prod_line begins "3F" 
   or 
   pt_mstr:pt_prod_line begins "4F"
   or
   pt_mstr:pt_prod_line = "1wgi"
   or
   pt_mstr:pt_prod_line = "2wgi"
  )


list/domain="prh_hist"/nodetail/nototals/csv=output_name
   
  ad_mstr:ad_name/heading="Supplier Name"/name="c1" 
  prh_hist:prh_site/heading="Site Name"/name="c2" 
  si:si_entity/heading="Site Code"/name="c3" 
  prh_hist:prh_nbr + "_" + str(prh_hist:prh_line)/heading="Order Number"/name="c4" 
  prh_hist:prh_part/heading="Part Nbr"/name="c5" 
  UM_Conv/heading="UM Conv"/decimalplaces=4/name="c6" 
  Qty_Ord/heading="Qty Ordered"/decimalplaces=2/commas/name="c7" 
  Qty_Rcvd/heading="Qty Received"/decimalplaces=2/name="c8" 
  FinalUM/heading="Qty Units"/name="c9" 
  pt_mstr:pt__dec01/heading="Width"/decimalplaces=2/nocommas/name="c10" 
  pt_mstr:pt__chr02/heading="Unit Width"/name="c11" 
  po:po_ord_date/mask="yyyy/mm/dd"/heading="Ord Date"/name="c12" 
  pod:pod_due_date/mask="yyyy/mm/dd"/heading="Due Date"/name="c13" 
  Perf_Date/mask="yyyy/mm/dd"/heading="Perf Date"/name="c14" 
  pod:pod_need/mask="yyyy/mm/dd"/heading="Need Date"/name="c15" 
  --prh_hist:prh_rcp_date/mask="yyyy/mm/dd"/heading="Received Date"/name="c16" 
  Received_Date/mask="yyyy/mm/dd"/heading="Received Date"/name="c16" 
  --Vineetha says should be @ column F -- UM_Conv/heading="UM Conv"/decimalplaces=4/name="c16" 
  pod:pod_so_job/heading="Excuse"/name="c17"

  --#ad_mstr:ad_addr/heading="Supplier code"/name="c18" 
  --#ad_mstr:ad_country/heading="Country"/name="c19" 
  --#SupplierType/heading="S Type"/name="c20" 
  --#vpmaster:vp__chr01/heading="Inco"/name="c21" 
  --#Act_Shp_Dat/mask="yyyy/mm/dd"/heading="Act_shp_Dat"/name="c22" 
  --#Doc_Dat/mask="yyyy/mm/dd"/heading="Doc Date"/name="c23" 
  --#round(vpmaster:vp__dec02)/heading="Lead Time"/name="c24" 
  --#Received_Date/mask="yyyy/mm/dd"/heading="Final Date"/name="c25"

sorted by
  --#Received_Date
  ad_mstr:ad_name
  prh_hist:prh_nbr
  prh_hist:prh_line
 
end of prh_hist:prh_line
 if
  pod:pod_status one of "C"
  --#and prh_hist:prh_site ends with "p"
  and prh_hist:prh_rcvd > 0 then 
{ 
  ad_mstr:ad_name/align=c1/heading="Supplier Name"
  prh_hist:prh_site/align=c2/heading="Site Name"
  si:si_entity/align=c3/heading="Site Code"
  prh_hist:prh_nbr + "_" + str(prh_hist:prh_line)/align=c4/heading="Order Number"
  prh_hist:prh_part/align=c5/heading="Part Nbr"
  UM_Conv/decimalplaces=4/align=c6/heading="UM Conv"
  Qty_Ord/decimalplaces=2/commas/align=c7/heading="Qty Ordered"
  total[Qty_Rcvd]/decimalplaces=2/align=c8/heading = "Qty Received"
  FinalUM/align=c9/heading="Qty Units"
  pt_mstr:pt__dec01/decimalplaces=2/nocommas/align=c10/heading="Width"
  pt_mstr:pt__chr02/align=c11/heading="Unit Width"
  po:po_ord_date/mask="yyyy/mm/dd"/align=c12/heading="Ord Date"
  pod:pod_due_date/mask="yyyy/mm/dd"/align=c13/heading="Due Date"
  Perf_Date/mask="yyyy/mm/dd"/align=c14/heading="Perf Date"
  pod:pod_need/mask="yyyy/mm/dd"/align=c15/heading="Need Date"
  --#maximum[prh_hist:prh_rcp_date,prh_hist:prh_line]/mask="yyyy/mm/dd"/align=c16/heading="Received Date"
  maximum[Received_Date]/mask="yyyy/mm/dd"/align=c16/heading="Received Date"
  --UM_Conv/decimalplaces= 4/align=c16/heading="UM Conv"
  pod:pod_so_job/align=c17/heading="Excuse"
  --#ad_mstr:ad_addr/align=c18
  --#ad_mstr:ad_country/align=c19
  --#SupplierType/align=c20
  --#vpmaster:vp__chr01/align=c21
  --#Act_Shp_Dat/mask="yyyy/mm/dd"/align=c22
  --#Doc_Dat/mask="yyyy/mm/dd"/align=c23
  --#round(vpmaster:vp__dec02)/align=c24
  --#Received_Date/mask="yyyy/mm/dd"/align=c25
}
