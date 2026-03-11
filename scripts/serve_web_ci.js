// serve_web_ci.js – Minimal static HTTP server for Godot Web export smoke tests.
// Serves build/web/ on port 8080 with the COOP + COEP headers that Godot's WASM
// build requires to enable SharedArrayBuffer (thread support).
//
// Usage (CI step):
//   node scripts/serve_web_ci.js &
//   npx wait-on http://localhost:8080
'use strict';

const http = require('http');
const fs   = require('fs');
const path = require('path');

const PORT = 8080;
const ROOT = path.join(__dirname, '..', 'build', 'web');

const MIME_TYPES = {
  '.html' : 'text/html; charset=utf-8',
  '.js'   : 'application/javascript',
  '.wasm' : 'application/wasm',
  '.pck'  : 'application/octet-stream',
  '.png'  : 'image/png',
  '.svg'  : 'image/svg+xml',
  '.ico'  : 'image/x-icon',
  '.json' : 'application/json',
};

// These headers are mandatory for Godot 4 Web exports that use threads (SharedArrayBuffer).
const SECURITY_HEADERS = {
  'Cross-Origin-Opener-Policy'   : 'same-origin',
  'Cross-Origin-Embedder-Policy' : 'require-corp',
};

const server = http.createServer((req, res) => {
  // Normalise URL – default to index.html
  let urlPath = req.url.split('?')[0];
  if (urlPath === '/') urlPath = '/index.html';

  const filePath = path.join(ROOT, urlPath);

  // Prevent directory traversal
  if (!filePath.startsWith(ROOT)) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(err.code === 'ENOENT' ? 404 : 500);
      res.end(err.code === 'ENOENT' ? 'Not Found' : 'Internal Server Error');
      return;
    }
    const ext  = path.extname(filePath).toLowerCase();
    const mime = MIME_TYPES[ext] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': mime, ...SECURITY_HEADERS });
    res.end(data);
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[serve_web_ci] Serving ${ROOT} on http://127.0.0.1:${PORT}`);
});
