#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import datetime
import errno
import os
import sys
import time
from splinter import Browser
from fuzzywuzzy import fuzz
import re
from urllib.parse import unquote
import html
from bs4 import BeautifulSoup

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
        self.xss_partials = []
        self.user_args = self.parse_args()
        self.browser = Browser('firefox')

    def main(self):
        """Call functions to inject XSS and test for vulnerabilities."""
        self.print_welcome_message()
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
        elif self.xss_partials:
            print(Color.YELLOW + "Partial XSS vulnerabilities were detected!" + Color.END)
            self.log_file(self.xss_partials)
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
            params[key] = payload
            injected_link = base_url + '?' + '&'.join(f'{k}={v}' for k, v in params.items() if v)

            if request_delay:
                time.sleep(float(request_delay))

            try:
                self.browser.visit(injected_link)
                self.detect_xss(payload, injected_link)
            except Exception as e:
                # print(Color.RED + f"\n[-] Exception occurred: {str(e)}" + Color.END)
                self.xss_links.append(injected_link)
                if self.user_args.SCREENSHOT_NAME:
                    self.take_screenshot(injected_link)

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
                if self.user_args.SCREENSHOT_NAME:
                    self.take_screenshot(injected_link)
                self.xss_links.append(injected_link)
                print(Color.BLUE + injected_link + Color.END)
            elif self.user_args.FUZZY_DETECTION and (partial_score := fuzz.token_set_ratio(decoded_payload, stripped_html)) >= self.user_args.FUZZY_DETECTION:
                print(Color.YELLOW + "\n[-] Partial XSS vulnerability found:" + Color.END)
                print(Color.BLUE + injected_link + Color.END)
                self.xss_partials.append(injected_link)
                print(f"Detection score: {partial_score}")
            else:
                print(Color.RED + "\n[+] No XSS detected at: \n" + Color.BLUE + injected_link + Color.END)
                if self.user_args.FUZZY_DETECTION:
                    print(f"Detection score: {partial_score}")

        except Exception as e:
            print(Color.YELLOW + "\n[+] XSS vulnerability Possible" + Color.END)
            self.xss_links.append(injected_link)
            print(Color.BLUE + injected_link + Color.END)
            if self.user_args.SCREENSHOT_NAME:
                self.take_screenshot(injected_link)

    def take_screenshot(self, injected_link):
        """Take a screenshot of the page in the browser object."""
        if not self.user_args.SCREENSHOT_NAME:
            return
        
        self.make_sure_path_exists("screenshots")
        screenshot_file_name = f"screenshots/{self.user_args.SCREENSHOT_NAME}_{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}.png"
        self.browser.driver.save_screenshot(screenshot_file_name)
        print(Color.YELLOW + "Screenshot saved: " + screenshot_file_name + Color.END)

    def test_xss(self):
        """Load strings from payload list and call function to inject them."""
        payloads = self.load_payloads(self.user_args.PAYLOADS_LIST)
        urls = []

        if self.user_args.URL:
            urls.append(self.user_args.URL)

        if self.user_args.URL_LIST:
            with open(self.user_args.URL_LIST) as url_file:
                urls.extend([line.strip() for line in url_file])

        if self.user_args.REQUEST_DELAY:
            print(Color.YELLOW + f"\n[!] Request delay is set to [{self.user_args.REQUEST_DELAY}] seconds between requests." + Color.END)

        for url in urls:
            for payload in payloads:
                print()
                self.inject_payload(payload, url, self.user_args.REQUEST_DELAY)

    def load_payloads(self, payloads_param):
        """Load the payloads from the specified file."""
        with open(payloads_param) as payload_file:
            return [line.strip() for line in payload_file]

    def load_urls(self, url_param, url_file_param):
        """Load the URLs from the specified file or single URL."""
        if url_file_param:
            with open(url_file_param) as url_file:
                return [line.strip() for line in url_file]
        else:
            return [url_param]

    def log_file(self, link_list):
        """Log successful XSS payload reflections to file."""
        log_confirm = input("\nWould you like to save these results? [y/n] > ")
        if log_confirm.lower() == "":
            target_name = "No Name"
            self.make_sure_path_exists("logs")
            file_name = f"logs/{target_name}_{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}"
            self.save_log(file_name, link_list)
            print("\nFile successfully saved as: " + Color.BLUE + file_name + Color.END)
        elif log_confirm.lower() == "y":
            target_name = input("Please enter the target name > ")
            self.make_sure_path_exists("logs")
            file_name = f"logs/{target_name}_{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}"
            self.save_log(file_name, link_list)
            print("\nFile successfully saved as: " + Color.BLUE + file_name + Color.END)
        else:
            print("\nGoodbye!\n")

    def save_log(self, file_name, link_list):
        """Save the log to the specified file."""
        with open(file_name + ".txt", 'w') as link_file:
            for link in link_list:
                link_file.write(link + "\n")
            link_file.write(f"\n*** Created from the payload file >>> {self.user_args.PAYLOADS_LIST}")
        if self.user_args.FUZZY_DETECTION:
            with open(file_name + "_partials.txt", 'w') as partial_file:
                for link in self.xss_partials:
                    partial_file.write(link + "\n")
                partial_file.write(f"\n*** Created from the payload file >>> {self.user_args.PAYLOADS_LIST}")

    def parse_args(self):
        """Parse arguments from the user sent on command line."""
        parser = argparse.ArgumentParser(description="Trikuta XSS Testing Tool")
        parser.add_argument('-u', action='store', dest='URL', help='The URL to inject XSS payloads into.')
        parser.add_argument('-p', action='store', dest='PAYLOADS_LIST', help='The payload list to use for injection.', required=True)
        parser.add_argument('-t', action='store', dest='REQUEST_DELAY', help='Amount of time (in seconds) to delay between requests.')
        parser.add_argument('-s', '--screen', action='store', dest='SCREENSHOT_NAME', help='Enable screenshots of XSS hits.')
        parser.add_argument('-f', '--fuzzy', action='store', dest='FUZZY_DETECTION', type=int, const=50, nargs="?", help='Fuzzy detection rate of XSS [0 to 100 match] (default=50).')
        parser.add_argument('-ul', '--url_list', action='store', dest='URL_LIST', help='File containing a list of URLs to test.')

        arguments = parser.parse_args()

        if not arguments.URL and not arguments.URL_LIST:
            print(Color.RED + "Please provide either a URL (-u) or a list of URLs (-ul)." + Color.END)
            parser.print_help()
            sys.exit(1)

        return arguments

if __name__ == "__main__":
    trikuta = Trikuta()
    trikuta.main()
