# This modifies (increases dramatically) the number of files the particular user can have
# open (concurrently). The user for whom we are increasing the limits is the current user.
# The understanding is that Q will be run by this user.
echo "`whoami` hard nofile 102400" | sudo tee --append /etc/security/limits.conf
echo "`whoami` soft nofile 102400" | sudo tee --append /etc/security/limits.conf
