---
name: playwright-screenshots
description: Capture full-page screenshots from local or remote URLs using Playwright (sync or async API) for visual review, QA, or documentation.
---

# Playwright Screenshot Capture

Reusable workflow for taking full-page screenshots of web pages using Playwright.

## Prerequisites

- Python 3 with `playwright` package installed.
- Chromium browser binary (`python3 -m playwright install chromium`).

## Template

```python
python3 - <<'EOF'
from playwright.sync_api import sync_playwright
import time

URLS = [
    ("http://127.0.0.1:8000/", "home"),
    ("http://127.0.0.1:8000/about/", "about"),
    # Add more (url, label) pairs here
]

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={"width": 1440, "height": 900})

    for url, label in URLS:
        page.goto(url, wait_until="networkidle")
        page.wait_for_timeout(2000)  # allow JS rendering
        page.screenshot(path=f"/tmp/{label}.png", full_page=True)
        print(f"Saved /tmp/{label}.png")

    browser.close()
EOF
```

## Async variant (for complex pages with lazy loading)

```python
python3 - <<'EOF'
import asyncio
from playwright.async_api import async_playwright

URLS = [
    ("http://127.0.0.1:8000/", "home"),
]

async def capture():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={"width": 1440, "height": 900})

        for url, label in URLS:
            await page.goto(url, wait_until="networkidle")
            await page.wait_for_timeout(2000)
            await page.screenshot(path=f"/tmp/{label}.png", full_page=True)
            print(f"Saved /tmp/{label}.png")

        await browser.close()

asyncio.run(capture())
EOF
```

## Steps

1. **Ensure Playwright is available**: `which playwright || pip install playwright -q && python3 -m playwright install chromium --with-deps 2>&1 | tail -5`
2. **Start the target server** (if local): `python manage.py runserver &` or equivalent.
3. **Run the screenshot script** with the desired URLs filled in.
4. **Report results**: List saved files and their paths.

## Tips

- Use `full_page=True` for full-page captures (scrolls entire page).
- Use `viewport={"width": 1440, "height": 900}` for desktop-viewport screenshots.
- Adjust `wait_for_timeout` if pages load slowly (increase for JS-heavy sites).
- For login-required pages, use `page.fill()` and `page.click()` before screenshotting.
- Save output to `/tmp/` for easy access.

## Stopping conditions

- Script completes without error and reports saved files.
- If screenshots fail, check: server running, URL accessible, Playwright installed.
