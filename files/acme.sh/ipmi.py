#!/usr/bin/env python3

# vim: autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 filetype=python

# This file is part of Supermicro IPMI certificate updater.
# Supermicro IPMI certificate updater is free software: you can
# redistribute it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright (c) Jari Turkia


import os
import argparse
import requests
import logging
from datetime import datetime
from lxml import etree
from urllib.parse import urlparse

REQUEST_TIMEOUT = 5.0

LOGIN_URL = '%s/cgi/login.cgi'
IPMI_CERT_INFO_URL = '%s/cgi/ipmi.cgi'
UPLOAD_CERT_URL = '%s/cgi/upload_ssl.cgi'
REBOOT_IPMI_URL = '%s/cgi/BMCReset.cgi'
CONFIG_CERT_URL = '%s/cgi/url_redirect.cgi?url_name=config_ssl'


def login(session, url, username, password):
    """
    Log into IPMI interface
    :param session: Current session object
    :type session requests.session
    :param url: base-URL to IPMI
    :param username: username to use for logging in
    :param password: password to use for logging in
    :return: bool
    """
    login_data = {
        'name': username,
        'pwd': password
    }

    login_url = LOGIN_URL % url
    try:
        result = session.post(login_url, login_data, timeout=REQUEST_TIMEOUT, verify=False)
    except ConnectionError:
        return False
    if not result.ok:
        return False
    if '/cgi/url_redirect.cgi?url_name=mainmenu' not in result.text:
        return False

    return True


def get_ipmi_cert_info(session, url):
    """
    Verify existing certificate information
    :param session: Current session object
    :type session requests.session
    :param url: base-URL to IPMI
    :return: dict
    """
    timestamp = datetime.utcnow().strftime('%a %d %b %Y %H:%M:%S GMT')

    cert_info_data = {
        'SSL_STATUS.XML': '(0,0)',
        'time_stamp': timestamp  # 'Thu Jul 12 2018 19:52:48 GMT+0300 (FLE Daylight Time)'
    }

    #for cookie in session.cookies:
    #    print(cookie)
    ipmi_info_url = IPMI_CERT_INFO_URL % url
    try:
        result = session.post(ipmi_info_url, cert_info_data, timeout=REQUEST_TIMEOUT, verify=False)
    except ConnectionError:
        return False
    if not result.ok:
        return False

    root = etree.fromstring(result.text)
    # <?xml> <IPMI> <SSL_INFO> <STATUS>
    status = root.xpath('//IPMI/SSL_INFO/STATUS')
    if not status:
        return False
    # Since xpath will return a list, just pick the first one from it.
    status = status[0]
    has_cert = int(status.get('CERT_EXIST'))
    has_cert = bool(has_cert)
    if has_cert:
        valid_from = status.get('VALID_FROM')
        valid_until = status.get('VALID_UNTIL')

    return {
        'has_cert': has_cert,
        'valid_from': valid_from,
        'valid_until': valid_until
    }

def get_ipmi_cert_valid(session, url):
    """
    Verify existing certificate information
    :param session: Current session object
    :type session requests.session
    :param url: base-URL to IPMI
    :return: bool
    """
    timestamp = datetime.utcnow().strftime('%a %d %b %Y %H:%M:%S GMT')

    cert_info_data = {
        'SSL_VALIDATE.XML': '(0,0)',
        'time_stamp': timestamp  # 'Thu Jul 12 2018 19:52:48 GMT+0300 (FLE Daylight Time)'
    }

    #for cookie in session.cookies:
    #    print(cookie)
    ipmi_info_url = IPMI_CERT_INFO_URL % url
    try:
        result = session.post(ipmi_info_url, cert_info_data, timeout=REQUEST_TIMEOUT, verify=False)
    except ConnectionError:
        return False
    if not result.ok:
        return False

    root = etree.fromstring(result.text)
    # <?xml> <IPMI> <SSL_INFO>
    status = root.xpath('//IPMI/SSL_INFO')
    if not status:
        return False
    # Since xpath will return a list, just pick the first one from it.
    status = status[0]
    valid_cert = int(status.get('VALIDATE'))
    return bool(valid_cert)

def upload_cert(session, url, key_file, cert_file):
    """
    Send X.509 certificate and private key to server
    :param session: Current session object
    :type session requests.session
    :param url: base-URL to IPMI
    :param key_file: filename to X.509 certificate private key
    :param cert_file: filename to X.509 certificate PEM
    :return:
    """
    with open(key_file, 'rb') as filehandle:
        key_data = filehandle.read()
    with open(cert_file, 'rb') as filehandle:
        cert_data = filehandle.read()
    files_to_upload = [
        ('/tmp/cert.pem', ('cert.pem', cert_data, 'application/octet-stream')),
        ('/tmp/key.pem', ('key.pem', key_data, 'application/octet-stream'))
    ]

    upload_cert_url = UPLOAD_CERT_URL % url
    try:
        result = session.post(upload_cert_url, files=files_to_upload, timeout=REQUEST_TIMEOUT, verify=False)
    except ConnectionError:
        return False
    if not result.ok:
        return False

    if 'Content-Type' not in result.headers.keys() or result.headers['Content-Type'] != 'text/html':
        # On failure, Content-Type will be 'text/plain' and 'Transfer-Encoding' is 'chunked'
        return False
    if 'CONFPAGE_RESET' not in result.text:
        return False
    return True


