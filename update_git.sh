#/bin/bash

# auto-update the local git repo when the remote repo has change
# optionally restert a webserver after the update
# run this script with a crontab, every x minutes

LOCAL_MASTER=`git ls-remote . refs/heads/master | awk -F' ' '{print $1}'`
REMOTE_MASTER=`git ls-remote http://github.com/USER/REPO.git refs/heads/master | awk -F' ' '{print $1}'`

if [ "$LOCAL_MASTER" != "$REMOTE_MASTER" ]
then
  `sudo -u www-data git pull > /dev/null`
  `webroar restart MY_WEBAPP > /dev/null`
fi

