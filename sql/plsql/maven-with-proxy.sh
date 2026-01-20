#!/bin/bash
# Maven wrapper script that handles proxy DNS issues in containerized environments
# This script starts a local proxy that forwards to the authenticated proxy in $HTTPS_PROXY

set -e

PROXY_PORT=18080
PROXY_PID_FILE="/tmp/maven-proxy.pid"
PROXY_LOG_FILE="/tmp/maven-proxy.log"

# Function to start the proxy
start_proxy() {
    if [ -f "$PROXY_PID_FILE" ]; then
        PID=$(cat "$PROXY_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "Proxy already running (PID: $PID)"
            return 0
        fi
    fi

    echo "Starting proxy on localhost:$PROXY_PORT..."
    python3 "$(dirname "$0")/fast_proxy.py" > "$PROXY_LOG_FILE" 2>&1 &
    PROXY_PID=$!
    echo $PROXY_PID > "$PROXY_PID_FILE"

    # Wait for proxy to be ready
    for i in {1..10}; do
        if nc -z 127.0.0.1 $PROXY_PORT 2>/dev/null || timeout 1 bash -c "echo > /dev/tcp/127.0.0.1/$PROXY_PORT" 2>/dev/null; then
            echo "Proxy started successfully (PID: $PROXY_PID)"
            return 0
        fi
        sleep 0.5
    done

    echo "Warning: Proxy may not have started properly. Check $PROXY_LOG_FILE"
}

# Function to stop the proxy
stop_proxy() {
    if [ -f "$PROXY_PID_FILE" ]; then
        PID=$(cat "$PROXY_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "Stopping proxy (PID: $PID)..."
            kill "$PID" 2>/dev/null || true
            rm -f "$PROXY_PID_FILE"
        fi
    fi
}

# Handle cleanup on exit
trap stop_proxy EXIT INT TERM

# Start the proxy
start_proxy

# Configure Maven settings if not already configured
MAVEN_SETTINGS="$HOME/.m2/settings.xml"
if [ ! -f "$MAVEN_SETTINGS" ] || ! grep -q "127.0.0.1:$PROXY_PORT" "$MAVEN_SETTINGS" 2>/dev/null; then
    echo "Configuring Maven to use local proxy..."
    mkdir -p "$(dirname "$MAVEN_SETTINGS")"
    cat > "$MAVEN_SETTINGS" << EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
  <proxies>
    <proxy>
      <id>local-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>127.0.0.1</host>
      <port>$PROXY_PORT</port>
    </proxy>
  </proxies>
</settings>
EOF
fi

# Run Maven with all arguments passed to this script
echo "Running: mvn $@"
mvn "$@"
