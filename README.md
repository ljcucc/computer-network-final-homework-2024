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
```

Usage:

```sh
# For a GIF
python v2m.py input.gif -o output.mjpg -w 320 -g 240

# For an MP4 video
python v2m.py input.mp4 -o output.mjpg -w 320 -g 240

# For an MOV video
python v2m.py input.mov -o output.mjpg -w 320 -g 240
```
