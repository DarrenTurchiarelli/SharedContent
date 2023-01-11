# pip install requests - uncomment if this library is not installed 
# pip install bs4 - uncomment if this library is not installed 
import requests
from bs4 import BeautifulSoup

# Request 'Azure IP Ranges and Service Tags – Public Cloud' site
URL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519"
page = requests.get(URL)

# Parse HTML to get the real link
soup = BeautifulSoup(page.content, "html.parser")
link = soup.find('a', {'data-bi-containername':'download retry'})['href']

# Download file required containing the service tags
file_download = requests.get(link)

# Save the file in the location where this script was run
open("Azure_IPs_And_Service_Tags.json", "wb").write(file_download.content)
