#!/bin/bash
set -euo pipefail

# Arguments
DMG_PATH="$1"
DMG_URL="$2"
SHORT_VERSION="$3"
BUILD_NUMBER="$4"
SIGNATURE="$5"

DMG_SIZE=$(stat -f%z "$DMG_PATH")
PUB_DATE=$(date -u "+%a, %d %b %Y %H:%M:%S %z")

ED_SIGNATURE_LINE=""
if [ -n "$SIGNATURE" ]; then
  ED_SIGNATURE_LINE="      sparkle:edSignature=\"$SIGNATURE\""
fi

cat > appcast.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Clipboard Manager Updates</title>
    <item>
      <title>Version ${SHORT_VERSION}</title>
      <pubDate>${PUB_DATE}</pubDate>
      <enclosure
        url="${DMG_URL}"
        sparkle:os="macos"
        sparkle:version="${BUILD_NUMBER}"
        sparkle:shortVersionString="${SHORT_VERSION}"
${ED_SIGNATURE_LINE}
        length="${DMG_SIZE}"
        type="application/octet-stream"/>
    </item>
  </channel>
</rss>
EOF