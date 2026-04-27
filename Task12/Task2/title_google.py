import os
import shutil
from selenium import webdriver
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.firefox.options import Options as FirefoxOptions


def run_browser_test():
    # --- 1. Automatic approach (Selenium Manager) for Chrome ---
    print("Starting Chrome using automatic approach...")
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--headless")
    chrome_driver = webdriver.Chrome(options=chrome_options)
    try:
        chrome_driver.get("https://google.com")
        print(f"Chrome Page Title: {chrome_driver.title}")
    finally:
        chrome_driver.quit()

    # --- 2. Manual approach (Hard Coded Location) for Firefox ---
    print("\nStarting Firefox using manual approach (hardcoded path)...")

    gecko_path = "/home/unmd/Python-Course/geckodriver"

    # Since I have Linux Ubuntu, I created a profile directory where Snap has access.
    local_tmp = os.path.join(os.getcwd(), "ff_tmp")
    if os.path.exists(local_tmp):
        shutil.rmtree(local_tmp)
    os.makedirs(local_tmp)

    # Environment setup to avoid conflicts and allow Snap access
    clean_env = os.environ.copy()
    clean_env["TMPDIR"] = local_tmp
    if "LD_LIBRARY_PATH" in clean_env:
        del clean_env["LD_LIBRARY_PATH"]

    options = FirefoxOptions()
    options.add_argument("--headless")  # Essential for stable run in Linux
    options.binary_location = "/usr/bin/firefox"

    # Manual service with custom path and environment
    service = FirefoxService(executable_path=gecko_path, env=clean_env)

    try:
        # Initialize Firefox with both service and options
        firefox_driver = webdriver.Firefox(service=service, options=options)
        firefox_driver.get("https://google.com")
        print(f"Firefox Page Title: {firefox_driver.title}")
        firefox_driver.quit()
    except Exception as e:
        print(f"Firefox failed with error: {e}")
    finally:
        # Cleanup temporary folder
        if os.path.exists(local_tmp):
            shutil.rmtree(local_tmp)


if __name__ == "__main__":
    run_browser_test()
