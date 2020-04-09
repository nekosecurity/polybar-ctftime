#!/bin/bash

function get_upcoming(){
  local now
  local end
  local limit
  local selected
  local url

  now=$(date --date="$(date +%F -d '-1 day')" +'%s')
  end=$(date --date='+1 month' +'%s')
  limit=10

  IFS=$'\n'
  export -f _convert_date
  upcoming=( $(curl -s "https://ctftime.org/api/v1/events/?limit=$limit&start=$now&finish=$end" \
   |jq -r '.[] | [.title, .url, .start, .finish, .duration.days] |@csv' |  tr -d \"|awk -F ',' \
   '{
      cmd="date -d"$3"";
      cmd|getline start;
      close(cmd);
      cmd="date -d"$4"";
      cmd|getline end;
      close(cmd);
      printf("%s\n\t%s\n\tStart: %s\n\tEnd  : %s\n\tDuration: %d days\n", $1,$2,start,end,$5)}') )

  selected=$(echo "${upcoming[*]}" |rofi -dmenu -no-config -theme-str '#mainbox{children: [listview];}') 
  url=$(echo "$selected" |grep -E 'http' |tr -d '\t')
  if [ "$url" ]; then
    xdg-open "$url"
  fi

}

function get_rank() {
	if [ $# -eq 0 ]; then
		exit 1
	fi

  local year
  local rank
	year=$(date +"%Y")
	rank=$(curl -s "https://ctftime.org/api/v1/teams/$1/"|jq -r ".rating |.[]| select(.\"$year\" !=null) | .\"$year\".rating_place ")
	echo "$rank"
}

OPTS=$(getopt -o r:u -l rank:,upcoming -n "$0" -- "$@" )

if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi


eval set -- "$OPTS"

# extract options and their arguments into variables.
while true ; do
  case "$1" in
    -r | --rank )
      get_rank "$2"
      shift 2
      break
      ;;
    -u | --upcoming )
      get_upcoming 
      break
      ;;
    -- )
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done