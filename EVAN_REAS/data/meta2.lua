local M = {}
M[#M+1] = { name = "buyDate", qtype = "SC", width = 32, is_load = false }
M[#M+1] = { name = "expirationDate", qtype = "SC", width = 32, is_load = false }
M[#M+1] = { name = "stock", qtype = "SC", width = 32, is_load = false }
M[#M+1] = { name = "Duration", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "stockPrice", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "callDouble", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "putDouble", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "dailyVolume", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "gainLossPct1Day", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "gainLossPct5Day", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "gainLossPct10Day", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "gainLossPct30Day", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "gainLossPct90Day", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "gainLossPct180Day", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "gainLossPct270Day", qtype = "F4", is_memo = true, is_persist = true  }
M[#M+1] = { name = "priceIncrease52wkPct", qtype = "F4", is_memo = true, is_persist = true  }
-- the thing to predict
M[#M+1] = { name = "highAvgBPCombo", qtype = "F4", is_memo = true, is_persist = true  }
return M


