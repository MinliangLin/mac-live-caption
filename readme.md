# Install
First, install blackhole-2ch, which is necessary for capturing sound from other application.

You may follow the [official guide](https://github.com/ExistentialAudio/BlackHole#installation-instructions) or just use the below command.

```sh
brew install blackhole-2ch
```

Second, create a **multi-output device** in `Audio MIDI Setup`, which could be accessed through *Lauchpad* or by searching `midi` in *Spotlight* (`⌘+space`). This device should *use* both your favour speakers and Blackhole 2ch.

Please ensure that your favour spearkers are listed above Blackhole 2ch in the device list.

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

In the last command, the number **0** is the device ID of BlackHole, which may vary depending on the specific device. If you are unsure of the device ID, you can run `./stream` and check the first lines of the output.

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

| Model  | Disk   | Mem     | WER(%) |
|--------|--------|---------|--------|
| tiny   | 75 MB  | ~125 MB | 6      |
| base   | 142 MB | ~210 MB | 4.9    |
| small  | 466 MB | ~600 MB | 4      |
| medium | 1.5 GB | ~1.7 GB | 4.1    |
| large  | 2.9 GB | ~3.3 GB | 4      |

# Usage
If you want to use live caption for an application such as *Zoom*, you will need to select the **multi-output device** as the speaker for that application.
