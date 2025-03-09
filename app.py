from flask import Flask, request, jsonify
import os
import tempfile
from gemini_video_description import describe_video

app = Flask(__name__)

@app.route('/describe_video', methods=['POST'])
def describe_video_endpoint():
    if 'video' not in request.files:
        return jsonify({'error': 'No video file provided'}), 400
    video_file = request.files['video']
    if video_file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    # Save uploaded file to temporary location
    with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(video_file.filename)[1]) as tmp:
        video_file.save(tmp.name)
        tmp_path = tmp.name
    try:
        description = describe_video(tmp_path)
        return jsonify({'description': description})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        os.remove(tmp_path)

# ...existing code...
if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5020)
