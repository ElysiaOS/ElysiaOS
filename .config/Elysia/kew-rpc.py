from pypresence import Presence
import time
import subprocess
import os
from youtubesearchpython import VideosSearch

# Replace with your application's client ID
CLIENT_ID = '1297650919055298630'
RPC = Presence(CLIENT_ID)
RPC.connect()

def get_kew_metadata():
    try:
        metadata = subprocess.check_output(['playerctl', '-p', 'kew', 'metadata']).decode('utf-8').strip()
        data = {}
        for line in metadata.split('\n'):
            parts = line.split(maxsplit=2)
            if len(parts) == 3:
                key = parts[1].strip()
                value = parts[2].strip()
                if key.startswith('xesam:'):
                    key = key.replace('xesam:', '')
                elif key.startswith('mpris:'):
                    key = key.replace('mpris:', '')
                data[key] = value
        return data
    except subprocess.CalledProcessError:
        return None

def fetch_youtube_thumbnail(query):
    try:
        print(f"Searching for thumbnail with query: {query}")  # Log the query
        videos_search = VideosSearch(query, limit=3)
        result = videos_search.result()

        if result['result']:
            return result['result'][0]['thumbnails'][0]['url']
        else:
            print("No results found.")  # Log if no results were found
    except Exception as e:
        print(f"Error fetching YouTube thumbnail: {e}")
    
    return None

def get_song_position():
    try:
        position = subprocess.check_output(['playerctl', '-p', 'kew', 'position']).decode('utf-8').strip()
        return float(position)
    except subprocess.CalledProcessError:
        return None

def get_player_status():
    try:
        status = subprocess.check_output(['playerctl', '-p', 'kew', 'status']).decode('utf-8').strip()
        return status
    except subprocess.CalledProcessError:
        return None

def update_rich_presence():
    status = get_player_status()
    metadata = get_kew_metadata()

    if status == "Playing" and metadata:
        title = metadata.get('title', 'Unknown Title')
        artist = metadata.get('artist', 'Unknown Artist')
        query = f"{title} + {artist}"  # More specific query
        youtube_thumbnail_url = fetch_youtube_thumbnail(query)

        song_length_microseconds = int(metadata.get('length', 0))
        song_length_seconds = song_length_microseconds / 1_000_000
        current_position = get_song_position()

        if current_position and song_length_seconds:
            start_time = int(time.time() - current_position)
            end_time = int(start_time + song_length_seconds)
        else:
            start_time = None
            end_time = None

        RPC.update(
            state=f"Listening to {artist}",
            details=f"Playing {title}",
            large_image=youtube_thumbnail_url or 'kew_default',
            large_text="Kew Player",
            start=start_time,
            end=end_time,
            small_image="music",
            activity_type=2
        )

    elif status == "Paused":
        title = metadata.get('title', 'Unknown Title') if metadata else 'Unknown Title'
        artist = metadata.get('artist', 'Unknown Artist') if metadata else 'Unknown Artist'
        query = f"{title} {artist} official lyrics"
        youtube_thumbnail_url = fetch_youtube_thumbnail(query)

        RPC.update(
            state="Paused",
            details=f"{title} by {artist}",
            large_image=youtube_thumbnail_url or 'kew_default',
            large_text="Kew Player",
            start=None,
            end=None,
            small_image="music"
        )
        
    else:
        RPC.clear()

if __name__ == "__main__":
    while True:
        update_rich_presence()
        time.sleep(5)  # Update every 5 seconds