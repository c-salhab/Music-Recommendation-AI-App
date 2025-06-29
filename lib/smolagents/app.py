from flask import Flask, request, jsonify
from smolagents import CodeAgent, DuckDuckGoSearchTool, InferenceClientModel

app = Flask(__name__)

# Crée l'agent avec modèle + outil de recherche web
agent = CodeAgent(
    tools=[DuckDuckGoSearchTool()],
    model=InferenceClientModel(model_id="Qwen/Qwen2.5-Coder-32B-Instruct")
)

@app.route("/generate", methods=["POST"])
def generate():
    data = request.get_json()
    mood = data.get("mood")
    genres = data.get("genres")

    prompt = (
    f"Generate a list of 5 songs for a user based on:\n"
    f"- Mood: {mood}\n"
    f"- Genres: {genres}\n"
    "- Prefer songs released between 2000 and 2025.\n"
    "Search online if needed. Return each song as a string in the format 'Artist - Title'."
    )

    # print(mood)
    # print(genres)

    try:
        response = agent.run(prompt)
        # S'assurer que la réponse est une liste de lignes
        if isinstance(response, str):
            playlist = [line.strip() for line in response.strip().split("\n") if " - " in line]
            print(playlist)
        else:
            playlist = []

        return jsonify({"playlist": playlist})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)

