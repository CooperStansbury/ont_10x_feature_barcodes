import pandas as pd
import numpy as np
import os
import sys

if __name__ == "__main__":
    whitelist_path = sys.argv[1]
    output_path = sys.argv[2]
    flexiplex_paths = sys.argv[3:]

    # load the white list
    bdf = pd.read_csv(
        whitelist_path, 
        sep='[ \t]+',
        header=None,
        names=['bc', 'fbc'],
        engine='python',
    )
    bc_map = dict(zip(bdf.fbc.values, bdf.bc.values))

    df = []

    for fpath in flexiplex_paths:
        basename = os.path.basename(fpath)
        basename = basename.replace("_reads_barcodes.txt", "")
        print(basename)
        tmp = pd.read_csv(fpath, sep='\t', usecols=['Read', 'CellBarcode', 'BarcodeEditDist'])
        tmp.columns = ['read_name', 'fbc', 'edit_distance']
        tmp['cell_barcode'] = tmp['fbc'].map(bc_map)
        tmp['basename'] = basename
        df.append(tmp)

    df = pd.concat(df)
    df.to_csv(output_path, index=False)
