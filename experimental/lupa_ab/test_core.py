import core as ab
import json


ab_struct = ab.init_ab("my_config")
sum_result = ab.sum_ab(ab_struct, factor=2)
sum_dict = json.loads(sum_result)
for i, v in sum_dict.items():
    print(i, v)
ab.print_ab(ab_struct)
ab.free_ab(ab_struct)
