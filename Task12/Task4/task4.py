from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time

options = webdriver.ChromeOptions()
options.add_argument("--disable-blink-features=AutomationControlled")
options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)
options.add_argument(
    "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36")

driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()), options=options)
driver.maximize_window()
driver.implicitly_wait(10)
wait = WebDriverWait(driver, 15)

try:
    driver.get("https://google.com")
    time.sleep(2)

    # 1. Handling Cookies (I'm in Bulgaria, so I use 'Приемане на всички' )
    try:
        cookie_btn = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(., 'Приемане на всички')]")))
        cookie_btn.click()
    except:
        pass

    # 2. Search for Selenium
    search_query = wait.until(EC.element_to_be_clickable((By.NAME, "q")))
    search_query.clear()

    for char in "Selenium":
        search_query.send_keys(char)
        time.sleep(0.1)
    search_query.send_keys(Keys.ENTER)

    # 3. Open the first link
    first_link = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "h3")))
    print(f"Clicking: {first_link.text}")
    first_link.click()

    wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))
    print(f"SUCCESS: Opened '{driver.title}'")

except Exception as e:
    print(f"Error: {e}")
    time.sleep(60)

finally:
    driver.quit()
