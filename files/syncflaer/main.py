"""
A webserver that does DNS lookups to dns.google
"""
import http.client
from http.server import BaseHTTPRequestHandler, HTTPServer
from os import environ
import json

HTTP_ENDPOINT = "dns.google"
HTTP_PATH = "/resolve?type=A&name=" + environ.get('HOSTNAME')

def get_dns_record():
    """Gets the response from dns.google"""
    conn = http.client.HTTPSConnection(HTTP_ENDPOINT)
    conn.request("GET", HTTP_PATH, "")
    return json.loads(conn.getresponse().read().decode("utf-8"))["Answer"][0]["data"]

class DNSLookup(BaseHTTPRequestHandler):
    """DNS Lookup"""
    def do_GET(self):
        """Get DNS record"""
        self.send_response(200)
        self.end_headers()
        self.wfile.write(bytes(get_dns_record(), "utf-8"))

if __name__ == "__main__":
    webServer = HTTPServer(("", 80), DNSLookup)
    webServer.serve_forever()
