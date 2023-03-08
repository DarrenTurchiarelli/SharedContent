
import requests
from bs4 import BeautifulSoup
import csv

url = "https://azure.microsoft.com/en-us/products/"
r = requests.get(url)

soup = BeautifulSoup(r.content, 'html5lib') # Run 'pip install html5lib'

AzureProducts=[] #A list to store all the Azure Products

table = soup.find('div', attrs = {'id':'products-list'}) #Locate the table containing the Azure Products

for row in table.findAll('div', attrs = {'class':'column medium-6 end'}): #For each row in the table
        
        product = {} #Create a dictionary to store the data for each row
        # product['Category'] = row.h2.text #Extract the text from the h2 tag and store it in the Category column
        product['Service'] = row.a.span.text #Extract the text from the span tag and store it in the Service column
        product['Description'] = row.p.text #Extract the text from the p tag and store it in the Description column
        product['Link'] = row.a['href'] #Extract the link from the a tag and store it in the Link column          
        AzureProducts.append(product) #Append the dictionary to the AzureProducts list      

print(AzureProducts)

#export table to csv in the same folder that the script is run from
filename = 'Azure_Products.csv' 
with open(filename, 'w', newline='') as f:
    w = csv.DictWriter(f,['Category','Service','Description','Link'])
    w.writeheader()
    for product in AzureProducts:
        w.writerow(product)
