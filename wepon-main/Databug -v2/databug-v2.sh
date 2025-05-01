#!/bin/bash

echo "  _       _        _               _ "
echo "  __| | __ _| |_ __ _| |__  _   _  __| |"
echo " / _  |/ _  | __/ _  | '_ \| | | |/ _  |"
echo "| (_| | (_| | || (_| | |_) | |_| | (_| |"
echo " \__,_|\__,_|\__\__,_|_.__/ \__,_|\__,_|"
echo "  "
echo " v3  Made by Vaidik Pandya (h4x0r_fr34k)"
echo

if [ -z "$1" ]; then
  echo "Usage: $0 -l <input_file>"
  exit 1
fi

output_dir="categorized_urls"
mkdir -p "$output_dir"
mkdir -p "$output_dir/javascript"

input_file=""

while getopts "l:" opt; do
  case $opt in
    l)
      input_file="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ ! -f "$input_file" ]; then
  echo "Input file not found: $input_file"
  exit 1
fi

keywords=("redirect=" "redir=" "uri=" ".zip" ".sql" "uuid=" "id=" "refer=" "token=" "verification" "source=" "example=" "sample=" "test=" "users" "password" "jwt" "code" "verification_code" "=false" "=true" "private" "username" "debug" "file=" "path=" "target=" "tar.gz" ".pdf" "return_to=" "apikey" ".js")

uncategorized_file="$output_dir/uncategorized.txt"

while IFS= read -r url; do
  # Check if the URL is a .js file
  if [[ "$url" == *".js"* ]]; then
    echo "$url" >> "$output_dir/javascript/javascript_files.txt"
  else
    categorized=false
    for keyword in "${keywords[@]}"; do
      if [[ "$url" == *"$keyword"* ]]; then
        echo "$url" >> "$output_dir/$keyword.txt"
        categorized=true
        break
      fi
    done
    if [ "$categorized" = false ]; then
      echo "$url" >> "$uncategorized_file"
    fi
  fi
done < "$input_file"

read -p "Do you want to run Nuclei on the .js files? (yes/no): " run_nuclei

if [ "$run_nuclei" = "yes" ]; then


#add your nuclei temmplates location in the -t option below
  nuclei -l "$output_dir/javascript/javascript_files.txt" -t /your-templates-location/nuclei-templates/http/exposures -o exposed.txt
  echo "Nuclei scan completed."
elif [ "$run_nuclei" = "no" ]; then
  echo "Nuclei scan not performed. Exiting."
else
  echo "Invalid input. Nuclei scan not performed. Exiting."
fi

echo "Categorized URLs can be found in the '$output_dir' directory."
echo "Uncategorized URLs can be found in '$uncategorized_file'."


