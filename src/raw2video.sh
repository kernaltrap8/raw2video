#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo -e "No arguments supplied.\nPlease supply the input and output name."
  exit 1
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo -e "Incorrect number of arguments.\nUsage: $0 <raw_input> <audio_output> <final_output>"
  exit 1
fi

RAW_INPUT="$1"
AUDIO_OUTPUT="$2"
FINAL_OUTPUT="$3"

if [[ $AUDIO_OUTPUT != *.flac ]]; then
	AUDIO_OUTPUT="$2.flac"
fi

if [[ $FINAL_OUTPUT != *.mp4  ]]; then
	FINAL_OUTPUT="$3.mp4"
fi

if [ $(du -b $RAW_INPUT | cut -f1) -lt 1000000  ]; then
	echo "Input file is too small."
	exit 1
fi

echo "Creating audio stream..."
sleep 1
ffmpeg -f u8 -ar 44100 -i "$RAW_INPUT" -c:a flac "$AUDIO_OUTPUT"
echo "Done."
sleep 1
echo "Creating video stream and including audio..."
sleep 1
ffmpeg -f rawvideo -pix_fmt rgb24 -s 1920x1080 -i "$RAW_INPUT" -i "$AUDIO_OUTPUT" -c:v libx264 -c:a aac -b:a 192k "$FINAL_OUTPUT"
echo "Done."
sleep 1
echo "Removing old files..."
sleep 1
rm -vf "$2.flac"
