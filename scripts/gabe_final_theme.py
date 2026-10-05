"""Synthesizes Assets/Sound/GabeFinalTheme.wav: the music for Gabe's last
stage, an original chiptune boss theme in the style of a Eurobeat racing
track, pushed hard: fast, in harmonic minor so it leans on a tense major
chord, with an overdriven octave bass, syncopated brass-like power stabs,
sixteenth hats, crashes and tom fills, and a gritty lead whose tone sweeps
like a saw, doubled an octave up in the chorus, with sixteenth-note runs.

    python scripts/gabe_final_theme.py

Only the standard library is used. The song is an intro, then a verse,
pre-chorus and chorus. It prints the sample the loop should start from (the
end of the intro), which goes in the .wav's import settings as
edit/loop_begin, with edit/loop_mode=2, so the intro only plays once."""
import array
import math
import os
import random
import wave

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'Assets', 'Sound', 'GabeFinalTheme.wav')

RATE = 32000
BPM = 168
BEAT = 60 / BPM
BAR = BEAT * 4
EIGHTH = BEAT / 2
SIXTEENTH = BEAT / 4
# How loud the finished track is, to match the other music (RMS, dBFS).
TARGET_RMS_DB = -10.0

NOTES = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}
CHORDS = {
    'Em': ['E', 'G', 'B'], 'C': ['C', 'E', 'G'], 'D': ['D', 'F#', 'A'],
    'Am': ['A', 'C', 'E'], 'B': ['B', 'D#', 'F#'],
}

# The song: (name, chords one per bar, melody one string per bar of eight
# eighth notes). '-' holds the note before, '.' is a rest, and two notes
# joined with ':' share an eighth as two sixteenths.
INTRO = ('intro', ['Em', 'Em', 'C', 'B'], None)
VERSE = ('verse', ['Em', 'D', 'C', 'B', 'Em', 'D', 'C', 'B'], [
    'E4 E4 G4 E4 B4 E4 A4 G4', 'F#4 F#4 A4 F#4 D5 F#4 A4 F#4', 'G4 G4 C5 G4 E5 G4 C5 G4', 'F#4 F#4 B4 F#4 D#5 - F#5 -',
    'E4 E4 G4 E4 B4 E4 A4 G4', 'F#4 F#4 A4 F#4 D5 F#4 A4 F#4', 'G4 G4 C5 G4 E5 G4 C5 G4', 'D#5 - F#5 - B5 - - -',
])
PRE = ('pre', ['C', 'D', 'B', 'B', 'C', 'D', 'B', 'B'], [
    'E5 - - - G5 - E5 -', 'F#5 - - - A5 - F#5 -', 'D#5 - F#5 - B5 - A5 -', 'F#5 - - - D#5 - - -',
    'E5 - - - G5 - E5 -', 'F#5 - - - A5 - F#5 -', 'D#5 - F#5 - B5 - A5 -', 'B4:C5 D#5:E5 F#5:G5 A5:B5 C6:D#6 B5 - .',
])
CHORUS = ('chorus', ['Em', 'C', 'Am', 'B', 'Em', 'C', 'Am', 'B', 'Em', 'C', 'Am', 'B', 'Em', 'C', 'B', 'Em'], [
    'E5 - B4 E5 G5 - F#5:G5 A5:B5', 'C6 - B5 - G5 - E5 -', 'A5 - C6 - B5 A5 G5 F#5', 'D#5 - F#5 - B5 - A5:G5 F#5:D#5',
    'E5 - B4 E5 G5 - B5 -', 'E6 - D6 C6 B5 - G5 -', 'A5 C6 B5 A5 G5 - F#5 G5', 'F#5 - - - D#5:E5 F#5:G5 A5:B5 C6:D#6',
    'E5 - B4 E5 G5 - F#5:G5 A5:B5', 'C6 - B5 - G5 - E5 -', 'A5 - C6 - B5 A5 G5 F#5', 'D#5 - F#5 - B5 - A5:G5 F#5:D#5',
    'E5 - G5 - B5 - E6 -', 'E6 - D6 C6 B5 - G5 -', 'F#5 - A5 - D#6 - B5 -', 'E6 - - - - - . .',
])
SONG = [INTRO, VERSE, PRE, CHORUS]


def frequency(note):
    name, octave = note[:-1], int(note[-1])
    return 440.0 * 2 ** ((NOTES[name] + 12 * (octave + 1) - 69) / 12)


def chord_note(name, octave):
    return frequency(name + str(octave))


