import Q
import os
import sys


def test_print_csv():
    """Test Q.print_csv() with opfile=None (default)
    This will print the vector values to stdout"""

    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    Q.print_csv(vec)
    print("Successfully executed Q.print_csv test")


def test_print_csv_str():
    """Test Q.print_csv() with opfile=""
    This will return the string representation of vector"""

    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    result = Q.print_csv(vec, {'opfile' : ""})
    sys.stdout.write(result)
    print("Successfully executed Q.print_csv test")


def test_print_csv_list():
    """Test Q.print_csv() with list of vectors as input"""

    in_vals = [1, 2, 3, 4]
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.mk_col(in_vals, Q.I1)
    Q.print_csv([vec1, vec2])
    print("Successfully executed Q.print_csv with list as input")


def test_print_csv_to_file():
    """Test Q.print_csv() with opfile=file
    This will write the print_csv output to file"""

    in_vals = [1, 2, 3, 4]
    file_name = "result.txt"
    vec1 = Q.mk_col(in_vals, Q.I1)
    vec2 = Q.mk_col(in_vals, Q.I1)
    Q.print_csv([vec1, vec2], {'opfile':file_name})
    assert(os.path.exists(file_name))
    os.system("cat %s" % file_name)
    os.remove(file_name)
    assert(not os.path.exists(file_name))
    print("Successfully executed Q.print_csv with opfile as file")


if __name__ == "__main__":
    test_print_csv()
    print("==========================")
    test_print_csv_str()
    print("==========================")
    test_print_csv_list()
    print("==========================")
    test_print_csv_to_file()
    print("==========================")
