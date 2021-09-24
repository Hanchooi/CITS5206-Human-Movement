from typing import Tuple
import pytest
import pandas as pd


def test_record_append():
    record1 = pd.read_csv("data/records1.csv",
                         keep_default_na=False, na_values=[""])
    record2 = pd.read_csv("data/records2.csv",
                         keep_default_na=False, na_values=[""])
    record3 = pd.read_csv("data/records3.csv",
                         keep_default_na=False, na_values=[""])
    records = record1.append(record2).append(record3)
    print(records)
    # hash_test = hash(records)
    # hash_unit = hash(pd.read_csv("../output/finalData.csv",
    #                      keep_default_na=False, na_values=[""]))
    assert records.equals(pd.read_csv("../output/finalData.csv",
                         keep_default_na=False, na_values=[""])) is False
