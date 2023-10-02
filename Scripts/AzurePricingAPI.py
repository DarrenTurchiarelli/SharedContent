"""
__author__     = "Darren Turchiarelli"
__license__ = "GPL"
__version__ = "1.0.0"
__maintainer__ = "Darren Turchiarelli"
__email__      = "darren.turchiarelli@microsoft.com"
__status__ = "Production"
__summary__ = ("This script is designed to fetch pricing data from the Microsoft Azure Retail Prices API "
              "(https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices) "
              "for virtual machines in the Australia East region. It processes the obtained data to organize the "
              "pricing information based on different term lengths—1 year, 3 years, and 5 years—for savings "
              "plans associated with each virtual machine offering. The script extracts the unit and retail prices "
              "for each term length, and organizes this information alongside other relevant details "
              "about the virtual machine offerings into a structured format. Finally, the script outputs all this "
              "information to an Excel file for easy review and analysis. This allows users to have a "
              "clear view of the pricing structure for virtual machines in the specified region, aiding in budgeting "
              "and decision-making.")
"""

import requests
import pandas as pd
import numpy as np
import re  # Import the regex module

# Define the URL and headers
url = "https://prices.azure.com/api/retail/prices"
params = {
    'api-version': '2023-01-01-preview',  # Add the api-version parameter to the query which should make the script more future-proof
    'currencyCode': 'AUD',  # Add the currencyCode parameter to the query based on your region
    '$filter': "armRegionName eq 'australiaeast' and serviceName eq 'Virtual Machines'"  # Update the query according to the region that you are interested in
}

# Send a GET request to the URL
response = requests.get(url, params=params)

# Function to format column names
def format_column_name(column_name):
    # Replace underscores with spaces
    formatted_name = column_name.replace('_', ' ')
    # Insert space before capital letters that are in the middle of the text
    formatted_name = re.sub(r'(?<=[a-z])([A-Z])', r' \1', formatted_name)
    # Capitalize each word
    formatted_name = formatted_name.title()
    return formatted_name

# Check for a successful response (HTTP Status Code 200)
if response.status_code == 200:
    # Parse the JSON response
    data = response.json()
    
    # The relevant data is in a key named 'Items' in the JSON response
    items = data.get('Items', [])
    
    # Create a DataFrame from the items
    df = pd.DataFrame(items)
    
    # Initialize new columns for the savings plans
    for term in ['1_year', '3_year', '5_year']:
        df[f'{term}_term_unit_price'] = np.nan
        df[f'{term}_term_retail_price'] = np.nan
    
    # Loop through each row to extract savings plan details
    for index, row in df.iterrows():
        savings_plan = row.get('savingsPlan', [])
        if isinstance(savings_plan, list):  # Ensure savingsPlan is a list before iterating
            for plan in savings_plan:
                term = plan.get('term', '')
                if term == '1 Year':
                    df.at[index, '1_year_term_unit_price'] = plan.get('unitPrice', np.nan)
                    df.at[index, '1_year_term_retail_price'] = plan.get('retailPrice', np.nan)
                elif term == '3 Years':
                    df.at[index, '3_year_term_unit_price'] = plan.get('unitPrice', np.nan)
                    df.at[index, '3_year_term_retail_price'] = plan.get('retailPrice', np.nan)
                elif term == '5 Years':  # Check for a 5-year term
                    df.at[index, '5_year_term_unit_price'] = plan.get('unitPrice', np.nan)
                    df.at[index, '5_year_term_retail_price'] = plan.get('retailPrice', np.nan)
    
    # Drop the original savingsPlan and reservationTerm columns (optional)
    df = df.drop(columns=['savingsPlan', 'reservationTerm'])
    
    # Update column headings
    df.columns = df.columns.map(format_column_name)
    
    # Write the DataFrame to an Excel file
    df.to_excel('Azure_Pricing.xlsx', index=False)
else:
    print(f'Failed to retrieve data: {response.status_code}')
