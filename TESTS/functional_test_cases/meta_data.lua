local metadata = {
{ name = "updated_at",qtype="SC" , width = 10 }, 
{ name = "user_id", qtype="SC" , width = 37  },
{ name = "credit_score", qtype = "I4",  is_load = true},
{ name = "on_time_payments", has_nulls = false, qtype = "F8", is_load = true },
{ name = "credit_util_percentage", has_nulls = false, qtype = "F8", is_load = true },
{ name = "quarterly", has_nulls = true, qtype = "I4", is_load = true },
{ name = "two_years", has_nulls = true, qtype = "I4", is_load = true },
{ name = "credit_card_id", has_nulls = true, qtype = "I4", is_load = true },
{ name = "txn_ct", has_nulls = true, qtype = "I1", is_load = true },
{ name = "src_unique_click_id", qtype="SC", width = 32  },
}
return metadata
