local plstring = require 'pl.stringx'
local utils = require 'Q/UTILS/lua/utils'
local load_csv_col_seq   = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']

local fns = {}

-- see if the file exists
local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
local function lines_from_file(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

local function split_labels_n_links(lines_tbl)
  local label_tbl = {}
  local links_tbl = {}
  for k,v in pairs(lines_tbl) do
    if k>3 then
      if (string.find(v, "->")) ~= nil then
        v = plstring.strip(v) 
        local links, label = plstring.splitv(v, " %[")
        links = plstring.strip(links, ";")
        links_tbl[#links_tbl + 1] = links
      elseif v ~= "}" then
        v = plstring.strip(v)
        local index, label = plstring.splitv(v, " %[label=<")
        index = tonumber(index)
        label = plstring.splitv(label, ">, ")
        -- storing labels according to it node index only
        assert(#label_tbl == index)
        label_tbl[#label_tbl + 1] = label
      end
    end
  end
  return label_tbl, links_tbl
end

local function value_to_n_T_n_H (value)

end

local function get_condition_key_n_value(condition_str, feature_list)
  local feature, threshold = plstring.splitv(condition_str, ";")
  feature = plstring.strip(plstring.splitv(feature, "&le"))
  local feature_str = feature
  feature = utils["table_find"](feature_list, feature)
  return feature_str, feature, tonumber(threshold)
end

local function get_benefit_key_n_value(benefit_str)
  local benefit_key, benefit_val = plstring.splitv(benefit_str, "=")
  return benefit_key, tonumber(benefit_val)
end

local function get_value_n_T_n_H(value_str)
  local idx_s = string.find(value_str, "%[")
  local idx_e = string.find(value_str, "%]")
  local str_out = string.sub(value_str, idx_s+1, idx_e-1)
  local val_1, val_2 = plstring.splitv(str_out, ", ")
  return tonumber(val_1), tonumber(val_2)
end

local function replace_strings(str, src_str, dest_str)
  return plstring.replace(str, src_str, dest_str)
end

local function get_required_fields(label_tbl)
  local required_labels = {}
  local seperator = "<br/>"
  for i=1, #label_tbl do
    local l1, l2, l3, l4 = plstring.splitv(label_tbl[i], "<br/>")
    -- replacing the 'gini' label by 'benefit' 
    if l2 ~= nil and plstring.startswith(l2, "gini") then
      l2 = replace_strings(l2, "gini", "benefit")
    elseif l1 ~= nil and plstring.startswith(l1, "gini") then
      l1 = replace_strings(l1, "gini", "benefit")
    end
    local final_required_labels
    -- dropping the sample field
    if l4 ~= nil then
      final_required_labels = l1 .. seperator .. l2 .. seperator .. l4
    else
      final_required_labels = l1 .. seperator .. l3
    end
    required_labels[#required_labels + 1] = final_required_labels
  end
  return required_labels
end

local function create_dt(D, p_node_idx, c_node_idx, label_tbl, feature_list)
  -- getting the fields and field values for child only
  local l1, l2, l3 = plstring.splitv(label_tbl[c_node_idx+1], "<br/>")
  local c_feature, c_feature_str, c_threshold, c_benefit_key, c_benefit_val, c_n_T_value, c_n_H_value
  local is_feature_present = false
  
  if l3 ~= nil then
    is_feature_present = true
    c_feature_str, c_feature, c_threshold = get_condition_key_n_value(l1, feature_list)
    c_benefit_key, c_benefit_val = get_benefit_key_n_value(l2)
    c_n_T_value, c_n_H_value = get_value_n_T_n_H(l3)
  else
    c_benefit_key, c_benefit_val = get_benefit_key_n_value(l1)
    c_n_T_value, c_n_H_value = get_value_n_T_n_H(l2)
  end
  
  if D.node_idx == nil then
    -- getting the fields and fields values for parent only
    local l1, l2, l3 = plstring.splitv(label_tbl[p_node_idx+1], "<br/>")
    local p_feature_str, p_feature, p_threshold = get_condition_key_n_value(l1, feature_list)
    local p_benefit_key, p_benefit_val = get_benefit_key_n_value(l2)
    local p_n_T_value, p_n_H_value = get_value_n_T_n_H(l3)

    D.node_idx = p_node_idx
    D.n_T = p_n_T_value
    D.n_H = p_n_H_value
    D.feature =  p_feature
    D.feature_name = p_feature_str
    D.threshold = p_threshold
    D.benefit = p_benefit_val

    D.left = {}
    D.left.node_idx = c_node_idx
    D.left.n_T = c_n_T_value
    D.left.n_H = c_n_H_value
    D.left.benefit = c_benefit_val
    
    if is_feature_present then
      D.left.feature =  c_feature
      D.left.feature_name = c_feature_str
      D.left.threshold = c_threshold
    end
  elseif  D.node_idx == p_node_idx and D.left == nil then
    D.left = {}
    D.left.node_idx = c_node_idx
    D.left.n_T = c_n_T_value
    D.left.n_H = c_n_H_value
    D.left.benefit = c_benefit_val
    
    if is_feature_present then
      D.left.feature =  c_feature
      D.left.feature_name = c_feature_str
      D.left.threshold = c_threshold
    end

  elseif  D.node_idx == p_node_idx and D.right == nil then
    D.right = {}
    D.right.node_idx = c_node_idx
    D.right.n_T = c_n_T_value
    D.right.n_H = c_n_H_value
    D.right.benefit = c_benefit_val
    
    if is_feature_present then
      D.right.feature =  c_feature
      D.right.feature_name = c_feature_str
      D.right.threshold = c_threshold
    end
  end
  if D.node_idx ~= p_node_idx and D.left ~= nil then
    create_dt(D.left, p_node_idx, c_node_idx, label_tbl, feature_list)
  end
  if D.node_idx ~= p_node_idx and D.right ~= nil then
    create_dt(D.right, p_node_idx, c_node_idx, label_tbl, feature_list)
  end 
end

local function convert_sklearn_to_q(file, feature_list, goal_feature)
  -- getting the correct sequence of the feature_list
  feature_list = load_csv_col_seq(feature_list, goal_feature)

  local lines_tbl = lines_from_file(file)
  assert(type(lines_tbl) == "table")
  local D = {}
  
  local label_tbl, links_tbl = split_labels_n_links(lines_tbl)
  local required_labels_tbl = get_required_fields(label_tbl)
  for i=1, #links_tbl do
    local p_idx, c_idx = plstring.splitv(links_tbl[i], "->")
    p_idx = tonumber(p_idx)
    c_idx = tonumber(c_idx)
    create_dt(D, p_idx, c_idx, required_labels_tbl, feature_list)
  end
  return D
end

fns.convert_sklearn_to_q = convert_sklearn_to_q

return fns
