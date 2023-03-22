import requests
def lambda_handler(event, context):   
    response = requests.get("https://raw.githubusercontent.com/Arcanexus/api-demo-backend/main/lambda-api-server.py")
    print(response.text)
    return response.text