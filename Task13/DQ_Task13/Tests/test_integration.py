import allure
import pytest

@allure.feature("Data Integrity Tests")
class TestDataValidation:

    @allure.story("Scenario 1: API Data Verification")
    def test_user_posts_count(self, user_posts):
        """Verify that user 3 has 10 posts."""
        with allure.step("Check posts count for user 3"):
            actual_count = len(user_posts)
            assert actual_count == 10, f"Expected 10 posts, but found {actual_count}"

    @allure.story("Scenario 2: Cloud Sync Smoke Test")
    def test_data_is_presented_between_staging_raw(self, gcp_objects, aws_objects):
        """Verify GCP and AWS buckets are not empty."""
        with allure.step("Verify GCP objects existence"):
            assert len(gcp_objects) > 0, "GCP source is empty"

        with allure.step("Verify AWS objects existence"):
            assert len(aws_objects) > 0, "AWS target is empty"

    @allure.story("Technical: Selenium Manager")
    def test_selenium_manager_init(self, browser):
        """Verify browser can resolve and load page."""
        with allure.step("Load JSONPlaceholder page"):
            browser.get("https://jsonplaceholder.typicode.com")
            assert "JSONPlaceholder" in browser.title, "Failed to load website"