class Mix:
    def __init__(self, seconds):
        self.length = int(seconds * RATE) + RATE
        self.left = array.array('f', bytes(4 * self.length))

    def pulse(self, start, duration, freq, volume, duty=0.5, decay=None, sustain=1.0,
              release=0.03, vibrato=0.0, sweep=0.0, buffer=None):
        """A square wave of the given [duty], fading by [decay] seconds down
        to [sustain], with a [release] tail, an optional vibrato, and with
        [sweep] its duty swinging back and forth so it buzzes like a saw."""
        out = buffer if buffer is not None else self.left
        first = int(start * RATE)
        held = int(duration * RATE)
        tail = int(release * RATE)
        step = freq / RATE
        phase = 0.0
        for i in range(min(held + tail, self.length - first)):
            t = i / RATE
            env = min(1.0, t / 0.002)
            if decay:
                env *= sustain + (1.0 - sustain) * math.exp(-t / decay)
            if i >= held:
                env *= 1.0 - (i - held) / max(tail, 1)
            wobble = 1.0 + vibrato * math.sin(2 * math.pi * 6.0 * t) if vibrato and t > 0.1 else 1.0
            phase += step * wobble
            width = duty + sweep * math.sin(2 * math.pi * 3.0 * t) if sweep else duty
            out[first + i] += (volume if phase % 1.0 < width else -volume) * env

    def kick(self, start, volume=1.0):
        first = int(start * RATE)
        phase = 0.0
        for i in range(int(0.28 * RATE)):
            t = i / RATE
            phase += (48 + 180 * math.exp(-t / 0.025)) / RATE
            body = math.sin(2 * math.pi * phase) * math.exp(-t / 0.18)
            click = random.uniform(-1, 1) * math.exp(-t / 0.004) * 0.6
            self.left[first + i] += math.tanh((body + click) * 1.8) * volume

    def tom(self, start, pitch, volume=0.6):
        first = int(start * RATE)
        phase = 0.0
        for i in range(int(0.2 * RATE)):
            t = i / RATE
            phase += pitch * (1 + 0.6 * math.exp(-t / 0.03)) / RATE
            self.left[first + i] += math.sin(2 * math.pi * phase) * volume * math.exp(-t / 0.12)

    def noise(self, start, duration, volume, decay, tone=0.0, bright=True, swell=False):
        """Stepped noise like a chip's noise channel: bright for hats and
        crashes, with an optional [tone] in it for a snare, or swelling up
        instead of dying away for a riser."""
        first = int(start * RATE)
        previous = 0.0
        value = 0.0
        for i in range(min(int(duration * RATE), self.length - first)):
            t = i / RATE
            if i % 2 == 0:
                value = random.uniform(-1.0, 1.0)
            sample = value - previous if bright else value
            previous = value
            env = (t / duration) ** 2 if swell else math.exp(-t / decay)
            if tone:
                sample = sample * 0.8 + math.sin(2 * math.pi * tone * t) * 0.5 * math.exp(-t / 0.04)
            self.left[first + i] += sample * volume * env

    def stab(self, start, chord, volume=0.07):
        """A brass-like power chord: root, fifth and octave, each doubled
        slightly out of tune, hitting hard and dying fast."""
        names = CHORDS[chord]
        for freq in (chord_note(names[0], 3), chord_note(names[2], 3), chord_note(names[0], 4),
                     chord_note(names[1], 4)):
            for detune in (0.996, 1.004):
                self.pulse(start, EIGHTH * 0.7, freq * detune, volume, duty=0.3, decay=0.1, sustain=0.3,
                           release=0.04)


def melody_notes(bars):
    """(start in sixteenths, length in sixteenths, note) for each note of [bars]."""
    notes = []
    for bar, line in enumerate(bars):
        for slot, token in enumerate(line.split()):
            at = bar * 16 + slot * 2
            if token == '-':
                if notes:
                    start, length, note = notes[-1]
                    notes[-1] = (start, length + 2, note)
            elif token == '.':
                notes.append((at, 2, None))
            else:
                for half, note in enumerate(token.split(':')):
                    notes.append((at + half, 1 if ':' in token else 2, note))
    return [n for n in notes if n[2]]


