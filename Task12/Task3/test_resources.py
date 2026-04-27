from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.relative_locator import locate_with
from webdriver_manager.chrome import ChromeDriverManager

options = webdriver.ChromeOptions()
options.add_argument('--ignore-certificate-errors')
driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()), options=options)
driver.maximize_window()
wait = WebDriverWait(driver, 15)

try:
    # --- RESOURCE 1: https://phptravels.com/demo/ ---
    driver.get("https://phptravels.com/demo/")

    wait.until(EC.visibility_of_element_located((By.CLASS_NAME, "first_name")))

    # 1. CLASS NAME
    f_name_class = driver.find_element(By.CLASS_NAME, "first_name")
    l_name_class = driver.find_element(By.CLASS_NAME, "last_name")

    # 2. ID
    submit_btn_id = driver.find_element(By.ID, "demo")
    math_input_id = driver.find_element(By.ID, "number")

    # 3. NAME
    names = driver.find_elements(By.NAME, "firstname")

    # 4. CSS SELECTOR
    business_css = driver.find_element(By.CSS_SELECTOR, "input.company_name")
    email_css = driver.find_element(By.CSS_SELECTOR, "input.email")

    # 5. XPATH
    whatsapp_xpath = driver.find_element(By.XPATH, "//input[@placeholder='Enter WhatsApp number']")
    country_xpath = driver.find_element(By.XPATH, "//select[contains(@class, 'country_id')]")

    # 6. RELATIVE LOCATORS
    f_ref = driver.find_element(By.CLASS_NAME, "first_name")
    w_ref = driver.find_element(By.CLASS_NAME, "whatsapp_number")

    rel_right = driver.find_element(locate_with(By.TAG_NAME, "input").to_right_of(f_ref))
    rel_below = driver.find_element(locate_with(By.TAG_NAME, "input").below(w_ref))

    # --- RESOURCE 2: https://phptravels.org/register.php ---
    driver.get("https://phptravels.org/register.php")

    wait.until(EC.presence_of_element_located((By.ID, "inputFirstName")))

    # 1. CLASS NAME
    phone_class = driver.find_element(By.CLASS_NAME, "form-control")
    company_class = driver.find_element(By.CLASS_NAME, "field")

    # 2. ID
    first_name_id = driver.find_element(By.ID, "inputFirstName")
    last_name_id = driver.find_element(By.ID, "inputLastName")

    # 3. NAME
    email_name = driver.find_element(By.NAME, "email")
    address1_name = driver.find_element(By.NAME, "address1")

    # 4. CSS SELECTOR
    address2_css = driver.find_element(By.CSS_SELECTOR, "#inputAddress2")
    city_css = driver.find_element(By.CSS_SELECTOR, "input[name='city']")

    # 5. XPATH
    state_xpath = driver.find_element(By.XPATH, "//input[@id='stateinput']")
    postcode_xpath = driver.find_element(By.XPATH, "//input[@name='postcode']")

    # 6. RELATIVE LOCATORS
    last_name_rel = driver.find_element(locate_with(By.TAG_NAME, "input").to_right_of({By.ID: "inputFirstName"}))
    email_rel = driver.find_element(locate_with(By.TAG_NAME, "input").below({By.ID: "inputFirstName"}))

    # --- RESOURCE 3: https://phptravels.com/blog ---
    driver.get("https://phptravels.com/blog/")

    wait.until(EC.visibility_of_element_located((By.TAG_NAME, "nav")))

    # 1. CLASS NAME
    blog_image_class = driver.find_element(By.CLASS_NAME, "lazy-image")
    sales_icon_class = driver.find_element(By.CLASS_NAME, "material-symbols-outlined")

    # 2. CSS SELECTOR
    pricing_css = driver.find_element(By.CSS_SELECTOR, "a[href*='pricing']")
    demo_css = driver.find_element(By.CSS_SELECTOR, "a[href*='demo']")

    # 3. XPATH
    product_xpath = driver.find_element(By.XPATH, "//span[text()='Product']")
    features_xpath = driver.find_element(By.XPATH, "//span[text()='Features']")

    # 4. RELATIVE LOCATORS
    product_ref = driver.find_element(By.XPATH, "//span[text()='Product']")
    pricing_ref = driver.find_element(By.CSS_SELECTOR, "a[href*='pricing']")

    rel_features = driver.find_element(locate_with(By.TAG_NAME, "span").to_right_of(product_ref))
    rel_sales = driver.find_element(locate_with(By.TAG_NAME, "a").to_right_of(pricing_ref))

    print("All locators match the provided HTML structure")

except Exception as e:
    print(f"Error: {e}")
    driver.save_screenshot("final_error.png")

finally:
    driver.quit()
