#!/usr/bin/env python3

import pandas as pd

# Import data
baseline = pd.read_csv("$baseline")
kinship = pd.read_table("$kinship")

# Make KINSHIP catalogue for FID and IID
dfk1 = kinship[["FID1", "ID1"]].rename(columns={"FID1": "FID", "ID1": "IID"})
dfk2 = kinship[["FID2", "ID2"]].rename(columns={"FID2": "FID", "ID2": "IID"})
long_kinship = pd.concat([dfk1, dfk2]).drop_duplicates()

# Get the KINSHIP IIDs to the BASELINE FORMAT
long_kinship["PATID"] = long_kinship.iloc[:, 1].str.extract(r"^\\w+\\_(\\w+\\d+)\\_\\w+")[0]

# Make a join with BASELINE to get the IID and FID
baseline = baseline.merge(
    long_kinship[["FID", "IID", "PATID"]], left_on="PATID", right_on="PATID", how="left"
)
baseline = baseline.drop(["PATID"], axis=1)

kinship = kinship[["FID1", "ID1", "FID2", "ID2", "InfType"]]
agesex = (
    baseline[["FID", "IID", "AGE", "MALE"]]
    .replace(
        # replace boolean value for integer: M = Male, F = Female
        {"MALE": {0: "F", 1: "M"}}
    )
    .rename(
        # change column names
        columns={"MALE": "sex", "AGE": "age"}
    )
)

kinship.to_csv("kinship.csv", sep="\t", index=False)
agesex.to_csv("agesex.csv", sep="\t", index=False)