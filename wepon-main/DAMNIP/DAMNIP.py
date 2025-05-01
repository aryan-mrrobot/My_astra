#!/usr/bin/env python
import os
import subprocess

by = "\033[96m"
bye = "\033[96;00m"
rl = "\033[31m"
rle = "\033[00m"
br = "\033[1;31m"
bre = "\033[1;00m"
blink = "\033[5m"

print("""
 ____    _    __  __ _   _ ___ ____  
|  _ \  / \  |  \/  | \ | |_ _|  _ \\ 
| | | |/ _ \ | |\/| |  \| || || |_) |
| |_| / ___ \| |  | | |\  || ||  __/ 
|____/_/   \_\_|  |_|_| \_|___|_|     
""")

if len(os.sys.argv) != 2:
    print(f"{by}[INFO] Usage: {os.sys.argv[0]} <target>{bye}")
    exit(1)

target = os.sys.argv[1]

print(f"{by}[INFO] Target: {target} {bye}\n")
print(f"{rl}[CRITICAL]{rle} {by}Configure shodan with your API key before running {bye}\n")
print(f"{by}[INFO] Starting scan for IPs {bye}")

shodan_command = f"shodan search 'hostname:{target}  200' --limit 1000 --fields ip_str"
ips_result = subprocess.run(shodan_command, shell=True, text=True, stdout=subprocess.PIPE)
with open("IPs.txt", "w") as ips_file:
    ips_file.write(ips_result.stdout)

print(f"{by}[INFO] All IPs are saved in file: IPs.txt {bye}\n")
subprocess.run(f"cat IPs.txt | grep -oE '\\b([0-9]{{1,3}}\\.){{3}}[0-9]{{1,3}}\\b' | tee forRust.txt", shell=True)

print(f"{by}[INFO] Scanning for open ports {bye}")
rustscan_command = "rustscan -a 'forRust.txt' -r 1-65535 --ulimit 5000 --scripts none"
rustscan_result = subprocess.run(rustscan_command, shell=True, text=True, stdout=subprocess.PIPE)
with open("rustscanRes.txt", "w") as rustscan_file:
    rustscan_file.write(rustscan_result.stdout)

print("\n")
subprocess.run("cat rustscanRes.txt | grep Open | tee open_ports.txt", shell=True)

print("\n")
subprocess.run("cat open_ports.txt | sed 's/Open //' | httpx -silent | tee IPUrls.txt", shell=True)

print("\n")
subprocess.run("nuclei -l IPUrls.txt -t /Users/vaidikpandya/nuclei-templates/ | tee IPNucleiResults.txt", shell=True)
