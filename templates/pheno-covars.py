#!/usr/bin/env python3    
import pandas as pd
from scipy.special import ndtri

def intnorm(x):
    # Creates a Inverse Normal Transformation (INT)
    # for a pandas series (x)

    x_rank = x.rank()
    numerator = x_rank - 0.5 
    par = numerator/len(x)
    x_normalized = ndtri(par)
    
    return x_normalized

# Import data
baseline = pd.read_csv("$baseline")
kinship = pd.read_table("$kinship")
pcs = pd.read_table("$pcs")

# Change the PCs header
pcs = pcs.rename(columns={"sample.ID":"IID"})

# Make KINSHIP catalogue for FID and IID
dfk1 = kinship[["FID1", "ID1"]].rename(columns={"FID1": "FID", "ID1": "IID"})
dfk2 = kinship[["FID2", "ID2"]].rename(columns={"FID2": "FID", "ID2": "IID"})
long_kinship = pd.concat([dfk1, dfk2]).drop_duplicates()

# Get the KINSHIP IIDs to the BASELINE FORMAT
long_kinship["PATID"] = long_kinship.iloc[:, 1].str.extract(r"^\\w+\\_(\\w+\\d+)\\_\\w+")[0]

# Make a join with BASELINE to get the IID and FID
baseline = baseline.merge(
    long_kinship[["FID", "IID", "PATID"]],
    left_on="PATID",
    right_on="PATID",
    how="left"
)
baseline = baseline.drop(["PATID"], axis=1)
baseline = baseline[baseline[["FID", "IID"]].notnull().all(axis=1)]  # filter non-genotyped individuals

# 'Create': Pedigree
kinship = kinship[["FID1", "ID1", "FID2", "ID2", "InfType"]]
agesex = (
baseline[["FID", "IID", "AGE", "MALE"]]
                            .replace({"MALE": {0: "F", 1: "M"}})
                            .rename(columns={"PATID":"IID", "MALE":"sex", "AGE":"age"})
)
pedigree = pd.read_csv("$pedigree", sep=" ", header=None, names=["FID", "IID", "FATHER_ID", "MOTHER_ID"])

# Create: Covars
covars = baseline[["FID", "IID", "AGE", "MALE"]]
covars = covars.merge(pcs.iloc[:, 0:9], left_on="IID", right_on="IID", how="left")
covars.iloc[:, 2:] = covars.iloc[:, 2:].fillna("NA") # fill NA's as described `here <https://github.com/AlexTISYoung/snipar/blob/553e7ac1b2d0cecdede013c8907843fd79b1dcf6/snipar/read/phenotype.py#L8>`

# Create: Phenotype
baseline = baseline.drop(["FID"], axis=1)
baseline = baseline.merge(pedigree[["FID", "IID"]], on="IID", how="left")
cols_to_move = ["FID", "IID"] # columns to move to the beginning

for col in reversed(cols_to_move): # Use reversed to maintain the order of cols_to_move
    column = baseline.pop(col)
    baseline.insert(0, col, column)

phen_cols = ["AGE", "MALE", "YEAR_RECRUITED", "MONTH_RECRUITED", "COYOACAN", "MARITAL_STATUS"]
phenotype = baseline.drop(phen_cols, axis=1)
phenotype["BMI"] = phenotype["WEIGHT"] / (phenotype["HEIGHT"])**2 # calculate BMI
phenotype.iloc[:, 2:] = intnorm(phenotype.iloc[:, 2:]) # normalize based on INT
phenotype.iloc[:, 2:] = phenotype.iloc[:, 2:].fillna("NA") # fill NA's as described `here <https://github.com/AlexTISYoung/snipar/blob/553e7ac1b2d0cecdede013c8907843fd79b1dcf6/snipar/read/phenotype.py#L8>`
phenotype = phenotype.sort_values(by=["FID", "IID"]) # sort by FID and IID

# Export
phenotype.to_csv("phenotype.txt", sep=" ", index=False)
covars.to_csv("covariates.txt", sep=" ", index=False)