Create test files that contain values which are as diverse as possible.
Create both good tests and bad tests.
Here are some examples
o) Mismatched double quotes
o) Number of columns in CSV file does not match meta data
o) Number of columns in CSV file not same on each line
o) Last character is NOT eoln = record delimiter
o) Meta data says no null values but data has null values
o) Meta data says has null values but data has no null values [This is OK]
o) Missing escape character 
o) escape character not followed by escape character or dquote character
o) integer out of range
o) floating point out of range
o) Can we specify integer in hex format?
o) Can we specify floating point in exponent format?
o) Column names must be alphanumeric characters (and underscore) but should not start with underscore. 
o) Maximum length of column is 31 characters.

and on and on....

If any failure, all files should be cleaned up.


