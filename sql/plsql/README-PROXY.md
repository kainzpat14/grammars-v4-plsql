# Maven DNS Proxy Solution

## Problem

The Maven build in `sql/plsql` fails in containerized environments with DNS resolution errors:
```
repo.maven.apache.org: Temporary failure in name resolution
```

This occurs because:
1. The container has limited DNS configuration (`/etc/resolv.conf` is empty)
2. Java's DNS resolution doesn't use the `HTTP_PROXY`/`HTTPS_PROXY` environment variables that other tools (like curl) use automatically
3. Maven requires a properly configured proxy that supports HTTPS CONNECT tunneling with authentication

## Solution

We provide two components to solve this:

### 1. `fast_proxy.py`
A multi-threaded Python proxy that:
- Listens on `localhost:18080`
- Forwards requests to the authenticated proxy from `$HTTPS_PROXY`
- Handles HTTPS CONNECT tunneling properly
- Supports concurrent connections for fast Maven downloads

### 2. `maven-with-proxy.sh`
A wrapper script that:
- Automatically starts the proxy before running Maven
- Configures Maven's `~/.m2/settings.xml` to use the local proxy
- Cleans up the proxy on exit
- Passes all arguments through to Maven

## Usage

### Option 1: Using the wrapper script (Recommended)
```bash
./maven-with-proxy.sh clean compile
./maven-with-proxy.sh test
./maven-with-proxy.sh package
```

### Option 2: Manual proxy management
```bash
# Start the proxy
python3 fast_proxy.py &
PROXY_PID=$!

# Configure Maven settings (create ~/.m2/settings.xml with proxy config)

# Run Maven
mvn clean compile

# Stop the proxy
kill $PROXY_PID
```

## Files

- `fast_proxy.py` - Multi-threaded HTTPS proxy with CONNECT support
- `maven-with-proxy.sh` - Convenience wrapper for Maven commands
- `README-PROXY.md` - This documentation

## Performance

With the threaded proxy, Maven achieves good download speeds:
- Typical: 2-5 MB/s
- Build time for `clean compile`: ~15-20 seconds

## Troubleshooting

If the build fails:
1. Check the proxy is running: `ps aux | grep fast_proxy`
2. Check the proxy log: `tail /tmp/maven-proxy.log`
3. Verify Maven settings: `cat ~/.m2/settings.xml`
4. Test proxy connectivity: `curl -x http://127.0.0.1:18080 https://repo.maven.apache.org/maven2/`
