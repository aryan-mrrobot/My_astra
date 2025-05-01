#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import errno
import os
import sys
import time
from splinter import Browser
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse, unquote
import html
from bs4 import BeautifulSoup # type: ignore

class Color:
    """Use colors to make command line output prettier."""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    END = '\033[0m'

class Trikuta:
    """Object for testing lists of XSS payloads."""

    def __init__(self):
        """Initiate object with default encoding and other required data."""
        self.xss_links = []
        self.user_args = self.parse_args()
        self.target_name = None
        self.browser = Browser("firefox")

    def main(self):
        """Call functions to inject XSS and test for vulnerabilities."""
        self.print_welcome_message()
        self.target_name = input("Please enter the target name: ")
        self.prepare_log_files()
        self.test_xss()
        self.print_summary()

    def print_welcome_message(self):
        """Print the welcome message."""
        print("\n" + "=" * 34 + Color.YELLOW + "\nWelcome to the" + Color.RED +
              " Trikuta " + Color.YELLOW + "XSS tool!\n" + Color.END + "=" * 34)

    def print_summary(self):
        """Print the summary of the testing results."""
        print(Color.GREEN + "\n=== Testing complete! ===\n" + Color.END)
        if self.xss_links:
            print(Color.YELLOW + "XSS vulnerabilities were detected!" + Color.END)
            self.log_file(self.xss_links)
        else:
            print(Color.YELLOW + "No potential XSS vulnerabilities detected...\n" + Color.END)

    def make_sure_path_exists(self, path):
        """Ensure that file path exists before writing."""
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise

    def inject_payload(self, payload, link, request_delay):
        """Inject XSS payload string from user supplied payload list."""
        if '?' in link:
            base_url, params_str = link.split('?', 1)
        else:
            base_url = link
            params_str = ''

        # Parse parameters into a dictionary
        params = {}
        for param in params_str.split('&'):
            if '=' in param:
                key, value = param.split('=', 1)
                params[key] = value
            else:
                params[param] = ''  # Handle parameters without values

        # Original parameters for reset
        original_params = params.copy()

        # Inject payload into each parameter one at a time
        for key in params:
            original_value = original_params[key]
            params[key] = original_value + payload if original_value else payload
            injected_link = base_url + '?' + '&'.join(f'{k}={v}' for k, v in params.items())

            if request_delay:
                time.sleep(float(request_delay))

            try:
                self.browser.visit(injected_link)
                self.detect_xss(payload, injected_link)
            except Exception as e:
                # print(Color.RED + f"\n[-] Exception occurred: {str(e)}" + Color.END)
                self.xss_links.append(injected_link)

            # Reset the parameter to its original value
            params[key] = original_value

    def detect_xss(self, payload, injected_link):
        """Check the HTML source to determine if XSS payload was reflected."""
        try:
            html_lower = self.browser.html.lower()
            payload_lower = payload.lower()

            # Decode common encodings (e.g., URL encoding, HTML entities)
            decoded_payload = unquote(html.unescape(payload_lower))

            # Ignore specific HTML tags and attributes
            safe_tags = ['b', 'i', 'u', 'strong', 'em', 'br', 'hr', 'p', 'span', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'table', 'tr', 'td', 'th']
            soup = BeautifulSoup(html_lower, 'html.parser')
            for tag in soup.find_all(True):
                if tag.name in safe_tags:
                    tag.decompose()

            stripped_html = str(soup)

            if decoded_payload in stripped_html:
                print(Color.GREEN + "\n[+] XSS vulnerability found:" + Color.END)
                self.xss_links.append(injected_link)
                print(Color.BLUE + injected_link + Color.END)
            else:
                print(Color.RED + "\n[+] No XSS detected at: \n" + Color.BLUE + injected_link + Color.END)

        except Exception as e:
            # print(Color.RED + f"\n[-] Exception occurred: {str(e)}" + Color.END)
            print(Color.YELLOW + "\n[+] XSS vulnerability Possible" + Color.END)
            self.xss_links.append(injected_link)
            print(Color.BLUE + injected_link + Color.END)

    def test_xss(self):
        """Load string from payload list and call function to inject it."""
        payloads = self.load_payloads(self.user_args.PAYLOADS_LIST)
        if self.user_args.REQUEST_DELAY:
            print(Color.YELLOW + f"\n[!] Request delay is set to [{self.user_args.REQUEST_DELAY}] seconds between requests." + Color.END)
        
        urls = self.load_urls(self.user_args.URL, self.user_args.URL_LIST)
        
        for url in urls:
            for payload in payloads:
                print()
                self.inject_payload(payload, url, self.user_args.REQUEST_DELAY)

    def load_payloads(self, payloads_param):
        """Load the payloads from the specified file."""
        with open(payloads_param) as payload_file:
            return [line.strip() for line in payload_file]

    def load_urls(self, single_url, url_list_file):
        """Load the URLs from the specified file or use a single URL."""
        if single_url:
            return [single_url]
        else:
            with open(url_list_file) as url_file:
                return [line.strip() for line in url_file]

    def prepare_log_files(self):
        """Prepare the log file directories."""
        self.make_sure_path_exists("results")

    def log_file(self, link_list):
        """Log successful XSS payload reflections to file."""
        file_name = f"results/{self.target_name}"
        self.save_log(file_name, link_list)
        print("\nFile successfully saved as: " + Color.BLUE + file_name + Color.END)

    def save_log(self, file_name, link_list):
        """Save the log to the specified file."""
        with open(file_name + ".txt", 'w') as link_file:
            for link in link_list:
                link_file.write(link + "\n")
            link_file.write(f"\n*** Created from the payload file >>> {self.user_args.PAYLOADS_LIST}")

    def parse_args(self):
        """Parse arguments from the user sent on command line."""
        parser = argparse.ArgumentParser(description="Trikuta XSS Testing Tool")
        parser.add_argument('-u', action='store', dest='URL', help='The URL to inject XSS payloads into.')
        parser.add_argument('-ul', action='store', dest='URL_LIST', help='The file containing multiple URLs to test.')
        parser.add_argument('-p', action='store', dest='PAYLOADS_LIST', help='The payload list to use for injection.')
        parser.add_argument('-t', action='store', dest='REQUEST_DELAY', help='Amount of time (in seconds) to delay between requests.')
        return parser.parse_args()

if __name__ == "__main__":
    try:
        Trikuta().main()
    except KeyboardInterrupt:
        print(Color.YELLOW + "\nTesting interrupted by user!\n" + Color.END)
        sys.exit()
