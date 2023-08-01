
User, Group, 
Permissions numbers are :

0 = ---
1 = --x
2 = -w-
3 = -wx
4 = r-
5 = r-x
6 = rw-
7 = rwx

For example :

chmod 777 will give read, write, and execute permissions for everyone.
chmod 700 will give read, write, and execute permissions for the user only.
chmod 660 will give read write to user and group, none to everyone else.
chmod 640 will give read write to user, read to group, none to everyone else.

