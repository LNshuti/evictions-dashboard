import os
import pandas as pd
import sqlite3
import subprocess

def load_data_to_db(csv_file_path, db_file_path):
    df = pd.read_csv(csv_file_path)
    conn = sqlite3.connect(db_file_path)
    df.to_sql('data', conn, if_exists='replace', index=False)
    conn.close()

def publish_to_fly(db_file_path):
    subprocess.run(['datasette', 'publish', 'fly', db_file_path, '--project', 'your_project_name'])

csv_file_path = 'data/monthly.csv'
db_file_path = 'fixtures.db'

load_data_to_db(csv_file_path, db_file_path)
publish_to_fly(db_file_path)