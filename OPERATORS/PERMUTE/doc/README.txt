3 Inputs
1) Column A: value column. Types can be any qtype
2) Column B: index column. Types can be any of I1/I2/I4/I8
3) Mode = safe or fast, default is fast (details later)

Other constraints that must be verified 
Values of B must be 0, 1, 2, ... n-1 where n is length of Column A. 
Length(A) = Length(B)

1 Output
1) Column C: column A reordered based on Column A
qtype(C) = qtype(A)
length(C) = length(A)

C[i] = A[B[i]]
example
A = 10, 20, 30, 40, 50, 60
B = 0, 5, 1, 4, 2, 3
C = 10, 60, 20, 50, 30, 40

==============================================

In safe mode, we create a bit vector d of length 1 initialize to
0. When C[i] is assigned a value, d[i] is set to 1. At the end, if
sum(d[i] != length(C)) then it means that B was not a
permutation. This is okay but it means that the ith value of C is
undefined. Hence, we must set d as the nn vector of C. Else, we delete
d and return just C.

Note that in fast mode, we will never return a nn vector. We assume
that B was a genuine permutation of [0,1, 2, ... n-1]

--=================

Note that this is particularly simple because this does not need an 
expander like f1f2opf3. It gets going fairly directly.


