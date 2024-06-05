# computer-network-final-homework-2024

## Repository Structure

- `/vanilla` - First python implemetation on course
- `/cmd` - Some command line tools
- `/server` - golang implementation
- `/app` - client flutter app implementation

## Setup

for python scripts (including command-line tools):

1. Setup python3
2. Install [pipenv](https://pipenv.pypa.io/en/latest/)
3. Install packages: `pipenv install`

## Command line tools

### `cmd/v2m.py` video or gif to mjpeg convertor

```
usage: v2m.py [-h] [-o OUTPUT] [-w WIDTH] [-g HEIGHT] [-fps TARGET_FPS] input_file

Create an MJPEG file from a video or GIF

positional arguments:
  input_file            Path to the input video or GIF file

options:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        Output MJPEG file name
  -w WIDTH, --width WIDTH
                        Resize width for frames (default: 200)
  -g HEIGHT, --height HEIGHT
                        Resize height for frames (default: 150)
  -fps TARGET_FPS, --target_fps TARGET_FPS
                        Target frames per second (optional, for frame dropping)
```

Usage:

```sh
# For a GIF
python v2m.py input.gif -o output.mjpg -w 320 -g 240 -fps 10

# For an MP4 video
python v2m.py input.mp4 -o output.mjpg -w 320 -g 240 -fps 10

# For an MOV video
python v2m.py input.mov -o output.mjpg -w 320 -g 240 -fps 10
```
