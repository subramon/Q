README.md for LR_in_R.R file

LR_in_R.R contains an implementation of logistic regression in R. The algorithm is the same as the algorithm used in Q's implementation. The testing data was obtained from an example on Wikipedia (https://en.wikipedia.org/wiki/Logistic_regression#Example:_Probability_of_passing_an_exam_versus_hours_of_study).

Observations:
1) If logit and logit2 are implemented using e^x/(1 + e^x) and e^x/(1+e^x)^2 instead of 1/(1+e^(-x)) and 1/(1+e^(-x))^2, the LR algorithm fails.
2) The results match the coefficients on Wikipedia. However, if R's LR function glm() is used instead of the algorithm, the coefficients do not match.
