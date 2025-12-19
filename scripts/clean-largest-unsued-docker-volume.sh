#!/usr/bin/env bash
set -euo pipefail

TOP=1

# Parse args
if [[ $# -gt 0 ]]; then
  if [[ "$1" == "--top" && $# -ge 2 ]]; then
    TOP="$2"
  else
    echo "Usage: $0 [--top N]"
    exit 1
  fi
fi

echo "Scanning for largest unused Docker volumes..."

volumes=$(docker volume ls -q \
  | xargs -I{} sh -c 'docker ps -q --filter volume={} | grep -q . || du -s /var/lib/docker/volumes/{}/_data 2>/dev/null | awk "{print \$1, \"{}\"}"' \
  | sort -nr \
  | head -n"$TOP")

if [[ -z "$volumes" ]]; then
  echo "No unused volumes found."
  exit 0
fi

i=1
echo "Top $TOP unused volumes by size:"
while read -r size volume; do
  hsize=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "${size}K")
  echo "  [$i] $volume ($hsize)"
  i=$((i+1))
done <<< "$volumes"

echo
read -p "Enter numbers to remove (e.g. 1 3), or press Enter to skip: " choices

if [[ -z "$choices" ]]; then
  echo "No volumes removed."
  exit 0
fi

i=1
while read -r size volume; do
  for choice in $choices; do
    if [[ "$choice" == "$i" ]]; then
      echo "Removing $volume..."
      docker volume rm "$volume"
    fi
  done
  i=$((i+1))
done <<< "$volumes"

echo "Done."

# #!/usr/bin/env bash
# set -euo pipefail

# echo "Scanning for largest unused Docker volume..."

# largest=$(docker volume ls -q \
#   | xargs -I{} sh -c 'docker ps -q --filter volume={} | grep -q . || du -s /var/lib/docker/volumes/{}/_data 2>/dev/null | awk "{print \$1, \"{}\"}"' \
#   | sort -nr \
#   | head -n1)

# if [[ -z "$largest" ]]; then
#   echo "No unused volumes found."
#   exit 0
# fi

# size=$(echo "$largest" | awk '{print $1}')
# volume=$(echo "$largest" | awk '{print $2}')

# # human readable size
# hsize=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "${size}K")

# echo "Largest unused volume: $volume ($hsize)"

# read -p "Do you want to remove this volume? [y/N]: " confirm
# if [[ "$confirm" =~ ^[Yy]$ ]]; then
#   docker volume rm "$volume"
#   echo "Removed $volume"
# else
#   echo "Aborted."
# fi
