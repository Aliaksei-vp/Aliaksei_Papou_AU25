from selenium.webdriver.support.ui import WebDriverWait as WDW
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

class CaptureReportPage:
    def __init__(self, driver, delay):
        self.driver = driver
        self.delay = delay

        self.card_xpath = "//mat-card[.//mat-card-title[contains(text(), 'Capture report views')]]"
        self.nav_home = (By.XPATH, "//span[contains(@class, 'nav-pane-button-text-span') and text()='Home']")
        self.nav_learning = (By.XPATH, "//span[contains(@class, 'nav-pane-button-text-span') and text()='Learning center']")

    def open_capture_report_section(self):
        card = WDW(self.driver, self.delay).until(
            EC.presence_of_element_located((By.XPATH, self.card_xpath))
        )
        self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", card)
        self.driver.execute_script("arguments[0].click();", card)

    def is_home_button_present(self):
        element = WDW(self.driver, self.delay).until(
            EC.visibility_of_element_located(self.nav_home)
        )
        return element.is_displayed()

    def is_learning_center_present(self):
        element = WDW(self.driver, self.delay).until(
            EC.visibility_of_element_located(self.nav_learning)
        )
        return element.is_displayed()
