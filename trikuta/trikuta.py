#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import datetime
import errno
import os
import sys
import time
import traceback
from splinter import Browser
from fuzzywuzzy import fuzz


class Color:
    """Use colors to make command line output prettier."""

    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    END = "\033[0m"


class Trikuta:
    """Object for testing lists of XSS payloads."""

    def __init__(self):
        """Initiate object with default encoding and other required data."""
        self.xss_links = []
        self.xss_partials = []
        self.user_args = self.parse_args()
        self.browser = Browser("chrome")

    def main(self):
        """Call functions to inject XSS and test for vulnerabilities."""
        self.print_welcome_message()
        self.test_xss()
        self.print_summary()

    def print_welcome_message(self):
        """Print the welcome message."""
        print(
            "\n"
            + "=" * 34
            + Color.YELLOW
            + "\nWelcome to the"
            + Color.RED
            + " Trikuta "
            + Color.YELLOW
            + "XSS tool!\n"
            + Color.END
            + "=" * 34
        )

    def print_summary(self):
        """Print the summary of the testing results."""
        print(Color.GREEN + "\n=== Testing complete! ===\n" + Color.END)
        if self.xss_links:
            print(Color.YELLOW + "XSS vulnerabilities were detected!" + Color.END)
            self.log_file(self.xss_links)
        elif self.xss_partials:
            print(
                Color.YELLOW + "Partial XSS vulnerabilities were detected!" + Color.END
            )
            self.log_file(self.xss_partials)
        else:
            print(
                Color.YELLOW
                + "No potential XSS vulnerabilities detected...\n"
                + Color.END
            )
        # print("Goodbye!\n")

    def make_sure_path_exists(self, path):
        """Ensure that file path exists before writing."""
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise

    def inject_payload(self, payload, link, request_delay):
        """Inject XSS payload string from user supplied payload list."""
        injected_link = link.replace("{xss}", payload)
        if request_delay:
            time.sleep(float(request_delay))
        try:
            self.browser.visit(injected_link)
            self.detect_xss(payload, injected_link)
        except Exception as e:
            print(Color.RED + f"\n[-] Exception occurred: {str(e)}" + Color.END)
            self.xss_links.append(injected_link)
            if self.user_args.SCREENSHOT_NAME:
                self.take_screenshot(injected_link)

    def detect_xss(self, payload, injected_link):
        """Check the HTML source to determine if XSS payload was reflected."""
        try:
            partial_score = fuzz.token_set_ratio(
                payload.lower(), self.browser.html.lower()
            )
            fuzzy_level = self.user_args.FUZZY_DETECTION

            if payload.lower() in self.browser.html.lower():
                print(Color.GREEN + "\n[+] XSS vulnerability found:" + Color.END)
                if self.user_args.SCREENSHOT_NAME:
                    self.take_screenshot(injected_link)
                self.xss_links.append(injected_link)
                print(Color.BLUE + injected_link + Color.END)
            elif fuzzy_level and (partial_score >= fuzzy_level):
                print(
                    Color.YELLOW + "\n[-] Partial XSS vulnerability found:" + Color.END
                )
                print(Color.BLUE + injected_link + Color.END)
                self.xss_partials.append(injected_link)
                print(f"Detection score: {partial_score}")
            else:
                print(
                    Color.RED
                    + "\n[+] No XSS detected at: \n"
                    + Color.BLUE
                    + injected_link
                    + Color.END
                )
                if fuzzy_level:
                    print(f"Detection score: {partial_score}")

        except Exception as e:
            # print(Color.RED + f"\n[-] Exception occurred: {str(e)}" + Color.END)
            print(Color.GREEN + "\n[+] XSS vulnerability found:" + Color.END)
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
        """Load string from payload list and call function to inject it."""
        payloads = self.load_payloads(self.user_args.PAYLOADS_LIST)
        if self.user_args.REQUEST_DELAY:
            print(
                Color.YELLOW
                + f"\n[!] Request delay is set to [{self.user_args.REQUEST_DELAY}] seconds between requests."
                + Color.END
            )
        for payload in payloads:
            print()
            self.inject_payload(
                payload, self.user_args.URL, self.user_args.REQUEST_DELAY
            )

    def load_payloads(self, payloads_param):
        """Load the payloads from the specified file."""
        with open(payloads_param, encoding="utf-8", errors="ignore") as payload_file:
            return [line.strip() for line in payload_file]

    def log_file(self, link_list):
        """Log successful XSS payload reflections to file."""
        log_confirm = input("\nWould you like to save these results? [y/n] > ")
        if log_confirm.lower() == "y":
            target_name = input("Please enter the target name > ")
            self.make_sure_path_exists("logs")
            file_name = f"logs/{target_name}_{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}"
            self.save_log(file_name, link_list)
            print("\nFile successfully saved as: " + Color.BLUE + file_name + Color.END)
        else:
            print("\nGoodbye!\n")

    def save_log(self, file_name, link_list):
        """Save the log to the specified file."""
        with open(file_name + ".txt", "w") as link_file:
            for link in link_list:
                link_file.write(link + "\n")
            link_file.write(
                f"\n*** Created from the payload file >>> {self.user_args.PAYLOADS_LIST}"
            )
        if self.user_args.FUZZY_DETECTION:
            with open(file_name + "_partials.txt", "w") as partial_file:
                for link in self.xss_partials:
                    partial_file.write(link + "\n")
                partial_file.write(
                    f"\n*** Created from the payload file >>> {self.user_args.PAYLOADS_LIST}"
                )

    def parse_args(self):
        """Parse arguments from the user sent on command line."""
        parser = argparse.ArgumentParser(description="Trikuta XSS Testing Tool")
        parser.add_argument(
            "-u",
            action="store",
            dest="URL",
            help="The URL to inject XSS payloads into.",
            required=True,
        )
        parser.add_argument(
            "-p",
            action="store",
            dest="PAYLOADS_LIST",
            help="The payload list to use for injection.",
            required=True,
        )
        parser.add_argument(
            "-t",
            action="store",
            dest="REQUEST_DELAY",
            help="Amount of time (in seconds) to delay between requests.",
        )
        parser.add_argument(
            "-s",
            "--screen",
            action="store",
            dest="SCREENSHOT_NAME",
            help="Enable screenshots of XSS hits.",
        )
        parser.add_argument(
            "-f",
            "--fuzzy",
            action="store",
            dest="FUZZY_DETECTION",
            type=int,
            const=50,
            nargs="?",
            help="Fuzzy detection rate of XSS [0 to 100 match] (default=50).",
        )

        arguments = parser.parse_args()

        if "{xss}" not in arguments.URL:
            print(
                Color.RED
                + "Please provide the '{xss}' placeholder for injection point in the URL"
                + Color.END
            )
            print(
                Color.GREEN
                + 'Example: -u "http://example.com/index.php?name={xss}"'
                + Color.END
            )
            sys.exit()

        return arguments


if __name__ == "__main__":
    try:
        Trikuta().main()
    except KeyboardInterrupt:
        print(Color.YELLOW + "\nTesting interrupted by user!\n" + Color.END)
        Trikuta().log_file(Trikuta().xss_links)
        sys.exit()
