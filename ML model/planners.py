import google.generativeai as genai
import time
import random

# Set up Gemini API
genai.configure(api_key="enter_your_gemini_api_key_here")

def get_gemini_response(prompt, model_name='models/gemini-pro'):
    try:
        model = genai.GenerativeModel(model_name)
        for attempt in range(3):
            try:
                response = model.generate_content(prompt)
                return response.text if response else "No response from AI."
            except Exception as e:
                print(f"Attempt {attempt + 1} failed: {e}")
                if attempt < 2:
                    wait_time = (2 ** attempt) + random.random()
                    print(f"Waiting {wait_time:.2f} seconds before retrying...")
                    time.sleep(wait_time)
                else:
                    print("Max retries exceeded.")
                    return "Error generating response after multiple retries."
    except Exception as e:
        print(f"Error in get_gemini_response: {e}")
        return "Error generating response."

def get_workout_plan(weight, height, sport, injury=None):
    prompt = (
        f"Generate a 7-day advanced workout plan for a professional {sport} athlete with weight {weight} kg and height {height} cm."
        f" The plan should be specifically designed to enhance performance at the highest level in {sport}, focusing on sport-specific strength, power, speed, agility, and endurance."
    )
    if injury:
        prompt += f" Adjust for injury in {injury} by modifying exercises to prevent further strain and promote rapid recovery, while maintaining overall fitness."
    workout_plan = get_gemini_response(prompt)
    return workout_plan

def get_diet_plan(weight, height, sport, goal="performance optimization", dietary_preference="unspecified"):
    prompt = (
        f"Generate a 7-day advanced diet plan for a professional {sport} athlete with weight {weight} kg and height {height} cm, aiming for {goal}."
        f" The diet should be carefully tailored to support peak performance in {sport}, providing optimal fuel for training and competition, and promoting rapid recovery."
        f" Dietary preferences are {dietary_preference}." #Unspecified means the AI can ask for specification.
    )
    diet_plan = get_gemini_response(prompt)
    return diet_plan

def get_rest_recommendation(weight, height, sport, injury=None):
    prompt = (f"Provide an advanced rest and recovery plan for a professional {sport} athlete with weight {weight} kg and height {height} cm."
              " Include optimal sleep duration, active recovery techniques tailored for {sport}, and advanced stress management strategies to minimize burnout and maximize performance.")
    if injury:
        prompt += f" The athlete has an injury in the {injury}. Suggest advanced methods to aid faster recovery, considering the specific demands of {sport}."
    return get_gemini_response(prompt)

def adjust_plan_based_on_feedback(feedback, previous_workout, previous_diet, sport):
    prompt = (f"Based on the following feedback: '{feedback}', adjust the previous advanced workout and diet plans for a professional {sport} athlete."
              f" Previous workout: {previous_workout}. Previous diet: {previous_diet}."
              " Suggest specific and detailed modifications for better performance in their sport, considering their individual needs and the demands of professional competition.")
    return get_gemini_response(prompt)

# Example Usage
weight = float(input("Enter your weight (kg): "))
height = float(input("Enter your height (cm): "))
sport = input("Enter your professional sport: ").strip().lower()  # Targeted prompt
injury = input("Enter any injury location (or 'none' if no injury): ").strip().lower()
goal = input("Enter your primary fitness goal (performance optimization, injury recovery, etc.): ").strip().lower()  #More professional goal
dietary_preference = input("Enter your dietary preference (vegetarian, non-vegetarian, vegan, etc.): ").strip().lower() #AI now considers any value.

if injury == "none":
    injury = None

workout_plan = get_workout_plan(weight, height, sport, injury)
diet_plan = get_diet_plan(weight, height, sport, goal, dietary_preference)
rest_plan = get_rest_recommendation(weight, height, sport, injury)

print("\nGenerated Workout Plan:")
print(workout_plan)

print("\nGenerated Diet Plan:")
print(diet_plan)

print("\nGenerated Rest and Recovery Plan:")
print(rest_plan)

# Taking user feedback for AI-based adjustments
feedback = input("\nEnter your feedback after following the plan: ")
adjusted_plan = adjust_plan_based_on_feedback(feedback, workout_plan, diet_plan, sport)
print("\nUpdated Plan Based on Feedback:")
print(adjusted_plan)