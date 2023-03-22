import json

def lambda_handler(event, context):
  HTTPMethod = event['httpMethod']
    
  #CRUD (pour Create, Read, Update, Delete) 
  if HTTPMethod == "POST" or HTTPMethod == "PUT":
    try:
      body = json.loads(event['body'])
    except:
      return {
        'statusCode': 400,
        'body': "Bad request: the body must be in valid JSON format."
      }
    return {
      'statusCode': 201,
      'body': "{ \"Result\": \"Created\", \"Values\": " + json.dumps(body) + "}"
    }

  if HTTPMethod == "GET":
    return {
      'statusCode': 200,
      'body': "{\"Hello\":\"World\", \"Function Name\": " + context.function_name + "}"
    }

  if HTTPMethod == "PATCH":
    try:
      body = json.loads(event['body'])
    except:
      return {
        'statusCode': 400,
        'body': "Bad request: the body must be in valid JSON format."
      }
    return {
      'statusCode': 202,
      'body': "{ \"Result\": \"Modified\", \"Values\": " + json.dumps(body) + "}"
    }
  
  if HTTPMethod == "DELETE":
    try:
      body = json.loads(event['body'])
    except:
      return {
        'statusCode': 400,
        'body': "Bad request: the body must be in valid JSON format."
      }
    return {
      'statusCode': 204,
      'body': "{ \"Result\": \"Deleted\", \"Values\": " + json.dumps(body) + "}"
    }