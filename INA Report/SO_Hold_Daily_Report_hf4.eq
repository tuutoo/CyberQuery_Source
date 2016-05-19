viewpoint native;


where 
    tr_hist:tr_domain = 'in001' and
    tr_hist:tr_type = 'ORD-SO'

list/domain="tr_hist" /hold="so_hold_hf4"--/nototals/nodetail
  tr_hist:tr_trnbr
  tr_hist:tr_nbr
  tr_hist:tr_effdate
  tr_hist:tr_userid
sorted by
  tr_hist:tr_nbr
  tr_hist:tr_effdate
end of tr_hist:tr_nbr
  tr_hist:tr_trnbr
  tr_hist:tr_nbr /keyelement=1
  tr_hist:tr_effdate
  tr_hist:tr_userid
