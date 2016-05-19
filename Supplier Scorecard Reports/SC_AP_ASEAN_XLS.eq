viewpoint native;
define

  --#string output_name = "D:\Supplier_Scorecards\New_Uploads\New_SC\ASEAN\SC_AP_ASEAN_"+ str(todaysdate,"YYYY_MM_DD");
  string output_name = "SC_AP_ASEAN_"+ str(todaysdate,"YYYY_MM_DD");
  file ptp = access ptp_det,
    set ptp_det:ptp_domain = prh_hist:prh_domain,
    ptp_det:ptp_part = prh_hist:prh_part,
    ptp_det:ptp_site = prh_hist:prh_site,
    one to one,
    zero fill on failure;
  
  --#add start 2014/09/26
  number VesselLT = val(subfield(ptp:ptp__chr10,"^",1));
  number CustLT   = val(subfield(ptp:ptp__chr10,"^",2));
  --#add end 2014/09/26

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
                        else if ad_mstr:ad_ctry[1,2] = prh_hist:prh_domain[1,2] then "Local"
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
  
 --#add start 2014/09/26
  date DAT_Date = if Doc_Dat <> null then
  Doc_Dat
  else
  prh_hist:prh_rcp_date - CustLT;

  date FOB_Date = if Act_Shp_Dat <> null then
  Act_Shp_Dat
  else
  prh_hist:prh_rcp_date - CustLT - VesselLT;
  --#add end 2014/09/26

  file vpmaster = access vp_mstr,
    set vp_mstr:vp_domain = prh_hist:prh_domain,
    vp_mstr:vp_vend = prh_hist:prh_vend,
    vp_mstr:vp_part = prh_hist:prh_part;
  
  date Intra_Date = if Act_Shp_Dat <> null then
  Act_Shp_Dat
  else
  prh_hist:prh_rcp_date - round(vpmaster:vp__dec02);
  
  date Received_Date = if (SupplierType = "Global" and vpmaster:vp__chr01 begins "C")
  then Global_Date
  else if (SupplierType = "Global" and vpmaster:vp__chr01 = "DAT")
  then DAT_Date
  else if (SupplierType = "Global" and vpmaster:vp__chr01 = "FOB")
  then FOB_Date
  else if (SupplierType = "Intra" and vpmaster:vp__chr01 begins "EX")
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

  string Date_Validate = if (Received_Date < po:po_ord_date) 
                         then "Received Date < Ord Date"
                         else "";

  --#date RFS_Date = if pos("^",pod_det:pod__chr01) > 0 then
  --#date(subfield(subfield(pod_det:pod__chr01,"^",1),"@",1));

where 
  Received_Date >= start_of_year
  and prh_hist:prh_domain one of "MY001","TH001"
  and prh_hist:prh_rcvd > 0
  and  
  (pt_mstr:pt_prod_line begins "1R" )
  and prh_hist:prh_site one of "BGP","RYP"


list/domain="prh_hist"/nodetail/nototals/noheadings/xls=output_name
   
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
  --#prh_hist:prh_rcp_date/mask="yyyy/mm/dd"/heading="Received Date"/name="c16" 
  Received_Date/mask="yyyy/mm/dd"/heading="Received Date"/name="c16" 
  --Vineetha says should be @ column F -- UM_Conv/heading="UM Conv"/decimalplaces=4/name="c16" 
  pod:pod_so_job/heading="Excuse"/name="c17"

  --below columns are just for validation, should be marked when go live!
  ad_mstr:ad_addr/heading="Supplier code"/name="c18" 
  ad_mstr:ad_country/heading="Country"/name="c19" 
  SupplierType/heading="Supplier Type"/name="c20" 
  vpmaster:vp__chr01/heading="Inco Terms"/name="c21" 
  Act_Shp_Dat/mask="yyyy/mm/dd"/heading="Act_shp_Dat"/name="c22" 
  Doc_Dat/mask="yyyy/mm/dd"/heading="Doc Date"/name="c23" 
  round(vpmaster:vp__dec02)/heading="Inland Lead Time"/name="c24" 
  prh_hist:prh_rcp_date/mask="yyyy/mm/dd"/heading="latest GRN Date"/name="c25" 
  Date_Validate/heading="Date Validation"/name="c26" 
--#add start 2014/09/26
  VesselLT/heading="Vessel LT"/name="c27" 
  CustLT/heading="Cust LT"/name="c28" 
--#add end 2014/09/26

  --#RFS_Date/mask="yyyy/mm/dd"/heading="RFS Date"/name="c26"
   

sorted by
  --#Received_Date
  prh_hist:prh_domain
  ad_mstr:ad_name
  prh_hist:prh_nbr
  prh_hist:prh_line
 
end of prh_hist:prh_line
 if
  pod:pod_status one of "C"
  --#and prh_hist:prh_site ends with "p"
  and prh_hist:prh_rcvd > 0 then 
{ 
  ad_mstr:ad_name/align=c1--/heading="Supplier Name"
  prh_hist:prh_site/align=c2--/heading="Site Name"
  si:si_entity/align=c3--/heading="Site Code"
  prh_hist:prh_nbr + "_" + str(prh_hist:prh_line)/align=c4--/heading="Order Number"
  prh_hist:prh_part/align=c5--/heading="Part Nbr"
  UM_Conv/decimalplaces=4/align=c6--/heading="UM Conv"
  Qty_Ord/decimalplaces=2/commas/align=c7--/heading="Qty Ordered"
  total[Qty_Rcvd]/decimalplaces=2/align=c8--/heading = "Qty Received"
  FinalUM/align=c9--/heading="Qty Units"
  pt_mstr:pt__dec01/decimalplaces=2/nocommas/align=c10--/heading="Width"
  pt_mstr:pt__chr02/align=c11--/heading="Unit Width"
  po:po_ord_date/mask="yyyy/mm/dd"/align=c12--/heading="Ord Date"
  pod:pod_due_date/mask="yyyy/mm/dd"/align=c13--/heading="Due Date"
  Perf_Date/mask="yyyy/mm/dd"/align=c14--/heading="Perf Date"
  pod:pod_need/mask="yyyy/mm/dd"/align=c15--/heading="Need Date"
  --#maximum[prh_hist:prh_rcp_date,prh_hist:prh_line]/mask="yyyy/mm/dd"/align=c16--/heading="latest GRN Date"
  maximum[Received_Date]/mask="yyyy/mm/dd"/align=c16--/heading="Received Date"
  --UM_Conv/decimalplaces= 4/align=c16--/heading="UM Conv"
  pod:pod_so_job/align=c17--/heading="Excuse"

  --below columns are just for validation, should be marked when go live!
  ad_mstr:ad_addr/align=c18
  ad_mstr:ad_country/align=c19
  SupplierType/align=c20
  vpmaster:vp__chr01/align=c21--/heading="Inco Terms"
  Act_Shp_Dat/mask="yyyy/mm/dd"/align=c22
  Doc_Dat/mask="yyyy/mm/dd"/align=c23
  round(vpmaster:vp__dec02)/align=c24--/heading="Inland Lead Time"
  maximum[prh_hist:prh_rcp_date,prh_hist:prh_line]/mask="yyyy/mm/dd"/align=c25--/heading="latest GRN Date"
  Date_Validate/align=c26
--#add start 2014/09/26
  VesselLT/align=c27
  CustLT/align=c28
--#add end 2014/09/26
  --#RFS_Date/mask="yyyy/mm/dd"/align=c26--/heading="RFS Date"
}
