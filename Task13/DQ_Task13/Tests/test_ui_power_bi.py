import pytest

def test_01_verify_home_nav_button(pbi_page):
    """UI Test: Testing the Home button in the side navigation"""
    pbi_page.open_capture_report_section()
    assert pbi_page.is_home_button_present() is True

def test_02_verify_learning_center_nav_button(pbi_page):
    """UI Test: Testing the Learning Center button in the side navigation"""
    pbi_page.open_capture_report_section()
    assert pbi_page.is_learning_center_present() is True
