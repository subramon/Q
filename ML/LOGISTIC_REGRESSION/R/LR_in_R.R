hours	= c(0.50,0.75,1.00,1.25,1.50,1.75,1.75,2.00,2.25,2.50,
          2.75,3.00,3.25,3.50,4.00,4.25,4.50,4.75,5.00,5.50)
pass = c(0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1)
d = data.frame(hours, pass)
dtrain = d[-c(3,6,7,9,15),]
dtest = d[c(3,6,7,9,15),]
lr = glm(pass ~ hours, data = dtrain, family = "binomial")
summary(lr)
predict(lr, dtest, type = "response")

#----------------------------

logit = function(x) {
  e = 2.7182818285
  1/(1 + e^(-x))
}

logit2 = function(x) {
  e = 2.7182818285
  1/((1 + e^(-x))^2)
}

beta_step = function(X, y, beta) {
  Xbeta = X %*% beta
  p = logit(Xbeta)
  w = logit2(Xbeta)
  W = diag(as.vector(w), length(w), length(w))
  ysubp = y - p
  A = t(X) %*% W %*% X
  b = t(X) %*% ysubp
  beta_new_sub_beta = solve(A, b)
  new_beta = beta_new_sub_beta + beta
  new_beta
}  

d$intercept = rep(1, nrow(d))
beta = as.matrix(c(0,0))
X = as.matrix(d[,c(1,3)])
y = as.matrix(d[,2])

lg = function(X, y, beta) {
  for (i in 1:100) {
    #print(i)
    #browser()
    beta = beta_step(X, y, beta)
  }
  beta
}

coeffs = lg(X, y, beta)
coeffs
