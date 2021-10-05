
import pytest

from PyQt5 import QtCore
from PyQt5.QtWidgets import QWidget
from .ui.window import Ui_Window
from .views import Window
import time
import os


@pytest.fixture
def app(qtbot):
    integrator_app = Window()
    qtbot.addWidget(integrator_app)

    return integrator_app


def test_label(app):
    assert app.label.text() == "User Data Files:"


def test_label2(app):
    assert app.label_2.text() == "Data Files for Integration"


def test_label3(app):
    assert app.label_3.text() == "Integrated Files"


def test_loadFilesButton(app):
    assert app.loadFilesButton.text() == "&Load Files"
    assert app.loadFilesButton.isEnabled() == True


def test_integrateButton(app):
    assert app.integrateButton.text() == "Integrate"
    assert app.integrateButton.isEnabled() == False


def test_click(app, qtbot):
    qtbot.mouseClick(app.loadFilesButton, QtCore.Qt.LeftButton)
    qtbot.mouseClick(app.integrateButton, QtCore.Qt.LeftButton)
    time.sleep(5)


def test_output_exist():
    assert os.path.isfile("output/finalData.csv") == True
    assert os.path.isfile("output/output_garmin.csv") == True


def test_output_content():
    with open("output/finalData.csv") as f:
        txt = f.read().split("\n")
    assert txt[0] == "id,date,latitude,longitude,speed,vis_name,vis_activity1,vis_activity2,vis_activity3,vis_lat,vis_long,loc_name,loc_lat,loc_long,garmin_lat,garmin_long,garmin_alt"
