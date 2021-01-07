# tX Interactions

See https://forum.door43.org/t/door43-org-tx-development-architecture/65 which describes the system architecture.

## Repos involved:

The individual repos are here:

* https://github.com/unfoldingWord-dev/door43-enqueue-job
* https://github.com/unfoldingWord-dev/door43-job-handler
* https://github.com/unfoldingWord-dev/tx-enqueue-job
* https://github.com/unfoldingWord-dev/tx-job-handler
* https://github.com/unfoldingWord-dev/obs-pdf
* https://github.com/unfoldingWord-dev/uw-pdf
* https://github.com/unfoldingWord-dev/tools/tree/develop/tx
	

## Job Queues involved:

tX has these 3 job queues: 

1. make HTML pages
1. make OBS PDFs
1. make other PDFs
   
The queue for #2 is called tX_obs_PDF_webhook. 

The queue for #3 is called tX_other_PDF_webhook. 


## Docker Containers:

The OBS PDF container is based on https://hub.docker.com/repository/docker/unfoldingword/obs-stretch-base (slim version of Debian stretch with Python 3.8.1 built from https://github.com/unfoldingWord-dev/obs-pdf/blob/develop/resources/docker-slim-python3.8-base/Dockerfile).


## Making a RQ app

To make a RQ app:

