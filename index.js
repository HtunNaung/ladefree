const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const subtxt = path.join(__dirname, '.npm', 'sub.txt');
const PORT = process.env.PORT || 3000;

// Function to run start.sh if it exists
function runStartScript() {
  const scriptPath = path.join(__dirname, 'start.sh');
  if (fs.existsSync(scriptPath)) {
    fs.chmod(scriptPath, 0o755, (err) => {
      if (err) {
        console.error(`start.sh permission change failed: ${err}`);
        return;
      }
      console.log(`start.sh permission change successful`);
      const child = exec(`bash ${scriptPath}`);
      child.stdout.on('data', (data) => process.stdout.write(data));
      child.stderr.on('data', (data) => process.stderr.write(data));
      child.on('close', (code) => {
        console.log(`start.sh exited with code ${code}`);
        try { console.clear(); } catch (_) {}
        console.log(`App is running`);
      });
    });
  } else {
    console.error("start.sh file not found.");
  }
}

// Start the script
runStartScript();

// Create HTTP server
const server = http.createServer((req, res) => {
  if (req.url === '/' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Hello world!');
  }
  else if (req.url === '/sub' && req.method === 'GET') {
    fs.readFile(subtxt, 'utf8', (err, data) => {
      if (err) {
        console.error(err);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Error reading sub.txt' }));
      } else {
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(data);
      }
    });
  }
  else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');
  }
});

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
