-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

--[[

This computes probabilities of getting various totals from rolling
dice. They take data frames with two columns, "value" and
"probability". Each row gives one possible total and its
probability. AddProbabilities takes a list of data frames where the
same value might appear more than once and accumulates probabilities
for matching values. AddRolls takes data frames for two different
independent rolls and returns the information for the sum of the two
rolls.

AddProbabilities <- function(...) {
  do.call("rbind", list(...)) %>%
    group_by(value) %>%
    summarize(probability = sum(probability))
}

AddRolls <- function(r1, r2) {
  value <- as.vector(outer(r1$value, r2$value, "+"))
  probability <- as.vector(outer(r1$probability, r2$probability, "*"))
  data.frame(value = value, probability = probability) %>%
    AddProbabilities()
}
--]]

local tests = {}
tests.t1 = function ()
end
return tests
