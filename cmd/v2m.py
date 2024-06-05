import argparse
import traceback
from PIL import Image
import io
import cv2

class VideoStream:
    def __init__(self, filename):
        self.filename = filename
        self.format = filename.split('.')[-1].lower()  # Get file extension
        try:
            if self.format == 'gif':
                self.frames = gif_to_jpeg_bytearrays(filename)
            elif self.format in ('mp4', 'mov'):
                self.frames = video_to_jpeg_bytearrays(filename)
            else:
                raise ValueError("Unsupported file format")
        except Exception as e:
            print(e)
            raise IOError
        self.frameNum = 0

    def nextFrame(self):
        """Get next frame."""
        if self.frameNum >= len(self.frames):
            return self.frames[-1]
        data = self.frames[self.frameNum]
        self.frameNum += 1
        print(f"{self.frameNum}/{len(self.frames)}")
        return data

    def frameNbr(self):
        """Get frame number."""
        return self.frameNum

def gif_to_jpeg_bytearrays(gif_path, resize_width=200, resize_height=150):
    """
    Extracts frames from a GIF, resizes them, and stores as JPEG bytearrays.
    """
    frame_bytearrays = []
    img = Image.open(gif_path)
    print(f"found: {img.n_frames}")

    try:
        for i in range(img.n_frames):
            img.seek(i)
            frame = img.convert('RGB')
            frame = frame.resize((resize_width, resize_height))
            jpeg_buffer = io.BytesIO()
            frame.save(jpeg_buffer, format="JPEG")
            frame_bytearrays.append(jpeg_buffer.getvalue())
    except Exception as e:
        print(e)
        print(traceback.format_exc())
    return frame_bytearrays

def video_to_jpeg_bytearrays(video_path, resize_width=200, resize_height=150):
    """
    Extracts frames from a video, resizes them, and stores as JPEG bytearrays.
    """
    frame_bytearrays = []
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        raise IOError("Error opening video file")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Resize the frame
        frame = cv2.resize(frame, (resize_width, resize_height))

        # Convert to JPEG
        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytearrays.append(buffer.tobytes())

    cap.release()
    return frame_bytearrays

def main():
    parser = argparse.ArgumentParser(description='Create an MJPEG file from a video or GIF')
    parser.add_argument('input_file', help='Path to the input video or GIF file')
    parser.add_argument('-o', '--output', default='output.mjpg', help='Output MJPEG file name')
    parser.add_argument('-w', '--width', type=int, default=200, help='Resize width for frames (default: 200)')
    parser.add_argument('-g', '--height', type=int, default=150, help='Resize height for frames (default: 150)')
    args = parser.parse_args()

    try:
        stream = VideoStream(args.input_file)
        with open(args.output, 'wb') as outfile:
            while True:
                frame = stream.nextFrame()
                if frame:
                    outfile.write(frame)
                else:
                    break
    except Exception as e:
        print(f"Error: {e}")
        print(traceback.format_exc())

if __name__ == "__main__":
    main()
