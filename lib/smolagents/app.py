from flask import Flask, request, jsonify
from smolagents import CodeAgent, DuckDuckGoSearchTool, InferenceClientModel
import os
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from dotenv import load_dotenv

app = Flask(__name__)

load_dotenv()

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=os.getenv('SPOTIPY_CLIENT_ID'),
                                               client_secret=os.getenv('SPOTIPY_CLIENT_SECRET'),
                                               redirect_uri=os.getenv('SPOTIPY_REDIRECT_URI'),
                                               scope="playlist-modify-private"))

user = sp.current_user()
print(f"Authenticated as {user['display_name']}")

def search_tracks(track_names, artist_names=None):
    track_ids = []

    for i, track_name in enumerate(track_names):
        artist = artist_names[i] if artist_names and i < len(artist_names) else None

        query = f"track:{track_name}"
        if artist:
            query += f" artist:{artist}"

        print(f"\nSearching Spotify with query: '{query}'")

        result = sp.search(q=query, type="track", limit=1)
        tracks = result.get("tracks", {}).get("items", [])

        print(f"Raw Spotify Response for '{track_name}' / '{artist}':")
        for t in tracks:
            print(f"- Found: {t['name']} by {t['artists'][0]['name']} (ID: {t['id']})")

        if tracks:
            track_id = tracks[0]["id"]
            track_ids.append(track_id)
            print(f"Using track ID: {track_id}")
        else:
            print(f"Track not found for query: '{query}'")

    print(f"\nFinal track IDs collected: {track_ids}")
    return track_ids

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

@app.route('/create_playlist', methods=['POST'])
def create_playlist():
    data = request.get_json()
    artist_names = data.get('artists', [])
    track_names = data.get('tracks', [])
    playlist_name = data.get('playlist_name', 'My Playlist')
    user_id = sp.current_user()['id']
    track_ids = search_tracks(track_names, artist_names)
    playlist = sp.user_playlist_create(user=user_id, name=playlist_name, public=False)
    sp.playlist_add_items(playlist_id=playlist['id'], items=track_ids)
    return jsonify({'playlist_url': playlist['external_urls']['spotify']})

@app.route("/callback")
def callback():
    code = request.args.get('code')
    return f"Spotify auth code received: {code}"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
