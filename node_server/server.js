const express = require('express');
const cookieParser = require('cookie-parser');
const { exec } = require('child_process');
const path = require('path');

const app = express();
app.use(express.json());
app.use(cookieParser());


// Helper functions
function encodeSession(sessionObj) {
  return Buffer.from(JSON.stringify(sessionObj)).toString('base64');
}

function decodeSession(sessionStr) {
  try {
    return JSON.parse(Buffer.from(sessionStr, 'base64').toString('utf-8'));
  } catch (e) {
    return null;
  }
}

function getSession(req) {
  const sessionCookie = req.cookies.secure_session_data;
  if (!sessionCookie) return null;
  return decodeSession(sessionCookie);
}

// Routes
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});


app.get('/api/session', (req, res) => {
  const session = getSession(req);
  res.json({
    logged_in: !!session,
    user: session || null
  });
});


app.post('/api/login', (req, res) => {
  const session = { id: 105, role: 'dev' };
  const encoded = encodeSession(session);
  
  res.cookie('secure_session_data', encoded);
    res.json({ success: true, message: 'Logged in as dev' });
});

app.post('/api/logout', (req, res) => {
  res.clearCookie('secure_session_data');
  res.json({ success: true, message: 'Logged out' });
});

// Command Injection (RCE)
app.post('/api/admin/network-test', (req, res) => {
    if (!req.cookies.secure_session_data) {
        return res.status(401).send("No session found.");
    }

    try {
        const session = JSON.parse(Buffer.from(req.cookies.secure_session_data, 'base64').toString());
        if (session.role !== 'admin') {
            return res.status(403).send("Unauthorized: Only Admins can run network tests.");
        }

        const host = req.body.host;
        exec(`ping -c 1 ${host}`, (err, stdout, stderr) => {
            res.send(stdout || stderr);
        });
    } catch (e) {
        res.status(400).send("Invalid session data.");
    }
});

app.listen(3000, '0.0.0.0', () => console.log('Running on http://0.0.0.0:3000'));
