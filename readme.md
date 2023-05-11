# Install
First, install blackhole-2ch, which is necessary for capturing sound from other application.

You may follow the [official guide](https://github.com/ExistentialAudio/BlackHole#installation-instructions) or just use the below command.

```sh
brew install blackhole-2ch
```

Second, create a **multi-output device** in `Audio MIDI Setup`, which could be found from *Lauchpad* or search `midi` in *Spotlight* (`⌘+space`). The multi-output device should *use* both your favour speakers and Blackhole 2ch.

And your favour spearkers should be above Blackhole 2ch in the device list.

![](docs/launchpad.jpg)

![](docs/multi-output.jpg)

Third, set up [whisper.cpp]( https://github.com/ggerganov/whisper.cpp) by the below command.

```sh
git clone https://github.com/ggerganov/whisper.cpp ~/Desktop/whisper.cpp
cd whisper.cpp

bash models/download-ggml-model.sh base.en # download basic model
make stream

# start speech recogntion
./stream -c 0
```

**0** in the last command is the device number of BlackHole. It may vary in different device. If you are not sure about that, just run `./stream` and see the first lines in the output.

```
init: found 5 capture devices:
init:    - Capture device #0: 'BlackHole 2ch'
init:    - Capture device #1: 'External Microphone'
...
```

You may check other command options by

```
./stream -h
```

There are other model avaialable as well.

 Model  | Disk   | Mem     
--------|--------|---------
 tiny   | 75 MB  | ~125 MB 
 base   | 142 MB | ~210 MB 
 small  | 466 MB | ~600 MB 
 medium | 1.5 GB | ~1.7 GB 
 large  | 2.9 GB | ~3.3 GB 



# Usage
For the application you want a live caption, e.g. *Zoom*, select the **multi-output device** as its speaker.
