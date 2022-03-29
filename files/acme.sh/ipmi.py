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
import re
import requests
import logging
from base64 import b64encode
from datetime import datetime
from lxml import etree
from urllib.parse import urlparse
from requests.auth import HTTPBasicAuth

REQUEST_TIMEOUT = 5.0

class IPMIUpdater:
    def __init__(self, session, ipmi_url):
        self.session = session
        self.ipmi_url = ipmi_url

        self.login_url = f'{ipmi_url}/cgi/login.cgi'
        self.cert_info_url = f'{ipmi_url}/cgi/ipmi.cgi'
        self.upload_cert_url = f'{ipmi_url}/cgi/upload_ssl.cgi'
        self.url_redirect_template = f'{ipmi_url}/cgi/url_redirect.cgi?url_name=%s'

        self.use_b64encoded_login = True

        self._csrf_token = None

        error_log = logging.getLogger("IPMIUpdater")
        error_log.setLevel(logging.ERROR)
        self.setLogger(error_log)

    def setLogger(self, logger):
        self.logger = logger

    def get_csrf_token(self, url_name):
        if self._csrf_token is not None:
            return self._csrf_token

        page_url = self.url_redirect_template % url_name
        result = self.session.get(page_url)
        result.raise_for_status()

        match = re.search(r'SmcCsrfInsert\s*\("CSRF_TOKEN",\s*"([^"]*)"\);', result.text)
        if match:
            return match.group(1)

    def get_csrf_headers(self, url_name):
        page_url = self.url_redirect_template % url_name

        headers = {
            "Origin": self.ipmi_url,
            "Referer": page_url,
        }
        csrf_token = self.get_csrf_token(url_name)
        if csrf_token is not None:
            headers["CSRF_TOKEN"] = csrf_token

        self.logger.debug("HEADERS:%s" % headers)
        return headers

    def get_xhr_headers(self, url_name):
        headers = self.get_csrf_headers(url_name)
        headers["X-Requested-With"] = "XMLHttpRequest"
        return headers

    def login(self, username, password):
        """
        Log into IPMI interface
        :param username: username to use for logging in
        :param password: password to use for logging in
        :return: bool
        """
        if self.use_b64encoded_login:
            login_data = {
                'name': b64encode(username.encode("UTF-8")),
                'pwd': b64encode(password.encode("UTF-8")),
                'check': '00'
            }
        else:
            login_data = {
                'name': username,
                'pwd': password
            }

        try:
            result = self.session.post(self.login_url, login_data, timeout=REQUEST_TIMEOUT, verify=False)
        except ConnectionError:
            return False
        if not result.ok:
            return False
        if '/cgi/url_redirect.cgi?url_name=mainmenu' not in result.text:
            return False

        # Set mandatory cookies:
        url_parts = urlparse(self.ipmi_url)
        # Cookie: langSetFlag=0; language=English; SID=<dynamic session ID here!>; mainpage=configuration; subpage=config_ssl
        mandatory_cookies = {
            'langSetFlag': '0',
            'language': 'English'
        }
        for cookie_name, cookie_value in mandatory_cookies.items():
            self.session.cookies.set(cookie_name, cookie_value, domain=url_parts.hostname)

        return True


    def get_ipmi_cert_info(self):
        """
        Verify existing certificate information
        :return: dict
        """

        headers = self.get_xhr_headers("config_ssl")

        cert_info_data = self._get_op_data('SSL_STATUS.XML', '(0,0)')

        try:
            result = self.session.post(self.cert_info_url, cert_info_data, headers=headers, timeout=REQUEST_TIMEOUT, verify=False)
        except ConnectionError:
            return False
        if not result.ok:
            return False

        self.logger.debug(result.text)
        root = etree.fromstring(result.text)
        # <?xml> <IPMI> <SSL_INFO> <STATUS>
        status = root.xpath('//IPMI/SSL_INFO/STATUS')
        if not status:
            return False
        # Since xpath will return a list, just pick the first one from it.
        status = status[0]
        has_cert = bool(int(status.get('CERT_EXIST')))
        if has_cert:
            valid_from = status.get('VALID_FROM')
            valid_until = status.get('VALID_UNTIL')

        return {
            'has_cert': has_cert,
            'valid_from': valid_from,
            'valid_until': valid_until
        }

    def get_ipmi_cert_valid(self):
        """
        Verify existing certificate information
        :return: bool
        """

        headers = self.get_xhr_headers("config_ssl")

        cert_info_data = self._get_op_data('SSL_VALIDATE.XML', '(0,0)')

        try:
            result = self.session.post(self.cert_info_url, cert_info_data, headers=headers, timeout=REQUEST_TIMEOUT, verify=False)
        except ConnectionError:
            return False
        if not result.ok:
            return False

        self.logger.debug(result.text)
        root = etree.fromstring(result.text)
        # <?xml> <IPMI> <SSL_INFO>
        status = root.xpath('//IPMI/SSL_INFO')
        if not status:
            return False
        # Since xpath will return a list, just pick the first one from it.
        status = status[0]
        return bool(int(status.get('VALIDATE')))

    def upload_cert(self, key_file, cert_file):
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
            # extract certificates only (IMPI doesn't like DH PARAMS)
            cert_data = b'\n'.join(re.findall(b'-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----', cert_data, re.DOTALL)) + b'\n'

        files_to_upload = self._get_upload_data(cert_data, key_data)

        headers = self.get_csrf_headers("config_ssl")
        csrf_token = self.get_csrf_token("config_ssl")
        csrf_data = {}
        if csrf_token is not None:
            csrf_data["CSRF_TOKEN"] = csrf_token

        try:
            result = self.session.post(self.upload_cert_url, csrf_data, files=files_to_upload, headers=headers, timeout=REQUEST_TIMEOUT, verify=False)
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


    def _check_reboot_result(self, result):
        return True

    def reboot_ipmi(self):
        # do we need a different Referer here?
        headers = self.get_xhr_headers("config_ssl")

        reboot_data = self._get_op_data('main_bmcreset', None)

        try:
            result = self.session.post(self.reboot_url, reboot_data, headers=headers, timeout=REQUEST_TIMEOUT, verify=False)
        except ConnectionError:
            return False
        if not result.ok:
            return False

        if not self._check_reboot_result(result):
            return False
        return True

