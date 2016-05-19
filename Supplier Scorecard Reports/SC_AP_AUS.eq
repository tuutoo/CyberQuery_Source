viewpoint native;
define
  string output_name = "D:\Supplier_Scorecards\New_Uploads\New_SC\SC_AP_AUS_"+ str((todaysdate-7),"YYYY_MMM");

  file po = access po_mstr,
    set po_mstr:po_domain = prh_hist:prh_domain,
    po_mstr:po_nbr = prh_hist:prh_nbr,
    one to one;
  
 
  file pod = access pod_det,
    set pod_det:pod_domain = prh_hist:prh_domain,
    pod_det:pod_nbr = prh_hist:prh_nbr,
    pod_det:pod_line=prh_hist:prh_line,
    one to one;
  
   file si = access si_mstr,
    set si_mstr:si_domain=prh_hist:prh_domain,
    si_mstr:si_site=prh_hist:prh_site,
    one to one;
  
  number UM_Conv = if prh_hist:prh_um like "MT" then (prh_hist:prh_um_conv) divide 1000 
         else if prh_hist:prh_um like "M2" then 1
         else prh_hist:prh_um_conv

  string FinalUM = if prh_hist:prh_um = "MT" then "KG" else prh_hist:prh_um  

  number Qty_Rcvd = if prh_hist:prh_um = "MT" then prh_hist:prh_rcvd*1000 else prh_hist:prh_rcvd
  number Qty_Ord = if prh_hist:prh_um = "MT" then pod:pod_qty_ord*1000 else pod:pod_qty_ord

 -- date Perf_Date = if prh_hist:prh_rcp_date-ptp_det:ptp_pur_lead > po_mstr:po_ord_date then prh_hist:prh_rcp_date 
   --    else po_mstr:po_ord_date+ptp_det:ptp_pur_lead;

 date start_of_lastmonth = date("1." + str((todaysdate-7),"MMM") +"."+ str(year(todaysdate-7)));
 date end_of_lastmonth = date("1." + str(todaysdate,"MMM") +"."+ str(year(todaysdate))) - 1;
where 
prh_hist:prh_domain one of "AU001","NZ001"
--(prh_hist:prh_rcp_date >= todaysdate - day(todaysdate) + 1  and prh_hist:prh_rcp_date <= todaysdate )   
--#(prh_hist:prh_rcp_date >= 11.01.2014  and prh_hist:prh_rcp_date <= 11.30.2014)
and (prh_hist:prh_rcp_date >= start_of_lastmonth and prh_hist:prh_rcp_date <= end_of_lastmonth)

list/domain="prh_hist"/nodetail/csv=output_name
   
  ad_mstr:ad_name/heading="Supplier Name"/name="c1"
  prh_hist:prh_site/heading="Site Name"/name="c2"
  si:si_entity/heading="Site Code"/name="c3"
  prh_hist:prh_nbr + "_" + str(prh_hist:prh_line)/heading="Order Number"/name="c4"
  prh_hist:prh_part/heading="Part Nbr"/name="c5"
  Qty_Ord/heading="Qty Ordered"/decimalplaces=2/commas/name="c6"
  Qty_Rcvd/heading = "Qty Received"/decimalplaces=2/name="c7"
  FinalUM/heading="Qty Units"/name="c8"
  pt_mstr:pt__dec01/heading="Width"/decimalplaces=2/nocommas/name="c9"
  pt_mstr:pt__chr02/heading="Unit Width"/name="c10"
  po:po_ord_date/mask="yyyy/mm/dd"/heading="Ord Date"/name="c11"
  pod:pod_due_date/mask="yyyy/mm/dd"/heading="Due Date"/name="c12"
  prh_hist:prh_per_date/mask="yyyy/mm/dd"/heading="Perf Date"/name="c13"
  pod:pod_need/mask="yyyy/mm/dd"/heading="Need Date"/name="c14"
  prh_hist:prh_rcp_date/mask="yyyy/mm/dd"/heading="Received Date"/name="c15"
  UM_Conv/heading="-UM Conv"/decimalplaces= 4/name="c16"
  ""/heading="Excuse"/name="c17"
 

sorted by
  prh_hist:prh_nbr
  prh_hist:prh_line
 

end of prh_hist:prh_line
if
  pod:pod_status one of
    "C"
--  and prh_hist:prh_site =
 --   "ryp"
 -- pt_mstr:pt_prod_line begins
--    "1R" 
  and 
prh_hist:prh_rcvd > 0 then
{
  ad_mstr:ad_name/heading="Supplier Name"/align=c1
  prh_hist:prh_site/heading="Site Name"/align=c2
  si:si_entity/heading="Site Code"/align=c3
  prh_hist:prh_nbr + "_" + str(prh_hist:prh_line)/heading="Order Number"/align=c4
  prh_hist:prh_part/heading="Part Nbr"/align=c5
  Qty_Ord/heading="Qty Ordered"/decimalplaces=2/commas/align=c6
  total[Qty_Rcvd]/heading = "Qty Received"/decimalplaces=2/align=c7
  FinalUM/heading="Qty Units"/align=c8
  pt_mstr:pt__dec01/heading="Width"/decimalplaces=2/nocommas/align=c9
  pt_mstr:pt__chr02/heading="Unit Width"/align=c10
  po:po_ord_date/mask="yyyy/mm/dd"/heading="Ord Date"/align=c11
  pod:pod_due_date/mask="yyyy/mm/dd"/heading="Due Date"/align=c12
  pod:pod_per_date/mask="yyyy/mm/dd"/heading="Perf Date"/align=c13
  pod:pod_need/mask="yyyy/mm/dd"/heading="Need Date"/align=c14
  maximum[prh_hist:prh_rcp_date,prh_hist:prh_line]/mask="yyyy/mm/dd"/heading="Received Date"/align=c15
  UM_Conv/heading="-UM Conv"/decimalplaces= 4/align=c16
  ""/heading="Excuse"/align=c17
}
