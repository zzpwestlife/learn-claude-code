#!/usr/bin/env python3
import os
import sys
import json
import urllib.request
import urllib.error

def notify(message, webhook_url=None):
    """
    Sends a notification to the specified Webhook URL.
    Supports Slack-compatible webhooks (Slack, Discord, Mattermost) and Feishu/Lark.
    """
    url = webhook_url or os.environ.get('CLAUDE_WEBHOOK_URL') or os.environ.get('SLACK_WEBHOOK_URL')
    
    if not url:
        print("⚠️  Notification skipped: CLAUDE_WEBHOOK_URL not set.")
        return False

    # Determine payload format based on URL
    if "feishu.cn" in url or "larksuite.com" in url:
        # Feishu/Lark format
        payload = {
            "msg_type": "text",
            "content": {
                "text": message
            }
        }
    else:
        # Slack/Discord format
        payload = {
            "text": message
        }
    
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )

    try:
        with urllib.request.urlopen(req) as response:
            if response.status >= 200 and response.status < 300:
                # Feishu returns 200 even on some errors, check body if possible, 
                # but for simple script checking status code is usually enough.
                # However, Feishu often returns JSON body.
                print(f"✅ Notification sent to {url.split('://')[0]}...")
                return True
            else:
                print(f"❌ Notification failed: HTTP {response.status}")
                return False
    except urllib.error.URLError as e:
        print(f"❌ Notification failed: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: notify.py <message> [webhook_url]")
        sys.exit(1)
        
    msg = sys.argv[1]
    url = sys.argv[2] if len(sys.argv) > 2 else None
    
    notify(msg, url)
