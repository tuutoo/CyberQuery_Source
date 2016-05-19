viewpoint native;

define
  string output_name = "D:\Supplier_Scorecards\New_Uploads\New_SC\KOREA\SC_AP_KOREA_"+ str(todaysdate,"YYYY_MM_DD");
  date start_of_year = date("1.Jan." + str(year(todaysdate)));

  file po = access po_mstr,
    set po_mstr:po_domain = prh_hist:prh_domain,
    po_mstr:po_nbr = prh_hist:prh_nbr,
    one to one;
  
  file pod = access pod_det,
    set pod_det:pod_domain = prh_hist:prh_domain,
    pod_det:pod_nbr = prh_hist:prh_nbr,
    pod_det:pod_line=prh_hist:prh_line,
    one to one;

  file ptp = access ptp_det,
    set ptp_det:ptp_domain = prh_hist:prh_domain,
    ptp_det:ptp_site = prh_hist:prh_site,
    ptp_det:ptp_part = prh_hist:prh_part,
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
  number Qty_Ord = if prh_hist:prh_um = "MT" then pod:pod__dec01*1000 else pod:pod__dec01

  date Perf_Date = if prh_hist:prh_rcp_date-ptp:ptp_pur_lead > po_mstr:po_ord_date then prh_hist:prh_rcp_date 
       else po_mstr:po_ord_date+ptp:ptp_pur_lead;

  -- Use Regexp to filter out error Supplier names
  string suppliername = if vd_mstr:vd__chr01[1] = @"[A-Za-z0-9]" then vd_mstr:vd__chr01 else ("KR Name - " + vd_mstr:vd_addr); 

where 
  prh_hist:prh_rcp_date >= 
    start_of_year 
and prh_hist:prh_domain one of 
    "KR001"

list/domain="prh_hist"/nodetail/csv=output_name
   
  suppliername/heading="Supplier Name"/name="c1"
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
  UM_Conv/heading="UM Conv"/decimalplaces= 4/name="c16"
  pod:pod_so_job/heading="Excuse"/name="c17"
 

sorted by
  prh_hist:prh_nbr
  prh_hist:prh_line
 

end of prh_hist:prh_line
 if
  pod:pod_status one of
    "C"
  and prh_hist:prh_site ends with "p"
  and pt_mstr:pt_prod_line begins
    "1R" 
  and prh_hist:prh_rcvd > 0 then 

{ 
  suppliername/heading="Supplier Name"/align=c1
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
  Perf_Date/mask="yyyy/mm/dd"/heading="Perf Date"/align=c13
  pod:pod_need/mask="yyyy/mm/dd"/heading="Need Date"/align=c14
  maximum[prh_hist:prh_rcp_date,prh_hist:prh_line]/mask="yyyy/mm/dd"/heading="Received Date"/align=c15
  UM_Conv/heading="UM Conv"/decimalplaces= 4/align=c16
  pod:pod_so_job/heading="Excuse"/align=c17
}
