#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2016 Elastic, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

#########################
# HELP
#########################

help()
{
    echo "This script sends user information to Elastic marketing team, allowing for follow-up conversations"
    echo "Parameters:"
    echo "-U api url"
    echo "-I marketing id"
    echo "-c company name"
    echo "-e email address"
    echo "-f first name"
    echo "-l last name"
    echo "-t job title"
    echo "-h view this help content"
}

# log() does an echo prefixed with time
log()
{
    echo \[$(date +%d%m%Y-%H:%M:%S)\] "$1"
    echo \[$(date +%d%m%Y-%H:%M:%S)\] "$1" >> /var/log/arm-install.log
}

log "Begin execution of User Information script extension"

#########################
# Paramater handling
#########################

API_URL=""
MARKETING_ID=""
COMPANY_NAME=""
EMAIL=""
FIRST_NAME=""
LAST_NAME=""
JOB_TITLE=""

#Loop through options passed
while getopts :U:I:c:e:f:l:t:h optname; do
  log "Option $optname set"
  case $optname in
    U) #set API url
      API_URL=${OPTARG}
      ;;
    I) #set marketing id
      MARKETING_ID=${OPTARG}
      ;;
    c) #set company name
      COMPANY_NAME=${OPTARG}
      ;;
    e) #set email
      EMAIL=${OPTARG}
      ;;
    f) #set first name
      FIRST_NAME=${OPTARG}
      ;;
    l) #set last name
      LAST_NAME=${OPTARG}
      ;;
    t) #set job title
      JOB_TITLE=${OPTARG}
      ;;
    h) #show help
      help
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

#########################
# Installation steps as functions
#########################

post_user_information()
{
    log "creating lead"    
    CURL_COMMAND="curl -X POST \"$API_URL\" --data-urlencode \"formid=4026\" --data-urlencode \"munchkinId=$MARKETING_ID\" --data-urlencode \"formVid=4026\" "
    if [[ ! -z $FIRST_NAME ]]; then
        CURL_COMMAND=$CURL_COMMAND"--data-urlencode \"FirstName=$FIRST_NAME\"" 
    fi

    if [[ ! -z $LAST_NAME ]]; then
        CURL_COMMAND=$CURL_COMMAND" --data-urlencode \"LastName=$LAST_NAME\""
    fi

    if [[ ! -z $EMAIL ]]; then
        CURL_COMMAND=$CURL_COMMAND" --data-urlencode \"Email=$EMAIL\""
    fi

    if [[ ! -z $COMPANY_NAME ]]; then
        CURL_COMMAND=$CURL_COMMAND" --data-urlencode \"Company=$COMPANY_NAME\""
    fi

    if [[ ! -z $JOB_TITLE ]]; then
        CURL_COMMAND=$CURL_COMMAND" --data-urlencode \"Title=$JOB_TITLE\""
    fi

    CURL_COMMAND=$CURL_COMMAND" --silent --write-out %{http_code} --output /dev/null"
    STATUS_CODE=$(eval $CURL_COMMAND)

    if test $STATUS_CODE -ne 200; then
        log "failed to send lead details. status code: $STATUS_CODE"
    else
        log "lead successfully sent"
    fi
}

# Need the endpoint and marketing id to be able to send
if [[ -z $API_URL || -z $MARKETING_ID ]]; then
  log "No api url or marketing id defined."
  exit 1
fi

# Don't try send a lead if we don't have any details
if [[ -z $FIRST_NAME && -z $LAST_NAME && -z $EMAIL && -z $COMPANY_NAME && -z $JOB_TITLE ]]; then
  log "No user information supplied. No lead to send."
  exit 0
fi

post_user_information

log "End execution of User Information script extension"
exit 0