class IPMIX10Updater(IPMIUpdater):
    def __init__(self, session, ipmi_url):
        super().__init__(session, ipmi_url)
        self.reboot_url = f'{ipmi_url}/cgi/BMCReset.cgi'
        self.use_b64encoded_login = False

    def _get_op_data(self, op, r):
        timestamp = datetime.utcnow().strftime('%a %d %b %Y %H:%M:%S GMT')

        data = {
            'time_stamp': timestamp  # 'Thu Jul 12 2018 19:52:48 GMT+0300 (FLE Daylight Time)'
        }
        if r is not None:
            data[op] = r
        return data

    def _get_upload_data(self, cert_data, key_data):
        return [
            ('cert_file', ('cert.pem', cert_data, 'application/octet-stream')),
            ('key_file', ('privkey.pem', key_data, 'application/octet-stream'))
        ]

    def _check_reboot_result(self, result):
        self.logger.debug(result.text)
        root = etree.fromstring(result.text)
        # <?xml> <IPMI> <SSL_INFO>
        status = root.xpath('//IPMI/BMC_RESET/STATE')
        if not status:
            return False
        if status[0].get('CODE') == 'OK':
            return True
        return False
        #if '<STATE CODE="OK"/>' not in result.text:
        #    return False


class IPMIX11Updater(IPMIUpdater):
    def __init__(self, session, ipmi_url):
        super().__init__(session, ipmi_url)
        self.reboot_url = f'{ipmi_url}/cgi/op.cgi'
        self.use_b64encoded_login = True

    def _get_op_data(self, op, r):
        data = {
            'op': op
        }

        if r is not None:
            data['r'] = r
        data['_'] = ''
        return data

    def _get_upload_data(self, cert_data, key_data):
        return [
            ('cert_file', ('fullchain.pem', cert_data, 'application/octet-stream')),
            ('key_file', ('privkey.pem', key_data, 'application/octet-stream'))
        ]


