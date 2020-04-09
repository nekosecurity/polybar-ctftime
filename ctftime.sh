#!/bin/bash

now=$(date +"%s")
end=$(date --date='+1 month' +"%s")

# ctftime api
# https://ctftime.org/api/v1/events/
# ?limit=100&start=1422019499&finish=1423029499
data=$(curl -H 'application/json' "https://ctftime.org/api/v1/events/?limit=10&start=$now&finish=$end" |jq -r '.[] | [.format, .title, .url, .start, .finish] | @csv')

echo $data
