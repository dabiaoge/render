# render
Text Render by awk

Version 1.5

Author : dabioage

Usage:  awk -F, -f render.awk template.txt var_list.csv

# For example
var_list.csv
```text
no,product,expiration
1,apple,20261201
5,banana,20261215
```
template.txt
```text
This product is ${product}, the number of this product is ${no} and expiration date is ${expiration}.
```
```bash
awk -F, -f render.awk template.txt var_list.csv
```
output:
```text
This product is apple, the number of this product is 1 and expiration date is 20261201.
This product is banana, the number of this product is 5 and expiration date is 20261215.
```
Support csv header as variable,also supper awk builtin variable ($0,$1,$2 ...)
