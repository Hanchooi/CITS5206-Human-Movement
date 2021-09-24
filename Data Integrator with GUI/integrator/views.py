# -*- coding: utf-8 -*-

"""This module provides the Integrator main window."""

from collections import deque
from pathlib import Path

from PyQt5.QtCore import QThread
from PyQt5.QtWidgets import QFileDialog, QWidget

from .integrator import Integrator
from .ui.window import Ui_Window

FILTERS = ";;".join(
    (
        "CSV Files (*.csv)",
        "JSON Files (*.json)",
        "GPX Files (*.gpx)",
    )
)


class Window(QWidget, Ui_Window):
    def __init__(self):
        super().__init__()
        self._files = deque()
        self._filesCount = len(self._files)
        self._setupUI()
        self._connectSignalsSlots()

    def _setupUI(self):
        self.setupUi(self)
        self._updateStateWhenNoFiles()

    def _updateStateWhenNoFiles(self):
        self._filesCount = len(self._files)
        self.loadFilesButton.setEnabled(True)
        self.loadFilesButton.setFocus(True)
        self.integrateButton.setEnabled(False)

    def _connectSignalsSlots(self):
        self.loadFilesButton.clicked.connect(self.loadFiles)
        self.integrateButton.clicked.connect(self.integrateFiles)

    def loadFiles(self):
        self.dstFileList.clear()
        if self.dirEdit.text():
            initDir = self.dirEdit.text()
        else:
            initDir = str(Path.home())
        files, filter = QFileDialog.getOpenFileNames(
            self, "Choose Files to Integrate", initDir
        )
        if len(files) > 0:
            srcDirName = str(Path(files[0]).parent)
            self.dirEdit.setText(srcDirName)
            for file in files:
                self._files.append(Path(file))
                self.srcFileList.addItem(file)
            self._filesCount = len(self._files)
            self.integrateButton.setEnabled(True)

    def integrateFiles(self):
        self._runIntegratorThread()
        self._updateStateWhileIntegrating()

    def _updateStateWhileIntegrating(self):
        self.loadFilesButton.setEnabled(False)
        self.integrateButton.setEnabled(False)

    def _runIntegratorThread(self):
        self._thread = QThread()
        self._integrator = Integrator(
            files=tuple(self._files)
        )
        self._integrator.moveToThread(self._thread)
        # Integrate
        self._thread.started.connect(self._integrator.integrateFiles)
        # Update state
        self._integrator.integratedFile.connect(
            self._updateStateWhenFileIntegrated)
        self._integrator.progressed.connect(self._updateProgressBar)
        self._integrator.finished.connect(self._updateStateWhenNoFiles)
        # Clean up
        self._integrator.finished.connect(self._thread.quit)
        self._integrator.finished.connect(self._integrator.deleteLater)
        self._thread.finished.connect(self._thread.deleteLater)
        # Run the thread
        self._thread.start()

    def _updateStateWhenFileIntegrated(self, newFile):
        self._files.popleft()
        self.srcFileList.takeItem(0)
        self.dstFileList.addItem(str(newFile))

    def _updateProgressBar(self, fileNumber):
        progressPercent = int(fileNumber / self._filesCount * 100)
        self.progressBar.setValue(progressPercent)
