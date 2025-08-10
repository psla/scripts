Create a python script that does two things.



Given the list of folders in parameters (arguments), it calculates a hash (with a fast hashing function) of each file in the subfolders. It outputs the result to a json file.



The second mode is: given the json file and a list of folders, for every file with a matching filename, it calculates its hash (using the same fast hashing function).



If the hash does not match, a warning to stderr is printed.



If the hash matches, the full path of the matching file is printed to stdout. Each file is printed in a separate line.




