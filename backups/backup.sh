#!/bin/sh

PROGNAME=$0
usage() {
  cat << EOF >&2
Usage: $PROGNAME [-r restore ]
-r <tar file>: restore backup
EOF
  exit 1
}


while getopts r: o; do
  case $o in
    [Rr]*)
      restore_file=$OPTARG
    break;;
    (*) usage
  esac
done



if [ ! -z $restore_file ]; then
  # Restoration
  container=$3
  dir=$(dirname $(realpath $restore_file))
  file=$(basename $restore_file)
#  printf "dir: $dir\n"
#  printf "file: $file\n"
#  printf "container: $container\n"
  docker run --rm --volumes-from $container \
        -v $dir:/backup alpine:3.11 \
        sh -c "cd $/; tar xvf  /backup/$file"
else
  # Backup
  container=$1
  backup_path=$2
#  printf "container: $container\n"
#  printf "backup_path: $backup_path\n"
  docker run --rm --volumes-from $container \
        -v $(pwd)/backups:/backup alpine:3.11 \
        tar cvf /backup/$container.tar $backup_path --exclude='var/www/backend/storage/app/glide_cache' --exclude='Bloomsart-Spain' --exclude='Bloomsart-France'
fi
