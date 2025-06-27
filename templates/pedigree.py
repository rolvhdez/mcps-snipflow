#!/usr/bin/env python3    
import pandas as pd
from snipar.pedigree import create_pedigree

pedigree = create_pedigree(
    king_address="${kinship}"
    , agesex_address="${agesex}"
    , same_parents_in_ped=True
)
pedigree.to_csv("pedigree.txt", sep=" ", index=False, header=False)