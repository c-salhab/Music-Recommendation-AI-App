from flask import Flask, request, jsonify
from smolagents import CodeAgent, DuckDuckGoSearchTool, InferenceClientModel

app = Flask(__name__)


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
    "Search online if needed. Return each song as a string in the format 'Artist - Title'."
    )

    # print(mood)
    print(genres)

    try:
        response = agent.run(prompt)

        print("MODEL RAW RESPONSE:\n", response)
        
        if isinstance(response, list):
            playlist = response
        
        elif isinstance(response, str):
            playlist = [line.strip() for line in response.strip().split("\n") if " - " in line]
        else:
            playlist = []

        new_playlist = jsonify({"playlist": playlist})

        print("JSONIFY :\n", new_playlist)
        
        return new_playlist
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/generate_by_artist", methods=["POST"])
def generate_by_artist():
    data = request.get_json()
    artist = data.get("artist")

    if not artist:
        return jsonify({"error": "Missing artist field"}), 400

    prompt = (
        f"Generate a list of 5 songs of the artist '{artist}'.\n"
        "Return each song as a string in the format 'Artist - Title'."
    )

    try:
        response = agent.run(prompt)

        print("MODEL RAW RESPONSE:\n", response)

        if isinstance(response, list):
            playlist = response
        elif isinstance(response, str):
            playlist = [line.strip() for line in response.strip().split("\n") if " - " in line]
        else:
            playlist = []

        return jsonify({"playlist": playlist})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/generate_mood_artist", methods=["POST"])
def generate_mood_artist():
    data = request.get_json()
    artist = data.get("artist")
    mood = data.get("mood")
    genres = data.get("genres")

    if not artist or not mood or not genres:
        return jsonify({"error": "Missing artist, mood or genres"}), 400

    prompt = (
        f"Create a playlist of 5 songs from the artist '{artist}' "
        f"that matches this mood: '{mood}' and these genres: '{genres}'.\n"
        "Return each song in the format: 'Artist - Title'.\n"
    )

    try:
        response = agent.run(prompt)

        print("MODEL RAW RESPONSE:\n", response)

        if isinstance(response, list):
            playlist = response
        elif isinstance(response, str):
            playlist = [line.strip() for line in response.strip().split("\n") if " - " in line]
        else:
            playlist = []

        return jsonify({"playlist": playlist})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
