import pytest

@pytest.mark.ui
def test_01_verify_main_navigation_buttons(pbi_page):
    """UI Test: Verify 'Home' and 'Learning center' buttons on the main page"""
    pbi_page.open_capture_report_section()
    assert pbi_page.is_home_button_present() is True
    assert pbi_page.is_learning_center_present() is True

@pytest.mark.ui
def test_02_verify_report_kpi_metrics(pbi_page):
    """UI Test: Verify actual numerical KPI data inside the Power BI report iframe"""
    pbi_page.open_capture_report_section()
    # Checks for specific values: 49,832 and 32.9%
    assert pbi_page.verify_kpi_data_presence() is True, "KPI metrics are missing"

@pytest.mark.ui
def test_03_verify_region_filter_slicers(pbi_page):
    """UI Test: Verify that interactive Region slicers (Central, East, West) exist"""
    pbi_page.open_capture_report_section()
    assert pbi_page.verify_region_slicers_presence() is True, "Region slicer buttons are missing"
