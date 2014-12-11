#!/bin/sh

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

aws s3 cp --acl public-read $DIR/../conf/kickoff.json s3://stelligent-aws-group-policy/kickoff.json

