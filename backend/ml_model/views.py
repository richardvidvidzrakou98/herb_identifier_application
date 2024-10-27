from django.http import JsonResponse
import tensorflow as tf
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User  # Import User model, or replace with custom user model

import os
import tempfile
from PIL import Image, ImageOps
import numpy as np
from .models import HerbIdentification
from .models import HerbSearchHistory
# Load the TensorFlow model
model = tf.keras.models.load_model('E:/My Projects/MobileApp/herb_identifier/backend/ml_model/models/model.h5')

# Define class names and their properties
class_names = ['Arive-Dantu', 'Basale', 'Betel', 'Crape_Jasmine', 'Curry', 'Drumstick', 
               'Fenugreek', 'Guava', 'Hibiscus', 'Beech', 'Mustard', 'Jackfruit', 
               'Jamaica_Cherry-Gasagase', 'Jamun', 'Jasmine', 'Karanda', 'Lemon', 'Mango', 
               'Mexican_Mint', 'Mint', 'Neem', 'Oleander', 'Parijata', 'Peepal', 'Pomegranate', 
               'Rasna', 'Rose_apple', 'Roxburgh_fig', 'Sandalwood', 'Tulsi']

# Mapping of herb descriptions
herb_descriptions = {
    'Arive-Dantu': 'Arive-Dantu: Used for diet and weight loss, rich in fiber, and helps cure ulcers and diarrhea.',
    'Basale': 'Basale: Has anti-inflammatory properties and aids in wound healing.',
    'Betel': 'Betel: Improves digestive health, mood, and contains anti-microbial agents.',
    'Crape_Jasmine': 'Crape Jasmine: Used to improve mood, reduce stress, and fight skin diseases.',
    'Curry': 'Curry: Helps with digestion, morning sickness, nausea, and lowers blood cholesterol.',
    'Drumstick': 'Drumstick: Contains Vitamin C and antioxidants, helps build immunity, and strengthens bones.',
    'Fenugreek': 'Fenugreek: Aids in regulating blood sugar, relieves heartburn, and prevents obesity.',
    'Guava': 'Guava: Rich in Vitamin C and antioxidants, prevents infections, and treats hypertension.',
    'Hibiscus': 'Hibiscus: Lowers blood pressure, relieves dry coughs, and helps in wound healing.',
    'Indian_Beech': 'Indian Beech: Used for skin disorders, has antimicrobial and anti-inflammatory properties.',
    'aloe_vera': 'Aloe Vera: Rich in vitamins and antioxidants, helps fight chronic conditions like diabetes and heart disease.',
    'Jackfruit': 'Jackfruit: Contains compounds that reduce high blood pressure, heart diseases, and improve nerve function.',
    'Jamaica_Cherry-Gasagase': 'Jamaican Cherry: Has anti-diabetic properties, boosts immunity, and promotes digestive health.',
    'Jamun': 'Jamun: Treats cold, cough, flu, and sore throat; fights dysentery and spleen enlargement.',
    'Jasmine': 'Jasmine: Used for liver diseases, mood improvement, reducing stress, and skin healing.',
    'Karanda': 'Karanda: Used to cure digestive problems, respiratory infections, and skin conditions.',
    'Lemon': 'Lemon: Excellent source of Vitamin C and fiber; prevents heart diseases and kidney stones.',
    'Mango': 'Mango: Rich in vitamins and antioxidants, promotes digestive health and reduces cancer risk.',
    'Mexican_Mint': 'Mexican Mint: Treats respiratory illnesses, cold, sore throat, and helps in natural skincare.',
    'Mint': 'Mint: Relieves indigestion, improves IBS symptoms, and is rich in essential nutrients.',
    'Neem': 'Neem: Used to cure skin diseases, boost immunity, and prevent gastrointestinal diseases.',
    'Oleander': 'Oleander: Used for heart conditions, asthma, epilepsy, and other serious health issues (use cautiously).',
    'Parijata': 'Parijata: Has anti-inflammatory and antipyretic properties; used for pain relief, fever, and skin ailments.',
    'Peepal': 'Peepal: Helps with skin conditions, strengthens blood capillaries, and speeds up wound healing.',
    'Pomegranate': 'Pomegranate: Rich in antioxidants, boosts immunity, prevents cancer, and protects memory.',
    'Rasna': 'Rasna: Reduces bone and joint pain, helps in respiratory conditions, and aids in wound healing.',
    'Rose_apple': 'Rose apple: Improves brain health, treats asthma, epilepsy, and joint inflammation.',
    'Roxburgh_fig': 'Roxburgh fig: Used for wound healing, diarrhea, and dysentery.',
    'Sandalwood': 'Sandalwood: Treats common cold, cough, urinary tract infections, liver disease, and heart conditions.',
    'Tulsi': 'Tulsi: Used in traditional remedies for fever, skin problems, respiratory issues, and heart health.',
}


# Preprocessing function
def preprocess_for_inference(img_path):
    image = Image.open(img_path)
    image = ImageOps.fit(image, (150, 150), Image.Resampling.LANCZOS)
    image_array = np.asarray(image)
    normalized_image_array = (image_array.astype(np.float32) / 127.5) - 1  # Normalize to [-1, 1]
    return np.expand_dims(normalized_image_array, axis=0)  # Expand dimensions for batch


@csrf_exempt
def classify_herb(request):
    if request.method == 'POST':
        image = request.FILES.get('image')
        user_id = request.POST.get('user_id')

        if not image:
            return JsonResponse({'error': 'No image uploaded'}, status=400)
        
        temp_dir = tempfile.gettempdir()
        image_path = os.path.join(temp_dir, image.name)

        try:
            with open(image_path, 'wb+') as destination:
                for chunk in image.chunks():
                    destination.write(chunk)

            img_array = preprocess_for_inference(image_path)
            prediction = model.predict(img_array)
            pred_index = np.argmax(prediction)
            highest_prob = prediction[0][pred_index]

            if highest_prob < 0.85:
                return JsonResponse({
                    'error': 'The confidence level for the prediction is low. Please try again with a clearer image.'
                }, status=200)

            herb_name = class_names[pred_index]
            description = herb_descriptions.get(herb_name, "Description not found")

            result = {
                'herbName': herb_name,
                'medicinalProperties': description,
                'uses': f'Uses of {herb_name}'
            }

            if user_id:
                try:
                    user = User.objects.get(id=user_id)
                    HerbSearchHistory.objects.create(
                        user=user,
                        herb_name=herb_name,
                        medicinal_properties=description,
                        uses=result['uses']
                    )
                except User.DoesNotExist:
                    return JsonResponse({'error': 'User not found'}, status=404)

            HerbIdentification.objects.create(
                herb_name=herb_name,
                description=description
            )

            return JsonResponse(result)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request'}, status=400)

# Define the get_search_history view
@csrf_exempt
def get_search_history(request):
    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse({'error': 'User ID is required'}, status=400)

    try:
        # Filter the search history based on user_id
        history = HerbSearchHistory.objects.filter(user_id=user_id).order_by('-timestamp')
        
        # Format the history data for JSON response
        history_data = [
            {
                'herb_name': item.herb_name,
                'medicinal_properties': item.medicinal_properties,
                'uses': item.uses,
                'timestamp': item.timestamp.strftime("%Y-%m-%d %H:%M:%S")
            }
            for item in history
        ]
        return JsonResponse(history_data, safe=False)
    
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)