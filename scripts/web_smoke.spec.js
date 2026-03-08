// web_smoke.spec.js – Playwright smoke test for the Godot 4 Web export.
// Verifies that the WASM build loads in Chromium, the canvas renders,
// and no fatal runtime errors are thrown.
//
// Run via: npx playwright test scripts/web_smoke.spec.js
// Requires serve_web_ci.js to be running on http://localhost:8080.
'use strict';

const { test, expect } = require('@playwright/test');

const BASE_URL = process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:8080';

// Collect all browser console errors emitted during the test.
// Godot 4 WASM prints 'abort()' or 'RuntimeError' on fatal failure.
const FATAL_PATTERNS = [/RuntimeError/, /abort\(\)/, /Uncaught Error/];

test.describe('Godot Web export smoke test', () => {

  test('canvas is visible and non-zero sized within 30 s', async ({ page }) => {
    const consoleErrors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') consoleErrors.push(msg.text());
    });
    page.on('pageerror', err => consoleErrors.push(err.message));

    await page.goto(BASE_URL, { waitUntil: 'domcontentloaded' });

    // Godot's loader injects a <canvas> element once the engine starts.
    const canvas = page.locator('canvas');
    await expect(canvas).toBeVisible({ timeout: 30_000 });

    // Allow engine to complete at least one rendered frame (Godot shows
    // the main menu scene after WASM init + scene tree _ready() calls).
    await page.waitForTimeout(5_000);

    // Canvas must occupy a meaningful screen area.
    const box = await canvas.boundingBox();
    expect(box.width,  'canvas width')  .toBeGreaterThan(100);
    expect(box.height, 'canvas height') .toBeGreaterThan(100);

    // Capture screenshot as CI artifact for visual inspection.
    await page.screenshot({
      path: 'test-results/web_smoke.png',
      fullPage: true,
    });

    // No fatal WASM / engine errors.
    const fatal = consoleErrors.filter(e =>
      FATAL_PATTERNS.some(p => p.test(e))
    );
    expect(fatal, `Fatal console errors: ${fatal.join('\n')}`).toHaveLength(0);
  });

});
