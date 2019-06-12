//Want to reduce the amount of executors on master to only 4
//That will be for housekeeping jobs executed on master 

import jenkins.model.*
Jenkins.instance.setNumExecutors(4)
