### 82512025_Churning_Customers
Author: Ryan Tangu Mbun Tangwe

# Telco Churn Prediction App

This project consists of a Telco Churn Prediction system with a backend implemented in Flask and a Flutter-based frontend for user interaction.
A Multi-Layer Perceptron deep learning model was trained using the keras Functional API.
The model can assists telecom operators in predicting customers who are most likely subject to churn.

## Backend (Flask)

### Getting Started

1. Navigate to the `Backend (Flask API)` directory:

    ```bash
    cd Backend (Flask API)
    ```

2. Install dependencies:

    ```bash
    pip install -r requirements.txt
    ```

3. Run the Flask app:

    ```bash
    python rest_api.py
    ```

The backend will start on `http://localhost:5000`.

### API Endpoints

- `/predict`: Endpoint for making churn predictions. Send a POST request with JSON data containing customer details.

### Sample Request Body

```json
{
  "input_data": [28, 2.0, 150.5, "Yes", "No", "Fiber optic", "No", "No", "Yes", "No", "Yes", "No", "Electronic check"]
}
```

### Sample Response Body

```json
{
  "prediction": 1,
  "confidence": 85.34
}
```

- `prediction`: Binary prediction for customer churn (1 for Yes, 0 for No).
- `confidence`: Confidence level in percentage for the prediction.

## Frontend (Flutter)

### Getting Started

1. Navigate to the `churn_predictor` directory:

    ```bash
    cd churn_predictor
    ```

2. Run the Flutter app:

    ```bash
    flutter run
    ```

The app will start on your connected device or emulator.

### Dependencies
- http: ^0.13.3

### Features

- **User Input:** Enter customer details, including numeric features and categorical features.
- **Prediction:** Get predictions for customer churn along with confidence levels.
- **Error Handling:** Display error messages for invalid input or server errors.

### Screenshots

Include screenshots of the app to provide a visual representation.

### Usage

1. Enter customer details, including numeric and categorical features.
2. Press the "Predict Customer Churn" button.
3. View the prediction and confidence levels.


## Acknowledgments
The data for model training was sourced from Kaggle
