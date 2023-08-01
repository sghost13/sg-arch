#/usr/bin/env bash
set -Eeuo pipefail

# https://www.hostinger.com/tutorials/bash-for-loop-guide-and-examples/

# Bash version 3.0+ can shorten the range with “..”.
for i in {1..5} ; do
  echo "House $i"
done



# Bash version 4.0+ allows you to use the {START..END..INCREMENT} syntax.
# Results in printing: Hello 0\nHello 2\nHello 4\nHello 6\nHello 8\n 
for i in {0..8..2} ; do
  echo "Hello $i"
done

# The other common two loop command syntaxes are this:
for VARIABLE in file1 file2 file3 ; do
    command1 on $VARIABLE
    command2
    commandN
done

# And this:
for OUTPUT in $(Linux-Or-Unix-Command-Here)
do
    command1 on $OUTPUT
    command2 on $OUTPUT
    commandN
done

