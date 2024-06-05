import argparse
import traceback
from PIL import Image
import io
import cv2
import time
import struct  # For packing frame length


class VideoStream:
    def __init__(self, filename, target_fps=None, width=None, height=None):
        self.filename = filename
        self.target_fps = target_fps or 10
        self.format = filename.split('.')[-1].lower()  # Get file extension
        self.width = width or 200
        self.height = height or 150

        try:
            if self.format == 'gif':
                self.frames = gif_to_jpeg_bytearrays(filename, resize_width=self.width, resize_height=self.height)
            elif self.format in ('mp4', 'mov'):
                print(f"framerate config: {self.target_fps}")
                self.frames = video_to_jpeg_bytearrays(filename, target_fps=self.target_fps , resize_width=self.width, resize_height=self.height)
            else:
                raise ValueError("Unsupported file format")

            # # Adjust frame rate if target_fps is set
            # if target_fps is not None:
            #     self.frames = self._drop_frames(self.frames, target_fps)

        except Exception as e:
            print(e)
            raise IOError
        self.frameNum = 0

    def nextFrame(self):
        """Get next frame."""
        if self.frameNum >= len(self.frames):
            return None  # Return None to indicate end of frames
        data = self.frames[self.frameNum]
        self.frameNum += 1
        print(f"{self.frameNum}/{len(self.frames)}")
        return data

    def frameNbr(self):
        """Get frame number."""
        return self.frameNum

    # def _drop_frames(self, frames, target_fps):
    #     """Drops frames to achieve a target FPS."""
    #     original_fps = len(frames)  # Assuming 1 second of frames for simplicity
    #     keep_every_n_frames = int(original_fps / target_fps)
    #     return frames[::keep_every_n_frames]

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

def video_to_jpeg_bytearrays(video_path, resize_width=200, resize_height=150, target_fps=10):
    """
    Extracts frames from a video, resizes them, and stores as JPEG bytearrays.
    """
    frame_bytearrays = []
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)
    print(f"{fps} frames per second")

    if not cap.isOpened():
        raise IOError("Error opening video file")

    print(f"skip every {int(fps/target_fps)} frame for framerate settings")

    while True:
        ret, frame = None, None
        for i in range(max(1, int(fps/target_fps))):
            ret, frame = cap.read()

        if not ret:
            break

        # Resize the frame
        frame = cv2.resize(frame, (resize_width, resize_height))

        # Convert to JPEG
        img = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        im_pil = Image.fromarray(img)

        jpeg_buffer = io.BytesIO()
        im_pil.save(jpeg_buffer, format="JPEG")
        frame_bytearrays.append(jpeg_buffer.getvalue())


    cap.release()
    return frame_bytearrays

def main():
    parser = argparse.ArgumentParser(description='Create an MJPEG file from a video or GIF')
    parser.add_argument('input_file', help='Path to the input video or GIF file')
    parser.add_argument('-o', '--output', default='output.mjpg', help='Output MJPEG file name')
    parser.add_argument('-w', '--width', type=int, default=200, help='Resize width for frames (default: 200)')
    parser.add_argument('-g', '--height', type=int, default=150, help='Resize height for frames (default: 150)')
    parser.add_argument('-fps', '--target_fps', type=int, help='Target frames per second (optional, for frame dropping)')
    args = parser.parse_args()

    try:
        stream = VideoStream(args.input_file, target_fps=args.target_fps, width=args.width, height=args.height)
        with open(args.output, 'wb') as outfile:
            while True:
                frame = stream.nextFrame()
                if frame != None:
                    # Write frame length
                    frame_length = len(frame)
                    outfile.write(struct.pack('>L', frame_length))
                    outfile.write(frame)
                else:
                    break
    except Exception as e:
        print(f"Error: {e}")
        print(traceback.format_exc())

if __name__ == "__main__":
    main()