def reboot_ipmi(session, url):
    timestamp = datetime.utcnow().strftime('%a %d %b %Y %H:%M:%S GMT')

    reboot_data = {
        'time_stamp': timestamp  # 'Thu Jul 12 2018 19:52:48 GMT+0300 (FLE Daylight Time)'
    }

    upload_cert_url = REBOOT_IPMI_URL % url
    try:
        result = session.post(upload_cert_url, reboot_data, timeout=REQUEST_TIMEOUT, verify=False)
    except ConnectionError:
        return False
    if not result.ok:
        return False

    #print("Url: %s" % upload_cert_url)
    #print(result.headers)
    #print(result.text)
    if '<STATE CODE="OK"/>' not in result.text:
        return False

    return True


def main():
    parser = argparse.ArgumentParser(description='Update Supermicro IPMI SSL certificate')
    parser.add_argument('--ipmi-url', required=True,
                        help='Supermicro IPMI 2.0 URL')
    parser.add_argument('--key-file', required=True,
                        help='X.509 Private key filename')
    parser.add_argument('--cert-file', required=True,
                        help='X.509 Certificate filename')
    parser.add_argument('--username', required=True,
                        help='IPMI username with admin access')
    parser.add_argument('--password', required=True,
                        help='IPMI user password')
    parser.add_argument('--no-reboot', action='store_true',
                        help='The default is to reboot the IPMI after upload for the change to take effect.')
    parser.add_argument('--quiet', action='store_true',
                        help='Do not output anything if successful')
    args = parser.parse_args()

    # Confirm args
    if not os.path.isfile(args.key_file):
        print("--key-file '%s' doesn't exist!" % args.key_file)
        exit(2)
    if not os.path.isfile(args.cert_file):
        print("--cert-file '%s' doesn't exist!" % args.cert_file)
        exit(2)
    if args.ipmi_url[-1] == '/':
        args.ipmi_url = args.ipmi_url[0:-1]

    if not args.quiet:
        # Enable reuest logging
        logging.basicConfig()
        logging.getLogger().setLevel(logging.DEBUG)
        requests_log = logging.getLogger("requests.packages.urllib3")
        requests_log.setLevel(logging.DEBUG)
        requests_log.propagate = True

    # Start the operation
    requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)
    session = requests.session()
    if not login(session, args.ipmi_url, args.username, args.password):
        print("Login failed. Cannot continue!")
        exit(2)


    # Set mandatory cookies:
    url_parts = urlparse(args.ipmi_url)
    # Cookie: langSetFlag=0; language=English; SID=<dynamic session ID here!>; mainpage=configuration; subpage=config_ssl
    mandatory_cookies = {
        'langSetFlag': '0',
        'language': 'English',
        'mainpage': 'configuration',
        'subpage': 'config_ssl'
    }
    for cookie_name, cookie_value in mandatory_cookies.items():
        session.cookies.set(cookie_name, cookie_value, domain=url_parts.hostname)

    cert_info = get_ipmi_cert_info(session, args.ipmi_url)
    if not cert_info:
        print("Failed to extract certificate information from IPMI!")
        exit(2)
    if not args.quiet and cert_info['has_cert']:
        print("There exists a certificate, which is valid until: %s" % cert_info['valid_until'])

    # Go upload!
    if not upload_cert(session, args.ipmi_url, args.key_file, args.cert_file):
        print("Failed to upload X.509 files to IPMI!")
        exit(2)

    cert_valid = get_ipmi_cert_valid(session, args.ipmi_url)
    if not cert_valid:
        print("Uploads failed validation")
        exit(2)

    if not args.quiet:
        print("Uploaded files ok.")

    cert_info = get_ipmi_cert_info(session, args.ipmi_url)
    if not cert_info:
        print("Failed to extract certificate information from IPMI!")
        exit(2)
    if not args.quiet and cert_info['has_cert']:
        print("After upload, there exists a certificate, which is valid until: %s" % cert_info['valid_until'])

    if not args.no_reboot:
        if not args.quiet:
            print("Rebooting IPMI to apply changes.")
        if not reboot_ipmi(session, args.ipmi_url):
            print("Rebooting failed! Go reboot it manually?")

    if not args.quiet:
        print("All done!")


if __name__ == "__main__":
    main()
