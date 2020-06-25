local function print_dt(
  D,            -- prepared decision tree
  f             -- file_descriptor
  )
-- Preorder
  local seperator = "<br/>"
  local label = D.node_idx
  if D.left then
    local condition
    if D.left.feature then
      condition = " [label=<" .. D.left.feature_name .. " &le; " .. D.left.threshold .. seperator .. "benefit = " .. D.left.benefit .. seperator
    else
      -- leaf node
      condition = " [label=<" .. "n_T_test =" .. tostring(D.left.n_T_test) .. seperator .. "n_H_test = " .. tostring(D.left.n_H_test) .. seperator .. "payout = " .. tostring(D.left.payout) .. seperator
    end
    local str = D.left.node_idx .. condition .. "value = [" .. tostring(D.left.n_T) ..", " .. tostring(D.left.n_H) .."]>,fillcolor=\"#399de56d\"] ;"

    f:write(str .. "\n")
    f:write(label .. " -> " .. D.left.node_idx .. " ;\n")
    print_dt(D.left, f)
  end
  if D.right then
    local condition
    if D.right.feature then
      condition = " [label=<" .. D.right.feature_name .. " &le; " .. D.right.threshold .. seperator .. "benefit = " .. D.right.benefit .. seperator
    else
      -- leaf node
      condition = " [label=<" .. "n_T_test =" .. tostring(D.right.n_T_test) .. seperator .. "n_H_test = " .. tostring(D.right.n_H_test) .. seperator .. "payout = " .. tostring(D.right.payout) .. seperator
    end

    local str = D.right.node_idx .. condition .. "value = [" .. tostring(D.right.n_T) ..", " .. tostring(D.right.n_H) .."]>,fillcolor=\"#399de56d\"] ;"
    f:write(str .. "\n")
    f:write(label .. " -> " .. D.right.node_idx .." ;\n")
    print_dt(D.right, f)
  end
end

local function export_to_graphviz(file_name, tree)
  local f = io.open(file_name, "w")
  f:write("digraph Tree {\n")
  f:write("node [shape=box, style=\"filled, rounded\", color=\"pink\", fontname=helvetica] ;\n")
  f:write("edge [fontname=helvetica] ;\n")
  local seperator = "<br/>"
  local condition = " [label=<"
  if tree.feature then
    condition = condition .. tree.feature_name .. " &le; " .. tree.threshold .. seperator .. "benefit = " .. tree.benefit .. seperator
  end
  local root_node_str = tree.node_idx .. condition .. " value = [" .. tostring(tree.n_T) ..", " .. tostring(tree.n_H) .."]>,fillcolor=\"#399de56d\"] ;\n"
  f:write(root_node_str)
  print_dt(tree, f)
  print("Exported the Q to graphviz file ", file_name)
  f:write("}\n")
  f:close()
end

return export_to_graphviz
