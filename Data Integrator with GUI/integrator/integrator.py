# -*- coding: utf-8 -*-

"""This module provides the Integrator class to merge multiple files."""
import json
import time
import os
from pathlib import Path
import pandas as pd

from PyQt5.QtCore import QObject, pyqtSignal


class Integrator(QObject):
    # Define custom signals
    progressed = pyqtSignal(int)
    integratedFile = pyqtSignal(Path)
    finished = pyqtSignal()

    def __init__(self, files):
        super().__init__()
        self._files = files

    def integrateFiles(self):
        os.system('mkdir data')
        cwd = os.getcwd()
        for fileNumber, file in enumerate(self._files, 1):
            oldName = file.name
            newPath = file.parent, joinpath(
                f"{cwd}/output/{str(oldName.replace('.json','.csv'))}"
            )
            data = json.loads(open(file).read())
            df = pd.DataFrame(data, index=[0])
            df.to_csv(newPath)
            time.sleep(0.1)  # Comment this line to integrate move faster.
            self.progressed.emit(fileNumber)
            self.integratedFile.emit(newPath)
        self.progressed.emit(0)  # Reset the progress
        self.finished.emit()

    def integrateFiles(self):
        cwd = os.getcwd()
        for fileNumber, file in enumerate(self._files, 1):
            oldName = file.name
            newPath = file.parent.joinpath(
                f"{cwd}/data/{str(oldName)}"
            )
            file.rename(newPath)
            time.sleep(0.1)  # Comment this line to integrate move faster.
            self.progressed.emit(fileNumber)
            self.integratedFile.emit(newPath)
        self.progressed.emit(0)  # Reset the progress
        self.finished.emit()

        cmd = '''
        mkdir output
        mkdir data/Used\ Data/
        head -1 data/records1.csv > output/finalData.csv
        tail -n +2 -q data/records*.csv >> output/finalData.csv
        FILE_loc=data/locations.csv
        FILE_garmin=data/garmin_gpx.gpx
        FILE_vis=data/visited_places.csv
        
        if [[ -f "$FILE_garmin" ]]; then
            echo "Garmin File Exists -> Creating Garming CSV"
            gpx_converter --function "gpx_to_csv" --input_file "$FILE_garmin" --output_file "output/output_garmin.csv"
        fi

        if [[ -f "$FILE_vis" && -f "$FILE_loc" && -f "$FILE_garmin" ]]; then
            echo "All Files Provided -> Merging"
            sqlite3 < merge_visited.sql
            sqlite3 < merge_locations.sql
            sqlite3 < merge_garmin.sql
            mv data/*.gpx data/Used\ Data/
        elif [[ -f "$FILE_vis" && -f "$FILE_loc" ]]; then
            echo "Garmin File Not Provided -> Merging"
            sqlite3 < merge_visited.sql
            sqlite3 < merge_locations.sql
        elif [[ -f "$FILE_vis" && -f "$FILE_garmin" ]]; then
            echo "Location File Not Provided -> Merging"
            sqlite3 < merge_visited.sql
            sqlite3 < merge_garmin.sql
            mv data/*.gpx data/Used\ Data/
        elif [[ -f "$FILE_loc" && -f "$FILE_garmin" ]]; then
            echo "Visited File Not Provided  -> Merging"
            sqlite3 < merge_locations.sql
            sqlite3 < merge_garmin.sql
            mv data/*.gpx data/Used\ Data/
        elif [ -f "$FILE_vis" ]; then
            echo "VISITED FILE ONLY -> Merging"
            sqlite3 < merge_visited.sql
        elif [ -f "$FILE_loc" ]; then
            echo "LOCATION FILE ONLY -> Merging"
            sqlite3 < merge_locations.sql
        elif [ -f "$FILE_garmin" ]; then
            echo "GARMIN FILE ONLY -> Merging"
            sqlite3 < merge_garmin.sql
            mv data/*.gpx data/Used\ Data/
        fi

        echo "Data Integration Completed"
        echo "Output files are stored in output folder"

        mv data/*.csv data/Used\ Data/

        echo "Used files are moved to Data/Used Data"

        '''
        os.system(cmd)
