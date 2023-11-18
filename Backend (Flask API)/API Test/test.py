import requests

# Assuming your Flask app is running locally on port 5000
url = 'http://192.168.56.1:5000/predict'

# Example input data
input_data = {'input_data': [1, 29.85, 1029.85, 'Yes',
                             'No', 'Yes', 'No', 'Yes', 'No', 'Yes', 'No', 'Yes', 1]}
print(input_data)
# Send a POST request to the /predict endpoint
response = requests.post(url, json=input_data)

# Print the response from the API
print(response.json())
 'SeniorCitizen_Yes',
    'Contract_Month-to-month',
    'Contract_Two year',
    'InternetService_Fiber optic',
    'InternetService_No',