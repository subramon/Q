Debugging with CLion screenshots explanation

Please have look at screenshots
. Image "1_Q_script" shows the sample Q script under debugging which performs vector addition
. Image "2_*" (i.e "2__print_csv", "2_is_eov", "2_is_nascent", "2_memo", "2_num_elements", "2_qtype") shows we can query simple vector properties when the execution control hits to breakpoint
. Image "3__performing_sort" shows we can modify the vector at runtime while debugging, here we have sorted the vector in descending order
. Image "3_get_meta_after_sort" shows the updated metadata of the vector and image "4_after_sort_print_csv" confirms the vector elements are sorted in descending order
. Image "5_saving_vector_state_at_clion" shows we can store the state at the time of debugging into a file using Q.save()
. Image "6_restoring_state_at_qli" shows we can restore the state in QLI session and query the vector state. Here we tried

Usecase:
. Image "u_1_Clion_create_&_print_vector" shows the output vector contents in the CLion debugging
. Image "u_1_get_meta(sort_order)" confirms there is no any metadata associated with output vector regarding "sort_order"
. Image "u_2_saveit_in_Clion" serializes the vector state to a file from CLion
. Image "u_3_restore_&_modify_vector_in_QLI" restores the saved state in QLI and modifies the vector, sorts it in descending order
. Now, we are restoring the updated vector in CLion session, Image "4_Clion_before_restore_operation" just confirms state of the vector before restore operation
. Image "u_5_restore_modified_vector_backin_Clion" restores the modified vector in CLion
. Image "u_6_Clion_print_csv" prints the updated vector (updated in QLI session) and confirms it is a sorted vector now.
. Image "u_7_get_meta(sort_order)" shows the metadata of the modified vector
