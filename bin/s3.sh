#!/bin/bash
# Courtesy of https://gist.github.com/chrismdp/6c6b6c825b07f680e710
# Based on a modified script from here: http://tmont.com/blargh/2014/1/uploading-to-s3-in-bash
#
# Can also use Fog or the aws-cli python client, but this is good for when we
# don't have a lib installed.

! read -d '' usage <<"EOF"
  s3.sh

  USAGE:
  s3.sh /local/path s3://bucket-name/remote-path [content-type]

  Default content type is application/x-compressed-tar
EOF

function quit {
  echo $@
  exit 1
}

# TODO: read this from ~/.aws/config if it exists
key=${AWS_ACCESS_KEY_ID}
secret=${AWS_SECRET_ACCESS_KEY}
bucket='beyond-packer'
acl="x-amz-acl:public-read"

[[ ${key} ]] || quit 'ERROR: Must set AWS_ACCESS_KEY_ID'
[[ ${secret} ]] || quit 'ERROR: Must set AWS_SECRET_ACCESS_KEY'
[[ ${1} ]] || quit $usage
[[ ${2} ]] || quit $usage

# TODO: append the filename if the target ends in a slash
regex='s3://([a-z\-]+)/(.*)'
# TODO: these return non-zero error codes, so can't use set -e
bucket=`echo $2 | pcregrep -o1 -i "$regex"`
path=`echo $2 | pcregrep -o2 -i "$regex"`
echo bucket is $bucket
echo path is $path

# This is some seriously archane syntax for a default param.
# TODO: include some guesses for common (e.g. json) extensions.
content_type=${3-'application/x-compressed-tar'}

date=$(date +"%a, %d %b %Y %T %z")
action="PUT\n\n$content_type\n$date\n$acl\n/$bucket/$file"
signature=$(echo -en "${action}" | openssl sha1 -hmac "${secret}" -binary | base64)

echo curl -X PUT -T "$remote/$file" \
  -H "Host: $bucket.s3.amazonaws.com" \
  -H "Date: $date" \
  -H "Content-Type: $content_type" \
  -H "$acl" \
  -H "Authorization: AWS ${key}:$signature" \
  "https://$bucket.s3.amazonaws.com/$file"
