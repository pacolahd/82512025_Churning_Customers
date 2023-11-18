from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import tensorflow as tf
import pickle
from tensorflow.keras.models import load_model

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes


# Load the model
model = load_model('initial_model.h5')

# Load the scaler using pickle
with open('scaler.pkl', 'rb') as scaler_file:
    scaler = pickle.load(scaler_file)

# Define the endpoint for predictions


@app.route('/predict', methods=['POST'])
def predict():
    print("CT:", request.headers['Content-Type'])
    try:
        # Ensure content type is JSON
        print("CT:", request.headers['Content-Type'])
        if not str(request.headers['Content-Type']).__contains__('application/json'):
            return jsonify({'error': 'Content-Type must be application/json'}), 400

        # Get input data from the request
        input_data = request.json['input_data']
        app.logger.info(f"Received input data: {input_data}")
        print(input_data)
        # Convert categorical features to numerical representation
        input_data[3:] = [1 if str(val).lower() == 'yes' or val ==
                          '1' else 0 for val in input_data[3:]]
        app.logger.info(f"Converted categorical features: {input_data}")

        # Scale numeric features using the loaded scaler
        input_data[:3] = scaler.transform([input_data[:3]])[0]
        app.logger.info(f"Scaled numeric features: {input_data}")
        print(input_data)

        # Make the prediction
        # prediction = model.predict(input_data)
        prediction = model.predict(np.array([input_data]))

        app.logger.info(f"Prediction: {prediction}")

        # Extract the raw prediction
        raw_prediction = prediction[0][0]

        # Calculate confidence
        confidence = (1 - raw_prediction) * \
            100 if raw_prediction < 0.5 else raw_prediction * 100

        # Return the prediction and confidence with a 200 status code
        return jsonify({'prediction': int(raw_prediction > 0.5), 'confidence': round(confidence, 2)}), 200

    except KeyError as e:
        app.logger.error(f"KeyError: {str(e)}")
        return jsonify({'error': 'Invalid input format. Check if all required fields are present.'}), 400

    except Exception as e:
        app.logger.error(f"Error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    app.run(debug=True, host='192.168.56.1', port=5000)
