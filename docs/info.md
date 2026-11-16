## How it works

A phase accumulator adds a UART-set step to a 16 bit phase every sample, and a sine table or the phase bits give the wave. A fixed point multiplier sets the amplitude, and the result drives PWM and sigma delta outputs. In text mode, seven square waves at 8 to 14 times the base frequency are made from the same phase: the top bit of k times the phase, mod 256, is a square wave at k times the base frequency. A column ROM switches the tones on and off every 80 ms so that a spectrogram of the output shows a 5x7 pixel message scrolling past. Rows start at 8 times the base frequency so that the lowest odd harmonic (24 times) lands above the text.

## How to test

Hold ui[7] high (UART idle). Pick a wave with ui[1:0] and listen to uio[0] through an RC low pass filter (1 kOhm, 15 nF) into an amplified speaker. Set ui[2] high and point a phone spectrogram app, set to about 0 to 10 kHz, at the speaker: UNICHIP scrolls across between 4 and 7 kHz. Optionally send the two bytes 0x00 and a step value at 115200 baud to change the frequency, which moves the text up or down.

## External hardware

RC low pass filter and amplified speaker on uio[0], a phone or laptop with a spectrogram app. Optional: USB serial adapter on ui[7], VGA monitor (TinyVGA PMOD).