1. include [RQ](https://pypi.org/project/rq/) and change queue name in your copy of https://github.com/unfoldingWord-dev/obs-pdf/blob/develop/public/rq_settings.py.
1. create a function for rq to call named job as in https://github.com/unfoldingWord-dev/obs-pdf/blob/develop/public/webhook.py.
1. job(...) should receive a JSON dict as described in https://forum.door43.org/t/door43-org-tx-development-architecture/65 section 4.
1. The worker should create the PDF file and upload it to `(dev-)cdn.door43.org/u/<repo_owner_username>/<repo_name>/<branch_or_tag_name>/`. The PDF file must be called either `<repo_owner_username>–<repo_name>–<tag_name>.pdf` or `<repo_owner_username>–<repo_name>–<branch_name>–<commit_hash>.pdf`.


## Running/Testing tX Locally

How to run tX on Ubuntu Linux:

1. Open about six tabs in a terminal window.
1. Change directory to the appropriate cloned repos, e.g., `cd yourpath/door43-enqueue-job`
1. Setup a Python 3.8 or newer (currently 3.8.6) virtual environment and activate it
1. Run a batch file to setup environment variables
1. Run the tX process from the Makefile in debug mode
1. Simulate the sending of a JSON payload and watch everything happen -- debug mode prints more on the terminal screen

### In terminal tab 1:

1. `cd yourpath/door43-enqueue-job`
2. `python3 -m venv myVenv/; source myVenv/bin/activate`
3. `vi setENVs.sh` (new file)

	Add the following content, setting variables to your credentials:
```
#!/usr/bin/env bash
#
# setENVs.sh for Door43 Enqueue Job
#       Last modified: 2018-12-04 RJH
#

export AWS_ACCESS_KEY_ID="AKJ.........QRF"
export AWS_SECRET_ACCESS_KEY="kxZ...................1bm"
```

4. `source setENVs.sh`
5. `make composeEnqueueRedis` - 
	Starts a Redis server on 127.0.0.1:6379
	Then starts the (dev-)door43-enqueue-job process
		which handles JSON payloads from Door43 webhooks
	It also handles callbacks from tx-job-handler
		and uploads the converted files to Door43
	

### In terminal tab 2:

1. `cd yourpath/door43-job-handler`
2. `python3 -m venv myVenv/; source myVenv/bin/activate`
3. `vi setENVs.sh` (new file)

	Add the following content, setting variables to your credentials:
```	
#!/usr/bin/env bash
#
# setENVs.sh for Door43 Job Handler
# Last modified: 2020-03-19 RJH
#

export DB_ENDPOINT="door43.cluster-ccidwldijq9p.us-west-2.rds.amazonaws.com"
export TX_DATABASE_PW="fxt......bv1"
export AWS_ACCESS_KEY_ID="AKJ.........QRF"
export AWS_SECRET_ACCESS_KEY="kxZ...................1bm"
export GOGS_USER_TOKEN="672................................882"
```

4. `source setENVs.sh`
5. `make runDevDebug` - 
	Starts the (dev-)door43-job-handler process
		which then connects to the local Redis server
		and does preprocessing of Door43 repos
	
	
### In terminal tab 3:

1. `cd yourpath/tx-enqueue-job`
2. `python3 -m venv myVenv/; source myVenv/bin/activate`
3. `vi setENVs.sh` (new file)
   
	Add the following content, setting variables to your credentials:
```	
#!/usr/bin/env bash
#
# setENVs.sh for tX Enqueue Job
# Last modified: 2018-12-04 RJH
#

export AWS_ACCESS_KEY_ID="AKJ.........QRF"
export AWS_SECRET_ACCESS_KEY="kxZ...................1bm"
```

4. `source setENVs.sh`
5. `make composeEnqueue` - 
	Starts the (dev-)tx-enqueue-job process
		which handles JSON payloads from door43-job-handler
		and from door43.org PDF button
   
### In terminal tab 4:

1. `cd yourpath/tx-job-handler`
2. `python3 -m venv myVenv/; source myVenv/bin/activate`
3. `vi setENVs.sh` (new file)
   
	Add the following content, setting variables to your credentials:
```	
#!/usr/bin/env bash
#
# setENVs.sh for tX Job Handler
# Last modified: 2018-10-27 RJH
#

export AWS_ACCESS_KEY_ID="AKJ.........QRF"
export AWS_SECRET_ACCESS_KEY="kxZ...................1bm"
```

4. `source setENVs.sh`
5. `make runDevDebug` -
	Starts the (dev-)tx-job-handler process
		which then connects to the local Redis server
		and translates preprocessed repos to HTML
		and then enqueues a door43-callback
	
	
### In terminal tab 5:

1. `cd yourpath/obs-pdf`
2. `python3 -m venv myVenv/; source myVenv/bin/activate`
3. `vi setENVs.sh` (new file)
   
	Add the following content, setting variables to your credentials:
```	
#!/usr/bin/env bash
#
# setENVs.sh for OBS PDF creator
#       Last modified: 2019-07-15 RJH
#
export AWS_ACCESS_KEY_ID="AKJ.........QRF"
export AWS_SECRET_ACCESS_KEY="kxZ...................1bm"

# Added for rq version
export QUEUE_PREFIX="dev-"
export REDIS_URL="redis://172.21.0.2:6379"

# Optional -- not sure what they do
export DEBUG_MODE="Yeah"
export TEST_MODE="Maybe"
```


4. `source setENVs.sh`
5. `make runDevDebug`
	
Then (inside the container):

1. `cd /`
2. `./start_RqApp.sh`
   
`start_RqApp.sh` file:

Starts the (dev-)obs-pdf creator process
		which then connects to the local Redis server
		and translates preprocessed OBS repos to a PDF
		and then enqueues a door43-callback

```
#! /usr/bin/env bash
set -e

# Start the Rq worker
cd /app/obs-pdf/public
#rq worker --config rq_settings --name tX_Dev_HTML_Job_Handler
rq worker --config rq_settings
```


### Docker check

You have to make sure that all these docker processes are communicating properly:

1. `docker network ls`
1. `docker network inspect tx-net`
1. `docker network connect tx-net tx-enqueue-job_txenqueue_1` (I think) if it's not already connected automagically.


Now it's all set-up.


## Generating a PDF

### In terminal tab 0:

1. `cd yourpath/tools/tx`
2. `./submit_one_Door43_test.py` -
	submits a simulated JSON "push" payload to start tX off, e.g.:
```
{
  "secret": "",
  "ref": "refs/heads/master",
  "before": "master",
  "after": "master",
  "compare_url": "",
  "commits": [
    {
      "id": "master",
      "message": "Completed \"And\" corrections and continued Matthew edit (#1806)\n",
      "url": "https://git.door43.org/unfoldingWord/en_ult/commit/master",
      "author": {
	"name": "Larry Sallee",                                                                                                   
	"email": "lrsallee@noreply.door43.org",                                                                                   
	"username": ""                                                                                                            
      },
      "committer": {
	"name": "Gogs",                                                                                                           
	"email": "gogs@fake.local",
	"username": ""
      },
      "verification": null,
      "timestamp": "0001-01-01T00:00:00Z"
    }
  ],
  "repository": {
    "id": 11419,
    "owner": {
      "id": 613,
      "login": "unfoldingWord",
      "full_name": "unfoldingWord",
      "email": "unfoldingword@noreply.door43.org",
      "avatar_url": "https://git.door43.org/avatars/4f8ed65a91810d6162092c907126c8d3",
      "username": "unfoldingWord"
    },
    "name": "en_ult",
    "full_name": "unfoldingWord/en_ult",
    "description": "Source files for unfoldingWord Literal Text (formerly ULB)",
    "empty": false,
    "private": false,
    "fork": false,
    "parent": null,
    "mirror": false,
    "size": 91754,
    "html_url": "https://git.door43.org/unfoldingWord/en_ult",
    "ssh_url": "git@git.door43.org:unfoldingWord/en_ult.git",
    "clone_url": "https://git.door43.org/unfoldingWord/en_ult.git",
    "website": "https://unfoldingword.bible/ult/",
    "stars_count": 7,
    "forks_count": 15,
    "watchers_count": 4,
    "open_issues_count": 44,
    "default_branch": "master",
    "created_at": "2017-06-01T22:16:16Z",
    "updated_at": "2018-10-26T21:03:29Z",
    "permissions": {
      "admin": false,
      "push": false,
      "pull": false
    }
  },
  "pusher": {
    "id": 6442,
    "login": "RobH",
    "full_name": "Robert Hunt",
    "email": "robh@noreply.door43.org",
    "avatar_url": "https://git.door43.org/avatars/f85d2867fead49449e89c6822dc77bc6",
    "username": "RobH"
  },
  "sender": {
    "id": 6442,
    "login": "RobH",
    "full_name": "Robert Hunt",
    "email": "robh@noreply.door43.org",
    "avatar_url": "https://git.door43.org/avatars/f85d2867fead49449e89c6822dc77bc6",
    "username": "RobH"
  }
}
```

3. or alternatively, to make a PDF via tx-enqueue-job (IIRC):
   
```
{
    "job_id": "OBS-PDF.test-1.en",
    "identifier": "unfoldingWord--en_obs--master",
    "user_token": "682...............................842",
    "resource_type": "Open_Bible_Stories",
    "input_format": "md",
    "output_format": "pdf",
    "source": "https://git.door43.org/unfoldingWord/en_obs/archive/master.zip"
}
```
