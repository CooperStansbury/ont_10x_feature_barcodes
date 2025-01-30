import pandas as pd
import numpy as np
import os
import sys
from scipy.sparse import csr_matrix

def process_chunk(chunk):
    df_pivot = pd.pivot_table(
        chunk,
        index='cell_barcode',
        columns='basename',
        values='read_name',
        aggfunc='count',
        fill_value=0.0,
    )

    # Find the column index with the maximum value for each row
    df_sparse = csr_matrix(df_pivot.values)
    max_indices = np.argmax(df_sparse, axis=1)
    pred = df_pivot.columns[max_indices.A1] 

    # **Create a DataFrame with 'cell_barcode' and 'pred'**
    result_df = pd.DataFrame({'cell_barcode': df_pivot.index, 'pred': pred})

    # **Add the counts from df_pivot to result_df**
    result_df = result_df.join(df_pivot, on='cell_barcode') 

    return result_df

if __name__ == "__main__":
    fbc_path = sys.argv[1]
    output_path = sys.argv[2]

    chunksize = 100000
    all_results = []

    for chunk in pd.read_csv(fbc_path, chunksize=chunksize):
        chunk_result = process_chunk(chunk)
        all_results.append(chunk_result)

    final_df = pd.concat(all_results)
    final_df.to_csv(output_path, index=False)