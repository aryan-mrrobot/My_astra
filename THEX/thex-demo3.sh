#!/bin/bash

# Prompt user for domain name
echo "Please enter the domain name (e.g., domain.com):"
read domain_name

# Validate the input format
if [[ ! $domain_name =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Invalid domain name format. Please enter the domain name in the format 'domain.com'."
    exit 1
fi

#puredns bruteforce  ../raw  apple.com -r ../resolvers.txt.1 -q


# Run Puredns
echo "Running Puredns..."
puredns bruteforce  /home/xgod/THEX/raw  $domain_name -r /home/xgod/THEX/resolvers.txt.1 -q >> puredns_output.txt
echo "Puredns scan completed. Output saved to puredns_output.txt"

# Run subfinder
echo "Running subfinder..."
subfinder -d $domain_name >> subfinder_output.txt
echo "Subfinder scan completed. Output saved to subfinder_output.txt"

# Run findomain
echo "Running findomain..."
findomain -t $domain_name | grep -E '^[a-zA-Z0-9.-]+$' > findomain_output.txt
echo "Findomain scan completed. Output saved to findomain_output.txt"

# Run crt.sh
echo "Running crt.sh..."
curl "https://crt.sh/?q=%.$domain_name&output=json" | jq -r '.[].name_value' | grep -v '*' | sort | uniq >> crtsh_output.txt
echo "crt.sh scan completed. Output saved to crtsh_output.txt"

# Run assetfinder
echo "Running assetfinder..."
assetfinder --subs-only $domain_name >> assetfinder_output.txt
echo "Assetfinder scan completed. Output saved to assetfinder_output.txt"

# Run Amass
#echo "Running Amass..."
#amass_output=$(amass enum -d $domain_name)
#echo "$amass_output" | grep -oE '[a-zA-Z0-9._-]+\.' $domain_name | sort -u >> amass_output.txt
#echo "Amass scan completed. Output saved to amass_output.txt"

# Combine the outputs and remove duplicates
echo "Combining the outputs and removing duplicates..."
cat puredns_output.txt subfinder_output.txt findomain_output.txt crtsh_output.txt assetfinder_output.txt | sort -u > subdomains.txt
echo "Combined output saved to subdomains.txt"

#python3 /path/to/katana.py -u $domain_name -d m -o - | grep -oE 'https?://[a-zA-Z0-9./_-]+' > katana_output.txt


# Run Katana
echo "Running Katana..."
katana -u subdomains.txt -d 5 | grep -oE 'https?://[a-zA-Z0-9./_-]+' > katana_output.txt
echo "Katana scan completed. Output saved to katana_output.txt"

# Run ParamSpider
echo "Running ParamSpider..."
paramspider --domain "$domain_name" -p " " && cat results/$domain_name.txt | grep -oE 'https?://[^ ]+' > paramspider_output.txt
#paramspider --domain $domain_name -p " " |  grep -oE 'https?://[^ ]+' > paramspider_output.txt
echo "ParamSpider scan completed. Output saved to paramspider_output directory"

# Run waybackurls on the domain
echo "Running waybackurls on $domain_name..."
waybackurls $domain_name | tee -a waybackurls_output.txt
echo "Output saved to waybackurls_output.txt"

# Run waymore on the domain
echo "Running waymore on $domain_name..."
waymore -i $domain_name -oU waymore_output.txt
echo "Output saved to waymore_output.txt"

# Run gau on the domain (uncomment if you want to)
#echo "Running gau on $domain_name..."
#gau $domain_name | tee -a gau_output.txt
#echo "Output saved to gau_output.txt"

# Combine the outputs and remove duplicates
echo "Combining the outputs and removing duplicates..."
cat waybackurls_output.txt waymore_output.txt  | sort -u > ww.txt
echo "Combined output saved to ww.txt"

# Define keywords for specific file extensions
extensions=(".js" ".json" ".sql" ".zip" ".txt" ".php" ".aspx" ".env")

# Create ext.txt file to save extensions
> ext.txt

# Loop through each extension and grep the lines containing it from ww.txt
for ext in "${extensions[@]}"; do
    echo "Extracting lines containing extension: $ext"
    grep -i "$ext" ww.txt >> ext.txt
    echo "Lines containing extension saved to ext.txt"
done

# Define keywords for databug
keywords=("redirect=" "redir=" "uri=" ".zip" ".sql" "uuid=" "id=" "refer=" "token=" "verification" "source=" "example=" "sample=" "test=" "users" "password" "jwt" "code" "verification_code" "=false" "=true" "private" "username" "debug" "file=" "path=" "target=" "tar.gz" ".pdf" "return_to=" "apikey" ".js")

# Create a directory to save files
mkdir -p databug

# Loop through each keyword and grep the lines containing it from ww.txt
for keyword in "${keywords[@]}"; do
    echo "Extracting lines containing keyword: $keyword"
    grep -i "$keyword" ww.txt > "databug/$keyword.txt"
    echo "Lines containing keyword saved to databug/$keyword.txt"
done

# Run Shodan to search for IPs
echo -e "[INFO] Starting scan for IPs..."
shodan search "hostname:$domain_name" 200 --limit 1000 --fields ip_str | tee IPs.txt
echo -e "[INFO] All IPs are saved in file: IPs.txt"

# Extract IPs from IPs.txt
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" IPs.txt > forRust.txt

# Run Rustscan to scan for open ports
echo -e "[INFO] Scanning for open ports..."
rustscan -a 'forRust.txt' -r 1-65535 --ulimit 5000 --scripts none | tee rustscanRes.txt
echo -e "[INFO] Open ports scanned and results saved in rustscanRes.txt"

# Run Nuclei on rustscanRes.txt
echo -e "[INFO] Running Nuclei on Rustscan results..."
nuclei -l rustscanRes.txt -t /home/xgod/nuclei-templates | tee NucleiResults.txt
echo -e "[INFO] Nuclei scan completed and results saved in NucleiResults.txt"

# Combine rustscanRes.txt and sub2.txt
echo "Combining rustscanRes.txt and sub2.txt..."
cat rustscanRes.txt sub2.txt | sort -u > rawf.txt
echo "Combined output saved to rawf.txt"

# Use httpx to find URLs returning 404
echo "Finding URLs with 404 status code using httpx..."
httpx -l subdomains.txt  -mc 404 | tee 404_urls.txt
echo "URLs with 404 status code saved to 404_urls.txt"

# Fuzz URLs with ffuf and save output to ffuf1.txt
echo "Fuzzing URLs with ffuf and saving output to ffuf1.txt..."
cat 404_urls.txt | xargs -I@ sh -c 'ffuf -w /home/xgod/THEX/404.txt -u @/FUZZ -mc 200' > ffuf1.txt
echo "Fuzzing completed and output saved to ffuf1.txt"

# Extract URLs from ffuf1.txt and save output to extracted_urls.txt
echo "Extracting URLs from ffuf1.txt and saving to extracted_urls.txt..."
grep -oE 'https?://[^"]+' ffuf1.txt > extracted_urls.txt
echo "URLs extracted and saved to extracted_urls.txt"

# Fuzz URLs from extracted_urls.txt with ffuf and save output to ffuf1.txt
echo "Fuzzing URLs from extracted_urls.txt with ffuf and saving output to ffuf1.txt..."
cat extracted_urls.txt | xargs -I@ sh -c 'ffuf -w /home/xgod/THEX/404.txt -u @/FUZZ -mc 200' > ffuf2.txt
echo "Fuzzing completed and output saved to ffuf2.txt"

# Use httpx to find URLs returning 403 status code
echo "Finding URLs with 403 status code using httpx..."
httpx -l subdomains.txt  -mc 403 | tee 403_urls.txt
echo "URLs with 403 status code saved to 403_urls.txt"

# Fuzz URLs with ffuf and save output to ffuf_403.txt
echo "Fuzzing URLs with 403 status code using ffuf and saving output to ffuf_403.txt..."
cat 403_urls.txt | xargs -I@ sh -c 'ffuf -w /home/xgod/THEX/403.txt -u @/FUZZ -mc 200' > ffuf_403.txt
echo "Fuzzing completed and output saved to ffuf_403.txt"

# Extract URLs from ffuf_403.txt and save output to extracted_403_urls.txt
echo "Extracting URLs from ffuf_403.txt and saving to extracted_403_urls.txt..."
grep -oE 'https?://[^"]+' ffuf_403.txt > extracted_403_urls.txt
echo "URLs extracted and saved to extracted_403_urls.txt"

# Fuzz URLs from extracted_403_urls.txt with ffuf and save output to ffuf2_403.txt
echo "Fuzzing URLs from extracted_403_urls.txt with ffuf and saving output to ffuf2_403.txt..."
cat extracted_403_urls.txt | xargs -I@ sh -c 'ffuf -w /home/xgod/THEX/403.txt -u @/FUZZ -mc 200' > ffuf2_403.txt
echo "Fuzzing completed and output saved to ffuf2_403.txt"

# Merge ffuf2_403.txt and ffuf2.txt and save to merged_ffuf.txt
echo "Merging ffuf2_403.txt and ffuf2.txt..."
cat ffuf2_403.txt ffuf2.txt > merged_ffuf.txt

# Extract URLs and remove duplicates
echo "Extracting URLs from merged_ffuf.txt and removing duplicates..."
grep -oE 'https?://[^"]+' merged_ffuf.txt | sort -u > sorted-fffuf.txt
echo "URLs extracted and duplicates removed. Output saved to sorted-fffuf.txt"

# Fuzz URLs from sorted-fffuf.txt with ffuf and save output to ffuf_sorted.txt
echo "Fuzzing URLs from sorted-fffuf.txt with ffuf and saving output to ffuf_sorted.txt..."
cat sorted-fffuf.txt | xargs -I@ sh -c 'ffuf -w /home/xgod/THEX/wordlists/extensoon.txt -u @/FUZZ -mc 200' > ffuf_sorted.txt
echo "Fuzzing completed and output saved to ffuf_sorted.txt"

# Combine ww.txt, Katana output, and paramspider output into rawparams.txt
echo "Combining ww.txt, Katana output, and paramspider output into rawparams.txt..."
cat ww.txt katana_output.txt paramspider_output.txt > rawparams.txt
echo "Combined output saved to rawparams.txt"

# Use uro tool on rawparams.txt
echo "Running uro tool on rawparams.txt..."
uro -i rawparams.txt -o uro_output.txt
echo "uro tool completed. Output saved to uro_output.txt"

# Use crlfuzz on uro_output.txt and save output to crlfuzz_output.txt
echo "Running crlfuzz on uro_output.txt..."
crlfuzz -l uro_output.txt -silent -o crlfuzz_output.txt
echo "crlfuzz completed. Output saved to crlfuzz_output.txt"

# Filter crlfuzz_output.txt for 200 OK responses and save to crlf-200.txt
echo "Filtering 200 OK responses from crlfuzz_output.txt..."
grep -E 'HTTP/1.1 200 OK' crlfuzz_output.txt > crlf-200.txt
echo "Filtered output saved to crlf-200.txt"

# Run corsy on URLs containing password parameter CORS DETECTOR
grep -oE 'http[s]?://[^ ]*\?.*password.*' ww.txt > forcorsy.txt && corsy -i forcorsy.txt > corsy_output.txt


# Use httpx on sub2.txt and save alive URLs to httpx_output.txt
httpx -l rawf.txt -o httpx_output.txt

# Use httprobe on sub2.txt and save alive URLs to httprobe_output.txt
httprobe -c 50 -t 3000 -l rawf.txt -o httprobe_output.txt

# Combine the output files and remove duplicates to create alive.txt
cat httpx_output.txt httprobe_output.txt | sort -u > alive.txt


# Set the output file name
output_file="xsstrike.txt"

# Read URLs from uro_output.txt line by line and run XSStrike on each URL
while IFS= read -r url; do
    xsstrike -u "$url" | tee -a "$output_file"
done < uro_output.txt

# Set the output file name
output_file="kxss_output.txt"

# Read URLs from uro_output.txt line by line and run kxss on each URL
while IFS= read -r url; do
    echo "$url" | kxss | tee -a "$output_file"
done < uro_output.txt

# Iterate through each URL in ext.txt and run headi tool, saving all output to headi.txt
while read -r url; do
    headi -u "$url"
done < ext.txt > headi.txt

# Pipe the content of rawparams.txt to openredirex.py, providing it with payloads from payloads.txt,
# using "FUZZ" as the placeholder for the payload insertion, and setting the concurrency level to 50.
cat paramspider_output.txt | openredirex -p /home/xgod/tools/openredirex/payloads.txt -k "FUZZ" -c 50 > openredirex.txt


# Loop through each URL in alive.txt and run xsscrapy
while read -r url; do
    ./xsscrapy.py -u "$url"
done < alive.txt > xsscrapy.txt

echo "xsscrapy scans completed. Output saved in xsscrapy.txt"

# Run Nuclei tool to scan alive URLs from ext.txt
nuclei -l alive.txt -t /home/xgod/nuclei-templates/ -o nuke1.txt


# Grep for specific keywords in nuke1.txt and extract only URLs AMAZON 
grep -iE 'wordpress' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > wordpress_urls.txt
grep -iE 'aem' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > aem_urls.txt
grep -iE 'nginx' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > nginx_urls.txt
grep -iE 'cloudflare' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > cloudflare_urls.txt
grep -iE 'akamai' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > akamai_urls.txt
grep -iE 'amazon' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > amazon_urls.txt
grep -iE 'cisco' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > cisco_urls.txt
grep -iE 'jira' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > jira_urls.txt
grep -iE 'jenkins' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > jenkins_urls.txt
grep -iE 'contentful' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > contentful_urls.txt
grep -iE 'hubspot' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > hubspot_urls.txt
grep -iE 'apache' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > apache_urls.txt
grep -iE 'drupal' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > drupal_urls.txt
grep -iE 'phpmyadmin' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > phpmyadmin_urls.txt
grep -iE 'grafana' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > grafana_urls.txt
grep -iE 'graphql' nuke1.txt | grep -oE 'https?://[^[:space:]]+' > graphql_urls.txt



# Fuzzing WordPress URLs
cat wordpress_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/wordpressxx.txt -u @/FUZZ -mc 200' > ffuf_wordpress.txt

# Fuzzing AEM URLs
cat aem_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/aemx -u @/FUZZ -mc 200' > ffuf_aem.txt

# Fuzzing Nginx URLs
cat nginx_urls.txt | xargs -I@ sh -c 'ffuf -w  home/xgod/THEX/wordlists/ngnixx -u @/FUZZ -mc 200' > ffuf_nginx.txt

# Fuzzing Cloudflare URLs
cat cloudflare_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/cloudflarex -u @/FUZZ -mc 200' > ffuf_cloudflare.txt

# Fuzzing Akamai URLs
cat akamai_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/akamaix -u @/FUZZ -mc 200' > ffuf_akamai.txt

# Cisco
cat cisco_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/ciscox -u @/FUZZ -mc 200' > ffuf_cisco.txt

# Jira
cat jira_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/jira -u @/FUZZ -mc 200' > ffuf_jira.txt

# Jira
cat amazon_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/amzx -u @/FUZZ -mc 200' > ffuf_amazon.txt

# Jenkins
cat jenkins_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/jen -u @/FUZZ -mc 200' > ffuf_jenkins.txt

# Contentful
cat contentful_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/contentfulx -u @/FUZZ -mc 200' > ffuf_contentful.txt

# Hubspot
cat hubspot_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/allllx -u @/FUZZ -mc 200' > ffuf_hubspot.txt

# Apache
cat apache_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/apachex -u @/FUZZ -mc 200' > ffuf_apache.txt

# Drupal
cat drupal_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/allllx -u @/FUZZ -mc 200' > ffuf_drupal.txt

# PhpMyAdmin
cat phpmyadmin_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/phpmyx -u @/FUZZ -mc 200' > ffuf_phpmyadmin.txt

# Grafana
cat grafana_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/allllx -u @/FUZZ -mc 200' > ffuf_grafana.txt

# GraphQL
cat graphql_urls.txt | xargs -I@ sh -c 'ffuf -w home/xgod/THEX/wordlists/graphqlx -u @/FUZZ -mc 200' > ffuf_graphql.txt

# Define the VPS hostname or IP address
vps_host="http://canarytokens.com/static/terms/feedback/wspnz8cnjvb3g83028wqojtqr/index.html"

# Temporary file to store individual scan outputs
temp_file="aem_hacker_temp_output.txt"

# Iterate over each URL in aem_urls.txt
while IFS= read -r url; do
    echo "Running AEM Hacker on $url..."
    python3 /home/xgod/tools/aem-hacker/aem_hacker.py -u "$url" --host "$vps_host" >> "$temp_file"
    echo "AEM Hacker scan completed for $url"
done < aem_urls.txt

# Combine all temporary files into a single output file
cat "$temp_file" > aemhacker-out.txt

# Remove the temporary file
rm "$temp_file"


# Run Nuclei ext.txt
echo -e "Running Nuclei on ext.txt..."
nuclei -l ext.txt -t /home/xgod/nuclei-templates/http/exposures | tee ExposeX
echo -e "Nuclei scan completed and results saved in ExposeX"


# CLoud_enum 
