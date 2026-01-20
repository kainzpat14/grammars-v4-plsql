#!/usr/bin/env python3
"""Fast multi-threaded HTTP/HTTPS proxy with CONNECT support"""
import os
import sys
import socket
import select
import urllib.parse
import base64
from http.server import HTTPServer, BaseHTTPRequestHandler
from socketserver import ThreadingMixIn
import threading

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """HTTP Server that handles each request in a new thread"""
    daemon_threads = True
    allow_reuse_address = True

class FastProxyHandler(BaseHTTPRequestHandler):
    timeout = 30

    def do_CONNECT(self):
        """Handle CONNECT for HTTPS tunneling"""
        try:
            host, port = self.path.split(':')
            port = int(port)

            # Get proxy from environment
            proxy_url = os.environ.get('HTTPS_PROXY') or os.environ.get('HTTP_PROXY')
            if not proxy_url:
                self.send_error(502, "No proxy in environment")
                return

            parsed = urllib.parse.urlparse(proxy_url)

            # Connect to upstream proxy
            proxy_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            proxy_sock.settimeout(30)
            proxy_sock.connect((parsed.hostname, parsed.port))

            # Send CONNECT with Basic auth
            connect_req = f"CONNECT {host}:{port} HTTP/1.1\r\n"
            connect_req += f"Host: {host}:{port}\r\n"

            if parsed.username and parsed.password:
                cred = f"{parsed.username}:{parsed.password}"
                b64 = base64.b64encode(cred.encode()).decode()
                connect_req += f"Proxy-Authorization: Basic {b64}\r\n"

            connect_req += "\r\n"
            proxy_sock.sendall(connect_req.encode())

            # Read response
            resp = b""
            while b"\r\n\r\n" not in resp:
                chunk = proxy_sock.recv(4096)
                if not chunk:
                    break
                resp += chunk

            if b'200' not in resp.split(b'\r\n')[0]:
                self.send_error(502, f"Proxy CONNECT failed")
                proxy_sock.close()
                return

            # Send success to client
            self.send_response(200, 'Connection Established')
            self.end_headers()

            # Tunnel data bidirectionally
            self._tunnel(self.connection, proxy_sock)

        except Exception as e:
            print(f"CONNECT error: {e}", file=sys.stderr, flush=True)

    def _tunnel(self, client, remote):
        """Bidirectional tunnel using select"""
        sockets = [client, remote]
        try:
            while True:
                r, _, x = select.select(sockets, [], sockets, 60)

                if x or not r:
                    break

                for sock in r:
                    data = sock.recv(8192)
                    if not data:
                        return

                    other = remote if sock == client else client
                    other.sendall(data)
        except:
            pass
        finally:
            try:
                remote.close()
            except:
                pass

    def log_message(self, fmt, *args):
        # Minimal logging
        pass

def main():
    port = 18080
    print(f"Starting fast threaded proxy on localhost:{port}", flush=True)
    server = ThreadedHTTPServer(('127.0.0.1', port), FastProxyHandler)
    print("Ready to accept connections", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down")
        server.shutdown()

if __name__ == '__main__':
    main()