def create_updater(args):
    session = requests.session()

    if args.model is None:
        model = determine_model(session, args.ipmi_url, args.debug)
    else:
        model = args.model

    if not args.quiet:
        print("Board model is " + model)

    if model == "X10":
        return IPMIX10Updater(session, args.ipmi_url)
    elif model == "X11":
        return IPMIX11Updater(session, args.ipmi_url)
    else:
        raise Exception(f"Unknown model: {model}")

def determine_model(session, ipmi_url, debug):
    redfish_url = f'{ipmi_url}/redfish/v1/'

    try:
        r = session.get(redfish_url, timeout=REQUEST_TIMEOUT, verify=False)
    except (ConnectionError, requests.exceptions.SSLError) as err:
        print("Failed to determine model: connection error")
        if debug:
            print(err)
        exit(2)
    if not r.ok:
        print(f"Failed to determine model (try --model): {r.status_code} {r.reason}")
        exit(2)

    data = r.json()

    # The UpdateService methods are only available on newer X11 based boards
    if "UpdateService" in data:
        return "X11"
    else:
        return "X10"

def main():
    parser = argparse.ArgumentParser(description='Update Supermicro IPMI SSL certificate')
    parser.add_argument('--ipmi-url', required=True,
                        help='Supermicro IPMI 2.0 URL')
    parser.add_argument('--model', required=False,
                        help='Board model, eg. X10 or X11')
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
    parser.add_argument('--debug', action='store_true',
                        help='Output additional debugging')
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

    if args.debug:
        import http.client as http_client
        http_client.HTTPConnection.debuglevel = 1

        # Enable request logging
        logging.basicConfig()
        logging.getLogger().setLevel(logging.DEBUG)
        requests_log = logging.getLogger("requests.packages.urllib3")
        requests_log.setLevel(logging.DEBUG)
        requests_log.propagate = True

    # Start the operation
    requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

    updater = create_updater(args)
    if args.debug:
        debug_log = logging.getLogger("IPMIUpdater")
        debug_log.setLevel(logging.DEBUG)
        updater.setLogger(debug_log)

    if not updater.login(args.username, args.password):
        print("Login failed. Cannot continue!")
        exit(2)

    cert_info = updater.get_ipmi_cert_info()
    if not cert_info:
        print("Failed to extract certificate information from IPMI!")
        exit(2)
    if not args.quiet and cert_info['has_cert']:
        print("There exists a certificate, which is valid until: %s" % cert_info['valid_until'])

    # Go upload!
    if not updater.upload_cert(args.key_file, args.cert_file):
        print("Failed to upload X.509 files to IPMI!")
        exit(2)

    cert_valid = updater.get_ipmi_cert_valid()
    if not cert_valid:
        print("Uploads failed validation")
        exit(2)

    if not args.quiet:
        print("Uploaded files ok.")

    cert_info = updater.get_ipmi_cert_info()
    if not cert_info:
        print("Failed to extract certificate information from IPMI!")
        exit(2)
    if not args.quiet and cert_info['has_cert']:
        print("After upload, there exists a certificate, which is valid until: %s" % cert_info['valid_until'])

    if not args.no_reboot:
        if not args.quiet:
            print("Rebooting IPMI to apply changes.")
        if not updater.reboot_ipmi():
            print("Rebooting failed! Go reboot it manually?")

    if not args.quiet:
        print("All done!")


if __name__ == "__main__":
    main()
