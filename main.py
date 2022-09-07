#!/usr/bin/env python3

import argparse
import queue
import sounddevice as sd
import vosk
import sys
import json
import threading
import tkinter as tk

class Window(object):
    def __init__(self):
        self.root = tk.Tk()
        self.root.geometry("400x200")
        self.root.config(bg='systemTransparent')
        self.text = tk.Label(self.root, font=['', 25], wraplength=400)
        self.text.grid()
        self.root.after(100, self.update)
    def update(self):
        self.text.config(text=recg.text)
        self.root.after(100, self.update)


class Recognizer(threading.Thread):
    def __init__(self, args):
        super().__init__()
        self.q = queue.Queue()
        self.args = args
        self.text = 'CC'
    def callback(self, indata, frames, time, status):
        """This is called (from a separate thread) for each audio block."""
        if status:
            print(status, file=sys.stderr)
        self.q.put(bytes(indata))
    def run(self):
        if self.args.samplerate is None:
            device_info = sd.query_devices(self.args.device, 'input')
            print(device_info)
            # soundfile expects an int, sounddevice provides a float:
            self.args.samplerate = int(device_info['default_samplerate'])

        model = vosk.Model(lang="en-us")
        # model = vosk.Model(model_name="vosk-model-en-us-0.22-lgraph")

        if self.args.filename:
            dump_fn = open(self.args.filename, "wb")
        else:
            dump_fn = None

        with sd.RawInputStream(samplerate=self.args.samplerate, blocksize = 8000, device=self.args.device, dtype='int16',
                                channels=1, callback=self.callback):
                rec = vosk.KaldiRecognizer(model, args.samplerate)
                while True:
                    data = self.q.get()
                    if rec.AcceptWaveform(data):
                        text = json.loads(rec.Result())['text']
                    else:
                        text = json.loads(rec.PartialResult())['partial']
                    if text != '':
                        self.text = text
                    if dump_fn is not None:
                        dump_fn.write(data)


if __name__ == "__main__":
    def int_or_str(text):
        """Helper function for argument parsing."""
        try:
            return int(text)
        except ValueError:
            return text

    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument(
        '-l', '--list-devices', action='store_true',
        help='show list of audio devices and exit')
    args, remaining = parser.parse_known_args()
    if args.list_devices:
        print(sd.query_devices())
        parser.exit(0)
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        parents=[parser])
    parser.add_argument(
        '-f', '--filename', type=str, metavar='FILENAME',
        help='audio file to store recording to')
    parser.add_argument(
        '-d', '--device', type=int_or_str, default='blackhole',
        help='input device (numeric ID or substring)')
    parser.add_argument(
        '-r', '--samplerate', type=int, help='sampling rate')
    args = parser.parse_args(remaining)
    recg = Recognizer(args)
    recg.start()
    win = Window()
    win.root.mainloop()