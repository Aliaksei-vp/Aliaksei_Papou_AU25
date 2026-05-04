from selenium.webdriver.support.ui import WebDriverWait as WDW
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

class CaptureReportPage:
    def __init__(self, driver, delay):
        self.driver = driver
        self.delay = delay

        # Selectors on the main page layout
        self.card_xpath = "//mat-card[.//mat-card-title[contains(text(), 'Capture report views')]]"
        self.nav_home = (By.XPATH, "//span[contains(@class, 'nav-pane-button-text-span') and text()='Home']")
        self.nav_learning = (By.XPATH, "//span[contains(@class, 'nav-pane-button-text-span') and text()='Learning center']")

        # Selectors for Power BI Report
        self.kpi_vol = (By.XPATH, "//*[text()='49,832']")
        self.kpi_share = (By.XPATH, "//*[text()='32.9%']")
        self.region_central = (By.XPATH, "//*[text()='Central']")
        self.region_east = (By.XPATH, "//*[text()='East']")
        self.region_west = (By.XPATH, "//*[text()='West']")

    def open_capture_report_section(self):
        card = WDW(self.driver, self.delay).until(
            EC.presence_of_element_located((By.XPATH, self.card_xpath))
        )
        self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", card)
        card.click()

    def _switch_to_report_context(self):
        wait = WDW(self.driver, self.delay)
        outer_frame = wait.until(EC.presence_of_element_located((By.TAG_NAME, "iframe")))
        self.driver.switch_to.frame(outer_frame)
        try:
            inner_frame = wait.until(EC.presence_of_element_located((By.TAG_NAME, "iframe")))
            self.driver.switch_to.frame(inner_frame)
        except:
            pass

    def is_home_button_present(self):
        """Checks navigation button presence on the main page"""
        element = WDW(self.driver, self.delay).until(EC.visibility_of_element_located(self.nav_home))
        return element.is_displayed()

    def is_learning_center_present(self):
        """Checks navigation button presence on the main page"""
        element = WDW(self.driver, self.delay).until(EC.visibility_of_element_located(self.nav_learning))
        return element.is_displayed()

    def verify_kpi_data_presence(self):
        """Verifies actual KPI numerical data inside iframe"""
        self._switch_to_report_context()
        wait = WDW(self.driver, self.delay + 10)
        try:
            kv = wait.until(EC.presence_of_element_located(self.kpi_vol))
            ks = wait.until(EC.presence_of_element_located(self.kpi_share))
            return kv is not None and ks is not None
        except:
            return False
        finally:
            self.driver.switch_to.default_content()

    def verify_region_slicers_presence(self):
        """Checks if structural regional slicer buttons exist in the report"""
        self._switch_to_report_context()
        wait = WDW(self.driver, self.delay + 10)
        try:
            c = wait.until(EC.presence_of_element_located(self.region_central))
            e = wait.until(EC.presence_of_element_located(self.region_east))
            w = wait.until(EC.presence_of_element_located(self.region_west))
            return all([c, e, w])
        except:
            return False
        finally:
            self.driver.switch_to.default_content()