def main():
    random.seed(7)
    bars = sum(len(chords) for _, chords, _ in SONG)
    mix = Mix(bars * BAR)
    lead = array.array('f', bytes(4 * mix.length))
    bass = array.array('f', bytes(4 * mix.length))
    t = 0.0
    loop_begin = 0
    for name, chords, melody in SONG:
        if name == 'verse':
            loop_begin = int(t * RATE)
        section_start = t
        for bar, chord in enumerate(chords):
            at = section_start + bar * BAR
            root = CHORDS[chord][0]
            last_bar = bar == len(chords) - 1
            if name == 'intro' and bar < 2:
                # Big hits with space between them, then the band kicks in.
                for hit in (0, 3, 6):
                    mix.stab(at + hit * EIGHTH, chord, 0.1)
                    mix.kick(at + hit * EIGHTH)
                mix.noise(at, 1.2, 0.4, 0.4)
                continue
            # Drums: kick on every beat, snare on two and four, sixteenth hats
            # with open ones on the offbeats, crashes every four bars.
            for beat in range(4):
                mix.kick(at + beat * BEAT)
                if beat in (1, 3):
                    mix.noise(at + beat * BEAT, 0.22, 0.55, 0.08, tone=200)
                for step in range(4):
                    open_hat = step == 2
                    mix.noise(at + beat * BEAT + step * SIXTEENTH, 0.12, 0.17 if open_hat else 0.07,
                              0.05 if open_hat else 0.015)
            if bar % 4 == 0 and name in ('chorus', 'pre'):
                mix.noise(at, 1.6, 0.4, 0.5)
            if last_bar and name in ('verse', 'pre', 'intro'):
                # A fill into the next section: toms, or a snare roll.
                for step in range(8):
                    when = at + 2 * BEAT + step * SIXTEENTH
                    if name == 'verse':
                        mix.tom(when, 220 - step * 18)
                    else:
                        mix.noise(when, 0.1, 0.3 + step * 0.04, 0.05, tone=210)
            # The octave bass on every eighth, gritty.
            for step in range(8):
                octave = 2 if step % 2 == 0 else 3
                for detune, duty in ((0.997, 0.25), (1.003, 0.5)):
                    mix.pulse(at + step * EIGHTH, EIGHTH * 0.85, chord_note(root, octave) * detune, 0.2,
                              duty=duty, decay=0.12, sustain=0.5, buffer=bass)
            # Syncopated power stabs, 3-3-2.
            for hit in (0, 3, 6):
                mix.stab(at + hit * EIGHTH, chord)
            # Sixteenth arpeggios racing over the chorus.
            if name == 'chorus':
                tones = [chord_note(n, 5) for n in CHORDS[chord]] + [chord_note(root, 6)]
                for step in range(16):
                    mix.pulse(at + step * SIXTEENTH, SIXTEENTH * 0.9, tones[step % 4], 0.08,
                              duty=0.125, decay=0.05, sustain=0.2)
        if name in ('pre', 'intro'):
            # A riser over the last two bars.
            mix.noise(section_start + (len(chords) - 2) * BAR, 2 * BAR, 0.35, 0, swell=True)
        if melody:
            big = name == 'chorus'
            for start, length, note in melody_notes(melody):
                when = section_start + start * SIXTEENTH
                freq = frequency(note)
                mix.pulse(when, length * SIXTEENTH * 0.92, freq, 0.25, duty=0.35, release=0.04,
                          vibrato=0.008 if length > 2 else 0.0, sweep=0.12, buffer=lead)
                if big:
                    mix.pulse(when, length * SIXTEENTH * 0.92, freq * 2 * 1.004, 0.12, duty=0.25,
                              release=0.04, vibrato=0.008 if length > 2 else 0.0, sweep=0.1, buffer=lead)
        t += len(chords) * BAR
    # Drive the bass and the lead hard, and give the lead a dotted-eighth echo.
    delay = int(EIGHTH * 1.5 * RATE)
    for i in range(mix.length):
        echo = lead[i - delay] * 0.28 if i >= delay else 0.0
        mix.left[i] += math.tanh(bass[i] * 2.5) * 0.3 + math.tanh((lead[i] + echo) * 2.2) * 0.32

    # Level it to match the other music, saturating the peaks so it hits hard.
    length = int(t * RATE)
    samples = mix.left[:length]
    rms = math.sqrt(sum(s * s for s in samples) / length)
    gain = 10 ** (TARGET_RMS_DB / 20) / rms
    shaped = [math.tanh(s * gain * 1.6) / 1.6 for s in samples]
    rms = math.sqrt(sum(s * s for s in shaped) / length)
    gain = 10 ** (TARGET_RMS_DB / 20) / rms
    peak = max(abs(s) for s in shaped) * gain
    if peak > 0.99:
        gain *= 0.99 / peak
    data = array.array('h', (int(max(-1.0, min(1.0, s * gain)) * 32767) for s in shaped))
    with wave.open(OUT, 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(data.tobytes())
    final_rms = math.sqrt(sum((s * gain) ** 2 for s in shaped) / length)
    print(f'Wrote {OUT}: {t:.1f}s, RMS {20 * math.log10(final_rms):.1f} dB. Loop from sample {loop_begin}.')


if __name__ == '__main__':
    main()
