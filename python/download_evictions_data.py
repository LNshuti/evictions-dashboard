import requests
import json
import pandas as pd
import matplotlib.pyplot as plt

# Replace YOUR_API_KEY with the actual API key you obtain from the Eviction Lab
api_key = "YOUR_API_KEY"

# Define the API endpoint and parameters
url = "https://api.evictionlab.org/api/v1/evictions"
params = {
    "key": api_key,
    "area_type": "county",
    "geoid": "all",
    "year_min": "2015",
    "year_max": "2021",
    "variables": "eviction-rate",
    "agg": "year",
    "format": "json"
}

# Send request to the API
response = requests.get(url, params=params)

# Check if the request was successful
if response.status_code == 200:
    data = json.loads(response.text)
    df = pd.DataFrame(data)
    
    # Convert geoid to string and year to datetime
    df['geoid'] = df['geoid'].astype(str)
    df['year'] = pd.to_datetime(df['year'], format="%Y")
    
    # Pivot the DataFrame to have years as columns and geoids as rows
    pivot_df = df.pivot_table(values='eviction-rate', index='geoid', columns='year')
    
    # Plot the data
    plt.figure(figsize=(12, 6))
    plt.plot(pivot_df)
    plt.xlabel("County (geoid)")
    plt.ylabel("Eviction Rate")
    plt.title("Eviction Rates by County")
    plt.legend(pivot_df.columns, title="Year", bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.show()

else:
    print("Error:", response.status_code, response.text)
