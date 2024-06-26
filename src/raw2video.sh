#!/usr/bin/env bash

# raw2video Copyright (C) 2024 kernaltrap8
# This program comes with ABSOLUTELY NO WARRANTY
# This is free software, and you are welcome to redistribute it
# under certain conditions

VERSION="1.2a"

# Argument checking

if [ "$1" == "-v" ] || [ "$1" == "--version" ]; then
	echo "raw2video v$VERSION"
	exit 0
fi

if [ "$#" -eq 0 ]; then
  echo -e "No arguments supplied.\nPlease supply the input and output name."
  exit 1
fi

if [ "$#" -ne 3 ]; then
  echo -e "Incorrect number of arguments.\nUsage: $0 <raw_input> <audio_output> <final_output>"
  exit 1
fi

# Variable setup

RAW_INPUT="$1"
AUDIO_OUTPUT="$2"
FINAL_OUTPUT="$3"
UPSCALED="_upscaled_$FINAL_OUTPUT.mp4"
PREFIX="\033[37m[\033[0m\033[35m * \033[0m\033[37m]\033[0m"

# If input doesnt end in .flac or .mp4, append it to the FFMpeg input

if [[ $AUDIO_OUTPUT != *.flac ]]; then
	AUDIO_OUTPUT="$2.flac"
fi

if [[ $FINAL_OUTPUT != *.mp4  ]]; then
	FINAL_OUTPUT="$3.mp4"
fi

# Check the size of the input, 1MB or higher is best for better results

if [ $(du -b $RAW_INPUT | cut -f1) -lt 1000000  ]; then
	echo -e "Input file is too small."
	exit 1
fi

if [ -e "$AUDIO_OUTPUT" ] && [ -e "$FINAL_OUTPUT" ]; then
	rm "$AUDIO_OUTPUT" "$FINAL_OUTPUT"
fi

# Convert the file to video and audio
echo -e "$PREFIX Starting raw2video at" $(date '+%I:%M:%S %p')
echo -e "$PREFIX Creating audio stream..."
ffmpeg -v quiet -stats -f u8 -ar 44100 -i "$RAW_INPUT" -c:a flac "$AUDIO_OUTPUT"
#echo -e "$PREFIX Done."
echo -e "$PREFIX Creating video stream and including audio..."
ffmpeg -v quiet -stats -f rawvideo -pix_fmt rgb24 -s 32x32 -i "$RAW_INPUT" -i "$AUDIO_OUTPUT" -c:v libx264 -c:a aac -b:a 192k "$FINAL_OUTPUT"
#echo -e "$PREFIX Done."
echo -e "$PREFIX Upscaling to 640x480..."
ffmpeg -v quiet -stats -i "$FINAL_OUTPUT" -s 640x480 "$UPSCALED"
#echo -e "$PREFIX Done."
echo -e "$PREFIX Removing old files..."
rm -vf "$AUDIO_OUTPUT" "$FINAL_OUTPUT" >/dev/null 2>&1
mv "$UPSCALED" "$FINAL_OUTPUT" >/dev/null 2>&1
echo -e "$PREFIX Done."
echo -e "$PREFIX Finished at" $(date '+%I:%M:%S %p')
